[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [string]$OutputDir,

    [Parameter(Mandatory=$false)]
    [string]$FileName,

    [Parameter(Mandatory=$false)]
    [string]$Domains,

    [Parameter(Mandatory=$false)]
    [ValidateSet("mkcert", "openssl")]
    [string]$Tool
)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  Note: Running as Administrator is recommended to install system-wide trust." -ForegroundColor Yellow
}

if ([string]::IsNullOrWhiteSpace($Tool)) {
    Write-Host "`n--- 1. TOOL SELECTION ---" -ForegroundColor Cyan
    Write-Host "1) mkcert  [Recommended - Clean local CA with instant system trust]"
    Write-Host "2) OpenSSL [Traditional - Self-signed certificate with SAN]"
    $choice = Read-Host "Choose an option (1 or 2) [Default: 1]"
    
    if ($choice -eq "2") {
        $Tool = "openssl"
    } else {
        $Tool = "mkcert"
    }
}

if ([string]::IsNullOrWhiteSpace($Domains)) {
    Write-Host "`n--- 2. DOMAINS ---" -ForegroundColor Cyan
    $Domains = Read-Host "Enter domains separated by space or comma (e.g. *.test app.local)"
    
    while ([string]::IsNullOrWhiteSpace($Domains)) {
        $Domains = Read-Host "Please enter at least one domain (e.g. *.test)"
    }
}

$domainList = $Domains -split '[, ]+' | Where-Object { $_ -ne "" }

$defaultFileName = ($domainList[0] -replace '\*','wildcard') -replace '[^\w\.-]', '_'
if (-not $defaultFileName) { $defaultFileName = "cert" }

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    Write-Host "`n--- 3. OUTPUT DIRECTORY ---" -ForegroundColor Cyan
    $inputDir = Read-Host "Enter output directory path [Default: . (current directory)]"
    
    if ([string]::IsNullOrWhiteSpace($inputDir)) {
        $OutputDir = "."
    } else {
        $OutputDir = $inputDir
    }
}

if ([string]::IsNullOrWhiteSpace($FileName)) {
    Write-Host "`n--- 4. FILE NAME ---" -ForegroundColor Cyan
    $inputName = Read-Host "Enter base filename for .crt/.key files [Default: $defaultFileName]"
    
    if ([string]::IsNullOrWhiteSpace($inputName)) {
        $FileName = $defaultFileName
    } else {
        $FileName = ($inputName -replace '\*','wildcard') -replace '[^\w\.-]', '_'
    }
}

if (-not (Test-Path -Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$resolvedOutputDir = (Resolve-Path $OutputDir).Path
$keyPath = Join-Path $resolvedOutputDir "$FileName.key"
$crtPath = Join-Path $resolvedOutputDir "$FileName.crt"

Write-Host "`n--- CONFIGURATION SUMMARY ---" -ForegroundColor Cyan
Write-Host "Tool        : $Tool"
Write-Host "Domains     : $($domainList -join ', ')"
Write-Host "Destination : $resolvedOutputDir"
Write-Host "Files       : $FileName.key / $FileName.crt"
Write-Host "--------------------------------"`n

if ($Tool -eq "mkcert") {
    if (-not (Get-Command "mkcert" -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Error: 'mkcert' is not installed or not found in PATH." -ForegroundColor Red
        Write-Host "   Install it via: choco install mkcert (or scoop install mkcert)" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "Configuring local Certificate Authority (mkcert -install)..." -ForegroundColor Gray
    mkcert -install

    & mkcert -key-file "$keyPath" -cert-file "$crtPath" $domainList

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✅ Certificates created and trusted by system using mkcert." -ForegroundColor Green
    } else {
        Write-Host "`n❌ Error executing mkcert." -ForegroundColor Red
        exit 1
    }

} else {
    if (-not (Get-Command "openssl" -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Error: 'openssl' is not installed or not found in PATH." -ForegroundColor Red
        exit 1
    }

    $sanList = $domainList | ForEach-Object { "DNS:$_" }
    $sanString = $sanList -join ","
    $primaryCN = $domainList[0]

    openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
        -keyout "$keyPath" `
        -out "$crtPath" `
        -subj "/CN=$primaryCN/O=Dev Local/C=ES" `
        -addext "subjectAltName=$sanString" 2>$null

    if (Test-Path $crtPath) {
        Write-Host "✅ Certificate files generated with OpenSSL." -ForegroundColor Green

        Write-Host "`n--- INSTALLING INTO WINDOWS TRUST STORE ---" -ForegroundColor Cyan
        try {
            if ($isAdmin) {
                Import-Certificate -FilePath "$crtPath" -CertStoreLocation "Cert:\LocalMachine\Root" | Out-Null
                Write-Host "✅ Certificate added to 'Trusted Root Certification Authorities' (Local Machine)." -ForegroundColor Green
            } else {
                Import-Certificate -FilePath "$crtPath" -CertStoreLocation "Cert:\CurrentUser\Root" | Out-Null
                Write-Host "✅ Certificate added to 'Trusted Root Certification Authorities' (Current User)." -ForegroundColor Green
            }
        } catch {
            Write-Host "❌ Could not register certificate trust: $_" -ForegroundColor Red
        }
    } else {
        Write-Host "❌ Error generating certificate with OpenSSL." -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n--- GENERATED FILES ---" -ForegroundColor Yellow
Write-Host " Private Key : $keyPath"
Write-Host " Certificate : $crtPath"
Write-Host " Done!`n" -ForegroundColor Green