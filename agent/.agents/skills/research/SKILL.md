# /research

Conduct web research on a topic and produce a structured report.

## Steps

1. Check `memory/_index.md` for existing knowledge on the topic
2. Clarify the research question with the user if it's vague
3. Use WebSearch to find relevant sources (at least 3-5 searches with different angles)
4. Use WebFetch to read the most promising pages
5. Synthesize findings into a structured report
6. Save the full report to `knowledge/YYYY-MM-DD-research-<topic>.md`
7. Create a memory entry in `memory/` with key findings + link to the full report
8. Update `memory/_index.md`
9. Show a brief summary in chat with key findings

## Report format

```
# Research: [Topic]
Date: [date]

## Summary
[2-3 sentence overview]

## Key Findings
- [finding 1]
- [finding 2]
- ...

## Details
[detailed analysis organized by subtopic]

## Sources
- [url 1] — [what it covers]
- [url 2] — [what it covers]
```
