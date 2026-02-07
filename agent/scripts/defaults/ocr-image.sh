#!/usr/bin/env bash
# Extract text from an image using OCR
# Usage: ocr-image.sh <image_file> [language]
# Output: Extracted text to stdout
# Supported formats: PNG, JPG, TIFF, BMP, GIF
# Note: Claude Code can view images directly. Use this when
#       you need to extract actual text content from the image.
set -euo pipefail

if [ $# -lt 1 ] || [ ! -f "$1" ]; then
  echo "Usage: ocr-image.sh <image_file> [language]" >&2
  exit 1
fi

LANG="${2:-eng}"

tesseract "$1" stdout -l "$LANG" 2>/dev/null
