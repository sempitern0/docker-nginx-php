#!/bin/bash

OutputDir=""
FileName=""
Domains=""
Tool=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output) OutputDir="$2"; shift 2 ;;
        -n|--name) FileName="$2"; shift 2 ;;
        -d|--domains) Domains="$2"; shift 2 ;;
        -t|--tool) Tool="$2"; shift 2 ;;
        *) shift ;;
    esac
done

if [ "$EUID" -ne 0 ]; then
    echo -e "\033[33m⚠️  Note: Running as root (sudo) is recommended to install system-wide trust.\033[0m"
fi

if [ -z "$Tool" ]; then
    echo -e "\n\033[36m--- 1. TOOL SELECTION ---\033[0m"
    echo "1) mkcert  [Recommended - Clean local CA with instant system trust]"
    echo "2) OpenSSL [Traditional - Self-signed certificate with SAN]"
    read -p "Choose an option (1 or 2) [Default: 1]: " choice
    
    if [ "$choice" = "2" ]; then
        Tool="openssl"
    else
        Tool="mkcert"
    fi
fi

if [ -z "$Domains" ]; then
    echo -e "\n\033[36m--- 2. DOMAINS ---\033[0m"
    read -p "Enter domains separated by space or comma (e.g. *.test app.local): " Domains
    
    while [ -z "$Domains" ]; do
        read -p "Please enter at least one domain (e.g. *.test): " Domains
    done
fi

IFS=', ' read -r -a domainList <<< "$Domains"

defaultFileName=$(echo "${domainList[0]}" | sed 's/\*/wildcard/g' | sed 's/[^a-zA-Z0-9.-]/_/g')
if [ -z "$defaultFileName" ]; then
    defaultFileName="cert"
fi

if [ -z "$OutputDir" ]; then
    echo -e "\n\033[36m--- 3. OUTPUT DIRECTORY ---\033[0m"
    read -p "Enter output directory path [Default: . (current directory)]: " inputDir
    
    if [ -z "$inputDir" ]; then
        OutputDir="."
    else
        OutputDir="$inputDir"
    fi
fi

if [ -z "$FileName" ]; then
    echo -e "\n\033[36m--- 4. FILE NAME ---\033[0m"
    read -p "Enter base filename for .crt/.key files [Default: $defaultFileName]: " inputName
    
    if [ -z "$inputName" ]; then
        FileName="$defaultFileName"
    else
        FileName=$(echo "$inputName" | sed 's/\*/wildcard/g' | sed 's/[^a-zA-Z0-9.-]/_/g')
    fi
fi

mkdir -p "$OutputDir"
resolvedOutputDir=$(cd "$OutputDir" && pwd)
keyPath="$resolvedOutputDir/$FileName.key"
crtPath="$resolvedOutputDir/$FileName.crt"

echo -e "\n\033[36m--- CONFIGURATION SUMMARY ---\033[0m"
echo "Tool        : $Tool"
echo "Domains     : ${domainList[*]}"
echo "Destination : $resolvedOutputDir"
echo "Files       : $FileName.key / $FileName.crt"
echo -e "--------------------------------\n"

if [ "$Tool" = "mkcert" ]; then
    if ! command -v mkcert >/dev/null 2>&1; then
        echo -e "\033[31m❌ Error: 'mkcert' is not installed or not found in PATH.\033[0m"
        echo -e "\033[33m   Install it via your package manager (e.g., sudo apt install mkcert / brew install mkcert)\033[0m"
        exit 1
    fi

    echo -e "\033[90mConfiguring local Certificate Authority (mkcert -install)...\033[0m"
    mkcert -install

    mkcert -key-file "$keyPath" -cert-file "$crtPath" "${domainList[@]}"

    if [ $? -eq 0 ]; then
        echo -e "\n\033[32m✅ Certificates created and trusted by system using mkcert.\033[0m"
    else
        echo -e "\n\033[31m❌ Error executing mkcert.\033[0m"
        exit 1
    fi

else
    if ! command -v openssl >/dev/null 2>&1; then
        echo -e "\033[31m❌ Error: 'openssl' is not installed or not found in PATH.\033[0m"
        exit 1
    fi

    sanList=()
    for d in "${domainList[@]}"; do
        sanList+=("DNS:$d")
    done
    sanString=$(IFS=,; echo "${sanList[*]}")
    primaryCN="${domainList[0]}"

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$keyPath" \
        -out "$crtPath" \
        -subj "/CN=$primaryCN/O=Dev Local/C=ES" \
        -addext "subjectAltName=$sanString" 2>/dev/null

    if [ -f "$crtPath" ]; then
        echo -e "\033[32m✅ Certificate files generated with OpenSSL.\033[0m"

        echo -e "\n\033[36m--- INSTALLING INTO SYSTEM TRUST STORE ---\033[0m"
        if [ "$EUID" -eq 0 ]; then
            if [ -d "/usr/local/share/ca-certificates" ]; then
                cp "$crtPath" "/usr/local/share/ca-certificates/${FileName}.crt"
                update-ca-certificates >/dev/null 2>&1
                echo -e "\033[32m✅ Certificate added to system trust store (/usr/local/share/ca-certificates).\033[0m"
            elif [ -d "/etc/pki/ca-trust/source/anchors" ]; then
                cp "$crtPath" "/etc/pki/ca-trust/source/anchors/${FileName}.crt"
                update-ca-trust >/dev/null 2>&1
                echo -e "\033[32m✅ Certificate added to system trust store (/etc/pki/ca-trust/source/anchors).\033[0m"
            else
                echo -e "\033[33m⚠️ Could not auto-detect system trust store location.\033[0m"
            fi
        else
            echo -e "\033[33m⚠️ Skipped system trust installation: Administrator (root) privileges required.\033[0m"
        fi
    else
        echo -e "\033[31m❌ Error generating certificate with OpenSSL.\033[0m"
        exit 1
    fi
fi

echo -e "\n\033[33m--- GENERATED FILES ---\033[0m"
echo " Private Key : $keyPath"
echo " Certificate : $crtPath"
echo -e "\033[32m Done!\033[0m\n"