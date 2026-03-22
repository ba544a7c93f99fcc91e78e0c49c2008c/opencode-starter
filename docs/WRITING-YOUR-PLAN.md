# Writing Your PLAN.md

## The rule

Write it before the session. Not during.

---

## Why before?

An agent that starts a session without a clear plan will ask clarifying questions, make assumptions, and drift. Context contamination is the agent's primary enemy — a PLAN.md written mid-session carries the noise of an already-running context. Write the plan when your head is clear, before you open OpenCode.

---

## Use an AI to draft it

Don't write it alone. Paste this prompt into Claude.ai, ChatGPT, or any AI assistant:

```
I'm about to start a coding session with an AI agent.
Help me write a structured PLAN.md. Ask me questions one at a time:
what I want to build, what's in scope, what's explicitly excluded,
the technical constraints I already know, and how I'll know when it's done.
```

The AI asks questions. You answer. It writes the plan. You paste it into `PLAN.md` and open OpenCode.

This takes 5–10 minutes and saves hours of course correction.

---

## What each section needs

### Objective

One precise sentence. A specific outcome, not a category.

| | Example |
|--|---------|
| ✗ | `Improve the API` |
| ✅ | `Add rate limiting to the public REST API — 100 requests/minute per API key, returning HTTP 429 with a Retry-After header` |

The agent uses this as the north star for every decision it makes.

### Scope — Included

List the exact files, modules, or endpoints the agent should touch. The more specific, the better.

```
- Middleware in src/api/middleware/
- Redis-backed counter using src/lib/redis.ts (existing client)
- Unit tests for the middleware
```

### Scope — Excluded

List what the agent must NOT touch, even if it looks related. This is as important as what's included.

```
- Admin API endpoints (internal only, no rate limiting needed)
- Frontend changes
- Modifying the Redis client or connection pool
```

Without explicit exclusions, the agent may "improve" things you didn't ask it to touch.

### Implementation Details

Technical decisions you've already made. The agent should not reinvent what you decided.

```
- Use sliding window algorithm (not fixed window — see ADR-012)
- API key extracted from Authorization: Bearer header
- Existing redis client already handles connection errors
```

If you leave this empty, the agent will make these choices for you — and may choose wrong.

### Success Criteria

Binary checkboxes. Each item must be verifiable by running a command or reading output.

```
- [ ] 100 requests/minute per key enforced
- [ ] HTTP 429 + Retry-After header returned on excess requests
- [ ] Unit tests pass
- [ ] No regression on admin API endpoints
```

Vague criteria like "it works" are useless. The agent needs to know when to stop.

### References

Links to ADRs, tickets, external docs, or specs the agent needs for context.

```
- ADR-012: rate limiting algorithm decision
- https://redis.io/docs/manual/patterns/rate-limiting/
- Linear ticket: ENG-4521
```

---

## Good vs. Bad — the same feature

### Bad PLAN.md

```markdown
## Objective
Improve the API.

## Scope
### Included
- API stuff

## Success Criteria
- [ ] It works
```

**What happens:** The agent asks 10 clarifying questions. Makes assumptions that don't match your intent. You spend the session course-correcting instead of shipping.

---

### Good PLAN.md (same feature)

```markdown
## Objective
Add rate limiting to the public REST API — 100 requests/minute per API key,
returning HTTP 429 with a Retry-After header.

## Scope
### Included
- Middleware in src/api/middleware/
- Redis-backed counter using src/lib/redis.ts (existing client)
- Unit tests for the middleware

### Excluded
- Admin API endpoints (internal only, no rate limiting needed)
- Frontend changes
- Modifying the Redis client

## Implementation Details
- Sliding window algorithm (not fixed window — see ADR-012)
- API key extracted from Authorization: Bearer header
- Existing redis client already handles connection errors

## Success Criteria
- [ ] 100 req/min per key enforced
- [ ] HTTP 429 + Retry-After header returned on excess
- [ ] Unit tests pass
- [ ] No changes to admin API behavior

## References
- ADR-012: rate limiting decision
- https://redis.io/docs/manual/patterns/rate-limiting/
```

**What happens:** The agent goes straight to `src/api/middleware/`, uses the right algorithm, touches nothing outside scope, and stops when the checklist is complete.

---

## Pre-session checklist

Before opening OpenCode:

- [ ] Objective is one specific outcome, not a category
- [ ] Included scope lists exact files or modules
- [ ] Excluded scope has at least one explicit boundary
- [ ] Technical decisions are written down, not left to the agent
- [ ] Every success criterion is binary and verifiable by a command or output

---

## See also

[docs/USE-CASES.md](USE-CASES.md) — 4 ready-to-use PLAN.md examples for common scenarios (fix test, add tests, refactor, document API).
