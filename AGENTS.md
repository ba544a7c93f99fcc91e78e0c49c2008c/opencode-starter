# AGENTS.md
> OpenCode + Copilot Premium starter · One branch = one mission = one context
> For full documentation → docs/

---

## Philosophy

- The human **approves** PLAN.md · The agent drafts it with `/architect` or the human writes it directly
- One branch = one mission = clean context
- Simple first, deep if needed
- If info is missing → ask, never assume

---

## Session Start

```
1. DEVELOPER-PROFILE.md   → calibrate profile and language
2. PLAN.md                → mission scope (read-only)
3. MEMORY.md              → existing context
4. BACKLOG.md             → task status
5. HUMAN.md               → pending human actions
6. CLOUD-RESOURCES.md     → cloud resources if present
7. DEPENDENCIES.md        → verify versions
```

If DEVELOPER-PROFILE.md missing → run `/onboard` before anything else.

Scan docs/ and README.md → ask if you can read and update.

---

## Mission Files

| File | Role | Agent can modify |
|---|---|---|
| `PLAN.md` | Source of truth · Read-only | ❌ Never |
| `MEMORY.md` | Session memory | ✅ Continuously |
| `BACKLOG.md` | Tasks — agent-managed only | ✅ Agent only |
| `HUMAN.md` | Human backlog — active reminders | ✅ Agent only |
| `PROJECT-MAP.md` | Project map — generated and maintained by agent | ✅ Agent only |
| `CLOUD-RESOURCES.md` | Cloud resources + risk level | ✅ With confirmation |
| `DEPENDENCIES.md` | Modules, repos, known versions | ✅ Updated on commits |

---

## Absolute Rules

**PLAN.md** — Never modified. Conflict detected → flag to human.

**Write operations** — Any command that creates, modifies, deletes, deploys, scales, or applies changes to infrastructure, data, or configuration requires: show command + target + environment + impact, then wait for **"go"**. Read operations (get, list, describe, show, status, diff, log) execute freely.

| Requires "go" | Free to run |
|---|---|
| `az ... create/update/delete`, `kubectl apply/delete/scale`, `terraform apply/destroy`, `INSERT/UPDATE/DELETE/DROP`, `rm -rf`, `git push --force` | `az ... list/show`, `kubectl get/describe/logs`, `terraform plan`, `SELECT`, `git log/diff` |

When in doubt — if the command changes state anywhere, it's a write. Ask.

**Tests** — `@tester` writes and runs tests. `@build` writes code. Never both together. If test fails → report to human, never modify test to pass.

**Memory** — Update MEMORY.md after each important decision. Suggest `/compact` when memory/ exceeds 500 lines.

**Documentation** — Update, never rewrite. Show diff before applying. Code comments = documentation.

---

## Available Slash Commands

| Command | Action |
|---|---|
| `/onboard` | Initial developer profile setup |
| `/architect` | Generate PLAN.md from rough intent — questions + section-by-section approval |
| `/map` | Map project per PLAN.md scope |
| `/compact` | Summarize and archive memory |
| `/review` | Trigger reviewer agent on modified code |
| `/test` | Trigger tester agent and report |
| `/debug` | Diagnose a blocked agent — surfaces contradictions and decision points |

---

## Available Sub-agents

| Agent | Role | Suggested Model |
|---|---|---|
| `@reviewer` | Code review · Read-only · Never modifies directly | Sonnet |
| `@tester` | Unit and functional tests · Never writes functional code | Haiku |
| `@explorer` | Discovery · Mapping · Read-only | Sonnet |

---

> **Guardrail** — This file must not exceed 120 lines. Any additional detail → `docs/`
