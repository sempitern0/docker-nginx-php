[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [string]$OutputDir,

    [Parameter(Mandatory = $false)]
    [string]$FileName,

    [Parameter(Mandatory = $false)]
    [string]$Domains,

    [Parameter(Mandatory = $false)]
    [ValidateSet("mkcert", "openssl")]
    [string]$Tool
)

$ErrorActionPreference = "Stop"

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

function Sanitize-FileName {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return "cert" }
    $Value = $Value -replace '\*', 'wildcard'
    $Value = $Value -replace '[^a-zA-Z0-9._-]', '_'
    if ([string]::IsNullOrWhiteSpace($Value)) { return "cert" }
    return $Value
}

if ([string]::IsNullOrWhiteSpace($Tool)) {
    Write-Host "`n--- 1. TOOL SELECTION ---" -ForegroundColor Cyan
    Write-Host "1) mkcert  [Recommended - local CA + system/browser trust]"
    Write-Host "2) OpenSSL [Local CA + signed server certificate]"
    $choice = Read-Host "Choose an option (1 or 2) [Default: 1]"
    $Tool = if ($choice -eq "2") { "openssl" } else { "mkcert" }
}

if ([string]::IsNullOrWhiteSpace($Domains)) {
    Write-Host "`n--- 2. DOMAINS ---" -ForegroundColor Cyan
    $Domains = Read-Host "Enter domains separated by space or comma (e.g. *.test app.local)"
    while ([string]::IsNullOrWhiteSpace($Domains)) {
        $Domains = Read-Host "Please enter at least one domain"
    }
}

$domainList = @($Domains -split '[, ]+' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if ($domainList.Count -eq 0) {
    throw "No domains supplied."
}

$primaryDomain = $domainList[0]
$defaultFileName = Sanitize-FileName $primaryDomain

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
    Write-Host "`n--- 3. OUTPUT DIRECTORY ---" -ForegroundColor Cyan
    $inputDir = Read-Host "Enter output directory path [Default: .]"
    $OutputDir = if ([string]::IsNullOrWhiteSpace($inputDir)) { "." } else { $inputDir }
}

if ([string]::IsNullOrWhiteSpace($FileName)) {
    Write-Host "`n--- 4. FILE NAME ---" -ForegroundColor Cyan
    $inputName = Read-Host "Enter base filename [Default: $defaultFileName]"
    $FileName = if ([string]::IsNullOrWhiteSpace($inputName)) { $defaultFileName } else { $inputName }
}

$FileName = Sanitize-FileName $FileName

if (-not (Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$resolvedOutputDir = (Resolve-Path -LiteralPath $OutputDir).Path
$keyPath = Join-Path $resolvedOutputDir "$FileName.key"
$crtPath = Join-Path $resolvedOutputDir "$FileName.crt"
$caKeyPath = Join-Path $resolvedOutputDir "$FileName-CA.key"
$caCrtPath = Join-Path $resolvedOutputDir "$FileName-CA.crt"

Write-Host "`n--- CONFIGURATION SUMMARY ---" -ForegroundColor Cyan
Write-Host "Tool        : $Tool"
Write-Host "Domains     : $($domainList -join ', ')"
Write-Host "Destination : $resolvedOutputDir"
Write-Host "Server key  : $keyPath"
Write-Host "Server cert : $crtPath"
Write-Host "CA cert     : $caCrtPath"
if ($Tool -eq "openssl") {
    Write-Host "CA key      : $caKeyPath"
}
Write-Host "--------------------------------`n"

if ($Tool -eq "mkcert") {
    if (-not (Get-Command "mkcert" -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Error: 'mkcert' is not installed or not found in PATH." -ForegroundColor Red
        exit 1
    }

    Write-Host "Configuring local Certificate Authority (mkcert -install)..." -ForegroundColor Gray
    & mkcert -install
    if ($LASTEXITCODE -ne 0) {
        throw "mkcert -install failed with exit code $LASTEXITCODE."
    }

    Write-Host "Generating server certificate..." -ForegroundColor Gray
    & mkcert -key-file $keyPath -cert-file $crtPath @domainList
    if ($LASTEXITCODE -ne 0) {
        throw "mkcert certificate generation failed with exit code $LASTEXITCODE."
    }

    $caRootDir = (& mkcert -CAROOT).Trim()
    $caPemPath = Join-Path $caRootDir "rootCA.pem"

    if (-not (Test-Path -LiteralPath $caPemPath)) {
        throw "mkcert CA certificate not found: $caPemPath"
    }

    Copy-Item -LiteralPath $caPemPath -Destination $caCrtPath -Force

    Write-Host "`n✅ mkcert certificates generated." -ForegroundColor Green
    Write-Host "   mkcert CA directory : $caRootDir"
    Write-Host "   Exported CA         : $caCrtPath"
}
else {
    if (-not (Get-Command "openssl" -ErrorAction SilentlyContinue)) {
        Write-Host "❌ Error: 'openssl' is not installed or not found in PATH." -ForegroundColor Red
        exit 1
    }

    $sanString = ($domainList | ForEach-Object { "DNS:$_" }) -join ","
    $configPath = Join-Path $resolvedOutputDir "$FileName-openssl.cnf"
    $csrPath = Join-Path $resolvedOutputDir "$FileName.csr"
    $serialPath = Join-Path $resolvedOutputDir "$FileName-CA.srl"

    @"
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
"@ | Set-Content -LiteralPath $configPath -Encoding ascii

    & openssl genrsa -out $caKeyPath 4096 2>$null
    if ($LASTEXITCODE -ne 0) { throw "OpenSSL CA key generation failed." }

    & openssl req -x509 -new -sha256 -days 3650 `
        -key $caKeyPath `
        -out $caCrtPath `
        -subj "/CN=Dev Local CA/O=Dev Local/C=ES" `
        -extensions v3_ca `
        -config $configPath
    if ($LASTEXITCODE -ne 0) { throw "OpenSSL CA certificate generation failed." }

    & openssl genrsa -out $keyPath 2048 2>$null
    if ($LASTEXITCODE -ne 0) { throw "OpenSSL server key generation failed." }

    & openssl req -new -sha256 `
        -key $keyPath `
        -out $csrPath `
        -config $configPath
    if ($LASTEXITCODE -ne 0) { throw "OpenSSL CSR generation failed." }

    & openssl x509 -req -sha256 -days 825 `
        -in $csrPath `
        -CA $caCrtPath `
        -CAkey $caKeyPath `
        -CAcreateserial `
        -out $crtPath `
        -extensions v3_server `
        -extfile $configPath
    if ($LASTEXITCODE -ne 0) { throw "OpenSSL server certificate generation failed." }

    Remove-Item -LiteralPath $csrPath, $serialPath, $configPath -Force -ErrorAction SilentlyContinue

    Write-Host "`n--- INSTALLING CA INTO WINDOWS TRUST STORE ---" -ForegroundColor Cyan
    try {
        $store = if ($isAdmin) { "Cert:\LocalMachine\Root" } else { "Cert:\CurrentUser\Root" }
        Import-Certificate -FilePath $caCrtPath -CertStoreLocation $store | Out-Null
        Write-Host "✅ CA added to Trusted Root Certification Authorities: $store" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️ Could not register the CA automatically: $_" -ForegroundColor Yellow
        Write-Host "   Import manually: $caCrtPath" -ForegroundColor Yellow
    }

    Write-Host "`n✅ OpenSSL CA and server certificate generated." -ForegroundColor Green
}

Write-Host "`n--- GENERATED FILES ---" -ForegroundColor Yellow
Write-Host " Private Key : $keyPath"
Write-Host " Certificate : $crtPath"
Write-Host " CA Root     : $caCrtPath"
if ($Tool -eq "openssl") {
    Write-Host " CA Key      : $caKeyPath"
}
Write-Host " Done!`n" -ForegroundColor Green
