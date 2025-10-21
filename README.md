Compute semantic version

This composite GitHub Action computes a semantic version from a provided MAJOR.MINOR.PATCH and optionally appends a branch/run-based suffix for pull requests and feature branch pipelines.

Inputs

- `major_minor_patch` (required): Base semantic version, e.g. `1.2.3`.

This action always uses the repository default branch value supplied by the event payload to decide whether to append a feature suffix.

Note: this action assumes a trunk-based development workflow (a single default branch `main`). Workflows such as Gitflow that rely on long-lived release/support branches are not supported.

Outputs

- `semantic_version`: The full semantic version including any suffix, e.g. `1.2.3-feature.123`.
- `major_minor_patch`: The base version passed in.
- `version_suffix`: The computed suffix without the leading dash, e.g. `feature.123`.
- `extension`: The string appended to the base version, e.g. `-feature.123`.
- `use_version_suffix`: `true` if a suffix is used; `false` otherwise.

Example usage

In your workflow file (e.g. `.github/workflows/release.yml`):

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Compute semantic version
        uses: ./.github/actions/compute-semantic-version-action
        with:
          major_minor_patch: '1.2.3'

      - name: Show version
        run: |
          echo "Semantic version: ${{ steps.compute.outputs.semantic_version }}"
```

If you publish this action in a repository you can reference it by `owner/repo@v1` or a tag. The action is implemented as a composite action using Bash and requires GitHub Actions runner environment variables (e.g. `GITHUB_REF`, `GITHUB_RUN_NUMBER`, `GITHUB_HEAD_REF`).
