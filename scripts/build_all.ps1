[CmdletBinding()]
param(
    [string]$SourceDir = "examples",
    [string]$OutputDir = "dist",
    [switch]$Pdf
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$SourcePath = if ([System.IO.Path]::IsPathRooted($SourceDir)) { $SourceDir } else { Join-Path $Root $SourceDir }
$Files = Get-ChildItem -Path $SourcePath -Filter *.md -File
if ($Files.Count -eq 0) {
    throw "目录中没有 Markdown 文件：$SourcePath"
}

$BuildScript = Join-Path $PSScriptRoot 'build.ps1'
foreach ($File in $Files) {
    Write-Host "`n=== 构建 $($File.Name) ===" -ForegroundColor Magenta
    if ($Pdf) {
        & $BuildScript -Input $File.FullName -OutputDir $OutputDir -Pdf
    } else {
        & $BuildScript -Input $File.FullName -OutputDir $OutputDir
    }
}
