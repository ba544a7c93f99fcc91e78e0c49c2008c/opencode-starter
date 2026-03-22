# make.ps1 — opencode-starter
# Equivalent PowerShell script for Windows 10/11 (without WSL or GNU Make).
#
# Usage:  .\make.ps1 [target]
# Targets: test, lint, format, validate, check, map, help (default)
#
# On WSL/Ubuntu or any system with GNU make: use `make` directly instead.
# On Windows with winget:  winget install GnuWin32.Make  then use `make` directly.

param(
    [string]$Target = "help"
)

# ─── Stack detection ──────────────────────────────────────────────────────────

$Stack = "unknown"
if (Test-Path "package.json")                            { $Stack = "node" }
if (Test-Path "pyproject.toml" -or Test-Path "setup.py"){ $Stack = "python" }
if (Test-Path "go.mod")                                  { $Stack = "go" }
if (Test-Path "Cargo.toml")                              { $Stack = "rust" }
if (Get-ChildItem -Filter "*.csproj" -ErrorAction SilentlyContinue) { $Stack = "dotnet" }
if (Get-ChildItem -Filter "*.sln"    -ErrorAction SilentlyContinue) { $Stack = "dotnet" }
if (Test-Path "pom.xml")                                 { $Stack = "java-maven" }
if (Test-Path "build.gradle" -or Test-Path "build.gradle.kts") { $Stack = "java-gradle" }

# ─── Targets ──────────────────────────────────────────────────────────────────

function Invoke-Test {
    switch ($Stack) {
        "python"      { python -m pytest }
        "node"        { npm test }
        "go"          { go test ./... }
        "rust"        { cargo test }
        "dotnet"      { dotnet test }
        "java-maven"  { mvn test }
        "java-gradle" { .\gradlew.bat test }
        default       { Write-Host "[test] Stack '$Stack' not detected."; exit 1 }
    }
}

function Invoke-Lint {
    switch ($Stack) {
        "python"      { if (Get-Command ruff -ErrorAction SilentlyContinue) { ruff check . } elseif (Get-Command flake8 -ErrorAction SilentlyContinue) { flake8 . } else { Write-Host "[lint] Install ruff: pip install ruff" } }
        "node"        { if (Get-Command eslint -ErrorAction SilentlyContinue) { npx eslint . } else { Write-Host "[lint] Install eslint or biome." } }
        "go"          { go vet ./... }
        "rust"        { cargo clippy }
        "dotnet"      { dotnet build --no-restore /warnaserror }
        "java-maven"  { mvn checkstyle:check 2>$null; if ($LASTEXITCODE -ne 0) { mvn verify -DskipTests } }
        "java-gradle" { .\gradlew.bat checkstyleMain 2>$null; if ($LASTEXITCODE -ne 0) { .\gradlew.bat build -x test } }
        default       { Write-Host "[lint] Stack '$Stack' not detected."; exit 1 }
    }
}

function Invoke-Format {
    switch ($Stack) {
        "python"      { if (Get-Command ruff -ErrorAction SilentlyContinue) { ruff format . } elseif (Get-Command black -ErrorAction SilentlyContinue) { black . } else { Write-Host "[format] Install ruff: pip install ruff" } }
        "node"        { if (Get-Command prettier -ErrorAction SilentlyContinue) { npx prettier --write . } else { Write-Host "[format] Install prettier or biome." } }
        "go"          { gofmt -w . }
        "rust"        { cargo fmt }
        "dotnet"      { dotnet format }
        "java-maven"  { mvn spotless:apply 2>$null; if ($LASTEXITCODE -ne 0) { Write-Host "[format] Add spotless-maven-plugin to pom.xml." } }
        "java-gradle" { .\gradlew.bat spotlessApply 2>$null; if ($LASTEXITCODE -ne 0) { Write-Host "[format] Add com.diffplug.spotless plugin to build.gradle." } }
        default       { Write-Host "[format] Stack '$Stack' not detected."; exit 1 }
    }
}

function Invoke-Validate {
    Write-Host "[validate] Checking JSON files..."
    Get-ChildItem -Recurse -Filter "*.json" -Exclude ".git","node_modules",".venv","vendor" | ForEach-Object {
        try {
            Get-Content $_.FullName | ConvertFrom-Json | Out-Null
            Write-Host "  ok  $($_.FullName)"
        } catch {
            Write-Host "  ERR $($_.FullName)"
        }
    }
    Write-Host "[validate] Done."
}

function Invoke-Check {
    Write-Host "=== make check: full quality gate ==="
    Invoke-Test;    if ($LASTEXITCODE -eq 0) { Write-Host "[test]     PASS" } else { Write-Host "[test]     FAIL" }
    Invoke-Lint;    if ($LASTEXITCODE -eq 0) { Write-Host "[lint]     PASS" } else { Write-Host "[lint]     FAIL" }
    Invoke-Validate
    Write-Host "=== check complete ==="
}

function Invoke-Map {
    if (Test-Path ".agent/map_context.sh") {
        # WSL available
        if (Get-Command wsl -ErrorAction SilentlyContinue) {
            wsl sh .agent/map_context.sh
        } elseif (Get-Command bash -ErrorAction SilentlyContinue) {
            bash .agent/map_context.sh
        } else {
            Write-Host "[map] WSL or bash required for map_context.sh on Windows."
            Write-Host "      Install WSL: wsl --install"
        }
    }
}

function Invoke-Help {
    Write-Host "opencode-starter make.ps1"
    Write-Host "Detected stack: $Stack"
    Write-Host ""
    Write-Host "  .\make.ps1 test      Run the project test suite"
    Write-Host "  .\make.ps1 lint      Run the linter"
    Write-Host "  .\make.ps1 format    Auto-format source code"
    Write-Host "  .\make.ps1 validate  Validate JSON syntax"
    Write-Host "  .\make.ps1 check     Full quality gate (test + lint + validate)"
    Write-Host "  .\make.ps1 map       Generate context snapshot (requires WSL or bash)"
    Write-Host "  .\make.ps1 help      Show this help"
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
