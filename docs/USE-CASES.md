# Use Cases — Ready-to-Use PLAN.md Examples

Four common scenarios. Copy the block, fill in your specific values, save as `PLAN.md`.

See [WRITING-YOUR-PLAN.md](WRITING-YOUR-PLAN.md) for the full guide on each section.

---

## 1. Fix a Failing Test

```markdown
## Objective
Fix the failing test `tests/api/test_auth.py::test_token_expiry` — find the root cause
and fix the production code. Do not modify the test.

## Scope
### Included
- `src/auth/token.py` — likely source of the bug
- Any file the test directly imports

### Excluded
- Other test files
- Authentication middleware (separate concern)
- Database models

## Implementation Details
- Test must pass with zero modifications to the test file
- If root cause requires a bigger change, stop and report to human before proceeding

## Success Criteria
- [ ] `pytest tests/api/test_auth.py::test_token_expiry` passes
- [ ] No other tests broken (`pytest tests/` passes)
- [ ] Root cause identified and explained in MEMORY.md
```

---

## 2. Add Unit Tests to a Module

```markdown
## Objective
Add unit tests for `src/payments/calculator.py` — cover the main public functions,
targeting 80% line coverage.

## Scope
### Included
- `tests/payments/test_calculator.py` (create if missing)
- `src/payments/calculator.py` (read-only — do not modify)

### Excluded
- Integration tests
- Other modules in src/payments/
- Any fixture changes to conftest.py

## Implementation Details
- Use pytest
- Mock external calls (no real network or DB)
- Test edge cases: zero amounts, negative values, currency mismatch

## Success Criteria
- [ ] `pytest tests/payments/test_calculator.py` passes
- [ ] Coverage for `src/payments/calculator.py` is ≥ 80% (`pytest --cov=src/payments/calculator`)
- [ ] No changes to production code
```

---

## 3. Refactor a File

```markdown
## Objective
Refactor `src/reports/generator.py` — extract helper functions, reduce the main
function below 50 lines. No behavior change.

## Scope
### Included
- `src/reports/generator.py`

### Excluded
- Callers of generator.py (do not change the public interface)
- Tests (tests must pass without modification)
- Other files in src/reports/

## Implementation Details
- Extract private helpers with underscore prefix
- Keep the public function signature identical
- Do not change error handling behavior

## Success Criteria
- [ ] `generate_report()` function is under 50 lines
- [ ] All existing tests pass unchanged (`pytest tests/reports/`)
- [ ] Public interface is identical (same parameters, same return type)
- [ ] No new dependencies introduced
```

---

## 4. Document an API

```markdown
## Objective
Add OpenAPI annotations to all endpoints in `src/api/routes/users.py`.

## Scope
### Included
- `src/api/routes/users.py`

### Excluded
- Other route files
- Business logic — read-only
- Database models

## Implementation Details
- Use FastAPI/Pydantic response_model annotations (already used elsewhere in the project)
- Include 200, 400, 401, 404 response codes where applicable
- Add docstrings for each endpoint function

## Success Criteria
- [ ] All endpoints in users.py have response_model and status_code annotations
- [ ] `GET /docs` renders the users endpoints correctly (manual check)
- [ ] No logic changes (`git diff src/api/routes/users.py` shows only annotations and docstrings)
- [ ] Existing tests pass (`pytest tests/api/test_users.py`)
```
