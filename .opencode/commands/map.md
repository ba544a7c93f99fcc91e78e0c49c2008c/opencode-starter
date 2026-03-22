---
description: Map the project scoped to PLAN.md
agent: explorer
---
Read `PLAN.md` to identify the mission scope.

Explore the project structure within the scope defined in PLAN.md:
- Main directories and files
- Entry points (main, index, entrypoints)
- Key modules and dependencies
- Important configuration files

Generate or update `PROJECT-MAP.md` with this format:

```markdown
# PROJECT-MAP.md
> Generated on [date]. Scope: [scope from PLAN.md]

## Main Structure
[annotated tree of key folders and files]

## Entry Points
[list of entrypoints]

## Key Modules
[list with role of each module]

## External Dependencies
[list of important dependencies]

## Notes
[relevant observations for the mission]
```

If an argument is provided (`$ARGUMENTS`), limit the scan to that subdirectory.
