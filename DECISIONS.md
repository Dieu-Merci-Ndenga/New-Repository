# DECISIONS — Journal des décisions architecturales (ADR)

Ce fichier centralise les décisions d'architecture importantes. Chaque décision est enregistrée sous la forme d'un ADR (Architectural Decision Record) numéroté et daté.

Format recommandé pour chaque ADR:

```
# ADR-### - Titre concis
Date: YYYY-MM-DD
Statut: proposed | accepted | deprecated | withdrawn

Contexte:
  Bref contexte et raisons qui posent la décision.

Décision:
  Énoncé clair de la décision prise.

Pourquoi avons-nous choisi X ?
  Arguments en faveur de la solution choisie.

Pourquoi pas Y ?
  Contre-arguments ou raisons d'avoir rejeté une alternative notable (ex: DuckDB).

Pourquoi pas Z ?
  Contre-arguments ou raisons d'avoir rejeté une autre alternative notable (ex: PostgreSQL).

Conséquences:
  Effets attendus, impact sur le code, l'infra, la maintenance et les workflows.

Références:
  Liens vers discussions, issues, PRs ou documents d'analyse.
```

Exemple initial (template rempli) — ADR-001:

```
# ADR-001 - Stockage local pour l'index
Date: 2026-07-05
Statut: proposed

Contexte:
  Nous avons besoin d'un stockage structuré simple pour persister l'index et l'état local lors des futures étapes d'implémentation.

Décision:
  Utiliser SQLite comme stockage embarqué par défaut.

Pourquoi avons-nous choisi SQLite ?
  - Légèreté et facilité d'intégration.
  - Large adoption et stabilité.
  - Requêtes SQL complètes pour évolutivité fonctionnelle future.

Pourquoi pas DuckDB ?
  - DuckDB est optimisé pour les analyses en colonne et les charges OLAP ; notre besoin initial est orienté OLTP/stockage léger.
  - Moins d'intégration mature dans certains environnements embarqués comparé à SQLite.

Pourquoi pas PostgreSQL ?
  - Besoin d'une base serveur et d'une opération d'infra plus lourde pour les contributeurs locaux.
  - Overkill pour les premières itérations et pour un développeur qui souhaite cloner et lancer rapidement.

Conséquences:
  - Les développeurs peuvent démarrer sans infra externe.
  - Si la charge ou le modèle de données évoluent, il faudra prévoir une migration vers une base serveur (ex: PostgreSQL).

Références:
  - Issue #XX (discussion sur le stockage)
```

Procédure:
- Incrémentez le numéro ADR pour chaque nouvelle décision (ADR-002, ADR-003, ...).
- Ajoutez une référence à l'issue/PR correspondante pour traçabilité.

---

Fin du fichier.
# Decisions

## ADR-001

### Pourquoi avons-nous choisi SQLite ?

### Pourquoi pas DuckDB ?

### Pourquoi pas PostgreSQL ?

### Décision

### Conséquences