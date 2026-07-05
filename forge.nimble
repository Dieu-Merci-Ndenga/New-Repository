version       = "0.1.0"
author        = "Dieu-Merci Ndenga"
description   = "Forge Git intelligence CLI"
license       = "MIT"
bin           = @[
  "forge"
]
srcDir        = "src"

task build, "Build the Forge binary":
  exec "nim c -d:release -o:bin/forge src/forge.nim"

task test, "Run the test suite":
  exec "bash tools/run_tests_direct.sh"

task fmt, "Check formatting":
  exec "nimpretty --maxLineLen:100 src/forge.nim tests/test_forge.nim"