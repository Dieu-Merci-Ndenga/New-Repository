# Sprint 1 — Validation Freeze

But: geler la validation et l'infrastructure de test pour Sprint 1 — aucune
modification structurelle (CI, runner, forge.nimble, scripts de test) sans
procédure d'exception formelle.

Règles actives (immédiates):

- **Aucune modification** de `.github/workflows/ci.yml` concernant l'exécution
  des tests sauf ADR approuvée.
- **`tools/run_tests_direct.sh`** est le seul runner autorisé pour les tests.
  Ne pas ajouter de nouveaux scripts d'exécution des tests.
- **`forge.nimble`** reste en état `fail-fast` pour la tâche `test`.
- **`src/git/experimental/**`** est strictement expérimental et ne doit pas
  influencer la livraison de Sprint 1. Aucun promoton sans ADR.

Processus d'exception:

1. Ouvrir une ADR décrivant la nécessité et l'impact.
2. Rassembler approbation écrite d'au moins un mainteneur/architecte.
3. Mettre à jour la DECISION et documenter la réversion du gel.

Indicateurs de révision:

- PR qui modifie CI, `run_tests_direct.sh`, `forge.nimble`, ou ajoute des
  scripts de test doit être marquée `Do not merge` jusqu'à approbation.

Durée:

Ce gel est effectif immédiatement et restera en place jusqu'à levée
expresse via ADR et approbation explicite.
