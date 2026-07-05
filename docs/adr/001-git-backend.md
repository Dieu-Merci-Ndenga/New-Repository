# ADR-001 — Choix du backend Git

Date: 2026-07-05

Statut: accepted

Contexte
---------
Forge doit disposer d'un moteur Git fiable, reproductible et performant qui serve de fondation à tout le reste du projet. Le Sprint 1 exige une API minimale et stable fournie par un unique Git Engine. Nous devons décider quel mécanisme d'accès au contenu Git sera supporté par l'implémentation infra.

Options considérées
--------------------
1. CLI `git` — invoquer l'exécutable `git` et parser sa sortie.
2. `libgit2` — utiliser une implémentation native (bibliothèque C) exposée à Nim via binding/FFI.
3. FFI minimal maison — écrire une petite couche C/FFI qui n'expose que les fonctions strictement nécessaires.

Décision
---------
Nous choisissons : **libgit2** comme backend officiel pour Forge.

Résumé: l'Engine doit exposer une abstraction stable (`GitEngine`) ; l'implémentation infra devra, à terme, reposer sur `libgit2` et rester encapsulée derrière cette abstraction. Aucun autre module du dépôt ne doit importer ou appeler directement l'API C de `libgit2`.

Motivation (pour Sprint 1 et au‑delà)
-----------------------------------
- Robustesse fonctionnelle : `libgit2` implémente le protocole Git de façon exhaustive, stable et testée par la communauté ; il évite les erreurs de parsing et les cas limites que produit l'appel direct à `git`.
- Performance : `libgit2` offre un accès natif aux objets Git (lecture mémoire, parcours d'objet, accès au DAG) avec un coût moindre que le parsing répétitif du CLI, ce qui est important pour les futures analyses (même si nous n'optimisons pas maintenant).
- Contrôle sémantique : `libgit2` rend accessible des primitives Git correctes (objets, refs, objets pack) au lieu de dépendre des formats textuels changeants du CLI.
- Portabilité et intégration : la bibliothèque est largement utilisée et disponible sur les principales plateformes ; l'intégration native facilite la maintenance long terme.

Alternatives rejetées (et pourquoi)
----------------------------------
- CLI `git`: rejetée comme stratégie long terme.
  - Pourquoi rejetée : parsing fragile, dépendance aux locales et à la version de `git`, risques de sécurité si des chemins contiennent des caractères malicieux, et performances limitées pour parcours massifs. Pour du prototypage très court terme, le CLI reste une option acceptable temporaire, mais il ne devient pas la base officielle du projet.

- FFI minimal maison: rejetée comme stratégie principale.
  - Pourquoi rejetée : écrire et maintenir une C-FFI maison expose le projet à coûts d'ingénierie importants (gestion des formats Git, maintenance de compatibilité, tests). `libgit2` existe précisément pour éviter ce travail. Une FFI minimale n'est justifiée que si aucun binding maintenu n'existe et qu'un intermédiaire léger est requis pour lier `libgit2` proprement à Nim.

Conséquences de la décision
---------------------------
- Implémentation infra : nous devons fournir une implémentation `impl_libgit2` qui reste entièrement encapsulée dans `src/git/impl_libgit2.nim` (ou dossier équivalent). Le reste de l'application utilisera uniquement l'interface `src/git/engine.nim`.
- Abstraction stricte : imposer la règle de dépendance — aucun import direct des modules `impl_libgit2` ou des bindings C en dehors de `src/git/*impl*`.
- Tests et CI : ajouter des tests d'API et une étape CI qui empêche les imports interdits (lint d'import) afin d'empêcher les régressions architecturales.
- Travail initial requis : valider l'état de l'écosystème Nim (binding maintenu ou nécessité d'écrire une petite couche FFI). Si un binding Nim stable existe et couvre nos besoins, l'intégration se fera via ce binding ; sinon, écrire un adaptateur C minimal qui encapsule `libgit2` (ce dernier cas est un plan B).

Plan d'action minimal (Sprint 1 compliant)
-----------------------------------------
1. Rédiger et valider le contrat public `GitEngine` (signé) — micro‑sprint 3.
2. Écrire l'ADR (ce document) et le commiter — terminé.
3. Avant implémentation de `impl_libgit2` : vérifier localement ou via CI la disponibilité d'un binding Nim maintenu et compatible avec la version système de `libgit2` (étape de recherche et validation). Si le binding est valide, utiliser ce binding. Si aucun binding acceptable n'existe, écrire un adaptateur C minime pour `libgit2` (FFI) et l'encapsuler dans `src/git/impl_libgit2.nim`.
4. Pour prototypage rapide uniquement (si nécessaire) : autoriser temporairement une impl CLI (`src/git/impl_cli.nim`), marquée comme 'prototype' et strictement isolée. Cette impl CLI ne doit pas être référence définitive et ne doit pas être importée hors du dossier `src/git`.

Critères d'acceptation de l'ADR
-------------------------------
- Document `docs/adr/001-git-backend.md` ajouté et accepté (ce fichier).  
- L'équipe accepte la stratégie « libgit2 encapsulé » comme direction officielle.  
- Un plan de validation des bindings Nim est documenté et approuvé (étape suivante).  
- Une règle CI est planifiée pour empêcher imports infra hors place prévue.

Risques et mitigations
----------------------
- Risque : bindings Nim pour `libgit2` obsolètes ou insuffisants.  
  - Mitigation : écrire un adaptateur C minimal (plan B) ; encapsuler et tester fortement.  
- Risque : intégration native plus lourde en temps initial.  
  - Mitigation : conserver une impl CLI prototype pour validation fonctionnelle rapide, mais ne pas la promouvoir en production.  
- Risque : bugs ou fuites mémoire via FFI.  
  - Mitigation : tests unitaires stricts, revues de sécurité mémoire et CI avec sanitizers si possible (dans étapes ultérieures).

Notes opérationnelles
---------------------
- L'ADR n'impose pas que l'implémentation soit écrite en C : l'utilisation d'un binding Nim maintenu est préférée quand disponible.  
- La direction d'usage est claire : `GitEngine` (interface) ← `src/git/impl_libgit2` (infra) ← libgit2 (C). Aucune autre dépendance ne doit traverser cette frontière.

Références
----------
- Décision architecte projet (Lead Architect) — 2026-07-05

---

Fin de l'ADR-001
