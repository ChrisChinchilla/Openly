# Security audit

Date: 2026-10-30. Scope: whole repository, including CI. The repo contains no executable code, only YAML rules, word lists and a Ruby test harness, so the risk sits in CI and the release pipeline (consumers install the zip straight into their lint setup).

## Result in brief

- No secrets, credentials or keys committed. A grep for key/token patterns matched only `secrets.GITHUB_TOKEN` references in workflows.
- Regex denial of service: no catastrophic patterns found. `Punctuation.yml`, `So.yml` and others use lookarounds, which plain Go RE2 does not support, so Vale must use a backtracking engine for them. The patterns are short and simple, so the risk is low, but it is worth keeping new lookaround rules simple.
- Main exposure: unpinned, partly archived Actions with no least-privilege `permissions`, and three overlapping release workflows.

## Findings

| # | Severity | Finding | Fix |
| --- | --- | --- | --- |
| S1 | High | `release-on-tag.yml` uses archived `actions/create-release@v1` and `actions/upload-release-asset@v1` with no `permissions:` block, so it relies on the repo default token scope (may be read-write). | Delete the workflow; keep one release path. |
| S2 | High | Three workflows can publish `Openly.zip`: `ci.yml` (on `release: created`), `release.yml` (any tag `*`) and `release-on-tag.yml` (tags `v*`). A `v*` tag triggers two of them and can race or double-upload. | Keep only `release.yml`, restrict tags to `v*`, add `permissions: contents: write` at job level only. |
| S3 | Medium | No workflow pins Actions to commit SHAs (`@v4`, `@v1`, `@v2`). Third parties: `ncipollo/release-action`, `alstr/todo-to-issue-action`, `ruby/setup-ruby`. A moved tag would run in a job holding a write token. | Pin to SHAs, add Dependabot for `github-actions`. |
| S4 | Medium | `ci.yml`, `codeql.yml` (partly), `todo-issue.yml` lack top-level `permissions:`. `todo-issue.yml` runs a third-party action on every PR with the default token. | Add `permissions: contents: read` at top; grant `issues: write` only where needed. Consider dropping `todo-issue.yml` (see Q3). |
| S5 | Medium | Vale is downloaded with `wget` and extracted with no checksum verification, in three places and at three versions (3.12.0, 3.4.2, Travis 3.4.2). | Use `errata-ai/vale-action` pinned by SHA, or verify the published SHA-256 before extracting. |
| S6 | Medium | `pip install markdata` (unpinned, unused by anything in the repo), plus unpinned `yamllint` and `pyyaml`. Unused packages are pure supply-chain surface. | Remove `markdata` and `pyyaml`; pin `yamllint==x.y.z` or use a hashed requirements file. |
| S7 | Low | `codeql.yml` targets `javascript` but the repo has none, and uses deprecated `codeql-action@v2` / `checkout@v3`. The scan analyses nothing and gives false assurance. | Switch to `actions` language (scans workflows) with `@v3`, or remove. |
| S8 | Low | `actions/setup-python@v4`, `python-version: '3.6'` (release-on-tag) is unavailable on current `ubuntu-latest`; the job fails, so the release path is likely broken today. | Folded into S2 (delete). |
| S9 | Low | Release zip is unsigned and has no checksum or provenance; consumers using `Packages = <url>` trust the URL alone. | Publish a `.sha256` asset and enable `actions/attest-build-provenance`. |
| S10 | Low | `meta.json` (`vale_version: v1.7.1`, `feed` pointing at `testthedocs/openly`) sits outside the `Openly/` folder, so it is not in the zip and Vale never reads it. Stale feed URL means `vale sync` may follow the wrong repo. | Move into `Openly/`, update `feed` and `vale_version` (see AUDIT-RULES R-pkg). |
| S11 | Info | README install URL uses `ChrisChinchilla/Openly`; `origin` is `testthedocs/Openly`. Users could pull from an unexpected owner after a repo move. | Decide on the canonical owner and make README, `meta.json` and badges agree. |
| S12 | Info | `.gitignore` contains only `.DS_Store`; `tmp/` (Aruba working dir) is untracked but not ignored. | Ignore `tmp/`, `.vale-config/`, `*.zip`. |
| S13 | Info | `.travis.yml` is dead config that still holds a `deploy.api_key: $GITHUB_TOKEN` reference. No secret is exposed, but dead deploy config invites confusion. | Delete. |
| S14 | Info | Ruby 2.7 (EOL) in `release-on-tag.yml`; `.ruby-version` and `Gemfile.lock` (bundler 2.5.9, `arm64-darwin-23`) are local-machine specific. | Update with the test-harness decision. |

## Rule-content risks (non-technical)

- `GenderBias` and `Hyphens` embed opinionated or US-centric substitutions at `error` level (for example `landlord -> building manager`, `African-American -> African American`). They do not harm users technically, but at `error` level they can fail a consumer's CI build on unobjectionable text. Treated as a quality issue in AUDIT-RULES.
- `Spelling` at `error` level with a small allow-list will fail builds for any ordinary product or proper name.

## Status (2026-10-31)

Addressed in commits `45a3e92` onward: S1, S2, S3, S4, S5, S6, S7, S8, S12, S13, S14. Open: S9, S10. S11 is resolved in the README; only the `origin` remote URL differs. The workflows have run once; CodeQL output was not yet reviewed.

## Suggested order

1. S1, S2, S8, S13: remove the redundant release workflows and Travis config.
2. S3, S4, S5, S6: harden the one remaining pipeline.
3. S7, S9, S10, S12: housekeeping.
