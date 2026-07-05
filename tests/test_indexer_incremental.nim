import std/[unittest, os, osproc, strutils, times]

import git/experimental/indexer as indexer
import common_nim

proc createTempDir(prefix: string): string =
  let base = getTempDir()
  let name = prefix & "-" & $getTime().toUnix()
  let path = base / name
  createDir(path)
  return path

proc run(cmd: string, cwd: string) =
  let r = execCmdEx(cmd, workingDir = cwd)
  if r.exitCode != 0:
    quit r.exitCode

suite "indexer incremental":
  test "incremental indexing captures only new commits":
    let tmp = createTempDir("indexerinc")
    run("git init .", tmp)
    run("git config user.email test@example.com", tmp)
    run("git config user.name Test User", tmp)

    writeFile(tmp / "a.txt", "first")
    run("git add a.txt", tmp)
    run("git commit -m \"first commit\"", tmp)

    let full = indexer.buildIndex(tmp)
    check full.commits.len == 1

    # create a second commit
    writeFile(tmp / "b.txt", "second")
    run("git add b.txt", tmp)
    run("git commit -m \"second commit\"", tmp)

    let inc = indexer.buildIndexIncremental(tmp)
    check inc.commits.len == 1
    check inc.commits[0].message.contains("second commit")
