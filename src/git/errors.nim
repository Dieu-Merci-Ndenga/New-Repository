type
  ## Base exception pour les erreurs du Git Engine
  GitError* = object of Exception

  RepositoryNotFound* = object of GitError
  InvalidRepository* = object of GitError
  DetachedHead* = object of GitError
  AccessDenied* = object of GitError
  CorruptedRepository* = object of GitError
  UnsupportedRepositoryVersion* = object of GitError
