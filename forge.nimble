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

task test, "Run the test suite (deprecated)":
  # The canonical test runner is `./tools/run_tests_direct.sh`.
  # This task is kept as a placeholder to avoid accidental execution paths.
  exec "echo 'ERROR: use ./tools/run_tests_direct.sh instead of nimble test'; exit 1"

task fmt, "Check formatting":
  exec "nimpretty --maxLineLen:100 src/forge.nim tests/test_forge.nim"