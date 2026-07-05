import std/[os, strutils]
import git.engine as gitEngine, git.errors, domain


type
  RepoSummary* = object
    repositoryPath*: string
    currentBranch*: string
    commitCount*: int
    branchCount*: int


proc renderSummary*(summary: RepoSummary): string =
  result = "Repository: " & summary.repositoryPath & "\n"
  result.add "Current branch: " & summary.currentBranch & "\n"
  result.add "Commits: " & $summary.commitCount & "\n"
  result.add "Branches: " & $summary.branchCount & "\n"


proc indexRepository(path: string): int =
  if not dirExists(path):
    stderr.writeLine("Path does not exist: ", path)
    return 1

  if not gitEngine.isRepository(path):
    stderr.writeLine("Not a Git repository: ", path)
    return 1

  var eng = gitEngine.open(path)
  defer: gitEngine.close(eng)

  var currentBranch = ""
  try:
    currentBranch = gitEngine.head(eng)
  except DetachedHead:
    currentBranch = "detached"

  let branches = gitEngine.branches(eng)
  let commitsList = gitEngine.commits(eng)

  stdout.write("Repository: " & absolutePath(path) & "\n")
  stdout.write("Current branch: " & currentBranch & "\n")
  stdout.write("Branches: " & $(branches.len) & "\n")
  stdout.write("Commits: " & $(commitsList.len) & "\n")
  stdout.writeLine("")
  return 0


proc main(): int =
  if paramCount() != 2 or paramStr(1) != "index":
    stderr.writeLine("Usage: forge index <path>")
    return 1

  result = indexRepository(paramStr(2))


when isMainModule:
  quit(main())