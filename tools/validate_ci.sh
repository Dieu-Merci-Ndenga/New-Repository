#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "Running consolidated CI validations: import rules + engine API contract"

bash "$ROOT_DIR/tools/import_rule_check.sh"
bash "$ROOT_DIR/tools/check_engine_api.sh"

echo "All consolidated CI validations passed."
