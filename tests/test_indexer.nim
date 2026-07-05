import std/[unittest, os, osproc, strutils, times]

import git/indexer as indexer
import domain

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

suite "indexer":
  test "buildIndex on repository with one commit":
    let tmp = createTempDir("indexertest")
    run("git init .", tmp)
    run("git config user.email test@example.com", tmp)
    run("git config user.name Test User", tmp)
    # create a file and commit
    writeFile(tmp / "README.md", "hello world")
    run("git add README.md", tmp)
    run("git commit -m \"initial commit\"", tmp)

    let idx = indexer.buildIndex(tmp)
    check idx.commits.len == 1
    check idx.commits[0].message.contains("initial commit")
    check idx.commits[0].filesChanged.len >= 1
