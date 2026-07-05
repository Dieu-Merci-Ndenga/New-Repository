#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENGINE_FILE="$ROOT_DIR/src/git/engine.nim"
SIG_FILE="$ROOT_DIR/tools/engine_api_signature.txt"

grep -n "proc .*\*\s*(" "$ENGINE_FILE" | sed -E 's/^[0-9]+:?//g' | sed -E "s/\s*\(.*//" | sed -E 's/\*//g' | sed -E 's/^\s+//g' > "$SIG_FILE"

echo "Updated signature written to $SIG_FILE"
