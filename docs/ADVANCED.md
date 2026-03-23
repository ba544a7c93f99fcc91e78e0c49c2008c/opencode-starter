# Advanced Usage

---

## Segmented Memory

For long projects, replace `MEMORY.md` with a `memory/` directory:

```
memory/
├── decisions.md      ← architectural choices and rationale
├── patterns.md       ← validated patterns for this project
├── pitfalls.md       ← errors encountered and resolved
├── instructions.md   ← what human said to do/avoid
└── archive/          ← compacted sessions
    └── 2026-03-22_summary.md
```

Tell the agent at session start:
```
The memory/ directory contains my segmented memory.
Read all .md files in memory/ at startup.
Update the appropriate file based on the type of information.
```

---

## Session Versioning

Name session files by date:

```
memory/
├── 2026-03-20.md    ← March 20 session
├── 2026-03-22.md    ← March 22 session
└── MEMORY.md        ← active condensed summary
```

The agent creates the daily file automatically if you ask:
```
At the start of each session, create memory/[today's-date].md
and note the important decisions made during the session.
```

---

## Advanced Compacting

When `memory/` exceeds 500 lines, `/compact` proposes:

```
Archive created: memory/archive/2026-03-22_summary.md
Content: decisions from March 1 to March 22
Lines: 847 → 120
MEMORY.md updated with condensed summary
```

The archive is readable by future agents if historical context is needed.

---

## Parallel Multi-agents

For complex projects, OpenCode supports multiple simultaneous sessions:

```bash
# Terminal 1 — build agent
opencode --agent build

# Terminal 2 — review agent
opencode --agent reviewer

# Terminal 3 — test agent
opencode --agent tester
```

Each agent reads the same MD files but works in its own context.
Coordinate via BACKLOG.md and HUMAN.md.

---

## OpenCode Hooks & Plugins (optional automation)

OpenCode supports JavaScript/TypeScript plugins that run on platform events.
Place plugins in `.opencode/plugins/` — they use Bun's module system
(already available since OpenCode itself runs on Bun).

**Auto-validate JSON/YAML on edit** — runs `make validate` whenever a config file is saved:

```javascript
// .opencode/plugins/validate-on-edit.js
export default {
  "file.edited": async ({ $, directory }) => {
    await $`make validate`.cwd(directory).quiet().nothrow()
  }
}
```

**Context snapshot on session start** — runs `make map` when a new session opens:

```javascript
// .opencode/plugins/session-start.js
export default {
  "session.created": async ({ $, directory }) => {
    await $`sh .agent/map_context.sh`.cwd(directory).quiet().nothrow()
  }
}
```

See the [OpenCode docs](https://opencode.ai/docs) for the full hook event reference.
Plugins are optional — the starter works fully without them.

---

## Local RAG with ChromaDB

For very large projects where `memory/` becomes too bulky:

```bash
pip install chromadb sentence-transformers --break-system-packages
```

Index the memory/ directory:
```python
import chromadb

client = chromadb.Client()
collection = client.create_collection("memory")

import os
for f in os.listdir("memory"):
    if f.endswith(".md"):
        text = open(f"memory/{f}").read()
        collection.add(documents=[text], ids=[f])
```

> Recommended only if memory/ regularly exceeds 2000 lines.

---

## Deep PROJECT-MAP.md

For projects with millions of lines of code, limit the scan:

```
/map --scope src/api/payments
```

The agent maps only the `src/api/payments` directory and its direct dependencies. Avoids burning tokens on out-of-scope code.

---

## Model Selection and Cost

The starter is tiered by task cost:
- `@tester` → Haiku (fast, cheap — test generation is repetitive and low-stakes)
- `@reviewer` + `@explorer` → Sonnet (reasoning-intensive — catching bugs and mapping codebases)
- Build agent → Sonnet (default — code generation requires full reasoning)

To reduce costs further: add `model: anthropic/claude-haiku-4-5-20251001` to `.opencode/commands/map.md` if your `/map` runs are frequent. To track spend, use your provider's billing dashboard filtered by API key — no in-tool tracking is needed for a markdown-driven workflow.

---

## Global vs Project Skills

```
~/.config/opencode/skills/   ← available in all your projects
.opencode/skills/            ← specific to this project
```

Useful global skill examples:
- Your personal naming conventions
- Your preferred comment style
- Your usual error-handling patterns
