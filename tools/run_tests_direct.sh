#!/usr/bin/env bash
set -euo pipefail

# Robust direct test runner: compile and run each test individually
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

FAILED=0
for f in tests/*.nim; do
  echo "==> Running $f"
  if ! nim c -r --hints:off --path:src --path:tests "$f"; then
    echo "Test failed: $f" >&2
    FAILED=1
    break
  fi
done

if [ "$FAILED" -ne 0 ]; then
  echo "Some tests failed." >&2
  exit 1
fi

echo "All tests passed."
