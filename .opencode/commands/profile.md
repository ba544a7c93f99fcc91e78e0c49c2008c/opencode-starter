---
description: "Display the active developer profile and configured agents summary"
agent: build
---
Read and display the current configuration in two sections.

## Section 1 — Developer Profile

Look for `DEVELOPER-PROFILE.md` in this order:
1. Project root (`./DEVELOPER-PROFILE.md`)
2. Global config (`~/.config/opencode/DEVELOPER-PROFILE.md`)

If found, display:
- Name / role
- Experience level and stack
- Agent personality setting
- Language preference
- Any custom instructions

If not found: "No developer profile found. Run `/onboard` to create one."

## Section 2 — Configured Agents

Read all files in `.opencode/agents/`. For each agent, display:

```
@agent-name
  Model    : [model from frontmatter, or "default" if not set]
  Mode     : [subagent / default]
  Edit     : [allowed / denied]
  Bash     : [list of allowed commands, or "unrestricted"]
  Role     : [first sentence of the agent body]
```

Then read all files in `.opencode/commands/`. List each command with its description from frontmatter:

```
/command-name  — [description]
```

## Output format

Keep it compact. No headers beyond the two sections. No prose.
End with: "To update your profile: edit DEVELOPER-PROFILE.md or run `/onboard`."
