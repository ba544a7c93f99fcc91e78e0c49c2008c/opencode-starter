# Makefile — opencode-starter
# Language-agnostic quality targets for AI agent self-correction loop.
# No install dependencies required. Auto-detects stack from project files.
#
# Supported stacks: python · node (JS/TS) · go · rust · dotnet (C#) ·
#   java-maven · java-gradle (Kotlin included) · cmake (C/C++) · php ·
#   swift · ruby · terraform · helm
#
# Agent usage: run `make check` after changes. Read output and self-correct
# before presenting results to human. Circuit breaker: stop after 3 identical failures.
#
# Windows 10/11: use .\make.ps1 (PowerShell) or install GNU Make via winget.
# WSL/Ubuntu: use this Makefile directly.

.PHONY: test lint format validate check map self-test help

# ─── Stack detection ─────────────────────────────────────────────────────────
# Last match wins. Infrastructure stacks (terraform, helm) are last
# so they take precedence when a project contains both code and IaC files.

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
ifneq ($(wildcard CMakeLists.txt),)
  STACK := cmake
endif
ifneq ($(wildcard composer.json),)
  STACK := php
endif
ifneq ($(wildcard Package.swift),)
  STACK := swift
endif
ifneq ($(wildcard Gemfile),)
  STACK := ruby
endif
# Infrastructure stacks — detected last (highest priority in mixed repos)
ifneq ($(wildcard Chart.yaml),)
  STACK := helm
endif
ifneq ($(wildcard main.tf),)
  STACK := terraform
endif
ifneq ($(wildcard *.tf),)
  STACK := terraform
endif

# Node sub-runner detection (jest vs vitest vs npm test)
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
else ifeq ($(STACK),cmake)
	@cmake --build build --target test 2>/dev/null || \
	 ctest --test-dir build 2>/dev/null || \
	 echo "[test] Configure build first: cmake -B build && cmake --build build"
else ifeq ($(STACK),php)
	@command -v phpunit >/dev/null 2>&1 && phpunit || \
	 test -f vendor/bin/phpunit && vendor/bin/phpunit || \
	 composer test 2>/dev/null || \
	 echo "[test] Install phpunit: composer require --dev phpunit/phpunit"
else ifeq ($(STACK),swift)
	swift test
else ifeq ($(STACK),ruby)
	@command -v rspec >/dev/null 2>&1 && bundle exec rspec || \
	 bundle exec rake test 2>/dev/null || \
	 echo "[test] No test runner found. Install rspec: bundle add rspec"
else ifeq ($(STACK),terraform)
	@command -v terratest >/dev/null 2>&1 && go test ./... || \
	 terraform validate && echo "[test] terraform validate passed (add Terratest for unit tests)"
else ifeq ($(STACK),helm)
	helm template . > /dev/null && echo "[test] helm template rendered successfully"
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
else ifeq ($(STACK),cmake)
	@command -v clang-tidy >/dev/null 2>&1 && find . -name '*.cpp' -o -name '*.c' | xargs clang-tidy 2>/dev/null || \
	 command -v cppcheck >/dev/null 2>&1 && cppcheck --enable=all --suppress=missingIncludeSystem . || \
	 echo "[lint] Install clang-tidy or cppcheck for static analysis"
else ifeq ($(STACK),php)
	@command -v phpcs >/dev/null 2>&1 && phpcs . || \
	 php -l $(shell find . -name '*.php' -not -path './vendor/*' | head -20) || \
	 echo "[lint] Install phpcs: composer require --dev squizlabs/php_codesniffer"
else ifeq ($(STACK),swift)
	@command -v swiftlint >/dev/null 2>&1 && swiftlint || \
	 echo "[lint] Install SwiftLint: brew install swiftlint"
else ifeq ($(STACK),ruby)
	@command -v rubocop >/dev/null 2>&1 && bundle exec rubocop || \
	 echo "[lint] Install rubocop: bundle add rubocop"
else ifeq ($(STACK),terraform)
	@command -v tflint >/dev/null 2>&1 && tflint || \
	 terraform validate
else ifeq ($(STACK),helm)
	helm lint .
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
else ifeq ($(STACK),cmake)
	@command -v clang-format >/dev/null 2>&1 \
	 && find . -name '*.cpp' -o -name '*.c' -o -name '*.h' | xargs clang-format -i \
	 || echo "[format] Install clang-format for C/C++ formatting"
else ifeq ($(STACK),php)
	@command -v php-cs-fixer >/dev/null 2>&1 && php-cs-fixer fix . || \
	 test -f vendor/bin/php-cs-fixer && vendor/bin/php-cs-fixer fix . || \
	 echo "[format] Install php-cs-fixer: composer require --dev friendsofphp/php-cs-fixer"
else ifeq ($(STACK),swift)
	@command -v swift-format >/dev/null 2>&1 && swift-format -i -r . || \
	 echo "[format] Install swift-format: brew install swift-format"
else ifeq ($(STACK),ruby)
	@command -v rubocop >/dev/null 2>&1 && bundle exec rubocop -a || \
	 echo "[format] Install rubocop: bundle add rubocop"
else ifeq ($(STACK),terraform)
	terraform fmt -recursive
else ifeq ($(STACK),helm)
	@echo "[format] Helm charts are YAML — use 'make validate' to check syntax."
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
	    -o -path './.terraform' -prune \
	\) -name '*.json' -print | while read f; do \
	    python3 -c "import json; json.load(open('$$f'))" 2>&1 \
	    && echo "  ok  $$f" || echo "  ERR $$f"; \
	done
	@echo "[validate] Checking YAML files..."
	@find . -not \( \
	    -path './.git' -prune \
	    -o -path './node_modules' -prune \
	    -o -path './.venv' -prune \
	    -o -path './vendor' -prune \
	    -o -path './.terraform' -prune \
	\) \( -name '*.yml' -o -name '*.yaml' \) -print | while read f; do \
	    python3 -c "import sys; import yaml; yaml.safe_load(open('$$f'))" 2>&1 \
	    && echo "  ok  $$f" || echo "  ERR $$f"; \
	done 2>/dev/null || true
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

# ─── self-test ────────────────────────────────────────────────────────────────

## self-test: Run opencode-starter structural self-tests (zero dependencies)
self-test:
	@sh tests/run.sh

# ─── help ─────────────────────────────────────────────────────────────────────

## help: Show available targets and detected stack
help:
	@echo "opencode-starter Makefile"
	@echo "Detected stack: $(STACK)"
	@echo ""
	@grep -E '^## [a-z]' Makefile | sed 's/## /  make /'
	@echo ""
	@echo "Supported stacks: python · node (JS/TS) · go · rust · dotnet · java-maven · java-gradle"
	@echo "                  cmake (C/C++) · php · swift · ruby · terraform · helm"
	@echo ""
	@echo "Agent: run 'make check' after changes — self-correct from output before reporting to human."
