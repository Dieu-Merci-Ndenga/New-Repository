import std/[strutils, sequtils]

import git.impl_cli as impl, domain

type
  RepositoryService* = ref object
    ## Interface légère pour accéder au dépôt sans exposer libgit2
    isRepository*: proc(path: string): bool
    openRepository*: proc(path: string): impl.Repository
    getBranches*: proc(repo: impl.Repository): seq[Branch]
    getCommits*: proc(repo: impl.Repository, max: int = 0): seq[Commit]
    getTags*: proc(repo: impl.Repository): seq[Tag]
    getHead*: proc(repo: impl.Repository): string
    getStatus*: proc(repo: impl.Repository): seq[string]


proc parseCommitRaw(repoPath: string, hash: string): Commit {.private.} =
  let fmt = "%H%n%an%n%ae%n%ad%n%P%n%B"
  let txt = impl.runGit(repoPath, @[("show"), ("-s"), ("--format=" & fmt), hash]).text
  var lines = txt.splitLines()
  if lines.len < 5:
    raise newException(ValueError, "Unexpected git show output for " & hash)
  let h = lines[0].strip()
  let name = lines[1].strip()
  let email = lines[2].strip()
  let date = lines[3].strip()
  let parentsLine = lines[4].strip()
  var message = ""
  if lines.len > 5:
    message = lines[5..^1].join("\n").strip()
  var parents: seq[string] = @[]
  if parentsLine.len > 0:
    parents = parentsLine.splitWhitespace()

  let filesOut = impl.runGit(repoPath, @[("show"), ("--name-only"), ("--pretty=") , hash]).text
  let files = filesOut.splitLines().mapIt(it.strip()).filterIt(it.len > 0)

  result = Commit(
    hash: h,
    message: message,
    author: Author(name: name, email: email),
    timestamp: date,
    parents: parents,
    filesChanged: files
  )


proc newGitRepositoryService*(): RepositoryService =
  var svc = RepositoryService()

  svc.isRepository = proc(path: string): bool =
    impl.isRepository(path)

  svc.openRepository = proc(path: string): impl.Repository =
    impl.openRepository(path)

  svc.getBranches = proc(repo: impl.Repository): seq[Branch] =
    result = impl.getBranches(repo).mapIt(Branch(name: it, targetCommit: ""))

  svc.getTags = proc(repo: impl.Repository): seq[Tag] =
    result = impl.getTags(repo).mapIt(Tag(name: it, targetCommit: ""))

  svc.getHead = proc(repo: impl.Repository): string =
    impl.getHead(repo)

  svc.getStatus = proc(repo: impl.Repository): seq[string] =
    impl.getStatus(repo)

  svc.getCommits = proc(repo: impl.Repository, max: int = 0): seq[Commit] =
    let hashes = impl.getCommits(repo, max)
    result = @[]
    for h in hashes:
      result.add parseCommitRaw(repo.path, h)

  return svc
