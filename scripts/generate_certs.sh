#!/usr/bin/env bash
set -euo pipefail

OutputDir=""
FileName=""
Domains=""
Tool=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            [[ $# -ge 2 ]] || { echo "❌ Missing value for $1"; exit 1; }
            OutputDir="$2"
            shift 2
            ;;
        -n|--name)
            [[ $# -ge 2 ]] || { echo "❌ Missing value for $1"; exit 1; }
            FileName="$2"
            shift 2
            ;;
        -d|--domains)
            [[ $# -ge 2 ]] || { echo "❌ Missing value for $1"; exit 1; }
            Domains="$2"
            shift 2
            ;;
        -t|--tool)
            [[ $# -ge 2 ]] || { echo "❌ Missing value for $1"; exit 1; }
            Tool="$2"
            shift 2
            ;;
        -h|--help)
            cat <<'HELP'
Usage:
  ./generate_certs.sh [-o OUTPUT] [-n NAME] [-d "DOMAIN1 DOMAIN2"] [-t mkcert|openssl]

Examples:
  ./generate_certs.sh
  ./generate_certs.sh -t mkcert -d "example.test *.example.test"
  ./generate_certs.sh -t openssl -d "example.test *.example.test"
HELP
            exit 0
            ;;
        *)
            echo "❌ Unknown argument: $1"
            exit 1
            ;;
    esac
done

sanitize_filename() {
    printf '%s' "$1" | sed 's/\*/wildcard/g; s/[^a-zA-Z0-9._-]/_/g'
}

if [[ -z "$Tool" ]]; then
    echo -e "\n\033[36m--- 1. TOOL SELECTION ---\033[0m"
    echo "1) mkcert  [Recommended - local CA + system/browser trust]"
    echo "2) OpenSSL [Local CA + signed server certificate]"
    read -r -p "Choose an option (1 or 2) [Default: 1]: " choice
    Tool="openssl"
    [[ "$choice" != "2" ]] && Tool="mkcert"
fi

case "$Tool" in
    mkcert|openssl) ;;
    *)
        echo -e "\033[31m❌ Error: tool must be 'mkcert' or 'openssl'.\033[0m"
        exit 1
        ;;
esac

if [[ -z "$Domains" ]]; then
    echo -e "\n\033[36m--- 2. DOMAINS ---\033[0m"
    read -r -p "Enter domains separated by space or comma (e.g. *.test app.local): " Domains
    while [[ -z "$Domains" ]]; do
        read -r -p "Please enter at least one domain: " Domains
    done
fi

IFS=', ' read -r -a domainList <<< "$Domains"
# Remove accidental empty entries.
cleanedDomains=()
for d in "${domainList[@]}"; do
    [[ -n "$d" ]] && cleanedDomains+=("$d")
done

domainList=("${cleanedDomains[@]}")
((${#domainList[@]} > 0)) || { echo -e "\033[31m❌ No domains supplied.\033[0m"; exit 1; }

primaryDomain="${domainList[0]}"
defaultFileName="$(sanitize_filename "$primaryDomain")"
[[ -n "$defaultFileName" ]] || defaultFileName="cert"

if [[ -z "$OutputDir" ]]; then
    echo -e "\n\033[36m--- 3. OUTPUT DIRECTORY ---\033[0m"
    read -r -p "Enter output directory path [Default: .]: " inputDir
    OutputDir="${inputDir:-.}"
fi

if [[ -z "$FileName" ]]; then
    echo -e "\n\033[36m--- 4. FILE NAME ---\033[0m"
    read -r -p "Enter base filename [Default: $defaultFileName]: " inputName
    FileName="${inputName:-$defaultFileName}"
fi

FileName="$(sanitize_filename "$FileName")"
[[ -n "$FileName" ]] || FileName="cert"

mkdir -p "$OutputDir"
resolvedOutputDir="$(cd "$OutputDir" && pwd)"

keyPath="$resolvedOutputDir/$FileName.key"
crtPath="$resolvedOutputDir/$FileName.crt"
caKeyPath="$resolvedOutputDir/${FileName}-CA.key"
caCrtPath="$resolvedOutputDir/${FileName}-CA.crt"

if [[ "$Tool" == "mkcert" ]]; then
    # mkcert already manages a local CA. We only export a copy of its root
    # certificate so it can be imported manually into browsers/devices.
    if ! command -v mkcert >/dev/null 2>&1; then
        echo -e "\033[31m❌ Error: 'mkcert' is not installed or not found in PATH.\033[0m"
        exit 1
    fi
else
    if ! command -v openssl >/dev/null 2>&1; then
        echo -e "\033[31m❌ Error: 'openssl' is not installed or not found in PATH.\033[0m"
        exit 1
    fi
fi

echo -e "\n\033[36m--- CONFIGURATION SUMMARY ---\033[0m"
echo "Tool        : $Tool"
echo "Domains     : ${domainList[*]}"
echo "Destination : $resolvedOutputDir"
echo "Server key  : $keyPath"
echo "Server cert : $crtPath"
echo "CA cert     : $caCrtPath"
if [[ "$Tool" == "openssl" ]]; then
    echo "CA key      : $caKeyPath"
fi
echo -e "--------------------------------\n"

if [[ "$Tool" == "mkcert" ]]; then
    echo -e "\033[90mConfiguring local Certificate Authority (mkcert -install)...\033[0m"
    mkcert -install

    echo -e "\033[90mGenerating server certificate...\033[0m"
    mkcert \
        -key-file "$keyPath" \
        -cert-file "$crtPath" \
        "${domainList[@]}"

    caRootDir="$(mkcert -CAROOT)"
    caPemPath="$caRootDir/rootCA.pem"

    if [[ ! -f "$caPemPath" ]]; then
        echo -e "\033[31m❌ Error: mkcert CA certificate not found: $caPemPath\033[0m"
        exit 1
    fi

    cp "$caPemPath" "$caCrtPath"

    echo -e "\n\033[32m✅ mkcert certificates generated.\033[0m"
    echo "   mkcert CA directory : $caRootDir"
    echo "   Exported CA         : $caCrtPath"
else
    # OpenSSL mode creates a real local CA and a server certificate signed by it.
    # The CA is deliberately separate from the server certificate so the CA .crt
    # can be imported into a trust store without trusting the server key itself.
    sanEntries=()
    for d in "${domainList[@]}"; do
        sanEntries+=("DNS:$d")
    done
    sanString="$(IFS=,; echo "${sanEntries[*]}")"

    cat > "$resolvedOutputDir/${FileName}-server.cnf" <<EOF_CFG
[req]
distinguished_name = req_distinguished_name
req_extensions = req_ext
prompt = no

[req_distinguished_name]
CN = $primaryDomain
O = Dev Local
C = ES

[req_ext]
subjectAltName = $sanString

[v3_ca]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, keyCertSign, cRLSign

[v3_server]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints = critical, CA:false
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = $sanString
EOF_CFG

    openssl genrsa -out "$caKeyPath" 4096 >/dev/null 2>&1
    openssl req -x509 -new -sha256 -days 3650 \
        -key "$caKeyPath" \
        -out "$caCrtPath" \
        -subj "/CN=Dev Local CA/O=Dev Local/C=ES" \
        -extensions v3_ca \
        -config "$resolvedOutputDir/${FileName}-server.cnf" >/dev/null 2>&1

    openssl genrsa -out "$keyPath" 2048 >/dev/null 2>&1
    openssl req -new -sha256 \
        -key "$keyPath" \
        -out "$resolvedOutputDir/${FileName}.csr" \
        -config "$resolvedOutputDir/${FileName}-server.cnf" >/dev/null 2>&1

    openssl x509 -req -sha256 -days 825 \
        -in "$resolvedOutputDir/${FileName}.csr" \
        -CA "$caCrtPath" \
        -CAkey "$caKeyPath" \
        -CAcreateserial \
        -out "$crtPath" \
        -extensions v3_server \
        -extfile "$resolvedOutputDir/${FileName}-server.cnf" >/dev/null 2>&1

    rm -f \
        "$resolvedOutputDir/${FileName}.csr" \
        "$resolvedOutputDir/${FileName}-CA.srl" \
        "$resolvedOutputDir/${FileName}-server.cnf"

    # Try to install the CA into the local OS trust store when possible.
    if [[ "$EUID" -eq 0 ]]; then
        if command -v update-ca-certificates >/dev/null 2>&1 && [[ -d /usr/local/share/ca-certificates ]]; then
            cp "$caCrtPath" "/usr/local/share/ca-certificates/${FileName}-CA.crt"
            update-ca-certificates >/dev/null 2>&1 || true
            echo -e "\033[32m✅ CA installed into the Linux system trust store.\033[0m"
        elif command -v update-ca-trust >/dev/null 2>&1 && [[ -d /etc/pki/ca-trust/source/anchors ]]; then
            cp "$caCrtPath" "/etc/pki/ca-trust/source/anchors/${FileName}-CA.crt"
            update-ca-trust >/dev/null 2>&1 || true
            echo -e "\033[32m✅ CA installed into the Linux system trust store.\033[0m"
        fi
    fi

    chmod 600 "$caKeyPath" "$keyPath"
    echo -e "\n\033[32m✅ OpenSSL CA and server certificate generated.\033[0m"
fi

echo -e "\n\033[33m--- GENERATED FILES ---\033[0m"
echo " Private Key : $keyPath"
echo " Certificate : $crtPath"
echo " CA Root     : $caCrtPath"
if [[ "$Tool" == "openssl" ]]; then
    echo " CA Key      : $caKeyPath"
fi
echo -e "\033[32m Done!\033[0m\n"
