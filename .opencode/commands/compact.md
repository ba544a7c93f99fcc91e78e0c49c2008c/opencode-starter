---
description: Summarize and archive session memory
agent: build
---
Read all files in `memory/` (except `archive/`).

Count the total number of lines. If over 500, propose compaction.

**Compaction process:**

1. Summarize the content of `MEMORY.md`, keeping only:
   - Important architectural decisions
   - Validated patterns
   - Errors encountered and resolved
   - Permanent human instructions

2. Create a dated archive in `memory/archive/`:
   - Name: `YYYY-MM-DD_summary.md`
   - Content: full session summary with context

3. Update `MEMORY.md` with the condensed summary (target: < 120 lines)

4. Report to human:
   - Archive created: `memory/archive/[name]`
   - Lines before → after
   - MEMORY.md updated

Do not touch files in `memory/archive/`.
