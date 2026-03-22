#!/usr/bin/env sh
# .agent/map_context.sh
# Generates a compressed project context summary for agent session start.
# Usage: sh .agent/map_context.sh
# No dependencies. No writes. Read-only.

echo "=== PROJECT CONTEXT SNAPSHOT ==="
echo "Generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
echo "Directory: $(pwd)"
echo ""

echo "--- FILE TREE (depth 3, excluding .git/node_modules/__pycache__/etc.) ---"
find . -not \( \
    -path './.git' -prune \
    -o -path './node_modules' -prune \
    -o -path './__pycache__' -prune \
    -o -path './.venv' -prune \
    -o -path './vendor' -prune \
    -o -path './target' -prune \
    -o -path './dist' -prune \
    -o -path './build' -prune \
    -o -path './memory/archive' -prune \
\) -maxdepth 3 -print | sort
echo ""

echo "--- MISSION (PLAN.md first 30 lines) ---"
if [ -f PLAN.md ]; then
    head -30 PLAN.md
else
    echo "[PLAN.md not found — run /architect to create one]"
fi
echo ""

echo "--- MEMORY (MEMORY.md first 40 lines) ---"
if [ -f MEMORY.md ]; then
    head -40 MEMORY.md
else
    echo "[MEMORY.md not found]"
fi
echo ""

echo "--- BACKLOG STATUS ---"
if [ -f BACKLOG.md ]; then
    head -30 BACKLOG.md
else
    echo "[BACKLOG.md not found]"
fi
echo ""

echo "--- DEPENDENCY MANIFEST ---"
if [ -f package.json ]; then
    echo "Runtime: Node.js"
    head -20 package.json
elif [ -f pyproject.toml ]; then
    echo "Runtime: Python"
    head -20 pyproject.toml
elif [ -f go.mod ]; then
    echo "Runtime: Go"
    head -20 go.mod
elif [ -f Cargo.toml ]; then
    echo "Runtime: Rust"
    head -20 Cargo.toml
elif [ -f pom.xml ]; then
    echo "Runtime: Java/Maven"
    head -20 pom.xml
else
    echo "[No recognized package manifest found]"
fi
echo ""

echo "--- MEMORY SIZE ---"
if [ -d memory ]; then
    echo "memory/ files:"
    find memory -name '*.md' -not -path 'memory/archive/*' | xargs wc -l 2>/dev/null | tail -1
    echo "Threshold for /compact: 500 lines"
else
    echo "[memory/ directory not present]"
fi
echo ""

echo "--- GIT CONTEXT ---"
if [ -d .git ]; then
    echo "Branch: $(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    echo "Last 5 commits:"
    git log --oneline -5 2>/dev/null
    echo "Modified files:"
    git diff --name-only HEAD 2>/dev/null
else
    echo "[Not a git repository]"
fi
echo ""

echo "=== END CONTEXT SNAPSHOT ==="
