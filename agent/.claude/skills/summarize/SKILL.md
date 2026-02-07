# /summarize

Summarize one or more documents or files.

## Steps

1. Check `drop/` for any files, or ask the user which files to summarize
2. Read each file
3. Generate a concise summary for each:
   - Key points (bullet list)
   - Action items (if any)
   - Notable details
4. Save to `output/YYYY-MM-DD-summary-<description>.md`
5. Show the summary in chat
6. If the content contains facts worth remembering, offer to save them:
   - Full content → `knowledge/`
   - Key facts + summary → `memory/` with link back to `knowledge/`
