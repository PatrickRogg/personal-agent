#!/usr/bin/env bash
# Convert .xlsx file to CSV
# Usage: xlsx-to-csv.sh <file.xlsx> [sheet_name_or_number]
# Output: CSV to stdout
set -euo pipefail

if [ $# -lt 1 ] || [ ! -f "$1" ]; then
  echo "Usage: xlsx-to-csv.sh <file.xlsx> [sheet_name_or_number]" >&2
  exit 1
fi

SHEET="${2:-}"

# Try xlsx2csv first (fast, purpose-built)
if command -v xlsx2csv &>/dev/null; then
  if [ -n "$SHEET" ]; then
    xlsx2csv -n "$SHEET" "$1" 2>/dev/null && exit 0
  else
    xlsx2csv "$1" 2>/dev/null && exit 0
  fi
fi

# Fallback: openpyxl
/opt/agent-venv/bin/python3 -c "
import openpyxl, csv, sys, io

wb = openpyxl.load_workbook(sys.argv[1], read_only=True, data_only=True)
sheet_arg = sys.argv[2] if len(sys.argv) > 2 else None

if sheet_arg:
    try:
        ws = wb[sheet_arg]
    except KeyError:
        try:
            ws = wb.worksheets[int(sheet_arg) - 1]
        except (ValueError, IndexError):
            print(f'Sheet not found: {sheet_arg}', file=sys.stderr)
            print(f'Available sheets: {wb.sheetnames}', file=sys.stderr)
            sys.exit(1)
else:
    ws = wb.active

writer = csv.writer(sys.stdout)
for row in ws.iter_rows(values_only=True):
    writer.writerow([str(cell) if cell is not None else '' for cell in row])
wb.close()
" "$1" ${SHEET:+"$SHEET"}
