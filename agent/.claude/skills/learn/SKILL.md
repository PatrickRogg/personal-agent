# /learn

Learn from dropped files, links, or conversation. Uses a two-tier system:
- **`knowledge/`** — raw content archive. Originals preserved as-is.
- **`memory/`** — distilled summaries and key facts, with links back to `knowledge/`.

## From dropped files

1. List all files in `drop/`
2. Read each file based on its format:
   - **Text files** (.md, .txt, .csv, .json, .yaml, .xml): Read directly
   - **PDF files**: Read directly (use `pages` parameter for large PDFs)
   - **Images**: Read directly (you see them visually)
   - **Office documents**: Convert first using scripts in `scripts/defaults/`:
     - `.docx` → `bash scripts/defaults/docx-to-text.sh drop/<file>`
     - `.pptx` → `bash scripts/defaults/pptx-to-text.sh drop/<file>`
     - `.xlsx` → `bash scripts/defaults/xlsx-to-csv.sh drop/<file>`
     - `.xls` → `bash scripts/defaults/xls-to-csv.sh drop/<file>`
   - **Archives** (.zip, .tar.gz, .7z, .rar): Extract first with `bash scripts/defaults/extract-archive.sh drop/<file> drop/extracted/`, then process contents
   - **Unknown formats**: Run `bash scripts/defaults/file-info.sh drop/<file>` to identify, then decide
3. For each file:
   a. **Archive** — move or copy the raw file to `knowledge/` (preserve original as-is)
   b. **Distill** — create a memory entry in `memory/<topic>.md` containing:
      - Key facts extracted (names, dates, numbers, relationships)
      - Summary (2-3 sentences)
      - Source reference: `Full document: ../knowledge/<filename>`
   c. **Index** — add entry to `memory/_index.md`
   d. **Clean up** — delete the file from `drop/`
4. If the content relates to me (preferences, style, personal info), update `memory/me.md` instead
5. Summarize in chat what was learned

## From a link

1. Fetch the URL using WebFetch
2. Save full page content to `knowledge/YYYY-MM-DD-<title>.md`
3. Create memory entry in `memory/` with summary + key facts + link to knowledge file
4. Update `memory/_index.md`
5. Summarize in chat what was learned

## From conversation

When told to remember something:

1. Read `memory/_index.md` to see what exists
2. Determine the best memory file for this information
3. If no good fit, create a new memory file
4. If there is supporting detail worth preserving, save it to `knowledge/` and link from the memory entry
5. Update `memory/_index.md`
6. Confirm what was saved

## Guidelines

- Memory files are concise — key facts, summaries, and links. Not full documents.
- Knowledge files are complete — raw originals, full articles, detailed content.
- Use kebab-case filenames: `product-brief.md`, `contact-jane.md`, `sales-playbook.md`
- Each memory file has a clear `# Title` and always links to its source in `knowledge/`
- Prefer updating existing memory files over creating duplicates
- Keep `memory/_index.md` as a one-line-per-entry quick-reference catalog
