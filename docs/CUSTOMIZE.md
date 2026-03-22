# Customize

This guide explains how to adapt this starter to your situation.

---

## Level 1 — Quick Start (5 minutes)

1. Copy `templates/PLAN.md` to your project root
2. Write your objective in `PLAN.md`
3. Open OpenCode in the directory
4. Type `/onboard` on first use
5. That's it. The agent does the rest.

---

## Level 2 — Customize your profile

Edit `~/.config/opencode/DEVELOPER-PROFILE.md`:

```markdown
## Agent Personality
- Pragmatic   ← short answers, no unsolicited explanations
- Challenger  ← agent questions your choices before executing
- Teacher     ← agent explains why, not just how
```

This file is global — it applies to all your projects.

---

## Level 3 — Add domain skills

Create a directory in `.opencode/skills/`:

```
.opencode/skills/
└── my-skill/
    └── SKILL.md
```

Minimal format:
```markdown
---
name: my-skill
description: When to load this skill — be precise, this is what the agent reads to decide.
---

# Skill content
Instructions, conventions, useful commands...
```

**Useful skill examples:**
- Your company's naming conventions
- Framework-specific patterns
- Internal deployment procedures
- Security standards

---

## Level 4 — Add sub-agents

Create a file in `.opencode/agents/`:

```markdown
---
description: When to invoke this agent — precise and actionable.
mode: subagent
model: anthropic/claude-haiku-4-5-20251001  # Optional — lightweight model for simple tasks
---

# Agent role and instructions
```

**Sub-agent ideas:**
- `security-auditor` — vulnerability scanning
- `doc-writer` — documentation generation
- `migrator` — data migration scripts

---

## Level 5 — Add slash commands

Create a file in `.opencode/commands/`:

```markdown
---
description: "Short command description"
agent: agent-name  # Optional
---

Command instructions...
!shell-command  # Optional — executes a shell command
```

---

## What we advise against modifying

| File | Why not to touch |
|------|-----------------|
| `PLAN.md` | Source of truth — edit it yourself before the session, never during |
| `PROJECT-MAP.md` | Agent-managed — your changes will be overwritten |
| `BACKLOG.md` | Agent-managed — guaranteed confusion if you touch it |

---

## Contributing

Found a pattern that works well?
- Open an issue on GitHub with your use case
- Propose a skill or sub-agent via PR
- One rule: it must come from field practice, not theory
