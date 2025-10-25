# Compute semantic version

This composite GitHub Action computes a semantic version from provided version number and appends a feature branch prerelease suffix. The action intentionally does not create git tags or publish packages. Instead it emits a small set of outputs so downstream steps in language-specific workflows can decide how to use the version.

## Motivation

C# vs Go: Go tooling commonly uses git tags, and those tags frequently include a leading `v` (for example `v1.2.3`). C# package and CI pipelines typically prefer the plain semantic version (for example `1.2.3`) and do not require a `v` prefix. This action outputs the canonical semantic version (without adding a `v`) so callers can decide whether to prepend `v` when creating tags for Go repositories.

## How it works

- Minimal, composable behavior: By only computing and exposing a version, this action can be reused from pipelines without forcing a git tag or publishing decision on callers.
- Version control responsibility: The canonical version numbers must be provided by the workflow and are managed by the developer. The workflow is the single source of truth and is responsible for propagating the semantic version to other build artifacts if needed.
- Prereleases: feature branches and pull requests often need unique prerelease identifiers so CI can publish or test artifacts without colliding with official releases. The action generates branch/run-based suffixes that combine the branch name and the GitHub run number (for example `1.2.3-feature.42`). The GitHub run number increases with each workflow run, so the suffix provides an automatically-incrementing prerelease identifier — developers working on feature branches don't need to manage version numbers manually. Bumping the version is expected to happen as part of the PR completion / merge (the final release process), not during iterative feature work.

## Trunk-based development

This action assumes a trunk-based development workflow: a single repository default branch (e.g. `main`) is considered the release branch. Long-lived branching models such as Gitflow (with dedicated `release/*` or `support/*` branches) are not supported by this action.

## Inputs

- `major` (required): MAJOR version number, e.g. `1`.
- `minor` (required): MINOR version number, e.g. `2`.
- `patch` (required): PATCH version number, e.g. `3`.

The action relies on the GitHub Actions runtime environment variables (for example `GITHUB_REF`, `GITHUB_HEAD_REF`, `GITHUB_RUN_NUMBER`, and the repository default branch from the event payload) to determine when to append a suffix.

## Outputs

- `semantic_version`: The full semantic version including any suffix, e.g. `1.2.3-feature.123`.
- `version_suffix`: The computed suffix without the leading dash, e.g. `feature.123`.
- `extension`: The string appended to the base version, e.g. `-feature.123`.
- `use_version_suffix`: `true` if a suffix is present, `false` otherwise.

## Behavior / prerelease examples

- Default branch push (release): `major=1`, `minor=2`, `patch=3` → `semantic_version` = `1.2.3` (no suffix)
- Feature branch push: `major=1`, `minor=2`, `patch=3`, branch `feature/x`, run `101` → `semantic_version` = `1.2.3-x.101`
- Pull request: suffix is based on `GITHUB_HEAD_REF` and `GITHUB_RUN_NUMBER` (e.g. `1.2.3-pr-branch.42`)

# Where to use the semantic version number
Use the version number everywhere so you can identify and track artifacts by a single, consistent identifier:

- Program assemblies
- Docker image
- Git Tags
- Workflow name
- Workflow artifact
- API version

## Example workflow

For a sample workflow see the [`ci/cd pipeline`](.github/workflows/cicd.yml) in this repository. It demonstrates passing `major`, `minor`, and `patch` inputs and using the `semantic_version` output to release this GitHub action.
