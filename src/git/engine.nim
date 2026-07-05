import std/[os, strutils]

import git.impl_cli as impl
import git/errors

type
  GitEngine* = ref object
    repoPath*: string


proc isRepository*(path: string): bool =
  if not dirExists(path): return false
  return impl.isRepository(path)


proc open*(path: string): GitEngine =
  if not dirExists(path):
    raise newException(RepositoryNotFound, "Path does not exist: " & path)
  if not impl.isRepository(path):
    raise newException(InvalidRepository, "Not a Git repository: " & path)
  result = GitEngine(repoPath: absolutePath(path))


proc head*(self: GitEngine): string =
  let r = impl.runGit(self.repoPath, @["branch", "--show-current"]).text.strip()
  if r.len == 0:
    return "detached"
  return r


proc branches*(self: GitEngine): seq[string] =
  impl.getBranches(impl.Repository(path: self.repoPath)) # delegue


proc commits*(self: GitEngine, max: int = 0): seq[string] =
  impl.getCommits(impl.Repository(path: self.repoPath), max)


proc tags*(self: GitEngine): seq[string] =
  impl.getTags(impl.Repository(path: self.repoPath))


proc status*(self: GitEngine): seq[string] =
  impl.getStatus(impl.Repository(path: self.repoPath))


proc close*(self: GitEngine) =
  # No-op for now; placeholder for resources cleanup if needed
  discard
