[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "未检测到 Python。请先安装 Python 3.10+，安装时勾选 Add Python to PATH。"
}

if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "正在通过 winget 安装 Pandoc..." -ForegroundColor Cyan
        winget install --source winget --exact --id JohnMacFarlane.Pandoc --accept-package-agreements --accept-source-agreements
        Write-Host "Pandoc 安装后请重新打开 PowerShell，再运行本脚本。" -ForegroundColor Yellow
    } else {
        throw "未检测到 Pandoc，且系统没有 winget。请手动安装 Pandoc。"
    }
} else {
    Write-Host "Pandoc 已安装。" -ForegroundColor Green
}

Write-Host "正在安装 Python 依赖..." -ForegroundColor Cyan
python -m pip install --upgrade pip
python -m pip install -r (Join-Path $Root "requirements.txt")

Write-Host "`n环境准备完成。下一步执行：" -ForegroundColor Green
Write-Host "powershell -ExecutionPolicy Bypass -File .\scripts\build.ps1" -ForegroundColor Yellow
