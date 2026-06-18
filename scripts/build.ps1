[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Input = "examples/Compass_智能竞品分析平台.md",

    [string]$OutputDir = "dist",

    [switch]$Pdf,
    [switch]$SkipValidation,
    [switch]$RebuildTemplate
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

function Resolve-ProjectPath([string]$PathValue) {
    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }
    return [System.IO.Path]::GetFullPath((Join-Path $Root $PathValue))
}

function Require-Command([string]$Name, [string]$Help) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "$Name 未安装。$Help"
    }
}

Require-Command "python" "请先运行 scripts/install.ps1。"
Require-Command "pandoc" "请先运行 scripts/install.ps1。"

$InputPath = Resolve-ProjectPath $Input
$OutputPath = Resolve-ProjectPath $OutputDir
$ConfigPath = Join-Path $Root "config/pipeline.json"
$TemplatePath = Join-Path $Root "templates/compass-feishu-reference.docx"

if (-not (Test-Path $InputPath)) {
    throw "找不到 Markdown 文件：$InputPath"
}
New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $Root ".tmp") | Out-Null

if ($RebuildTemplate -or -not (Test-Path $TemplatePath)) {
    Write-Host "[1/4] 生成 DOCX 模板..." -ForegroundColor Cyan
    python (Join-Path $PSScriptRoot "create_template.py") --config $ConfigPath --output $TemplatePath
}

if (-not $SkipValidation) {
    Write-Host "[2/4] 校验 Markdown 与图片路径..." -ForegroundColor Cyan
    python (Join-Path $PSScriptRoot "validate_markdown.py") $InputPath --max-columns 5
}

$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
$TempDocx = Join-Path (Join-Path $Root ".tmp") ($BaseName + ".tmp.docx")
$FinalDocx = Join-Path $OutputPath ($BaseName + "_飞书导入版.docx")
$InputDir = Split-Path -Parent $InputPath
$AssetsDir = Join-Path $Root "assets"
$ResourcePath = "$InputDir;$AssetsDir"

Write-Host "[3/4] Pandoc 转换 Markdown → DOCX..." -ForegroundColor Cyan
pandoc $InputPath `
    --from="gfm+yaml_metadata_block" `
    --to=docx `
    --standalone `
    --reference-doc=$TemplatePath `
    --resource-path=$ResourcePath `
    --output=$TempDocx

Write-Host "[4/4] 自动美化表格、图片与代码块..." -ForegroundColor Cyan
python (Join-Path $PSScriptRoot "postprocess_docx.py") $TempDocx $FinalDocx --config $ConfigPath
Remove-Item $TempDocx -Force -ErrorAction SilentlyContinue

Write-Host "`n生成完成：$FinalDocx" -ForegroundColor Green
Write-Host "在飞书云文档首页选择：上传及导入 → 导入为在线文档。" -ForegroundColor Yellow

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
        Write-Host "正在额外导出 PDF..." -ForegroundColor Cyan
        & $Soffice --headless --convert-to pdf --outdir $OutputPath $FinalDocx | Out-Host
    } else {
        Write-Warning "未找到 LibreOffice，已跳过 PDF 导出。DOCX 不受影响。"
    }
}
