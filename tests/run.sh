#!/usr/bin/env sh
# tests/run.sh — opencode-starter self-test suite
# Tests all 4-pillar additions: file existence, JSON validity, frontmatter,
# map_context.sh behavior, and Makefile stack detection across 13 stacks.
#
# Requirements: sh, python3 (same as make validate), make
# Usage (from project root): sh tests/run.sh
# Zero writes to project files. Temp dirs are cleaned up on exit.

cd "$(dirname "$0")/.." || { echo "ERROR: cannot cd to project root"; exit 1; }
ROOT="$(pwd)"

PASS=0
FAIL=0

_ok()   { PASS=$((PASS+1)); printf '  ok  %s\n' "$1"; }
_fail() { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; }

check() {
    name="$1"; shift
    if "$@" >/dev/null 2>&1; then _ok "$name"; else _fail "$name"; fi
}

# ─── cleanup ──────────────────────────────────────────────────────────────────

TMPROOT=""
cleanup() { [ -n "$TMPROOT" ] && rm -rf "$TMPROOT"; }
trap cleanup EXIT INT TERM

# ─── Group A: File existence ───────────────────────────────────────────────────

printf '\n=== Group A: File existence ===\n'

for f in \
    .agent/AGENT_GUIDE.md \
    .agent/map_context.sh \
    templates/PROPOSAL.md \
    Makefile \
    make.ps1 \
    .opencode/commands/propose.md \
    docs/PILLARS.md \
    tools/tools-manifest.json \
    tools/run-tests.json \
    tools/run-lint.json \
    tools/run-format.json \
    tools/generate-map.json \
    tools/scan-security.json \
    tools/git-review.json; do
    check "exists: $f" test -f "$f"
done

# ─── Group B: Structural invariants ───────────────────────────────────────────

printf '\n=== Group B: Structural invariants ===\n'

AGENTS_LINES=$(wc -l < AGENTS.md 2>/dev/null) || AGENTS_LINES=9999
if [ "$AGENTS_LINES" -le 120 ]; then
    _ok "AGENTS.md line count ≤ 120 (actual: $AGENTS_LINES)"
else
    _fail "AGENTS.md line count ≤ 120 (actual: $AGENTS_LINES — OVER LIMIT)"
fi

PROPOSAL_SECTIONS=$(grep -c '^## ' templates/PROPOSAL.md 2>/dev/null) || PROPOSAL_SECTIONS=0
if [ "$PROPOSAL_SECTIONS" -ge 7 ]; then
    _ok "templates/PROPOSAL.md has ≥ 7 sections (actual: $PROPOSAL_SECTIONS)"
else
    _fail "templates/PROPOSAL.md has ≥ 7 sections (actual: $PROPOSAL_SECTIONS)"
fi

TOOL_COUNT=$(python3 -c "import json; t=json.load(open('tools/tools-manifest.json')); print(len(t['tools']))" 2>/dev/null) || TOOL_COUNT=0
if [ "$TOOL_COUNT" -eq 6 ]; then
    _ok "tools-manifest.json lists exactly 6 tools"
else
    _fail "tools-manifest.json lists exactly 6 tools (actual: $TOOL_COUNT)"
fi

# ─── Group C: JSON validity ────────────────────────────────────────────────────

printf '\n=== Group C: JSON validity ===\n'

for f in \
    tools/run-tests.json \
    tools/run-lint.json \
    tools/run-format.json \
    tools/generate-map.json \
    tools/scan-security.json \
    tools/git-review.json \
    tools/tools-manifest.json; do
    check "valid JSON: $f" python3 -c "import json; json.load(open('$f'))"
done

WG_FORMAT=$(python3 -c "import json; print(json.load(open('tools/run-format.json'))['write_gate'])" 2>/dev/null) || WG_FORMAT=""
if [ "$WG_FORMAT" = "True" ]; then
    _ok "run-format.json write_gate is true"
else
    _fail "run-format.json write_gate is true (actual: $WG_FORMAT)"
fi

for f in \
    tools/run-tests.json \
    tools/run-lint.json \
    tools/generate-map.json \
    tools/scan-security.json \
    tools/git-review.json; do
    WG=$(python3 -c "import json; print(json.load(open('$f'))['write_gate'])" 2>/dev/null) || WG=""
    if [ "$WG" = "False" ]; then
        _ok "$(basename "$f") write_gate is false"
    else
        _fail "$(basename "$f") write_gate is false (actual: $WG)"
    fi
done

# ─── Group D: YAML frontmatter validity ───────────────────────────────────────
# Note: requires PyYAML (python3 -c "import yaml"). If not installed, these tests fail.

printf '\n=== Group D: YAML frontmatter validity ===\n'

python3 -c "
import sys
content = open('.agent/AGENT_GUIDE.md').read()
parts = content.split('---', 2)
if len(parts) < 3:
    sys.exit(1)
import yaml
fm = yaml.safe_load(parts[1])
required = ['schema', 'project', 'type', 'context_budget']
missing = [k for k in required if k not in fm]
if missing:
    sys.exit(1)
" >/dev/null 2>&1 && _ok "AGENT_GUIDE.md frontmatter has required keys" || _fail "AGENT_GUIDE.md frontmatter has required keys"

python3 -c "
import sys
content = open('.opencode/commands/propose.md').read()
parts = content.split('---', 2)
if len(parts) < 3:
    sys.exit(1)
import yaml
fm = yaml.safe_load(parts[1])
if 'description' not in fm or 'agent' not in fm:
    sys.exit(1)
if fm.get('agent') != 'build':
    sys.exit(1)
" >/dev/null 2>&1 && _ok "propose.md frontmatter: description + agent=build" || _fail "propose.md frontmatter: description + agent=build"

for cmd in .opencode/commands/*.md; do
    cmdname=$(basename "$cmd")
    python3 -c "
import sys
content = open('$cmd').read()
parts = content.split('---', 2)
if len(parts) < 3:
    sys.exit(1)
import yaml
fm = yaml.safe_load(parts[1])
if 'description' not in fm:
    sys.exit(1)
" >/dev/null 2>&1 && _ok "command frontmatter: $cmdname" || _fail "command frontmatter: $cmdname"
done

# ─── Group E: map_context.sh behavior ─────────────────────────────────────────

printf '\n=== Group E: map_context.sh behavior ===\n'

MAP_OUT=$(sh .agent/map_context.sh 2>&1) || MAP_OUT=""

for banner in \
    "=== PROJECT CONTEXT SNAPSHOT ===" \
    "--- FILE TREE" \
    "--- MISSION" \
    "--- MEMORY" \
    "--- BACKLOG" \
    "--- DEPENDENCY MANIFEST" \
    "--- MEMORY SIZE" \
    "--- GIT CONTEXT" \
    "=== END CONTEXT SNAPSHOT ==="; do
    if printf '%s\n' "$MAP_OUT" | grep -qF -- "$banner"; then
        _ok "map_context.sh contains: $banner"
    else
        _fail "map_context.sh contains: $banner"
    fi
done

TMPROOT=$(mktemp -d)
FALLBACK_OUT=$(cd "$TMPROOT" && sh "$ROOT/.agent/map_context.sh" 2>&1) || FALLBACK_OUT=""
if printf '%s\n' "$FALLBACK_OUT" | grep -q "\[PLAN.md not found"; then
    _ok "map_context.sh: graceful fallback when PLAN.md missing"
else
    _fail "map_context.sh: graceful fallback when PLAN.md missing"
fi
if printf '%s\n' "$FALLBACK_OUT" | grep -q "\[MEMORY.md not found\]"; then
    _ok "map_context.sh: graceful fallback when MEMORY.md missing"
else
    _fail "map_context.sh: graceful fallback when MEMORY.md missing"
fi
rm -rf "$TMPROOT"; TMPROOT=""

# ─── Group F: Makefile stack detection ────────────────────────────────────────

printf '\n=== Group F: Makefile stack detection ===\n'

test_stack() {
    label="$1"; manifest="$2"; expected="$3"
    TMPROOT=$(mktemp -d)
    cp "$ROOT/Makefile" "$TMPROOT/"
    touch "$TMPROOT/$manifest"
    OUT=$(cd "$TMPROOT" && make help 2>/dev/null) || OUT=""
    rm -rf "$TMPROOT"; TMPROOT=""
    if printf '%s\n' "$OUT" | grep -q "Detected stack: $expected"; then
        _ok "stack: $label → $expected"
    else
        _fail "stack: $label → $expected"
    fi
}

test_stack "package.json"     package.json     node
test_stack "pyproject.toml"   pyproject.toml   python
test_stack "go.mod"           go.mod           go
test_stack "Cargo.toml"       Cargo.toml       rust
test_stack "foo.csproj"       foo.csproj       dotnet
test_stack "pom.xml"          pom.xml          java-maven
test_stack "build.gradle"     build.gradle     java-gradle
test_stack "build.gradle.kts" build.gradle.kts java-gradle
test_stack "CMakeLists.txt"   CMakeLists.txt   cmake
test_stack "composer.json"    composer.json    php
test_stack "Package.swift"    Package.swift    swift
test_stack "Gemfile"          Gemfile          ruby
test_stack "Chart.yaml"       Chart.yaml       helm
test_stack "main.tf"          main.tf          terraform

# Precedence: package.json + Chart.yaml → helm wins (infra stacks detected last)
TMPROOT=$(mktemp -d)
cp "$ROOT/Makefile" "$TMPROOT/"
touch "$TMPROOT/package.json" "$TMPROOT/Chart.yaml"
OUT=$(cd "$TMPROOT" && make help 2>/dev/null) || OUT=""
rm -rf "$TMPROOT"; TMPROOT=""
if printf '%s\n' "$OUT" | grep -q "Detected stack: helm"; then
    _ok "stack precedence: package.json + Chart.yaml → helm wins"
else
    _fail "stack precedence: package.json + Chart.yaml → helm wins"
fi

# Unknown stack (empty dir)
TMPROOT=$(mktemp -d)
cp "$ROOT/Makefile" "$TMPROOT/"
OUT=$(cd "$TMPROOT" && make help 2>/dev/null) || OUT=""
rm -rf "$TMPROOT"; TMPROOT=""
if printf '%s\n' "$OUT" | grep -q "Detected stack: unknown"; then
    _ok "stack: empty dir → unknown"
else
    _fail "stack: empty dir → unknown"
fi

# ─── Summary ──────────────────────────────────────────────────────────────────

printf '\n=== RESULTS ===\n'
printf '  PASS: %d\n' "$PASS"
printf '  FAIL: %d\n' "$FAIL"
printf '\n'

if [ "$FAIL" -eq 0 ]; then
    printf 'All tests passed.\n'
    exit 0
else
    printf 'Some tests FAILED. See output above.\n'
    exit 1
fi
