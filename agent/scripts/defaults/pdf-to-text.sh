#!/usr/bin/env bash
# Extract text from a PDF file
# Usage: pdf-to-text.sh <file.pdf> [--ocr]
# Output: Plain text to stdout
# Note: Claude Code can read PDFs directly. Use this for scanned
#       PDFs (--ocr) or when you need raw text extraction.
set -euo pipefail

if [ $# -lt 1 ] || [ ! -f "$1" ]; then
  echo "Usage: pdf-to-text.sh <file.pdf> [--ocr]" >&2
  exit 1
fi

FILE="$1"
OCR="${2:-}"

if [ "$OCR" = "--ocr" ]; then
  # OCR mode: convert PDF pages to images, then run Tesseract
  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' EXIT

  pdftoppm -png "$FILE" "$TMPDIR/page"

  for img in "$TMPDIR"/page-*.png; do
    [ -f "$img" ] || continue
    tesseract "$img" stdout 2>/dev/null
    echo ""
  done
else
  # Standard text extraction
  TEXT=$(pdftotext -layout "$FILE" - 2>/dev/null)

  if [ -z "$TEXT" ] || [ "$(echo "$TEXT" | tr -d '[:space:]' | wc -c)" -lt 50 ]; then
    echo "[Note: PDF appears to be scanned/image-based. Re-run with --ocr flag for OCR extraction.]" >&2
    echo "$TEXT"
  else
    echo "$TEXT"
  fi
fi
