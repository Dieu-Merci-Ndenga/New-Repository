# Git Engine — Contrat public (Sprint 1)

Ce document définit le contrat public et minimal du Git Engine pour Forge (Sprint 1). Il est contraignant : toute implémentation doit respecter ces signatures et garanties. Ce contrat couvre uniquement les fonctions nécessaires pour Sprint 1.

Règles générales
- L'Engine est l'unique point d'accès à Git. Aucune autre partie du code ne doit interroger directement `git` ou `libgit2`.
- Toutes les erreurs publiques sont des types d'exception nommés. Aucune exception ne doit être une chaîne.
- Le contrat est minimal : seules les fonctions exposées ci‑dessous sont publiques pour Sprint 1.
- Les fonctions publiques n'ont pas d'effets secondaires cachés (pas d'écriture du repo, pas de création de fichiers). Toute écriture éventuelle doit être explicite et hors de ce contrat.

Terminologie
- `RepositoryId`: alias conceptuel pour un chemin vers le dépôt (string).
- `CommitId`: alias conceptuel pour un identifiant de commit (string, SHA-1 ou SHA-256 selon repo).
- `BranchName`: alias conceptuel pour le nom d'une branche (string).
- `GitEngine`: instance opaque représentant un dépôt ouvert.

Erreurs publiques (types)
- `RepositoryNotFound` — le chemin n'existe pas.
- `InvalidRepository` — le chemin n'est pas un dépôt Git valide.
- `DetachedHead` — HEAD est détachée (appel à `head()` lèvera cette erreur).
- `AccessDenied` — accès refusé au repository (permissions).
- `CorruptedRepository` — données Git corrompues ou incohérentes.
- `UnsupportedRepositoryVersion` — format de repository non supporté.
- `EngineClosed` — appel d'une méthode sur un `GitEngine` déjà fermé.
- `GitBackendError` — erreur interne non classée du backend.

API publique (signatures conceptuelles)
- `isRepository(path: string) -> bool`
- `open(path: string) -> GitEngine`
- `close(engine: GitEngine) -> void`
- `head(engine: GitEngine) -> BranchName`  (lève `DetachedHead` si tête détachée)
- `branches(engine: GitEngine) -> seq[BranchName]`
- `commits(engine: GitEngine, max: int = 0) -> seq[CommitId]`

Spécification détaillée — préconditions, postconditions, invariants, exceptions, ownership, lifetime, exemples, sécurité

1) isRepository(path: string) -> bool
- Purpose: vérifier rapidement si `path` représente vraisemblablement un dépôt Git utilisable par l'Engine.
- Preconditions: `path` est un chemin valide (string). Aucune garantie sur existence.
- Postconditions: retourne `true` si l'Engine reconnait le dossier comme dépôt Git utilisable, `false` sinon.
- Invariants: n'effectue aucune modification sur le système de fichiers.
- Exceptions: aucune (les erreurs IO sont capturées et se traduisent par `false`).
- Ownership: aucune ressource transférée.
- Lifetime: opération stateless, valeur retournée indépendante.
- Examples:
  - `isRepository("/home/alice/repo") -> true`
- Thread safety: doit être réentrante et sûre pour appels concurrents sur des chemins distincts.
- Future compatibility: signature fixe; aucune option additionnelle exposée pour Sprint 1.

2) open(path: string) -> GitEngine
- Purpose: ouvrir et initialiser un handle `GitEngine` pour `path`.
- Preconditions: `path` est un chemin vers un dossier ; l'appelant doit avoir les droits nécessaires.
- Postconditions: si retourne sans exception, le `GitEngine` est prêt à répondre aux autres appels du contrat.
- Invariants: n'effectue aucune modification destructive du repo ; prépare uniquement les ressources nécessaires (mémoire, handles natifs encapsulés).
- Exceptions:
  - `RepositoryNotFound` si le chemin n'existe pas.
  - `InvalidRepository` si le dossier n'est pas un dépôt Git valide.
  - `AccessDenied` si l'accès est refusé.
  - `CorruptedRepository` si la structure Git semble corrompue.
  - `UnsupportedRepositoryVersion` si le format du repo n'est pas géré.
  - `GitBackendError` pour autres erreurs internes.
- Ownership: l'appelant devient propriétaire du `GitEngine` et doit appeler `close`.
- Lifetime: le `GitEngine` est valide depuis le retour de `open` jusqu'à l'appel de `close`.
- Examples:
  - `eng = open(".")`
- Thread safety: l'ouverture de dépôts distincts doit être sûre en parallèle. L'ouverture concurrente du même chemin peut être permis mais n'est pas garanti ; documenter le comportement dans l'implémentation.
- Future compatibility: options d'ouverture (flags readonly, etc.) peuvent être ajoutées via une surcharge future, sans casser la signature existante.

3) close(engine: GitEngine) -> void
- Purpose: libérer toutes ressources natives associées à `engine` et marquer l'instance comme fermée.
- Preconditions: `engine` a été retourné par `open` et n'est pas déjà fermé.
- Postconditions: après `close`, tout appel ultérieur sur `engine` doit lever `EngineClosed`.
- Invariants: `close` n'échoue pas en laissant des ressources non libérées ; les erreurs de cleanup doivent être loggées ou encapsulées dans `GitBackendError` si critique.
- Exceptions: aucune prévue ; erreurs critiques peuvent être signalées par `GitBackendError`.
- Ownership: l'appelant libère le handle et ne doit plus l'utiliser.
- Lifetime: met fin à la lifetime du `GitEngine`.
- Examples:
  - `close(eng)`
- Thread safety: l'appelant doit garantir qu'aucun autre thread n'utilise `engine` lors du `close` (par défaut non safe-concurrent sur la même instance).

4) head(engine: GitEngine) -> BranchName
- Purpose: renvoyer le nom de la branche courante (ex: `main`).
- Preconditions: `engine` valide et ouvert.
- Postconditions: retourne un `BranchName` non vide représentant la référence symbolique actuelle.
- Invariants:
  - si valeur retournée, elle représente la référence locale (nom) et non un hash.
  - si HEAD est détachée, la fonction doit lever `DetachedHead` (plutôt que de renvoyer un hash ou une valeur vide).
- Exceptions:
  - `DetachedHead` si HEAD est détachée.
  - `EngineClosed` si `engine` est fermé.
  - `GitBackendError` pour autres erreurs.
- Ownership: le string retourné est indépendant du `engine`.
- Lifetime: valeur indépendante après retour.
- Examples:
  - `b = head(eng)  // "main"`
- Thread safety: lecture ; doit être sûre tant qu'il n'y a pas de modification concurrente du repo.

5) branches(engine: GitEngine) -> seq[BranchName]
- Purpose: lister les noms de branches du repository (locales). Pour Sprint 1, la portée est minimale : lister les branches locales.
- Preconditions: `engine` valide.
- Postconditions: retourne une séquence de noms de branches ; chaque nom est non vide et unique dans la séquence.
- Invariants:
  - ordre non contractuel (implémentation peut trier ou renvoyer dans l'ordre natif).
  - ne doit pas contenir duplicates.
- Exceptions: `EngineClosed`, `GitBackendError`.
- Ownership: collection copiée ; l'appelant possède la donnée.
- Lifetime: indépendante du `engine`.
- Examples:
  - `bs = branches(eng); for b in bs: print(b)`
- Thread safety: lecture seule ; sûr si pas de modifications concurrentes.

6) commits(engine: GitEngine, max: int = 0) -> seq[CommitId]
- Purpose: lister les identifiants de commit accessibles depuis HEAD, du plus récent au plus ancien. Ne retourne que des `CommitId` (string) ; aucune donnée de commit enrichie n'est exposée dans Sprint 1.
- Preconditions: `engine` valide.
- Postconditions:
  - retourne une séquence de `CommitId` ordonnée du plus récent au plus ancien.
  - si `max > 0`, la longueur de la séquence est au plus `max`.
- Invariants:
  - chaque `CommitId` est non vide et correspond à un commit existant au moment de l'appel.
  - l'API n'expose pas le contenu du commit (pas de message, auteur, files, etc.).
- Exceptions: `EngineClosed`, `GitBackendError`.
- Ownership: collection copiée.
- Lifetime: indépendante du `engine`.
- Examples:
  - `hashes = commits(eng, max=100)`
- Thread safety: lecture seule ; sûr si pas de modifications concurrentes.
- Future compatibility: des méthodes additionnelles pour récupérer le contenu d'un commit (`getCommit`) sont volontairement exclues de Sprint 1 et pourront être ajoutées plus tard dans une API séparée si nécessaire.

Notes importantes
- Atomicité/snapshot: le contrat ne garantit pas un instantané atomique du repository entre appels successifs. Si le repository est modifié par un autre processus entre deux appels (`commits` puis `head`), les résultats peuvent refléter des états différents. Le consommateur doit être conscient de cela.
- Performance: ce document ne promet aucune complexité algorithmique spécifique. Les implémentations peuvent optimiser l'accès, mais ne doivent pas exposer d'optimisations via l'API publique de Sprint 1.
- Isolation d'implémentation: toute implémentation doit être encapsulée sous `src/git/impl_*` et ne doit pas fuiter des handles natifs ou pointeurs dans les valeurs retournées.

Checklist de conformité (avant merge)
- [ ] Le module public `src/git/engine.*` (interface) implémente exactement ces signatures et lève les exceptions listées.
- [ ] Aucun module hors `src/git` n'importe les modules `src/git/impl_*` ou des bindings C.
- [ ] Les tests d'API couvrent : ouverture valide, dossier non Git, dépôt vide, dépôt avec 1 commit, plusieurs branches, HEAD détachée, dépôt inaccessible.
- [ ] CI inclut un contrôle qui empêche les imports infra non autorisés.

Fin du contrat (Sprint 1)
