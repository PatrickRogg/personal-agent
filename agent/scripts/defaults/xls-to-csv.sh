#!/usr/bin/env bash
# Convert legacy .xls file to CSV
# Usage: xls-to-csv.sh <file.xls>
# Output: CSV to stdout
set -euo pipefail

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
  echo "Usage: xls-to-csv.sh <file.xls>" >&2
  exit 1
fi

xls2csv "$1"
