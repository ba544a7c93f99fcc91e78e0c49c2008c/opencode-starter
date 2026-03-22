# ONBOARD.md
> Run once at the start of a new project.
> If DEVELOPER-PROFILE.md already exists → skip this file.

---

## Instructions for the agent

Check if `DEVELOPER-PROFILE.md` exists in `~/.config/opencode/` or at the project root.

**If exists** → load the profile, confirm to human, and start the session.
**If missing** → ask the questions below one at a time, create the file, then start.

---

## Calibration Questions

Ask these questions conversationally, one at a time.

```
1. Preferred language for our exchanges?
   → English / French / Both

2. Your main stack?
   → e.g. C#, Java, Python, TypeScript, Go, DevOps, Fullstack...

3. Your work context?
   → Backend / Frontend / DevOps / Architect / Fullstack

4. Patterns you know well?
   → e.g. dependency injection, CI/CD, microservices, IaC...

5. Preferred detail level in my responses?
   → Short and direct / Detailed with context

6. Preferred agent personality?
   → Pragmatic / Teacher / Challenger / Creative / Mixed

7. Do you have naming conventions or standards to follow?
   → If yes, provide the document or describe the main rules.

8. Cloud environments used?
   → Azure / OpenShift / AWS / GCP / On-premise / Mixed
```

---

## Generated File

After answers, create `DEVELOPER-PROFILE.md` with this format:

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

> Save to `~/.config/opencode/DEVELOPER-PROFILE.md` for global reuse across projects.
