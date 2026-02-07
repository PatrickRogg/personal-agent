#!/usr/bin/env bash
# Extract text from a .pptx file
# Usage: pptx-to-text.sh <file.pptx>
# Output: Plain text to stdout (slide-by-slide)
set -euo pipefail

if [ $# -ne 1 ] || [ ! -f "$1" ]; then
  echo "Usage: pptx-to-text.sh <file.pptx>" >&2
  exit 1
fi

/opt/agent-venv/bin/python3 -c "
from pptx import Presentation
import sys

prs = Presentation(sys.argv[1])
for i, slide in enumerate(prs.slides, 1):
    print(f'--- Slide {i} ---')
    for shape in slide.shapes:
        if shape.has_text_frame:
            for para in shape.text_frame.paragraphs:
                text = para.text.strip()
                if text:
                    print(text)
        if shape.has_table:
            for row in shape.table.rows:
                print('\t'.join(cell.text.strip() for cell in row.cells))
    if slide.has_notes_slide and slide.notes_slide.notes_text_frame:
        notes = slide.notes_slide.notes_text_frame.text.strip()
        if notes:
            print(f'[Notes: {notes}]')
    print()
" "$1"
