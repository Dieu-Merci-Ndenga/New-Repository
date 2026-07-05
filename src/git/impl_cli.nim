import std/[os, osproc, strutils, sequtils]

type
  Repository* = object
    path*: string

proc runGit*(repoPath: string, args: openArray[string]): tuple[text: string, code: int] =
  ## Exécute une commande `git` dans le répertoire indiqué.
  let r = execCmdEx("git " & args.join(" "), workingDir = repoPath)
  result.text = r.output
  result.code = r.exitCode

proc isRepository*(path: string): bool =
  if not dirExists(path): return false
  let result = runGit(path, ["rev-parse", "--is-inside-work-tree"])
  result.code == 0 and result.text.strip() == "true"

proc openRepository*(path: string): Repository =
  let abs = absolutePath(path)
  if not isRepository(abs):
    raise newException(ValueError, "Not a Git repository: " & abs)
  result.path = abs

proc getBranches*(repo: Repository): seq[string] =
  let txt = runGit(repo.path, ["branch", "--all", "--list"]).text
  result = @[]
  for line in txt.splitLines():
    var b = line.replace("* ", "").strip()
    if b.len > 0 and not (b in result):
      result.add b

proc getCommits*(repo: Repository, max: int = 0): seq[string] =
  var args: seq[string]
  if max > 0:
    args = @[("rev-list"), ("--max-count=" & $max), "HEAD"]
  else:
    args = @[("rev-list"), "--all"]
  let txt = runGit(repo.path, args).text
  result = txt.splitLines().filterIt(it.strip().len > 0).mapIt(it.strip())

proc getTags*(repo: Repository): seq[string] =
  let txt = runGit(repo.path, ["tag", "--list"]).text
  result = txt.splitLines().mapIt(it.strip()).filterIt(it.len > 0)

proc getHead*(repo: Repository): string =
  let r = runGit(repo.path, ["branch", "--show-current"])
  let name = r.text.strip()
  if name.len > 0: return name
  return "detached"

proc getStatus*(repo: Repository): seq[string] =
  let txt = runGit(repo.path, ["status", "--porcelain"]).text
  result = txt.splitLines().mapIt(it.strip()).filterIt(it.len > 0)
