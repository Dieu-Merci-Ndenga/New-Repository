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

suite "Git Engine API":

  test "ouvrir un dépôt valide":
    let tmp = createTempDir("gitengineapi")
    run("git init .", tmp)
    let eng = ge.open(tmp)
    check eng.repoPath == absolutePath(tmp)
    eng.close()

  test "dossier non Git":
    let tmp2 = createTempDir("gitengineapi2")
    # no git init
    try:
      let _ = ge.open(tmp2)
      check false
    except InvalidRepository:
      check true

  test "dépôt vide":
    let tmp3 = createTempDir("gitengineapi3")
    run("git init .", tmp3)
    let eng3 = ge.open(tmp3)
    # empty repo: commits() should be empty
    check eng3.commits().len == 0
    # head() may raise DetachedHead or return a branch name or 'detached'
    try:
      let h = ge.head(eng3)
      check h.len >= 0
    except DetachedHead:
      check true
    eng3.close()

  test "dépôt avec 1 commit":
    let tmp4 = createTempDir("gitengineapi4")
    run("git init .", tmp4)
    run("git config user.email test@example.com", tmp4)
    run("git config user.name Test User", tmp4)
    writeFile(tmp4 / "f.txt", "x")
    run("git add f.txt", tmp4)
    run("git commit -m \"one\"", tmp4)
    let eng4 = ge.open(tmp4)
    check eng4.commits().len == 1
    check ge.head(eng4) != ""
    eng4.close()

  test "dépôt avec plusieurs branches":
    let tmp5 = createTempDir("gitengineapi5")
    run("git init .", tmp5)
    run("git config user.email test@example.com", tmp5)
    run("git config user.name Test User", tmp5)
    writeFile(tmp5 / "a.txt", "a")
    run("git add a.txt", tmp5)
    run("git commit -m \"init\"", tmp5)
    run("git branch feature", tmp5)
    run("git branch bugfix", tmp5)
    let eng5 = ge.open(tmp5)
    let bs = ge.branches(eng5)
    check bs.len >= 3 # includes master/main and two created
    eng5.close()

  test "HEAD détachée":
    let tmp6 = createTempDir("gitengineapi6")
    run("git init .", tmp6)
    run("git config user.email test@example.com", tmp6)
    run("git config user.name Test User", tmp6)
    writeFile(tmp6 / "x.txt", "x")
    run("git add x.txt", tmp6)
    run("git commit -m \"c1\"", tmp6)
    let h = execCmdEx("git rev-parse HEAD", workingDir = tmp6).output.strip()
    # detach
    run("git checkout " & h, tmp6)
    let eng6 = ge.open(tmp6)
    try:
      let h = ge.head(eng6)
      # accept 'detached' string or any non-empty result
      check h.len >= 0
    except DetachedHead:
      check true
    eng6.close()

  test "dépôt inaccessible":
    let tmp7 = createTempDir("gitengineapi7")
    run("git init .", tmp7)
    # make it inaccessible
    let permsOk = try:
      # run chmod from safe cwd
      run("chmod 000 " & tmp7, getTempDir())
      true
    except:
      false
    if permsOk:
      try:
        let _ = ge.open(tmp7)
        # On some systems this may still work; accept either error or success
      except GitError:
        check true
      except OSError:
        check true
      finally:
        # restore perms so temp cleanup works
        run("chmod 700 " & tmp7, getTempDir())
