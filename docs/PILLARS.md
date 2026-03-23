# Agentic Pillars

Four capability layers added on top of the core opencode-starter system.
Core contract → AGENTS.md. Implementation details → here.

---

## Pillar 1 — AI-First Discoverability (`.agent/`)

**Why:** An agent starting a session on a large codebase wastes tokens exploring
directory by directory. This pillar gives agents structured orientation in seconds.

### `.agent/AGENT_GUIDE.md`

Machine-readable project index using YAML blocks. Distinct from `AGENTS.md`:
- `AGENTS.md` — human-readable rules contract (120-line hard limit)
- `AGENT_GUIDE.md` — structured metadata for AI parsing, no narrative prose

Read at session start when context budget is tight (before AGENTS.md).

### `.agent/map_context.sh`

Shell script generating a compressed snapshot: file tree (depth 3), PLAN.md
first 30 lines, MEMORY.md first 40 lines, backlog, dependency manifest,
memory line count, git context (branch + last 5 commits + modified files).

```bash
sh .agent/map_context.sh    # direct
make map                    # via Makefile
```

No dependencies. No writes. Safe to run at any time.

---

## Pillar 2 — Planning Protocol (`PROPOSAL.md`)

**Why:** PLAN.md is the human's mission declaration. Within a session, some
agent sub-decisions are large enough to require review before execution.
PROPOSAL.md is that review mechanism.

**PLAN.md vs PROPOSAL.md:**

| | PLAN.md | PROPOSAL.md |
|--|---------|-------------|
| Author | Human | Agent |
| Scope | Full mission | One major task |
| Approval | Written before session | Required before execution |
| Read-only for | Agent (never modify) | Nobody — agent writes it |

### When to use `/propose`

Use when the change: touches > 3 files · has deployment or schema impact ·
has non-trivial regression risk · has an ambiguity PLAN.md doesn't resolve.

Skip for: docstring additions, typo fixes, MEMORY.md updates, test files
following existing conventions.

### Workflow

```
/propose → agent drafts PROPOSAL.md → human reviews → "go" → agent executes
```

If execution reveals the proposal was wrong → stop → re-run `/propose` with
updated context. Never proceed on a stale proposal.

---

## Pillar 3 — Self-Correction Loop (`Makefile`)

**Why:** Agents invoking test commands ad hoc produce inconsistent results
across stacks and miss lint/format issues. The Makefile gives every agent
a uniform interface regardless of project language.

### Targets

| Target | Runs |
|--------|------|
| `make test` | pytest · jest/vitest · go test · cargo test · dotnet test · mvn test · gradlew test · ctest · phpunit · swift test · rspec · terraform validate · helm template |
| `make lint` | ruff/flake8 · eslint/biome · golangci-lint · clippy · dotnet /warnaserror · mvn checkstyle · clang-tidy/cppcheck · phpcs · swiftlint · rubocop · tflint · helm lint |
| `make format` | ruff/black · prettier/biome · gofmt · cargo fmt · dotnet format · spotless · clang-format · php-cs-fixer · swift-format · rubocop -a · terraform fmt |
| `make validate` | JSON + YAML syntax (python3 built-ins) |
| `make check` | test + lint + validate — all run independently |
| `make map` | sh .agent/map_context.sh |
| `make help` | Lists targets + detected stack |

Stack auto-detected from manifest file at project root (last match wins):

| Fichier détecté | Stack |
|---|---|
| `package.json` | node (JS + TypeScript) |
| `pyproject.toml` / `setup.py` | python |
| `go.mod` | go |
| `Cargo.toml` | rust |
| `*.csproj` / `*.sln` | dotnet (C#) |
| `pom.xml` | java-maven |
| `build.gradle` / `build.gradle.kts` | java-gradle (Kotlin inclus) |
| `CMakeLists.txt` | cmake (C/C++) |
| `composer.json` | php |
| `Package.swift` | swift |
| `Gemfile` | ruby |
| `Chart.yaml` | helm |
| `*.tf` | terraform |

### Agent self-correction protocol

```
1. Make a change
2. Run: make check
3. Read output
4. Self-correct without asking human
5. If same failure 3 times → stop + report to human (circuit breaker)
```

The 3-attempt circuit breaker matches the existing `@tester` sub-agent behavior.

---

## Pillar 4 — Tool Abstraction (`tools/`)

**Why:** JSON Schema tool definitions allow this project to function as an MCP
tool server. Any MCP host (OpenCode, Claude Desktop, or compatible client) can
read `tools/tools-manifest.json` to discover available operations.

### Available tools

| Tool | Write gate |
|------|------------|
| `run-tests` | No |
| `run-lint` | No |
| `run-format` | Yes — requires "go" |
| `generate-map` | No |
| `scan-security` | No |
| `git-review` | No |

`write_gate: true` mirrors the project's read-free / write-gate principle.
Tools with write impact require the same human "go" as any other write operation.

### Adding a new tool

1. Create `tools/your-tool.json` following the existing schema pattern
2. Add an entry to `tools/tools-manifest.json`
3. Reference the Makefile target or shell command in `invocation`

Keep tools thin — they describe what to invoke, not how to implement it.

### What these are — and what they're not

The files in `tools/` are **JSON Schema descriptors**, not runtime tools.
They describe what an operation does, what inputs it accepts, and whether it writes.

To use them as a live MCP server, you would need to implement an MCP server that serves
these schemas and routes calls to their `invocation` targets. That is out of scope for
this starter — see the [OpenCode MCP docs](https://opencode.ai/docs) for setup.

For lightweight tool execution without a server, use the Makefile targets directly.
