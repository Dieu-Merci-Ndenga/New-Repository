Sprint 1 Validation Freeze — ACTIVE
=================================

State: ACTIVE

Start: 2026-07-05

Scope:
- No modifications to CI test execution path (`.github/workflows/ci.yml`,
  `tools/run_tests_direct.sh`, `forge.nimble` test task) without an ADR and
  written approval from an architect/maintainer.

Enforcement:
- PRs that modify CI or test runners must be opened as DRAFT and include an
  ADR link explaining the rationale.
- The PR template enforces this by reminding contributors.

Observation period:
- Minimum 2 business cycles (configurable by maintainers).

Lift procedure:
1. Create ADR describing why freeze should be lifted.
2. Obtain approval from an architect/maintainer.
3. Update DECISIONS/SPRINT1_VALIDATION_FREEZE.md with the lift details.
