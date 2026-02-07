#!/usr/bin/env bash
# Convert HTML to plain text or markdown
# Usage: html-to-text.sh <file.html> [--markdown]
# Output: Plain text or markdown to stdout
set -euo pipefail

if [ $# -lt 1 ] || [ ! -f "$1" ]; then
  echo "Usage: html-to-text.sh <file.html> [--markdown]" >&2
  exit 1
fi

FORMAT="${2:-}"

if [ "$FORMAT" = "--markdown" ]; then
  pandoc -f html -t markdown --wrap=none "$1"
else
  pandoc -f html -t plain --wrap=none "$1"
fi
