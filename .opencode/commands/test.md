---
description: Trigger tests and produce a report
agent: tester
subtask: true
---
Identify the test framework used in the project:
- `package.json` → Jest, Vitest, Mocha
- `pyproject.toml` / `setup.py` → pytest
- `*.csproj` → xUnit, NUnit, MSTest
- `go.mod` → go test
- `Cargo.toml` → cargo test

If `$ARGUMENTS` is provided, limit tests to that scope.

**Process:**

1. Run tests with the appropriate command
2. Capture the full output
3. Produce a report:

```
## Test Report — [date]

### Summary
- Total: [N]
- Passed: [N] ✅
- Failed: [N] ❌
- Skipped: [N] ⚠️

### Failed tests
For each failed test:
- Test name
- Exact error
- Probable cause (without modifying the test)

### Verdict
[Pass / Corrections needed]
```

**Absolute rule:** Never modify a test to make it pass. If a test fails, report the cause to the human.
