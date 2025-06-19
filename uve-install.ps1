<#
.SYNOPSIS
  Install or update UVE and uv on Windows using PowerShell.
#>

# Strict script behavior
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Color definitions
$HostSupportsColor = $Host.UI.SupportsVirtualTerminal
if ($HostSupportsColor) {
    $Red    = "`e[0;31m"
    $Green  = "`e[0;32m"
    $Yellow = "`e[1;33m"
    $Blue   = "`e[0;34m"
    $NC     = "`e[0m"
} else {
    $Red = $Green = $Yellow = $Blue = $NC = ""
}

function Write-Color ([string]$text, [string]$color=$NC) {
    Write-Host "$color$text$NC"
}

# Variables
$baseUrl  = 'https://github.com/iamshreeram/uve/releases/latest/download'
$binPath  = Join-Path $HOME '.local\bin'
New-Item -ItemType Directory -Path $binPath -Force | Out-Null

# OS & Arch detection
$os = 'windows'
$arch = if ($env:PROCESSOR_ARCHITECTURE -match '64') { 'amd64' } else { Write-Color 'Unsupported architecture' $Red; exit 1 }

Write-Color "Detected OS: $os, Arch: $arch" $Blue

# Download UVE
$zipName = "uve-windows-$arch.zip"
Write-Color "Downloading $zipName ..." $Blue
$zipPath = Join-Path $env:TEMP $zipName
Invoke-WebRequest -Uri "$baseUrl/$zipName" -OutFile $zipPath -UseBasicParsing

Write-Color "Extracting UVE..." $Blue
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $env:TEMP, $true)

Move-Item -Path (Join-Path $env:TEMP 'uve.exe') -Destination (Join-Path $binPath 'uve-bin.exe') -Force
Copy-Item (Join-Path $binPath 'uve-bin.exe') (Join-Path $binPath 'uve.exe') -Force

# Ensure PATH
$profileFile = $PROFILE.CurrentUserAllHosts
$addCmd = "`$env:PATH = '$binPath;' + `$env:PATH"
if (-not (Get-Content $profileFile 2>$null | Select-String -SimpleMatch $addCmd)) {
    Add-Content -Path $profileFile -Value $addCmd
    Write-Color "Added $binPath to PATH in $profileFile" $Yellow
}
Write-Color "Please restart PowerShell or run: . $profileFile" $Yellow

# Initialize shell integration
Write-Color "Initializing UVE shell integration..." $Blue
& (Join-Path $binPath 'uve-bin.exe') init

# Install uv if missing
Write-Color "Checking for 'uv'..." $Blue
try {
    & uv --version | Out-Null
    Write-Color "'uv' is already installed." $Green
} catch {
    Write-Color "'uv' not found — installing..." $Yellow
    try {
        iex (irm 'https://astral.sh/uv/install.ps1')
    } catch {
        Write-Color "❌ Error: Failed to install 'uv' via official script." $Red
        Write-Color "👉 'uve' requires 'uv'. Please install it manually." $Red
        exit 1
    }
}

Write-Color "✅ UVE installed successfully to $binPath" $Green
Write-Color "Please restart PowerShell to apply changes." $Yellow
