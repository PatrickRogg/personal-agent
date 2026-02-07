#!/usr/bin/env bash
# Extract text from a .docx file
# Usage: docx-to-text.sh <file.docx>
# Output: Markdown text to stdout
set -euo pipefail

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
  echo "Usage: docx-to-text.sh <file.docx>" >&2
  exit 1
fi

# pandoc produces excellent markdown from docx
pandoc -f docx -t markdown --wrap=none "$1" 2>/dev/null && exit 0

# Fallback: python-docx
/opt/agent-venv/bin/python3 -c "
import docx, sys
doc = docx.Document(sys.argv[1])
for para in doc.paragraphs:
    print(para.text)
for table in doc.tables:
    for row in table.rows:
        print('\t'.join(cell.text for cell in row.cells))
" "$1"
