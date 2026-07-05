#!/usr/bin/env bash
set -euo pipefail

REPO_PATH=${1:-.}

echo "Building project..."
nimble build

echo "Running benchmark (measures wall time and max RSS via /usr/bin/time)..."
echo "Command: /usr/bin/time -v bin/forge index ${REPO_PATH}"
/usr/bin/time -v bin/forge index "${REPO_PATH}"

echo "Benchmark complete."
