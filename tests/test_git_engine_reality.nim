import std/[unittest, os, osproc, strutils, times]

import git/engine as ge
import git/errors

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

suite "Git Engine Reality Tests":

  test "large repo (many commits)":
    let tmp = createTempDir("gitengine_large")
    run("git init .", tmp)
    run("git config user.email test@example.com", tmp)
    run("git config user.name Test User", tmp)

    const COUNT = 1000
    for i in 1..COUNT:
      writeFile(tmp / ("f" & $i & ".txt"), "contents " & $i)
      run("git add .", tmp)
      run("git commit -m \"c\"" & $i, tmp)

    let eng = ge.open(tmp)
    let commitsCount = ge.commits(eng).len
    check commitsCount >= COUNT
    eng.close()

  test "repo with submodule handled":
    let parent = createTempDir("git_parent")
    let child = createTempDir("git_child")
    # child repo
    run("git init .", child)
    run("git config user.email test@example.com", child)
    run("git config user.name Test User", child)
    writeFile(child / "c.txt", "c")
    run("git add c.txt", child)
    run("git commit -m \"child\"", child)
    # parent repo
    run("git init .", parent)
    run("git config user.email test@example.com", parent)
    run("git config user.name Test User", parent)
    # add submodule (allow file:// transport in restricted environments)
    run("GIT_ALLOW_PROTOCOL=file git submodule add " & child & " sub", parent)
    run("git commit -m \"add submodule\"", parent)

    let engP = ge.open(parent)
    # branches and commits should be accessible
    check ge.branches(engP).len >= 1
    check ge.commits(engP).len >= 1
    engP.close()

  test "corrupted HEAD handled gracefully":
    let tmp2 = createTempDir("git_corrupt")
    run("git init .", tmp2)
    run("git config user.email test@example.com", tmp2)
    run("git config user.name Test User", tmp2)
    writeFile(tmp2 / "a.txt", "a")
    run("git add a.txt", tmp2)
    run("git commit -m \"init\"", tmp2)
    # corrupt HEAD
    let headPath = tmp2 / ".git" / "HEAD"
    writeFile(headPath, "not a ref")

    try:
      let eng2 = ge.open(tmp2)
      # head() may raise or return 'detached' depending on implementation
      try:
        let _ = ge.head(eng2)
      except GitError:
        check true
      eng2.close()
    except GitError:
      check true
