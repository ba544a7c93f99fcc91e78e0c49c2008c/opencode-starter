# opencode-starter

> A pragmatic, opinionated starter kit for [OpenCode](https://opencode.ai) + [GitHub Copilot Premium](https://github.com/features/copilot).

**One branch. One mission. One clean context.**

---

## What is this?

A minimal system that makes AI agents actually useful on real projects — not toy demos.

Built from field experience. Not theory.

---

## Core idea

```
Human approves PLAN.md → Agent does everything else
```

Draft it with `/architect`, or write it yourself — see [docs/WRITING-YOUR-PLAN.md](docs/WRITING-YOUR-PLAN.md).
The rest is guardrails and memory hygiene.

---

## How it works

```mermaid
flowchart TD
    H([Human]) --> P["PLAN.md (read-only)"]
    P --> A[AGENTS.md]
    A --> C[commands/]
    A --> AG[agents/]
    A --> SK[skills/]

    C --> c1["/onboard"]
    C --> c2["/map"]
    C --> c3["/compact"]
    C --> c4["/review"]
    C --> c5["/test"]

    AG --> a1["reviewer · Sonnet"]
    AG --> a2["tester · Haiku"]
    AG --> a3["explorer · Sonnet"]

    SK --> s1[azure/SKILL.md]
    SK --> s2[openshift/SKILL.md]
    SK --> s3[terraform/SKILL.md]
```

---

## Session flow

```mermaid
sequenceDiagram
    participant H as Human
    participant OC as OpenCode
    participant A as Agent

    H->>OC: opencode
    OC->>A: load AGENTS.md
    A->>A: read DEVELOPER-PROFILE.md
    alt Profile missing
        A->>H: /onboard — calibration questions
        H->>A: answers
        A->>A: create DEVELOPER-PROFILE.md
    end
    A->>A: read PLAN.md — mission scope
    A->>A: read MEMORY.md — existing context
    A->>A: read BACKLOG.md — task status
    A->>H: Session ready
    loop Work
        H->>A: instruction or /command
        A->>A: execute within PLAN.md scope
        A->>A: update MEMORY.md
        A->>H: result
    end
```

---

## Command and agent interactions

```mermaid
flowchart TD
    H([Human])

    H -->|"/review"| RV["reviewer (read-only)"]
    RV --> GD[git diff]
    GD --> R1[Review report]

    H -->|"/test"| TST["tester (Haiku)"]
    TST --> TR[Test runner]
    TR --> R2[Test report]
    R2 -->|failure| BLD[build agent]

    H -->|"/map"| EXP["explorer (read-only)"]
    EXP --> PM[PROJECT-MAP.md]

    H -->|"/compact"| B2[build agent]
    B2 --> MEM["MEMORY.md condensed"]
    B2 --> ARC["memory/archive/"]
```

---

## Memory lifecycle

```mermaid
flowchart LR
    S([Session]) --> M[MEMORY.md]
    M --> C{"500+ lines?"}
    C -->|no| M
    C -->|yes| CP["/compact"]
    CP --> AR["memory/archive/"]
    CP --> M2["MEMORY.md condensed"]
    M2 --> S2([Next session])
```

---

## Get started

### New to OpenCode + GitHub Copilot?

**Step 1 — Install the tools**

```bash
# Install OpenCode
npm install -g opencode-ai

# GitHub Copilot Premium: activate at github.com/features/copilot
# Then authenticate OpenCode with your GitHub account
opencode auth github
```

**Step 2 — Copy the starter into your project**

```bash
git clone https://github.com/[your-username]/opencode-starter .opencode-starter
cp .opencode-starter/templates/PLAN.md ./PLAN.md
cp -r .opencode-starter/.opencode ./.opencode
```

**Step 3 — Write your first PLAN.md**

Don't start with a blank file. Pick an example from [docs/USE-CASES.md](docs/USE-CASES.md), copy the block, and fill in your values. Takes 5 minutes.

See [docs/WRITING-YOUR-PLAN.md](docs/WRITING-YOUR-PLAN.md) for the full guide.

**Step 4 — Start your first session**

```bash
opencode
```

Type `/onboard` — the agent asks 8 calibration questions and creates your developer profile. This runs once, then every session starts directly from your `PLAN.md`.

---

### Already know the stack?

```bash
# 1. Copy this repo into your project
git clone https://github.com/[your-username]/opencode-starter .opencode-starter

# 2. Copy the templates you need
cp .opencode-starter/templates/PLAN.md ./PLAN.md
cp -r .opencode-starter/.opencode ./.opencode

# 3. Write your PLAN.md, open OpenCode, type /onboard
opencode
```

---

## Structure

```
opencode-starter/
│
├── AGENTS.md              ← Agent instructions (80 lines max)
├── ONBOARD.md             ← First-run setup
│
├── templates/             ← Copy these into your project
│   ├── PLAN.md            ← YOU write this before the session. Agent reads it. Read-only.
│   ├── MEMORY.md          ← Agent manages this
│   ├── BACKLOG.md         ← Agent manages this
│   ├── HUMAN.md           ← Your action items, surfaced by agent
│   ├── DEPENDENCIES.md    ← Verified at every session start
│   ├── CLOUD-RESOURCES.md ← Lab vs prod safety map
│   └── DEVELOPER-PROFILE.md ← Your personal calibration
│
├── .opencode/
│   ├── commands/          ← Slash commands
│   │   ├── onboard.md     ← /onboard
│   │   ├── map.md         ← /map
│   │   ├── compact.md     ← /compact
│   │   ├── review.md      ← /review
│   │   └── test.md        ← /test
│   │
│   ├── agents/            ← Specialized sub-agents
│   │   ├── reviewer.md    ← Read-only code reviewer
│   │   ├── tester.md      ← Test writer (Haiku model)
│   │   └── explorer.md    ← Read-only discovery & mapping
│   │
│   └── skills/            ← Domain expertise, loaded on demand
│       ├── azure/
│       │   └── SKILL.md
│       ├── openshift/
│       │   └── SKILL.md
│       └── terraform/
│           └── SKILL.md
│
├── memory/                ← Local only, git-ignored
└── docs/
    ├── PHILOSOPHY.md
    ├── CUSTOMIZE.md
    └── ADVANCED.md
```

---

## Slash commands

| Command | What it does |
|---------|-------------|
| `/onboard` | First-run profile setup. Skips if profile exists. |
| `/map` | Map the project scoped to PLAN.md. Updates PROJECT-MAP.md. |
| `/compact` | Summarize and archive memory when it gets heavy. |
| `/review` | Trigger reviewer agent on modified files. |
| `/test` | Trigger tester agent, run tests, get report. |

---

## Sub-agents

| Agent | Role | Model |
|-------|------|-------|
| `@reviewer` | Code review — read-only, never modifies | Sonnet |
| `@tester` | Tests only — never writes functional code | Haiku |
| `@explorer` | Discovery & mapping — read-only | Sonnet |

**Hard rule on tests:** `@tester` writes tests. `@build` writes code. Never together.
A test is never modified to make it pass. Root cause is reported to human.

---

## Absolute rules

- `PLAN.md` — Read-only. Always. Conflict → flag to human.
- Destructive commands → Show command + target + env + impact. Wait for **"go"**.
- `memory/` → Agent-only. Human doesn't touch it.
- Tests → Never modified to pass. Root cause always reported.

---

## Security

**Run agents with the minimum permissions needed for the task.**

- Use a dedicated service account or sandbox identity — never your personal admin credentials
- In cloud environments: scope IAM/RBAC roles to the target resource group or namespace only
- The agent will always ask for **"go"** before any write operation — never bypass this
- For production access: use read-only credentials by default; grant write only for the specific operation

> This project follows the **read-free / write-gate** principle: read operations run freely, write operations always require explicit human approval.
> See [GUARDRAILS.md](https://guardrails.md/) and the [AGENTS.md standard](https://github.com/agentsmd/agents.md) for the broader conventions this project aligns with.

---

## Customize

See [docs/CUSTOMIZE.md](docs/CUSTOMIZE.md) for the 5-level customization guide.
See [docs/ADVANCED.md](docs/ADVANCED.md) for segmented memory, session versioning, parallel agents, and hooks.

---

## Philosophy

See [docs/PHILOSOPHY.md](docs/PHILOSOPHY.md).

TL;DR: **Keep memory alive.** Memory that grows without control becomes noise.
Create → Enrich → Compact → Archive → Repeat.

---

## Why not LangGraph / CrewAI / framework X?

Those are great for enterprise multi-agent systems.
This is for a solo developer who wants to ship faster without reading 200 pages of docs first.

---

## Built with

- [OpenCode](https://opencode.ai) — AI coding agent built for the terminal
- [GitHub Copilot Premium](https://github.com/features/copilot) — AI pair programmer with advanced models

---

## Contributing

Only field-tested patterns. No theory.
Open an issue with your use case before submitting a PR.

---

## License

MIT
