# make.ps1 — opencode-starter
# Equivalent PowerShell script for Windows 10/11 (without WSL or GNU Make).
#
# Usage:  .\make.ps1 [target]
# Targets: test, lint, format, validate, check, map, help (default)
#
# Supported stacks: python · node (JS/TS) · go · rust · dotnet (C#) ·
#   java-maven · java-gradle (Kotlin included) · cmake (C/C++) · php ·
#   swift · ruby · terraform · helm
#
# On WSL/Ubuntu or any system with GNU make: use `make` directly instead.
# On Windows with winget: winget install GnuWin32.Make  then use `make` directly.

param(
    [string]$Target = "help"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"

# ─── Stack detection ──────────────────────────────────────────────────────────

$Stack = "unknown"
if (Test-Path "package.json")                                        { $Stack = "node" }
if (Test-Path "pyproject.toml" -or (Test-Path "setup.py"))          { $Stack = "python" }
if (Test-Path "go.mod")                                              { $Stack = "go" }
if (Test-Path "Cargo.toml")                                          { $Stack = "rust" }
if (Get-ChildItem -Filter "*.csproj" -ErrorAction SilentlyContinue) { $Stack = "dotnet" }
if (Get-ChildItem -Filter "*.sln"    -ErrorAction SilentlyContinue) { $Stack = "dotnet" }
if (Test-Path "pom.xml")                                             { $Stack = "java-maven" }
if (Test-Path "build.gradle" -or (Test-Path "build.gradle.kts"))    { $Stack = "java-gradle" }
if (Test-Path "CMakeLists.txt")                                      { $Stack = "cmake" }
if (Test-Path "composer.json")                                       { $Stack = "php" }
if (Test-Path "Package.swift")                                       { $Stack = "swift" }
if (Test-Path "Gemfile")                                             { $Stack = "ruby" }
# Infrastructure stacks — detected last (highest priority in mixed repos)
if (Test-Path "Chart.yaml")                                          { $Stack = "helm" }
if (Get-ChildItem -Filter "*.tf" -ErrorAction SilentlyContinue)     { $Stack = "terraform" }

# ─── test ─────────────────────────────────────────────────────────────────────

function Invoke-Test {
    switch ($Stack) {
        "python"      { python -m pytest }
        "node"        { npm test }
        "go"          { go test ./... }
        "rust"        { cargo test }
        "dotnet"      { dotnet test }
        "java-maven"  { mvn test }
        "java-gradle" { .\gradlew.bat test }
        "cmake"       { cmake --build build --target test 2>$null; if ($LASTEXITCODE -ne 0) { Write-Host "[test] Configure first: cmake -B build && cmake --build build" } }
        "php"         { if (Test-Path "vendor/bin/phpunit") { .\vendor\bin\phpunit } else { composer test } }
        "swift"       { swift test }
        "ruby"        { bundle exec rspec 2>$null; if ($LASTEXITCODE -ne 0) { bundle exec rake test } }
        "terraform"   { terraform validate; Write-Host "[test] terraform validate passed" }
        "helm"        { helm template . | Out-Null; Write-Host "[test] helm template rendered successfully" }
        default       { Write-Host "[test] Stack '$Stack' not detected."; exit 1 }
    }
}

# ─── lint ─────────────────────────────────────────────────────────────────────

function Invoke-Lint {
    switch ($Stack) {
        "python"      {
            if (Get-Command ruff   -ErrorAction SilentlyContinue) { ruff check . }
            elseif (Get-Command flake8 -ErrorAction SilentlyContinue) { flake8 . }
            else { Write-Host "[lint] Install ruff: pip install ruff" }
        }
        "node"        {
            if (Get-Command eslint -ErrorAction SilentlyContinue) { npx eslint . }
            else { Write-Host "[lint] Install eslint or biome." }
        }
        "go"          { go vet ./... }
        "rust"        { cargo clippy }
        "dotnet"      { dotnet build --no-restore /warnaserror }
        "java-maven"  { mvn checkstyle:check 2>$null; if ($LASTEXITCODE -ne 0) { mvn verify -DskipTests } }
        "java-gradle" { .\gradlew.bat checkstyleMain 2>$null; if ($LASTEXITCODE -ne 0) { .\gradlew.bat build "-x" test } }
        "cmake"       {
            if (Get-Command clang-tidy -ErrorAction SilentlyContinue) { Get-ChildItem -Recurse -Include "*.cpp","*.c" | ForEach-Object { clang-tidy $_.FullName } }
            elseif (Get-Command cppcheck -ErrorAction SilentlyContinue) { cppcheck --enable=all --suppress=missingIncludeSystem . }
            else { Write-Host "[lint] Install clang-tidy or cppcheck" }
        }
        "php"         {
            if (Get-Command phpcs -ErrorAction SilentlyContinue) { phpcs . }
            else { Write-Host "[lint] Install phpcs: composer require --dev squizlabs/php_codesniffer" }
        }
        "swift"       {
            if (Get-Command swiftlint -ErrorAction SilentlyContinue) { swiftlint }
            else { Write-Host "[lint] Install SwiftLint" }
        }
        "ruby"        {
            if (Get-Command rubocop -ErrorAction SilentlyContinue) { bundle exec rubocop }
            else { Write-Host "[lint] Install rubocop: bundle add rubocop" }
        }
        "terraform"   {
            if (Get-Command tflint -ErrorAction SilentlyContinue) { tflint }
            else { terraform validate }
        }
        "helm"        { helm lint . }
        default       { Write-Host "[lint] Stack '$Stack' not detected."; exit 1 }
    }
}

# ─── format ───────────────────────────────────────────────────────────────────

function Invoke-Format {
    switch ($Stack) {
        "python"      {
            if (Get-Command ruff  -ErrorAction SilentlyContinue) { ruff format . }
            elseif (Get-Command black -ErrorAction SilentlyContinue) { black . }
            else { Write-Host "[format] Install ruff: pip install ruff" }
        }
        "node"        {
            if (Get-Command prettier -ErrorAction SilentlyContinue) { npx prettier --write . }
            else { Write-Host "[format] Install prettier or biome." }
        }
        "go"          { gofmt -w . }
        "rust"        { cargo fmt }
        "dotnet"      { dotnet format }
        "java-maven"  { mvn spotless:apply 2>$null; if ($LASTEXITCODE -ne 0) { Write-Host "[format] Add spotless-maven-plugin to pom.xml." } }
        "java-gradle" { .\gradlew.bat spotlessApply 2>$null; if ($LASTEXITCODE -ne 0) { Write-Host "[format] Add com.diffplug.spotless plugin to build.gradle." } }
        "cmake"       {
            if (Get-Command clang-format -ErrorAction SilentlyContinue) { Get-ChildItem -Recurse -Include "*.cpp","*.c","*.h" | ForEach-Object { clang-format -i $_.FullName } }
            else { Write-Host "[format] Install clang-format" }
        }
        "php"         {
            if (Test-Path "vendor/bin/php-cs-fixer") { .\vendor\bin\php-cs-fixer fix . }
            elseif (Get-Command php-cs-fixer -ErrorAction SilentlyContinue) { php-cs-fixer fix . }
            else { Write-Host "[format] composer require --dev friendsofphp/php-cs-fixer" }
        }
        "swift"       {
            if (Get-Command swift-format -ErrorAction SilentlyContinue) { swift-format -i -r . }
            else { Write-Host "[format] Install swift-format" }
        }
        "ruby"        {
            if (Get-Command rubocop -ErrorAction SilentlyContinue) { bundle exec rubocop -a }
            else { Write-Host "[format] Install rubocop: bundle add rubocop" }
        }
        "terraform"   { terraform fmt -recursive }
        "helm"        { Write-Host "[format] Helm charts are YAML — use '.\make.ps1 validate' to check syntax." }
        default       { Write-Host "[format] Stack '$Stack' not detected."; exit 1 }
    }
}

# ─── validate ─────────────────────────────────────────────────────────────────

function Invoke-Validate {
    Write-Host "[validate] Checking JSON files..."
    Get-ChildItem -Recurse -Filter "*.json" | Where-Object {
        $_.FullName -notmatch '\\\.git\\' -and
        $_.FullName -notmatch '\\node_modules\\' -and
        $_.FullName -notmatch '\\\.venv\\' -and
        $_.FullName -notmatch '\\vendor\\' -and
        $_.FullName -notmatch '\\\.terraform\\'
    } | ForEach-Object {
        try {
            Get-Content $_.FullName -Raw | ConvertFrom-Json | Out-Null
            Write-Host "  ok  $($_.FullName)"
        } catch {
            Write-Host "  ERR $($_.FullName)"
        }
    }
    Write-Host "[validate] Checking YAML files..."
    Get-ChildItem -Recurse -Include "*.yml","*.yaml" | Where-Object {
        $_.FullName -notmatch '\\\.git\\' -and
        $_.FullName -notmatch '\\node_modules\\' -and
        $_.FullName -notmatch '\\\.terraform\\'
    } | ForEach-Object {
        # PowerShell has no built-in YAML parser; use python3 if available
        if (Get-Command python3 -ErrorAction SilentlyContinue) {
            $result = python3 -c "import yaml,sys; yaml.safe_load(open('$($_.FullName.Replace('\','\\'))').read())" 2>&1
            if ($LASTEXITCODE -eq 0) { Write-Host "  ok  $($_.FullName)" }
            else { Write-Host "  ERR $($_.FullName): $result" }
        } else {
            Write-Host "  --  $($_.FullName) (install python3 for YAML validation)"
        }
    }
    Write-Host "[validate] Done."
}

# ─── check ────────────────────────────────────────────────────────────────────

function Invoke-Check {
    Write-Host "=== make check: full quality gate ==="
    Invoke-Test;    Write-Host $(if ($LASTEXITCODE -eq 0) { "[test]     PASS" } else { "[test]     FAIL" })
    Invoke-Lint;    Write-Host $(if ($LASTEXITCODE -eq 0) { "[lint]     PASS" } else { "[lint]     FAIL" })
    Invoke-Validate
    Write-Host "=== check complete ==="
}

# ─── map ──────────────────────────────────────────────────────────────────────

function Invoke-Map {
    if (Test-Path ".agent/map_context.sh") {
        if (Get-Command wsl  -ErrorAction SilentlyContinue) { wsl sh .agent/map_context.sh }
        elseif (Get-Command bash -ErrorAction SilentlyContinue) { bash .agent/map_context.sh }
        else { Write-Host "[map] WSL or bash required. Install WSL: wsl --install" }
    }
}

# ─── help ─────────────────────────────────────────────────────────────────────

function Invoke-Help {
    Write-Host "opencode-starter make.ps1"
    Write-Host "Detected stack: $Stack"
    Write-Host ""
    Write-Host "  .\make.ps1 test      Run the project test suite"
    Write-Host "  .\make.ps1 lint      Run the linter"
    Write-Host "  .\make.ps1 format    Auto-format source code"
    Write-Host "  .\make.ps1 validate  Validate JSON and YAML syntax"
    Write-Host "  .\make.ps1 check     Full quality gate (test + lint + validate)"
    Write-Host "  .\make.ps1 map       Generate context snapshot (requires WSL or bash)"
    Write-Host "  .\make.ps1 help      Show this help"
    Write-Host ""
    Write-Host "Supported stacks: python · node (JS/TS) · go · rust · dotnet · java-maven · java-gradle"
    Write-Host "                  cmake (C/C++) · php · swift · ruby · terraform · helm"
    Write-Host ""
    Write-Host "On WSL/Ubuntu: use 'make' directly instead of this script."
    Write-Host "On Windows with winget: winget install GnuWin32.Make"
}

# ─── Dispatch ─────────────────────────────────────────────────────────────────

switch ($Target) {
    "test"     { Invoke-Test }
    "lint"     { Invoke-Lint }
    "format"   { Invoke-Format }
    "validate" { Invoke-Validate }
    "check"    { Invoke-Check }
    "map"      { Invoke-Map }
    "help"     { Invoke-Help }
    default    { Write-Host "Unknown target: $Target. Run .\make.ps1 help"; exit 1 }
}
