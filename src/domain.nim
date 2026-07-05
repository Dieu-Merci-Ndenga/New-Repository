# Domain entities — indépendantes de toute bibliothèque externe

type
  ChangeType* = enum
    ctAdded, ctModified, ctDeleted, ctRenamed

  Author* = object
    name*: string
    email*: string

  Repository* = object
    path*: string
    name*: string
    defaultBranch*: string

  Branch* = object
    name*: string
    targetCommit*: string

  Tag* = object
    name*: string
    targetCommit*: string

  Commit* = object
    hash*: string
    message*: string
    author*: Author
    timestamp*: string
    parents*: seq[string]
    filesChanged*: seq[string] # list of file paths changed in this commit

  FileChange* = object
    path*: string
    changeType*: ChangeType
    additions*: int
    deletions*: int

  Diff* = object
    filePath*: string
    patch*: string # raw unified diff or empty if not available

  Summary* = object
    repository*: Repository
    commitCount*: int
    branchCount*: int
    tagCount*: int
    authorCount*: int

# Aucun code métier ici — uniquement les structures de données (entités)
