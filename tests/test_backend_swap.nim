import std/[unittest, os, osproc, strutils, times]

import git/backend, git/indexer
import git.impl_cli as impl

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

suite "backend swap":
  test "indexer uses injected backend (fake returns no commits)":
    let tmp = createTempDir("backendtest")
    run("git init .", tmp)
    run("git config user.email test@example.com", tmp)
    run("git config user.name Test User", tmp)
    writeFile(tmp / "README.md", "hello world")
    run("git add README.md", tmp)
    run("git commit -m \"initial commit\"", tmp)

    # create a fake backend that returns no commits but delegates openRepository
    var fake: GitBackend
    new(fake)
    fake.openRepository = proc(path: string): backend.Repository =
      let r = impl.openRepository(path)
      backend.Repository(path: r.path)
    fake.getCommits = proc(repo: backend.Repository, max: int = 0): seq[string] = @[]
    fake.getBranches = proc(repo: backend.Repository): seq[string] = impl.getBranches(impl.Repository(path: repo.path))
    fake.getTags = proc(repo: backend.Repository): seq[string] = impl.getTags(impl.Repository(path: repo.path))
    fake.getHead = proc(repo: backend.Repository): string = impl.getHead(impl.Repository(path: repo.path))
    fake.runGit = proc(repoPath: string, args: openArray[string]): tuple[text: string, code: int] = impl.runGit(repoPath, args)
    fake.getStatus = proc(repo: backend.Repository): seq[string] = impl.getStatus(impl.Repository(path: repo.path))

    # inject fake backend
    setBackend(fake)

    let idx = indexer.buildIndex(tmp)
    check idx.commits.len == 0

    # reset backend to default (nil triggers lazy init)
    setBackend(nil)
