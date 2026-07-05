import std/[sequtils]
import git.impl_cli as impl

type
  Repository* = object
    path*: string

  RunGitProc* = proc(repoPath: string, args: openArray[string]): tuple[text: string, code: int]
  OpenRepoProc* = proc(path: string): Repository
  GetCommitsProc* = proc(repo: Repository, max: int = 0): seq[string]
  GetBranchesProc* = proc(repo: Repository): seq[string]
  GetTagsProc* = proc(repo: Repository): seq[string]
  GetHeadProc* = proc(repo: Repository): string
  GetStatusProc* = proc(repo: Repository): seq[string]

  GitBackend* = ref object
    runGit*: RunGitProc
    openRepository*: OpenRepoProc
    getCommits*: GetCommitsProc
    getBranches*: GetBranchesProc
    getTags*: GetTagsProc
    getHead*: GetHeadProc
    getStatus*: GetStatusProc

var DefaultBackend*: GitBackend = nil

proc setBackend*(b: GitBackend) =
  DefaultBackend = b

proc makeImplCliBackend(): GitBackend =
  var b: GitBackend
  new(b)
  b.runGit = proc(repoPath: string, args: openArray[string]): tuple[text: string, code: int] =
    impl.runGit(repoPath, args)
  b.openRepository = proc(path: string): Repository =
    let r = impl.openRepository(path)
    Repository(path: r.path)
  b.getCommits = proc(repo: Repository, max: int = 0): seq[string] =
    impl.getCommits(impl.Repository(path: repo.path), max)
  b.getBranches = proc(repo: Repository): seq[string] =
    impl.getBranches(impl.Repository(path: repo.path))
  b.getTags = proc(repo: Repository): seq[string] =
    impl.getTags(impl.Repository(path: repo.path))
  b.getHead = proc(repo: Repository): string =
    impl.getHead(impl.Repository(path: repo.path))
  b.getStatus = proc(repo: Repository): seq[string] =
    impl.getStatus(impl.Repository(path: repo.path))
  return b

proc ensureBackend() =
  if DefaultBackend.isNil:
    DefaultBackend = makeImplCliBackend()

proc runGit*(repoPath: string, args: openArray[string]): tuple[text: string, code: int] =
  ensureBackend()
  result = DefaultBackend.runGit(repoPath, args)

proc openRepository*(path: string): Repository =
  ensureBackend()
  result = DefaultBackend.openRepository(path)

proc getCommits*(repo: Repository, max: int = 0): seq[string] =
  ensureBackend()
  result = DefaultBackend.getCommits(repo, max)

proc getBranches*(repo: Repository): seq[string] =
  ensureBackend()
  result = DefaultBackend.getBranches(repo)

proc getTags*(repo: Repository): seq[string] =
  ensureBackend()
  result = DefaultBackend.getTags(repo)

proc getHead*(repo: Repository): string =
  ensureBackend()
  result = DefaultBackend.getHead(repo)

proc getStatus*(repo: Repository): seq[string] =
  ensureBackend()
  result = DefaultBackend.getStatus(repo)
