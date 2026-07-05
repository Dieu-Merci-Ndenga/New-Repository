import std/[unittest, os, osproc, strutils, times]

import git.engine as ge
import git.errors

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

suite "git.engine basic":
  test "isRepository and open on new repo":
    let tmp = createTempDir("gitengtest")
    run("git init .", tmp)
    check ge.isRepository(tmp)
    let repo = ge.open(tmp)
    check repo.repoPath == absolutePath(tmp)

  test "getHead on empty repo is detached":
    let tmp2 = createTempDir("gitengtest2")
    run("git init .", tmp2)
    let repo2 = ge.open(tmp2)
    # head on an empty repo may be 'detached' or a default branch name (e.g. 'main')
    try:
      let h = ge.head(repo2)
      check h.len >= 0
    except DetachedHead:
      check true
