#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Checking single test entry..."

# Check forge.nimble contains the canonical runner note
if ! grep -q "run_tests_direct.sh" "$ROOT_DIR/forge.nimble"; then
  echo "forge.nimble does not reference the canonical test runner (run_tests_direct.sh)."
  echo "Please ensure forge.nimble mentions ./tools/run_tests_direct.sh as the canonical runner."
  exit 2
fi

# Check CI workflow uses the canonical runner
if ! grep -q "tools/run_tests_direct.sh" "$ROOT_DIR/.github/workflows/ci.yml"; then
  echo "CI workflow does not run tools/run_tests_direct.sh."
  echo "Please set CI Test step to: bash tools/run_tests_direct.sh"
  exit 3
fi

echo "Single test entry validated."
