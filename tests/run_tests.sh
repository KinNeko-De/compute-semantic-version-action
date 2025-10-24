#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
CASE_DIR="$ROOT_DIR/cases"

for case in "$CASE_DIR"/*.sh; do
  echo "Running $case"
  bash "$case"
done

echo "All tests passed"
