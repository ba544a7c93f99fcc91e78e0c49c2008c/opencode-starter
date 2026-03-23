---
description: Trigger code review on modified files
agent: reviewer
subtask: true
---
Identify files modified since the last commit:

```bash
git diff --name-only HEAD
```

If no modified files, look for staged files:

```bash
git diff --name-only --cached
```

For each modified file (excluding markdown config files):
- Read the full file
- Analyze the diff (`git diff HEAD -- [file]`)
- Produce a structured review

Review format for each file:

```
## [filename]

### Critical issues
- [list or "None"]

### Minor issues
- [list or "None"]

### Suggestions
- [list or "None"]

### Verdict
✅ Approved | ⚠️ Approved with reservations | ❌ Needs correction
```

Summarize at the end with the overall verdict and priority actions for the human.
