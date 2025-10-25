#!/usr/bin/env bash
set -euo pipefail

# Default branch push case
ROOT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

# Test inputs
MAJOR='1'
MINOR='2'
PATCH='3'
GITHUB_EVENT_NAME='push'
GITHUB_REF='refs/heads/main'
GITHUB_RUN_NUMBER='100'
DEFAULT_BRANCH='main'

# Expected output for this case
expected_semver='1.2.3'

# Execute assertion helper (will run the compute script)
TEST_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MAJOR="$MAJOR" MINOR="$MINOR" PATCH="$PATCH" GITHUB_EVENT_NAME="$GITHUB_EVENT_NAME" GITHUB_REF="$GITHUB_REF" GITHUB_RUN_NUMBER="$GITHUB_RUN_NUMBER" DEFAULT_BRANCH="$DEFAULT_BRANCH" expected_semver="$expected_semver" bash "$TEST_DIR/assert.sh"
