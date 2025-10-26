#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"

fail() {
  # If the temporary GITHUB_OUTPUT file exists, show its contents for debugging
  if [[ -n "${GITHUB_OUTPUT_TMP-}" && -f "$GITHUB_OUTPUT_TMP" ]]; then
    printf 'GITHUB_OUTPUT (tmp) content:\n%s\n' "$(cat "$GITHUB_OUTPUT_TMP" 2>/dev/null || true)"
  fi
  echo "FAIL: $1"
  exit 1
}

if [[ -z "${MAJOR-}" || -z "${MINOR-}" || -z "${PATCH-}" ]]; then
  fail "MAJOR, MINOR and PATCH must be set in the case script"
fi

if [[ -z "${expected_semver-}" ]]; then
  fail "expected_semver must be set in the case script"
fi

if [[ -z "${expected_version_suffix+x}" ]]; then
  fail "expected_version_suffix must be set in the case script"
fi

if [[ -z "${expected_extension+x}" ]]; then
  fail "expected_extension must be set in the case script"
fi

if [[ -z "${expected_use_version_suffix+x}" ]]; then
  fail "expected_use_version_suffix must be set in the case script"
fi

if [[ -z "${expected_next_default_branch_version+x}" ]]; then
  fail "expected_next_default_branch_version must be set in the case script"
fi

# Create temporary file for GITHUB_OUTPUT so the script can write outputs there
GITHUB_OUTPUT_TMP=$(mktemp)

# Ensure the temp file is removed on exit (success or failure)
trap 'rm -f "$GITHUB_OUTPUT_TMP"' EXIT

# Run the compute script; it will write key=value lines into $GITHUB_OUTPUT_TMP
GITHUB_OUTPUT="$GITHUB_OUTPUT_TMP" MAJOR="$MAJOR" MINOR="$MINOR" PATCH="$PATCH" DEFAULT_BRANCH="${DEFAULT_BRANCH-}" \
  GITHUB_EVENT_NAME="${GITHUB_EVENT_NAME-}" GITHUB_REF="${GITHUB_REF-}" GITHUB_HEAD_REF="${GITHUB_HEAD_REF-}" \
  GITHUB_RUN_NUMBER="${GITHUB_RUN_NUMBER-}" "$ROOT_DIR/../bin/compute-semver.sh" 2>&1

# Read semantic_version from the temp GITHUB_OUTPUT file
semver_line=$(grep -m1 '^semantic_version=' "$GITHUB_OUTPUT_TMP" || true)
semver=${semver_line#semantic_version=}

# If the semantic version doesn't match, fail() will print the temp file content
version_suffix_line=$(grep -m1 '^version_suffix=' "$GITHUB_OUTPUT_TMP" || true)
version_suffix=${version_suffix_line#version_suffix=}

extension_line=$(grep -m1 '^extension=' "$GITHUB_OUTPUT_TMP" || true)
extension=${extension_line#extension=}

use_suffix_line=$(grep -m1 '^use_version_suffix=' "$GITHUB_OUTPUT_TMP" || true)
use_version_suffix=${use_suffix_line#use_version_suffix=}

next_default_branch_line=$(grep -m1 '^next_default_branch_version=' "$GITHUB_OUTPUT_TMP" || true)
next_default_branch_version=${next_default_branch_line#next_default_branch_version=}

if [[ "$semver" != "$expected_semver" ]]; then
  fail "Expected semantic_version=$expected_semver but got semantic_version=$semver"
fi

if [[ "$version_suffix" != "$expected_version_suffix" ]]; then
  fail "Expected version_suffix=$expected_version_suffix but got version_suffix=$version_suffix"
fi

if [[ "$extension" != "$expected_extension" ]]; then
  fail "Expected extension=$expected_extension but got extension=$extension"
fi

if [[ "$use_version_suffix" != "$expected_use_version_suffix" ]]; then
  fail "Expected use_version_suffix=$expected_use_version_suffix but got use_version_suffix=$use_version_suffix"
fi

if [[ "$next_default_branch_version" != "$expected_next_default_branch_version" ]]; then
  fail "Expected next_default_branch_version=$expected_next_default_branch_version but got next_default_branch_version=$next_default_branch_version"
fi

echo "OK: $semver (suffix=$version_suffix, extension=$extension, use=$use_version_suffix, next_default_branch=$next_default_branch_version)"
