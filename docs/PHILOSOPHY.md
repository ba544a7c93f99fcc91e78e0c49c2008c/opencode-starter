# Philosophy

## Why this project

This starter was born from a simple frustration: existing AI agent frameworks are either too complex or too generic. They require hours of reading before producing a single useful line.

---

## Founding Principles

### 1. Human steers, agent executes

The human has one responsibility: write `PLAN.md`. Everything else — memory, backlog, mapping, tests, review — belongs to the agent. This isn't laziness. It's intelligent delegation.

### 2. One branch = one mission = clean context

Context contamination is the agent's primary enemy. An agent carrying memories from a previous mission produces biased code. Branch isolation solves this problem without infrastructure.

### 3. Simple first, deep if needed

`AGENTS.md` should be readable in 5 minutes. If someone is discouraged before starting, the project has failed. Depth is available — in `docs/`, in skills, in sub-agents — but it doesn't impose itself.

### 4. Native OpenCode — no reinvention

Hooks, slash commands, skills, sub-agents: OpenCode supports them natively. This project doesn't invent new mechanisms. It organizes and opinionates what already exists.

### 5. Keep memory alive

Memory that grows uncontrolled becomes noise. This project treats memory like a living organism: it's created, enriched, compacted, archived. `/compact` isn't optional — it's hygiene.

---

## What this project is not

- **Not a framework** — no dependencies, no installation
- **Not a generic template** — it reflects a vision and field practice
- **Not definitive** — it evolves with use

---

## Inspirations

- Claude Code best practices — Anthropic
- DeepAgents memory system — LangChain
- OpenCode native skills and agents — anomalyco
- mem-agent — Driaforall (markdown-based memory research)
- Field practice of a senior developer who stopped reinventing the wheel
