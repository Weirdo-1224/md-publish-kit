#!/usr/bin/env bash
set -euo pipefail
export LANG="${LANG:-C.UTF-8}"
export LC_ALL="${LC_ALL:-C.UTF-8}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INPUT="${1:-$ROOT/examples/Compass_智能竞品分析平台.md}"
OUTPUT_DIR="${2:-$ROOT/dist}"
CONFIG="$ROOT/config/pipeline.json"
TEMPLATE="$ROOT/templates/compass-feishu-reference.docx"
TMP_DIR="$ROOT/.tmp"

command -v python >/dev/null || { echo "Python not found" >&2; exit 1; }
command -v pandoc >/dev/null || { echo "Pandoc not found" >&2; exit 1; }

mkdir -p "$OUTPUT_DIR" "$TMP_DIR" "$(dirname "$TEMPLATE")"

if [[ ! -f "$TEMPLATE" ]]; then
  python "$ROOT/scripts/create_template.py" --config "$CONFIG" --output "$TEMPLATE"
fi
python "$ROOT/scripts/validate_markdown.py" "$INPUT" --max-columns 5

base="$(basename "$INPUT" .md)"
temp="$TMP_DIR/$base.tmp.docx"
final="$OUTPUT_DIR/${base}_飞书导入版.docx"
resource_path="$(dirname "$INPUT"):$ROOT/assets"

pandoc "$INPUT" \
  --from='gfm+yaml_metadata_block' \
  --to=docx \
  --standalone \
  --reference-doc="$TEMPLATE" \
  --resource-path="$resource_path" \
  --output="$temp"

python "$ROOT/scripts/postprocess_docx.py" "$temp" "$final" --config "$CONFIG"
rm -f "$temp"
echo "Generated: $final"
