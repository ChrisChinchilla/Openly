# Openly: project knowledge

Last updated: 2026-10-31. Phase 0 (rule fixes, tests, release workflow) committed; later phases not started. See [AUDIT-RULES.md](AUDIT-RULES.md) and [AUDIT-SECURITY.md](AUDIT-SECURITY.md).

## What it is

A Vale style (YAML rules, no code) that approximates Grammarly-type checks: clarity, tone, hedging, inclusive language, readability, spelling. Distributed as `Openly.zip` (a single top-level `Openly/` folder) via GitHub releases and consumed through Vale `Packages`.

- Origin: `testthedocs/Openly` (remote `origin`). Maintained by Chris Chinchilla. MIT licence, copyright "2019 TestTheDocs - Incubator".
- Git: canonical repo `ChrisChinchilla/Openly`, branch `main`. Local branches cleaned up; remote still has `develop` (merged, safe to delete). `origin` URL still `git@github.com:testthedocs/Openly.git` (redirects).
- Local Vale: 3.25.1 (`/opt/homebrew/bin/vale`). CI pins 3.25.1 with a SHA-256 check. `meta.json` still says `v1.7.1` (stale; target floor is 3.23).

## Layout

| Path | Purpose |
| --- | --- |
| `Openly/*.yml` | 21 rules (see table below) |
| `Openly/tech-terms/*.txt` | 19 word lists, ~95 terms (most empty or one line); all wired into `Spelling.yml` `ignore:`. |
| `tests/run.sh`, `fixtures/<name>/` | Golden-file tests: runs Vale over each fixture folder and diffs against `expected.txt`; `--update` regenerates |
| `.github/workflows/` | `ci.yml` (yamllint + `tests/run.sh`), `release.yml` (tags `v*`, zip + sha256), `codeql.yml` (`actions` language), `todo-issue.yml` (push to `main` only); all actions pinned by SHA, minimal `permissions`. `.github/dependabot.yml` keeps pins current |
| `meta.json` | Package metadata (still at repo root, not inside `Openly/`; stale) |
| `.yamllint.yml` | Disables `document-start` and `line-length` |

## Rules

| Rule | Check | Level | Notes |
| --- | --- | --- | --- |
| A11Y | substitution | suggestion | click -> "select"; skips right-click and double-click |
| Anthropomorphism | existence | warning | software nouns + verbs like "thinks" |
| But | existence | error | paragraph starts with "But" |
| Clarity | substitution | warning | only `help: assist` |
| E-Prime | existence | suggestion | forms of "to be" |
| FutureTense | existence | suggestion | `will`, `\w+'ll`, "is/are/am going to" |
| GenderBias | substitution | error | ~40 gendered terms |
| HeadingsPunctuation | existence | warning | trailing `:` or `.` in headings |
| Hedging | existence | warning | ~25 hedge words |
| Hyphens | substitution | warning | mostly US-centric compounds |
| Link | existence | error | link text (`scope: link`) such as here, click here, read more |
| Punctuation | substitution | warning | forces `e.g.,` / `i.e.,` (with replace action) |
| QuoteType | consistency | error | smart vs straight quotes |
| Readability | metric | warning (default) | Flesch reading ease < 70, whole document |
| SentenceLength | occurrence | warning | > 25 words |
| So | existence | error | sentence starts with "So" |
| Spelling | spelling | error | default en_US + tech-terms ignore lists |
| ThereIs | existence | error | sentence starts "There is/are" (any sentence, not just paragraph start) |
| Titles | capitalization | warning | headings in sentence case |
| UnclearAntecedent | existence | error | sentence starts "This is/are" (any sentence) |
| VerbingNouns | existence | suggestion | "perform validation" -> "validate" |

## Conventions seen in the repo

- Rules use `extends: existence|substitution|...`, `message`, `level`; most omit `link`.
- Several rules begin with `---`, some do not.
- Many rules were evidently copied from 18F/Vale `write-good`/Microsoft styles (the `HeadingsPunctuation` link points to a nonexistent `Openly/docs` repo, `SentenceLength` links to a Mailchimp guide).
- User preference (global CLAUDE.md): British/European English; suggest commit messages, never commit unprompted.

## Test suite

`tests/run.sh` runs in CI. Two checks per fixture folder: files named `pass*.md` must raise no alerts, and the full Vale output must match `expected.txt`. `fail*.md` and other files are meant to raise alerts; Vale finding problems there shows the rules work, so alerts are recorded, not treated as failures. After an intentional rule change: `tests/run.sh --update`, then review the diff.

Decision (2026-10-31): `eg` and `ie` are incorrect terms under the house style, so they are not added to the spelling allow-list. `Spelling` and `Punctuation` both reporting them on `fail.md` is accepted and recorded in `expected.txt`. Possible later cleanup: make only one of the two rules report them.

Coverage: `tests/run.sh` also fails if any rule in `Openly/` raises no alert in any fixture, so a new rule needs a failing example. All 21 rules are covered (`fail.md`, `fail-more.md`); `pass.md` includes a clean heading and the compliant forms of the newly covered rules.

## Open questions for the maintainer

See the end of [AUDIT-RULES.md](AUDIT-RULES.md).

## Decisions (2026-10-30)

Audience: product and technical documentation. Abbreviations: `e.g.,` and `i.e.,`. US English with Oxford comma. Keep `todo-issue.yml`. Package shape recommendation and pending items: AUDIT-RULES.md section G.
Minimum Vale version: 3.23. AI-tell rules (B15) parked. Coverage manifest from a Grammarly feature list: future task.

## History

- 2026-10-30: audit written; Phase 0 rule fixes, test harness replacement and release workflow clean-up.
- 2026-10-31: pass/fail test semantics made explicit; rule-coverage check added and the five uncovered rules (Readability, Clarity, So, VerbingNouns, HeadingsPunctuation) given failing examples. **Test-suite update complete.**

## Status

Phase 0 done and committed (2026-10-30/31): fixes to ThereIs, UnclearAntecedent, FutureTense, A11Y, Punctuation, Link; dead links removed; Cucumber/Ruby/Travis removed; one release workflow; workflows hardened. Security findings S1 to S8, S12, S13 addressed.

Still open: S9 (release provenance), S10 (`meta.json` move and update), package restructure (AUDIT-RULES section G), remote `develop` branch, `origin` URL, `Titles` exceptions (A6), the remaining AUDIT-RULES items (Phases 1 to 4). Workflow action versions were taken from the GitHub API and have run once on GitHub (the latest `main` CI run failed on the `expected.txt` mismatch fixed in this change; CodeQL result not yet checked).
