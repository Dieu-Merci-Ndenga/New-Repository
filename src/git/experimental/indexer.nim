import std/[strutils, sequtils, os, osproc]

import git.impl_cli as impl, domain

type
  Index* = object
    repository*: domain.Repository
    commits*: seq[domain.Commit]
    branches*: seq[domain.Branch]
    tags*: seq[domain.Tag]
    authors*: seq[domain.Author]


proc parseCommit*(repo: impl.Repository, hash: string): domain.Commit =
  let fmt = "%H%n%an%n%ae%n%ad%n%P%n%B"
  let txt = impl.runGit(repo.path, @[("show"), ("-s"), ("--format=" & fmt), hash]).text
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

  let filesOut = impl.runGit(repo.path, @[("show"), ("--name-only"), ("--pretty=") , hash]).text
  let files = filesOut.splitLines().mapIt(it.strip()).filterIt(it.len > 0)

  result = domain.Commit(
    hash: h,
    message: message,
    author: domain.Author(name: name, email: email),
    timestamp: date,
    parents: parents,
    filesChanged: files
  )


proc buildIndex*(path: string): Index =
  let repo = impl.openRepository(path)
  var commitsSeq: seq[domain.Commit] = @[]
  let hashes = impl.getCommits(repo)
  for h in hashes:
    commitsSeq.add parseCommit(repo, h)

  let branches = impl.getBranches(repo).mapIt(domain.Branch(name: it, targetCommit: ""))
  let tags = impl.getTags(repo).mapIt(domain.Tag(name: it, targetCommit: ""))

  var authorsSeq: seq[domain.Author] = @[]
  for c in commitsSeq:
    if not authorsSeq.anyIt(it.name == c.author.name and it.email == c.author.email):
      authorsSeq.add c.author

  let name = if repo.path.len > 0: repo.path.split("/")[^1] else: repo.path

  result = Index(
    repository: domain.Repository(path: repo.path, name: name, defaultBranch: impl.getHead(repo)),
    commits: commitsSeq,
    branches: branches,
    tags: tags,
    authors: authorsSeq
  )

proc buildIndexIncremental*(path: string): Index =
  # Minimal incremental implementation: return only the newest commit(s)
  let full = buildIndex(path)
  if full.commits.len == 0:
    return full
  let newest = @[full.commits[0]]
  result = Index(
    repository: full.repository,
    commits: newest,
    branches: full.branches,
    tags: full.tags,
    authors: @[full.commits[^1].author]
  )
