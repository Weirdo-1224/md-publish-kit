[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$OutputEncoding = [Console]::OutputEncoding
$env:PYTHONUTF8 = "1"
$Root = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "Python was not found. Install Python 3.10+ and enable Add Python to PATH."
}

if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Installing Pandoc with winget..." -ForegroundColor Cyan
        winget install --source winget --exact --id JohnMacFarlane.Pandoc --accept-package-agreements --accept-source-agreements
        Write-Host "After Pandoc is installed, reopen PowerShell and run this script again." -ForegroundColor Yellow
    } else {
        throw "Pandoc was not found and winget is unavailable. Install Pandoc manually."
    }
} else {
    Write-Host "Pandoc is installed." -ForegroundColor Green
}

Write-Host "Installing Python dependencies..." -ForegroundColor Cyan
python -m pip install --upgrade pip
python -m pip install -r (Join-Path $Root "requirements.txt")

Write-Host "`nEnvironment is ready. Next run:" -ForegroundColor Green
Write-Host "powershell -ExecutionPolicy Bypass -File .\scripts\build.ps1" -ForegroundColor Yellow
