# PLAN.md
> ⚠️ This file is READ-ONLY. The agent never modifies it.
> Replace this with your own mission when you start a new project.

---

## Objective

Maintain and evolve opencode-starter as a field-tested governance layer for OpenCode agents.
Keep all 4 agentic pillars consistent, documented, and self-verified.

## Scope

### Included
- AGENTS.md contract and its guardrails
- The 4 agentic pillars: `.agent/`, `PROPOSAL.md`, `Makefile`, `tools/`
- Documentation in `docs/` and `README.md`
- Self-test suite in `tests/run.sh`

### Excluded
- Application code — this is a starter kit, not an application
- External runtime dependencies beyond python3 and make
- CI/CD pipeline

## Implementation Details

- POSIX sh for all shell scripts — no bash-isms
- No external dependencies: python3 (system-level) is the only requirement beyond make
- Makefile auto-detects 13 language stacks via manifest file
- Self-test suite (`make self-test`) verifies structural invariants after every change

## Success Criteria

- [ ] `make self-test` passes with 0 failures
- [ ] AGENTS.md stays under 120 lines
- [ ] All `tools/*.json` are valid JSON
- [ ] All `.opencode/commands/*.md` have valid YAML frontmatter
- [ ] Documentation in README.md matches actual implementation

## References

- [docs/PILLARS.md](docs/PILLARS.md) — 4-pillar architecture details
- [docs/PHILOSOPHY.md](docs/PHILOSOPHY.md) — founding principles
- [AGENTS.md](AGENTS.md) — agent contract (120-line hard limit)
