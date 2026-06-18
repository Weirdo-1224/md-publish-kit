[CmdletBinding()]
param(
    [string]$SourceDir = "examples",
    [string]$OutputDir = "dist",
    [switch]$Pdf
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$OutputEncoding = [Console]::OutputEncoding
$env:PYTHONUTF8 = "1"
$Root = Split-Path -Parent $PSScriptRoot
$SourcePath = if ([System.IO.Path]::IsPathRooted($SourceDir)) { $SourceDir } else { Join-Path $Root $SourceDir }
$Files = Get-ChildItem -Path $SourcePath -Filter *.md -File
if ($Files.Count -eq 0) {
    throw "No Markdown files found in: $SourcePath"
}

$BuildScript = Join-Path $PSScriptRoot 'build.ps1'
foreach ($File in $Files) {
    Write-Host "`n=== Building $($File.Name) ===" -ForegroundColor Magenta
    if ($Pdf) {
        & $BuildScript -Input $File.FullName -OutputDir $OutputDir -Pdf
    } else {
        & $BuildScript -Input $File.FullName -OutputDir $OutputDir
    }
}
