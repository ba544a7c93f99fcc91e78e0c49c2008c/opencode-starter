# Makefile — opencode-starter
# Language-agnostic quality targets for AI agent self-correction loop.
# No install dependencies required. Auto-detects stack from project files.
#
# Agent usage: run `make check` after changes. Read output and self-correct
# before presenting results to human. Circuit breaker: stop after 3 identical failures.

.PHONY: test lint format validate check map help

# ─── Stack detection ─────────────────────────────────────────────────────────

STACK := unknown

ifneq ($(wildcard package.json),)
  STACK := node
endif
ifneq ($(wildcard pyproject.toml),)
  STACK := python
endif
ifneq ($(wildcard setup.py),)
  STACK := python
endif
ifneq ($(wildcard go.mod),)
  STACK := go
endif
ifneq ($(wildcard Cargo.toml),)
  STACK := rust
endif
ifneq ($(wildcard *.csproj),)
  STACK := dotnet
endif
ifneq ($(wildcard *.sln),)
  STACK := dotnet
endif
ifneq ($(wildcard pom.xml),)
  STACK := java-maven
endif
ifneq ($(wildcard build.gradle),)
  STACK := java-gradle
endif
ifneq ($(wildcard build.gradle.kts),)
  STACK := java-gradle
endif

ifeq ($(STACK),node)
  ifneq ($(shell grep -l '"vitest"' package.json 2>/dev/null),)
    NODE_TEST := npx vitest run
  else ifneq ($(shell grep -l '"jest"' package.json 2>/dev/null),)
    NODE_TEST := npx jest
  else
    NODE_TEST := npm test
  endif
  ifneq ($(shell which prettier 2>/dev/null),)
    NODE_FORMAT := npx prettier --write .
  else
    NODE_FORMAT := echo "[format] No formatter detected. Install prettier or biome."
  endif
  ifneq ($(shell which eslint 2>/dev/null),)
    NODE_LINT := npx eslint .
  else
    NODE_LINT := echo "[lint] No linter detected. Install eslint or biome."
  endif
endif

# ─── test ─────────────────────────────────────────────────────────────────────

## test: Run the project test suite
test:
ifeq ($(STACK),python)
	python -m pytest
else ifeq ($(STACK),node)
	$(NODE_TEST)
else ifeq ($(STACK),go)
	go test ./...
else ifeq ($(STACK),rust)
	cargo test
else ifeq ($(STACK),dotnet)
	dotnet test
else ifeq ($(STACK),java-maven)
	mvn test
else ifeq ($(STACK),java-gradle)
	./gradlew test
else
	@echo "[test] Stack '$(STACK)' not detected. Add your test command to this Makefile."
	@exit 1
endif

# ─── lint ─────────────────────────────────────────────────────────────────────

## lint: Run the linter
lint:
ifeq ($(STACK),python)
	@command -v ruff >/dev/null 2>&1 && ruff check . || \
	 command -v flake8 >/dev/null 2>&1 && flake8 . || \
	 echo "[lint] No linter found. Install ruff: pip install ruff"
else ifeq ($(STACK),node)
	$(NODE_LINT)
else ifeq ($(STACK),go)
	@command -v golangci-lint >/dev/null 2>&1 && golangci-lint run || go vet ./...
else ifeq ($(STACK),rust)
	cargo clippy
else ifeq ($(STACK),dotnet)
	dotnet build --no-restore /warnaserror
else ifeq ($(STACK),java-maven)
	mvn checkstyle:check 2>/dev/null || mvn verify -DskipTests
else ifeq ($(STACK),java-gradle)
	./gradlew checkstyleMain 2>/dev/null || ./gradlew build -x test
else
	@echo "[lint] Stack '$(STACK)' not detected. Add your lint command to this Makefile."
	@exit 1
endif

# ─── format ───────────────────────────────────────────────────────────────────

## format: Auto-format source code (write operation — requires "go" in prod)
format:
ifeq ($(STACK),python)
	@command -v ruff >/dev/null 2>&1 && ruff format . || \
	 command -v black >/dev/null 2>&1 && black . || \
	 echo "[format] No formatter found. Install ruff: pip install ruff"
else ifeq ($(STACK),node)
	$(NODE_FORMAT)
else ifeq ($(STACK),go)
	gofmt -w .
else ifeq ($(STACK),rust)
	cargo fmt
else ifeq ($(STACK),dotnet)
	dotnet format
else ifeq ($(STACK),java-maven)
	mvn spotless:apply 2>/dev/null || echo "[format] Add spotless-maven-plugin to pom.xml for auto-format."
else ifeq ($(STACK),java-gradle)
	./gradlew spotlessApply 2>/dev/null || echo "[format] Add com.diffplug.spotless plugin to build.gradle for auto-format."
else
	@echo "[format] Stack '$(STACK)' not detected. Add your format command to this Makefile."
	@exit 1
endif

# ─── validate ─────────────────────────────────────────────────────────────────

## validate: Validate JSON and YAML syntax in the project
validate:
	@echo "[validate] Checking JSON files..."
	@find . -not \( \
	    -path './.git' -prune \
	    -o -path './node_modules' -prune \
	    -o -path './.venv' -prune \
	    -o -path './vendor' -prune \
	\) -name '*.json' -print | while read f; do \
	    python3 -c "import json; json.load(open('$$f'))" 2>&1 \
	    && echo "  ok  $$f" || echo "  ERR $$f"; \
	done
	@echo "[validate] Done."

# ─── check ────────────────────────────────────────────────────────────────────

## check: Full quality gate — test + lint + validate (all targets run independently)
check:
	@echo "=== make check: full quality gate ==="
	@$(MAKE) test    && echo "[test]     PASS" || echo "[test]     FAIL"
	@$(MAKE) lint    && echo "[lint]     PASS" || echo "[lint]     FAIL"
	@$(MAKE) validate && echo "[validate] PASS" || echo "[validate] FAIL"
	@echo "=== check complete ==="

# ─── map ──────────────────────────────────────────────────────────────────────

## map: Generate compressed project context snapshot
map:
	@sh .agent/map_context.sh

# ─── help ─────────────────────────────────────────────────────────────────────

## help: Show available targets and detected stack
help:
	@echo "opencode-starter Makefile"
	@echo "Detected stack: $(STACK)"
	@echo ""
	@grep -E '^## [a-z]' Makefile | sed 's/## /  make /'
	@echo ""
	@echo "Agent: run 'make check' after changes — self-correct from output before reporting to human."
