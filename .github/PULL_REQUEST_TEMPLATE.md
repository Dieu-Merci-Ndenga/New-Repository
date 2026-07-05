## Avant d'ouvrir une PR

- Vérifier que la PR ne modifie pas la CI de test ni le runner canonique.
- Si la PR doit changer `CI` ou `tools/run_tests_direct.sh` ou `forge.nimble`,
  ouvrir d'abord une ADR et obtenir une approbation d'architecte.

IMPORTANT: Sprint 1 is under a Validation Freeze. All PRs that change CI,
test runners, or the test execution path must be opened as DRAFT and include
an ADR link. Do not mark as ready for review or merge until the freeze is
explicitly lifted by an ADR.

## Checklist
- [ ] Cette PR n'altère pas la vérité d'exécution des tests (run_tests_direct.sh)
- [ ] Si des changements infra sont nécessaires, une ADR est liée
- [ ] Les tests locaux passent avec `./tools/run_tests_direct.sh`

Notes: Sprint 1 est en 'Validation Freeze' — voir `DECISIONS/SPRINT1_VALIDATION_FREEZE.md`.
