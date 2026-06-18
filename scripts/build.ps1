[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Input = "",

    [string]$OutputDir = "dist",

    [switch]$Pdf,
    [switch]$SkipValidation,
    [switch]$RebuildTemplate
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$OutputEncoding = [Console]::OutputEncoding
$env:PYTHONUTF8 = "1"
$Root = Split-Path -Parent $PSScriptRoot

function Resolve-ProjectPath([string]$PathValue) {
    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $Root $PathValue))
}

function Require-Command([string]$Name, [string]$Help) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "$Name is not installed. $Help"
    }
}

function Get-FeishuSuffix {
    return -join ([char[]](0x005f, 0x98de, 0x4e66, 0x5bfc, 0x5165, 0x7248))
}

function Get-DefaultInput {
    $ExampleDir = Join-Path $Root "examples"
    $Files = Get-ChildItem -Path $ExampleDir -Filter *.md -File | Sort-Object Name
    if ($Files.Count -eq 0) {
        throw "No Markdown file found in examples."
    }
    return $Files[0].FullName
}

Require-Command "python" "Run scripts/install.ps1 first."
Require-Command "pandoc" "Run scripts/install.ps1 first."

$InputPath = if ([string]::IsNullOrWhiteSpace($Input)) { Get-DefaultInput } else { Resolve-ProjectPath $Input }
$OutputPath = Resolve-ProjectPath $OutputDir
$ConfigPath = Join-Path $Root "config/pipeline.json"
$TemplatePath = Join-Path $Root "templates/compass-feishu-reference.docx"

if (-not (Test-Path $InputPath)) {
    throw "Markdown file not found: $InputPath"
}
New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $Root ".tmp") | Out-Null

$Config = Get-Content -Raw -Encoding UTF8 $ConfigPath | ConvertFrom-Json
$MaxColumns = [int]$Config.tables.max_columns_recommended

if ($RebuildTemplate -or -not (Test-Path $TemplatePath)) {
    Write-Host "[1/4] Creating DOCX template..." -ForegroundColor Cyan
    python (Join-Path $PSScriptRoot "create_template.py") --config $ConfigPath --output $TemplatePath
}

if (-not $SkipValidation) {
    Write-Host "[2/4] Validating Markdown and image paths..." -ForegroundColor Cyan
    python (Join-Path $PSScriptRoot "validate_markdown.py") $InputPath --max-columns $MaxColumns
}

$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
$TempDocx = Join-Path (Join-Path $Root ".tmp") ($BaseName + ".tmp.docx")
$FinalDocx = Join-Path $OutputPath ($BaseName + (Get-FeishuSuffix) + ".docx")
$InputDir = Split-Path -Parent $InputPath
$AssetsDir = Join-Path $Root "assets"
$ResourcePath = "$InputDir;$AssetsDir"

Write-Host "[3/4] Converting Markdown to DOCX with Pandoc..." -ForegroundColor Cyan
pandoc $InputPath `
    --from="gfm+yaml_metadata_block" `
    --to=docx `
    --standalone `
    --reference-doc=$TemplatePath `
    --resource-path=$ResourcePath `
    --output=$TempDocx

Write-Host "[4/4] Postprocessing tables, images, and code blocks..." -ForegroundColor Cyan
python (Join-Path $PSScriptRoot "postprocess_docx.py") $TempDocx $FinalDocx --config $ConfigPath
Remove-Item $TempDocx -Force -ErrorAction SilentlyContinue

Write-Host "`nGenerated: $FinalDocx" -ForegroundColor Green
Write-Host "In Feishu Docs, use Upload and Import, then import this DOCX as an online document." -ForegroundColor Yellow

if ($Pdf) {
    $Soffice = Get-Command soffice -ErrorAction SilentlyContinue
    if (-not $Soffice) {
        $Candidates = @(
            "$env:ProgramFiles\LibreOffice\program\soffice.exe",
            "${env:ProgramFiles(x86)}\LibreOffice\program\soffice.exe"
        )
        $Soffice = $Candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    }
    if ($Soffice) {
        Write-Host "Exporting PDF..." -ForegroundColor Cyan
        & $Soffice --headless --convert-to pdf --outdir $OutputPath $FinalDocx | Out-Host
    } else {
        Write-Warning "LibreOffice was not found. PDF export skipped; DOCX output is unaffected."
    }
}
