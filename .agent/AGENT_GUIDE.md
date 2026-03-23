---
schema: agent-guide/1.0
project: opencode-starter
type: starter-kit
context_budget: low
---

# Agent Guide

> Machine-readable index. Prose docs → AGENTS.md, docs/
> This file: structured metadata + fast session orientation only.

## Identity

- Role: OpenCode-native AI agent starter kit
- Contract: AGENTS.md (120-line hard limit)
- Memory: MEMORY.md (session) · memory/ (archive)
- Mission source: PLAN.md (read-only — never modify)

## Session Start Sequence

```yaml
sequence:
  0: .agent/AGENT_GUIDE.md    # this file — skip if context is abundant
  1: DEVELOPER-PROFILE.md     # calibrate language + personality
  2: PLAN.md                  # mission scope — read-only
  3: MEMORY.md                # existing context
  4: BACKLOG.md               # task status
  5: HUMAN.md                 # pending human actions
  6: CLOUD-RESOURCES.md       # if present
  7: DEPENDENCIES.md          # verify versions
```

If DEVELOPER-PROFILE.md missing → `/onboard` before anything else.

## Key Constraints

```yaml
rules:
  PLAN.md: never_modify
  write_gate: show_command + target + env + impact → wait for "go"
  tests: tester_writes_tests · code_never_modifies_tests
  memory_threshold: compact_at_500_lines
  AGENTS.md_ceiling: 120_lines
```

## File Roles

```yaml
files:
  PLAN.md:            { role: mission_source,        writable: false }
  PROPOSAL.md:        { role: pre_change_proposal,   writable: agent_draft_human_approve }
  MEMORY.md:          { role: session_memory,        writable: agent_only }
  BACKLOG.md:         { role: task_tracking,         writable: agent_only }
  HUMAN.md:           { role: human_actions,         writable: agent_only }
  PROJECT-MAP.md:     { role: codebase_map,          writable: agent_only }
  CLOUD-RESOURCES.md: { role: cloud_inventory,       writable: with_confirmation }
  DEPENDENCIES.md:    { role: version_tracking,      writable: on_commit }
```

## Available Tools

```yaml
commands: [onboard, architect, map, compact, review, test, debug, propose, profile, joke]
agents:   [reviewer, tester, explorer]
skills:   [azure, openshift, terraform]
makefile: [test, lint, format, validate, check, map, help]
tools_manifest: tools/tools-manifest.json
```

## Context Optimization

Run `sh .agent/map_context.sh` (or `make map`) at session start when
the codebase is large. Output: compressed snapshot under ~200 lines.

## Pre-change Protocol

For changes touching > 3 files or with regression risk:
1. Draft PROPOSAL.md using `templates/PROPOSAL.md` (or run `/propose`)
2. Present to human for approval
3. Proceed only after explicit "go"
