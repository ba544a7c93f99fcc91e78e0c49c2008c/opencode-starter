---
description: Initial developer profile setup
agent: build
---
Check if `DEVELOPER-PROFILE.md` exists in `~/.config/opencode/` or at the project root.

**If exists** → load the profile, confirm to human, and start the session.

**If missing** → ask the following questions one at a time, conversationally:

1. Preferred language for our exchanges? (English / French / Both)
2. Your main stack? (e.g. C#, Java, Python, TypeScript, Go, DevOps, Fullstack)
3. Your work context? (Backend / Frontend / DevOps / Architect / Fullstack)
4. Patterns you know well? (e.g. dependency injection, CI/CD, microservices, IaC)
5. Preferred detail level in my responses? (Short and direct / Detailed with context)
6. Preferred agent personality? (Pragmatic / Teacher / Challenger / Creative / Mixed)
7. Do you have naming conventions or standards to follow? (If yes, describe the main rules)
8. Cloud environments used? (Azure / OpenShift / AWS / GCP / On-premise / Mixed)

After the answers, create `DEVELOPER-PROFILE.md` with this format:

```markdown
# Developer Profile

## Exchange Language
- [answer]

## Main Stack
- Language: [answer]
- Context: [answer]

## Familiar Patterns
- [list]

## Detail Level
- [answer]

## Agent Personality
- [answer]

## Conventions & Standards
- [answer or "None specified"]

## Cloud Environments
- [list]
```

Save to `~/.config/opencode/DEVELOPER-PROFILE.md` for global reuse across projects.
Confirm to human that the profile is created and the session can start.
