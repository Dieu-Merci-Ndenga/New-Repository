#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENGINE_FILE="$ROOT_DIR/src/git/engine.nim"
SIG_FILE="$ROOT_DIR/tools/engine_api_signature.txt"

if [ ! -f "$ENGINE_FILE" ]; then
  echo "Engine file not found: $ENGINE_FILE" >&2
  exit 2
fi

grep -n "proc .*\*\s*(" "$ENGINE_FILE" | sed -E 's/^[0-9]+:?//g' | sed -E "s/\s*\(.*//" | sed -E 's/\*//g' | sed -E 's/^\s+//g' > /tmp/engine_api_current.txt

if [ ! -f "$SIG_FILE" ]; then
  echo "Signature file missing; create it with tools/update_engine_api_signature.sh" >&2
  exit 3
fi

if ! diff -u "$SIG_FILE" /tmp/engine_api_current.txt >/tmp/engine_api_diff.txt; then
  echo "Engine API contract mismatch detected."
  echo "Diff:" >&2
  sed -n '1,200p' /tmp/engine_api_diff.txt >&2 || true
  echo "If this change is intentional, update the signature with:"
  echo "  bash tools/update_engine_api_signature.sh"
  exit 1
fi

echo "Engine API contract validated."
