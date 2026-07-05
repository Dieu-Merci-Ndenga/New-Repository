**Dependency Firewall — Règles et structure**

- **Objectif**: rendre impossible techniquement l'import direct ou transitif d'implémentations d'infrastructure (`git.impl_cli`, `git.impl_libgit2`, `git_engine`, ...) depuis n'importe quel fichier hors de `src/git`.

- **Structure de dossiers finale (exemple)**
  - `src/` : code principal
    - `src/cli` : code CLI minimal (utilise uniquement `src/git` public)
    - `src/app` : application/domain (utilise uniquement `src/git` public)
    - `src/git` : couche d'infrastructure publique + impl internes
      - `src/git/engine.nim` : SEULE API publique pour l'infra Git (isRepository, open, close, head, branches, commits)
      - `src/git/impl_cli.nim` : prototype CLI-backed implementation (internal)
      - `src/git/impl_libgit2.nim` : future native impl (internal)
  - `experimental/` : prototypes isolés (ne doivent pas être utilisés en production)
  - `tests/` : tests (doivent utiliser uniquement `src/git` public)
  - `tools/` : scripts de validation

- **Règles CI exactes**
  - Étape `Import rule check`: exécute `tools/import_rule_check.sh`.
  - `import_rule_check.sh` effectue:
    1. scan textuel rapide pour tokens interdits (`git_engine`, `impl_cli`, `impl_libgit2`) dans tous les fichiers `.nim` hors `src/git` — échec immédiat si trouvé.
    2. exécution de `tools/validate_import_graph.py` pour détecter chemins transitifs d'import jusqu'à des modules interdits.
  - Toute détection provoque un échec CI bloquant la PR.

- **Interdictions automatisées**
  - Aucun fichier en dehors de `src/git` ne peut importer — directement ou transitivement — `git.impl_cli`, `git.impl_libgit2`, `git_engine` ou tout module d'implémentation infra.
  - Les tests doivent suivre la même règle (ils doivent utiliser `src/git/engine.nim`).

- **Procédure de dérogation**
  - Toute dérogation nécessite un ADR (Architectural Decision Record) et approbation.

- **Outils inclus**
  - `tools/import_rule_check.sh` : script shell pour CI (rapide + appelle le validateur de graphe).
  - `tools/validate_import_graph.py` : analyse transitive des imports et rapports de chaînes de dépendance.

Mise en application: exécuter localement `bash tools/import_rule_check.sh` puis corriger les violations indiquées.
