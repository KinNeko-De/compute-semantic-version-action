#!/usr/bin/env bash
set -euo pipefail

USE=false
SUFFIX=""
EXTENSION=""

main() {
  determine_suffix
  compute_semver
  print_outputs
}

determine_suffix() {
  if [[ "$GITHUB_EVENT_NAME" == 'pull_request' ]]; then
    compute_semver_pull_request
  elif [[ "$GITHUB_REF" == "refs/heads/${DEFAULT_BRANCH}" ]]; then
    compute_semver_default_branch
  else
    compute_semver_feature_branch
  fi
}

compute_semver_pull_request() {
  echo "::debug::Compute for pull request" >&2
  USE=true
  SUFFIX="${GITHUB_HEAD_REF##*/}.${GITHUB_RUN_NUMBER}"
  EXTENSION="-${SUFFIX}"
}

compute_semver_default_branch() {
  echo "::debug::Compute for default branch" >&2
  USE=false
  SUFFIX=''
  EXTENSION=''
}

compute_semver_feature_branch() {
  echo "::debug::Compute for feature branch" >&2
  USE=true
  REF_NAME=${GITHUB_REF##*/}
  SUFFIX="${REF_NAME}.${GITHUB_RUN_NUMBER}"
  EXTENSION="-${SUFFIX}"
}

compute_semver() {
  SEMANTIC_VERSION="${MAJOR_MINOR_PATCH}${EXTENSION}"
}

print_outputs() {
  echo "use_version_suffix=$USE" >> "$GITHUB_OUTPUT"
  echo "version_suffix=$SUFFIX" >> "$GITHUB_OUTPUT"
  echo "extension=$EXTENSION" >> "$GITHUB_OUTPUT"
  echo "semantic_version=$SEMANTIC_VERSION" >> "$GITHUB_OUTPUT"
}

main "$@"
