---
description: Summarize and archive session memory
agent: build
---
Read all files in `memory/` (except `archive/`).

Count the total number of lines. If over 500, propose compaction.

**Compaction process:**

1. Compress `MEMORY.md` using telegraphic style — no full sentences, key:value or tight
   bullet points only. Examples:
   - Decision: `Auth: JWT (stateless, mobile requirement)`
   - Pattern: `DB: always use transactions for multi-table writes`
   - Error resolved: `Redis timeout → missing keepalive, fixed config.ts:42`
   - Instruction: `Never touch admin/ — prod only, manual deploys`
   Remove all narrative, explanation, and conversational context.
   If a fact can't be expressed in under 10 words, compress harder.

2. Create a dated archive in `memory/archive/`:
   - Name: `YYYY-MM-DD_summary.md`
   - Content: full session summary with context

3. Update `MEMORY.md` with the condensed summary (target: < 120 lines)

4. Report to human:
   - Archive created: `memory/archive/[name]`
   - Lines before → after
   - MEMORY.md updated

Do not touch files in `memory/archive/`.
