#!/usr/bin/env bash
# Show file information and metadata
# Usage: file-info.sh <file>
# Output: File type, size, and relevant metadata to stdout
set -euo pipefail

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
  echo "Usage: file-info.sh <file>" >&2
  exit 1
fi

FILE="$1"

echo "File: $(basename "$FILE")"
echo "Path: $(realpath "$FILE")"
echo "Size: $(du -h "$FILE" | cut -f1)"
echo "Type: $(file -b "$FILE")"
echo "MIME: $(file -b --mime-type "$FILE")"

case "${FILE,,}" in
  *.pdf)
    PAGES=$(pdfinfo "$FILE" 2>/dev/null | grep "Pages:" | awk '{print $2}')
    [ -n "$PAGES" ] && echo "Pages: $PAGES"
    ;;
  *.xlsx)
    /opt/agent-venv/bin/python3 -c "
import openpyxl, sys
wb = openpyxl.load_workbook(sys.argv[1], read_only=True)
print(f'Sheets: {wb.sheetnames}')
ws = wb.active
rows = sum(1 for _ in ws.iter_rows())
print(f'Active sheet rows: ~{rows}')
wb.close()
" "$FILE" 2>/dev/null || true
    ;;
  *.docx)
    /opt/agent-venv/bin/python3 -c "
import docx, sys
doc = docx.Document(sys.argv[1])
print(f'Paragraphs: {len(doc.paragraphs)}')
print(f'Tables: {len(doc.tables)}')
" "$FILE" 2>/dev/null || true
    ;;
  *.pptx)
    /opt/agent-venv/bin/python3 -c "
from pptx import Presentation
import sys
prs = Presentation(sys.argv[1])
print(f'Slides: {len(prs.slides)}')
" "$FILE" 2>/dev/null || true
    ;;
  *.jpg|*.jpeg|*.png|*.gif|*.bmp|*.tiff)
    identify "$FILE" 2>/dev/null | head -1 || true
    ;;
esac
