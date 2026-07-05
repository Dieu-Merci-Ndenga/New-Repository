#!/usr/bin/env bash
set -euo pipefail

echo "Running import rule check..."

# Quick textual scan for forbidden tokens (fast fail)
files=$(git ls-files | grep -E '\.nim$' || true)
errs=0
for f in $files; do
  case "$f" in
    src/git/*) continue ;; # allow infra imports inside src/git
  esac
  if grep -nE '\b(git_engine|impl_cli|impl_libgit2)\b' "$f" >/dev/null; then
    echo "Forbidden infra token found in: $f"
    grep -nE '\b(git_engine|impl_cli|impl_libgit2)\b' "$f" || true
    errs=$((errs+1))
  fi
done

if [ "$errs" -ne 0 ]; then
  echo "Import rule check FAILED (direct token scan): $errs forbidden occurrences found."
  exit 1
fi

echo "Direct scan passed; running import graph validator..."

if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required for import graph validation. Please install python3." >&2
  exit 2
fi

python3 tools/validate_import_graph.py
rc=$?
if [ $rc -ne 0 ]; then
  echo "Import graph validation FAILED (rc=$rc)"
  exit $rc
fi

echo "Import rule check passed."
