import git.impl_cli as impl

type
  Repository* = impl.Repository

proc runGit*(repoPath: string, args: openArray[string]): tuple[text: string, code: int] =
  impl.runGit(repoPath, args)

proc openRepository*(path: string): Repository =
  impl.openRepository(path)

proc getCommits*(repo: Repository, max: int = 0): seq[string] =
  impl.getCommits(repo, max)

proc getBranches*(repo: Repository): seq[string] =
  impl.getBranches(repo)

proc getTags*(repo: Repository): seq[string] =
  impl.getTags(repo)

proc getHead*(repo: Repository): string =
  impl.getHead(repo)

proc getStatus*(repo: Repository): seq[string] =
  impl.getStatus(repo)
