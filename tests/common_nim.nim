import std/[os, times]

proc createTempDir(prefix: string): string =
  let base = getTempDir()
  let name = prefix & "-" & $getTime().toUnix()
  let path = base / name
  createDir(path)
  return path
