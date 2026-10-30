# Openly: project knowledge

Last updated: 2026-10-30. Audit only, nothing implemented yet. See [AUDIT-RULES.md](AUDIT-RULES.md) and [AUDIT-SECURITY.md](AUDIT-SECURITY.md).

## What it is

A Vale style (YAML rules, no code) that approximates Grammarly-type checks: clarity, tone, hedging, inclusive language, readability, spelling. Distributed as `Openly.zip` (a single top-level `Openly/` folder) via GitHub releases and consumed through Vale `Packages`.

- Origin: `testthedocs/Openly` (remote `origin`). Maintained by Chris Chinchilla. MIT licence, copyright "2019 TestTheDocs - Incubator".
- Git: canonical repo `ChrisChinchilla/Openly`, branch `main` (decided 2026-10-30). Local `develop` and `refactor` deleted; remote branches pending deletion. `origin` URL still `testthedocs/Openly`.
- Local Vale: 3.25.1 (`/opt/homebrew/bin/vale`). CI pins 3.12.0; the release-on-tag workflow pins 3.4.2; `meta.json` says `v1.7.1`.

## Layout

| Path | Purpose |
| --- | --- |
| `Openly/*.yml` | 21 rules (see table below) |
| `Openly/tech-terms/*.txt` | 19 word lists, ~95 terms in total (most are empty or one line); all are wired into `Spelling.yml` `ignore:` |
| `features/`, `fixtures/basic/` | Cucumber/Aruba golden-output test: runs Vale over three Markdown files and compares to `features/rules.feature` |
| `.github/workflows/` | `ci.yml`, `release.yml`, `release-on-tag.yml`, `codeql.yml`, `todo-issue.yml` |
| `.travis.yml` | Dead (Travis CI), still referenced by the README badge |
| `meta.json` | Package metadata (note: sits at repo root, not inside `Openly/`) |
| `.yamllint.yml` | Disables `document-start` and `line-length` |

## Rules

| Rule | Check | Level | Notes |
| --- | --- | --- | --- |
| A11Y | substitution | error | click/press -> "select" |
| Anthropomorphism | existence | warning | software nouns + verbs like "thinks" |
| But | existence | error | paragraph starts with "But" |
| Clarity | substitution | warning | only `help: assist` |
| E-Prime | existence | suggestion | forms of "to be" |
| FutureTense | existence | warning | `will`, `'ll`, "would be" |
| GenderBias | substitution | error | ~40 gendered terms |
| HeadingsPunctuation | existence | warning | trailing `:` or `.` in headings |
| Hedging | existence | warning | ~25 hedge words |
| Hyphens | substitution | warning | mostly US-centric compounds |
| Link | existence | error | `[here](...)` only |
| Punctuation | substitution | warning | forces `eg,` / `ie,` |
| QuoteType | consistency | error | smart vs straight quotes |
| Readability | metric | warning (default) | Flesch reading ease < 70, whole document |
| SentenceLength | occurrence | warning | > 25 words |
| So | existence | error | sentence starts with "So" |
| Spelling | spelling | error | default en_US + tech-terms ignore lists |
| ThereIs | existence | error | sentence starts "There is/are" |
| Titles | capitalization | warning | headings in sentence case |
| UnclearAntecedent | existence | error | sentence starts "This is/are" |
| VerbingNouns | existence | suggestion | "perform validation" -> "validate" |

## Conventions seen in the repo

- Rules use `extends: existence|substitution|...`, `message`, `level`; most omit `link`.
- Several rules begin with `---`, some do not.
- Many rules were evidently copied from 18F/Vale `write-good`/Microsoft styles (the `HeadingsPunctuation` link points to a nonexistent `Openly/docs` repo, `SentenceLength` links to a Mailchimp guide).
- User preference (global CLAUDE.md): British/European English; suggest commit messages, never commit unprompted.

## Known state of the test suite

`cucumber` is not run in CI (only `yamllint` is). Against Vale 3.25.1 the golden file already fails:

- `ThereIs` and `UnclearAntecedent` no longer fire mid-paragraph (3 expected lines missing).
- `QuoteType` message shows `'”'` rather than `'"'`, and one expected alert is missing.
- `Spelling` now reports `Use 'JavaScript' instead of 'javascript'.`
- "pass.md" produces 9 alerts, so the fixture names are misleading.

## Open questions for the maintainer

See the end of [AUDIT-RULES.md](AUDIT-RULES.md).

## Decisions (2026-10-30)

Audience: product and technical documentation. Abbreviations: `e.g.,` and `i.e.,`. US English with Oxford comma. Keep `todo-issue.yml`. Package shape recommendation and pending items: AUDIT-RULES.md section G.
Minimum Vale version: 3.23. AI-tell rules (B15) parked. Coverage manifest from a Grammarly feature list: future task.

## Phase 0 progress (2026-10-30)

Done, uncommitted: rule fixes (ThereIs, UnclearAntecedent, FutureTense, A11Y, Punctuation, Link, dead links, eg/ie spelling); Cucumber/Ruby harness replaced by `tests/run.sh` (golden `fixtures/*/expected.txt`, `--update` to regenerate); `pass.md` now produces zero alerts; workflows reduced to `ci.yml`, `release.yml` (tags `v*`), `codeql.yml` (actions language), `todo-issue.yml`, all pinned by SHA with least-privilege permissions; Vale 3.25.1 installed with checksum; Dependabot for Actions; `.travis.yml`, `release-on-tag.yml`, `Gemfile*`, `.ruby-version` removed. Security findings S1 to S8, S12, S13 addressed. Not yet done: S9 (provenance), S10 (`meta.json`), S11 (README owner partly), package restructure (AUDIT-RULES section G).
