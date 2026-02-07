# Default Scripts & Installed Tools

Reference for all file-processing utilities available on this VM.

## Conversion Scripts

All scripts output to stdout. Run with `bash scripts/defaults/<script> <file>`.

| Script | Input | Output | Example |
|---|---|---|---|
| `docx-to-text.sh` | .docx | Markdown | `bash scripts/defaults/docx-to-text.sh file.docx` |
| `pptx-to-text.sh` | .pptx | Text (per slide) | `bash scripts/defaults/pptx-to-text.sh deck.pptx` |
| `xlsx-to-csv.sh` | .xlsx | CSV | `bash scripts/defaults/xlsx-to-csv.sh data.xlsx "Sheet1"` |
| `xls-to-csv.sh` | .xls | CSV | `bash scripts/defaults/xls-to-csv.sh legacy.xls` |
| `pdf-to-text.sh` | .pdf | Text | `bash scripts/defaults/pdf-to-text.sh doc.pdf --ocr` |
| `ocr-image.sh` | Image | Text (OCR) | `bash scripts/defaults/ocr-image.sh photo.png` |
| `extract-archive.sh` | Archive | Files | `bash scripts/defaults/extract-archive.sh pkg.zip ./out` |
| `html-to-text.sh` | .html | Text/Markdown | `bash scripts/defaults/html-to-text.sh page.html --markdown` |
| `file-info.sh` | Any | Metadata | `bash scripts/defaults/file-info.sh mystery.bin` |

## Installed System Packages

| Package | Provides | Usage |
|---|---|---|
| `poppler-utils` | `pdftotext`, `pdfinfo` | `pdftotext file.pdf -` |
| `tesseract-ocr` | `tesseract` | `tesseract image.png stdout` |
| `pandoc` | `pandoc` | `pandoc -f docx -t markdown file.docx` |
| `catdoc` | `catdoc`, `catppt`, `xls2csv` | `xls2csv file.xls` |
| `jq` | `jq` | `jq '.key' file.json` |
| `p7zip-full` | `7z` | `7z x archive.7z` |
| `imagemagick` | `identify`, `convert` | `identify image.png` |
| `libxml2-utils` | `xmllint` | `xmllint --format file.xml` |

## Python Packages (in /opt/agent-venv)

| Package | Purpose |
|---|---|
| `python-docx` | .docx text extraction |
| `python-pptx` | .pptx text extraction |
| `openpyxl` | .xlsx reading |
| `xlsx2csv` | .xlsx to CSV |
| `pdfplumber` | Advanced PDF extraction (tables, layout) |
| `Pillow` | Image handling |
| `pytesseract` | Python Tesseract wrapper |

Python venv path: `/opt/agent-venv/bin/python3`

## What Claude Code Can Read Directly

No scripts needed for these — just use the Read tool:
- Plain text, Markdown, CSV, JSON, YAML, XML
- PDF files (use `pages` parameter for large files)
- Images (PNG, JPG, etc. — viewed visually)
