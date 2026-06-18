from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

IMAGE_MD = re.compile(r'!\[[^\]]*\]\(([^)\s]+)(?:\s+["\'][^"\']*["\'])?\)')
IMAGE_HTML = re.compile(r'<img\b[^>]*\bsrc=["\']([^"\']+)["\'][^>]*>', re.I)
WIN_ABS = re.compile(r'^[A-Za-z]:[\\/]')
FRONT_MATTER = re.compile(r'^---\s*\n(.*?)\n---\s*\n', re.S)
TABLE_SEPARATOR = re.compile(r'^\s*\|?(?:\s*:?-{3,}:?\s*\|)+\s*$', re.M)


def parse_front_matter(text: str) -> dict[str, str]:
    m = FRONT_MATTER.match(text)
    if not m:
        return {}
    result: dict[str, str] = {}
    for line in m.group(1).splitlines():
        if ':' not in line:
            continue
        key, value = line.split(':', 1)
        result[key.strip()] = value.strip().strip('"\'')
    return result


def table_column_count(separator_line: str) -> int:
    line = separator_line.strip().strip('|')
    return len(line.split('|')) if line else 0


def validate(path: Path, max_columns: int) -> tuple[list[str], list[str]]:
    text = path.read_text(encoding='utf-8-sig')
    errors: list[str] = []
    warnings: list[str] = []

    meta = parse_front_matter(text)
    for key in ('title', 'subtitle', 'author', 'date'):
        if key not in meta:
            warnings.append(f'YAML metadata missing: {key}')

    refs = [*IMAGE_MD.findall(text), *IMAGE_HTML.findall(text)]
    for ref in refs:
        ref = ref.strip('<>')
        if ref.startswith(('http://', 'https://', 'data:')):
            continue
        if WIN_ABS.match(ref) or ref.startswith('/') or ref.startswith('file:'):
            errors.append(f'Image uses an absolute/local-only path: {ref}')
            continue
        clean = ref.split('#', 1)[0].split('?', 1)[0]
        target = (path.parent / clean).resolve()
        if not target.exists():
            errors.append(f'Image file not found: {ref} (resolved to {target})')

    for m in TABLE_SEPARATOR.finditer(text):
        line = m.group(0)
        cols = table_column_count(line)
        if cols > max_columns:
            warnings.append(f'Table has {cols} columns; recommended maximum is {max_columns}. Consider splitting it.')

    for no, line in enumerate(text.splitlines(), 1):
        if len(line) > 240 and '|' in line:
            warnings.append(f'Line {no}: very long table row ({len(line)} chars); imported cells may become dense.')
        if re.search(r'\S{70,}', line) and not line.lstrip().startswith(('http://', 'https://')):
            warnings.append(f'Line {no}: contains an unbroken token longer than 70 characters.')

    return errors, warnings


def main():
    parser = argparse.ArgumentParser(description='Validate Markdown before DOCX generation.')
    parser.add_argument('input', type=Path)
    parser.add_argument('--max-columns', type=int, default=5)
    parser.add_argument('--warnings-as-errors', action='store_true')
    args = parser.parse_args()

    path = args.input.resolve()
    if not path.exists():
        raise SystemExit(f'Input not found: {path}')
    errors, warnings = validate(path, args.max_columns)
    for item in warnings:
        print(f'[WARN] {item}')
    for item in errors:
        print(f'[ERROR] {item}', file=sys.stderr)
    if errors or (warnings and args.warnings_as_errors):
        raise SystemExit(2)
    print(f'[OK] Markdown validation passed: {path}')


if __name__ == '__main__':
    main()
