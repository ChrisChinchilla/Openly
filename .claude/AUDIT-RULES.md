# Rule set audit: updates and improvements

Date: 2026-10-30. Nothing here is implemented. Sources compared:

- Vale style docs (docs.vale.sh/topics/styles and the check, action, scope, vocabulary, package pages)
- `vale-cli/Google` (v0.7.1, Aug 2026), `vale-cli/Microsoft`, `vale-cli/readability`, `vale-cli/write-good`, `vale-cli/proselint`, `vale-cli/alex`
- Newer topic entries: `tbhb/vale-ai-tells`, `dylan-k/hedgeclipper`, `vale-cli/Std`
- Local runs of Vale 3.25.1 against the fixtures and a probe file

Caveat: external rule contents were read for Google, Headings, Passive, WordList, Latin, We, Colons, OxfordComma and a few more. For other styles I only have rule names, so any idea sourced from those needs reading before adoption.

## Priority key

P0 = broken or misleading today. P1 = clear quality gain. P2 = nice to have. S/M/L = effort.

## A. Correctness bugs in existing rules (P0)

| ID | Rule | Problem (verified by running Vale 3.25.1) | Fix | Effort |
| --- | --- | --- | --- | --- |
| A1 | `ThereIs`, `UnclearAntecedent` | Only fire at the start of a paragraph. Probe: "There is a bug. This is a bug." flags only the first. The regex `(?:^[^\w]*\|[;-]\s)` has no sentence-boundary alternative, so mid-paragraph sentences are missed and the golden test fails. | Use `scope: sentence` with `^` anchors, or a lookbehind on `[.?!]\s`. Merge both into one "weak sentence opener" rule with `tokens`. | S |
| A2 | `FutureTense` | `'[\w][ll]'` is a character class `[ll]` (the letter l), not the contraction `'ll`. It matches any two-letter word ending in "l" and only catches "We'll" by accident. Also `will` flags legitimate docs usage ("This will delete the file"). No leading `---`. | Replace with `\w+'ll`; drop `we are going`/`would be` or move to a separate suggestion-level rule; downgrade to suggestion. | S |
| A3 | `A11Y` | `press` at `error` level flags "Press Enter" (keyboard guidance is correct). The swap value `"'select'"` doubles the quotes (`''select''`). Replacing "click" is guidance for touch/accessibility, not an error. | Remove `press`; fix quoting; set level to suggestion; consider also `tap`, `hit`, `hover`. | S |
| A4 | `Punctuation` vs `Spelling` | `eg` and `ie` are reported twice: once by `Punctuation` ("Use 'eg,'") and once by `Spelling` ("Did you really mean 'eg'?"). The rule also tells users to write `eg,` (no stops) which clashes with `pass.md` calling `e.g.` correct. | Add `eg`/`ie` to a tech-terms/accept list; decide on one house form (see Q2); consider Google's `Latin.yml` approach (replace with "for example"/"that is", lookahead `(?=[\s,;]\|$)`). | S |
| A5 | `Link` | Matches only `[here](...)`. Misses "click here", "read more", "this link", "link", bare URLs as text. Probe: `[click here](...)` and `[read more](...)` pass. | Use a `tokens` list with `scope: link` (Vale 3 scope) instead of raw regex; add `exceptions`. | S |
| A6 | `Titles` | Sentence case with no `exceptions`. Probe: "Getting started with GitHub API" is flagged because of the proper noun and acronym. | Add `exceptions` (Google's `Headings.yml` has a long list to borrow), `indicators: [':']` and consider `$title` option per project. Switch to Vale `Packages`-level `vocab`. | M |
| A7 | `Spelling` | Level `error` with `code: false`; `JavaScript` now raises a "Use X" message (good) but the golden file expects the old message. `tech-terms/*.txt` are almost empty (95 terms), so most tech words fail. Includes odd entries (`esint`). | Move to `config/vocabularies/Openly/accept.txt` (Vale 3 vocab, applies to every rule, enforces case); lower to warning; seed from Microsoft/Google/Std vocabularies. See D1. | M |
| A8 | `E-Prime` | Duplicate `here's`; `am`, `being` flagged everywhere; contraction tokens like `i'm` only match with word boundaries around the apostrophe. Documented as "Grammarly-like" but E-Prime is a niche constraint. | De-duplicate; keep as opt-in (default off, see D3). | S |
| A9 | `Anthropomorphism` | `knows` duplicated; `raw` and `tokens` are combined without `append: true`. Per the docs, `raw` is then used on its own and `tokens` is not merged in; the intended noun-plus-verb behaviour should be confirmed with a test. | Make it a `raw` list built from the noun group and verb group explicitly, or use `sequence` with POS tags. | S |
| A10 | `Hyphens` | US-centric entries (`African-American`, `All American`, `Native-American`) and `state-wide` style rules; given the maintainer's European English preference these are wrong defaults. | Split off a `Hyphens` neutral set from US cultural terms. Keep `right click -> right-click`, `e-mail -> email`. | S |
| A11 | `GenderBias` | `landlord -> building manager`, `steward -> flight attendant`, `man enough` etc. at `error`; `fireman` list is copied from write-good era. Several entries are context-dependent. | Downgrade to warning; review each pair; consider replacing with `alex`/Microsoft `BiasFree`. | M |
| A12 | `HeadingsPunctuation` | `link:` points to `https://github.com/Openly/docs/blob/master/STYLE.md` (does not exist). `SentenceLength` link points to an old Mailchimp URL. | Drop `link:` or add an Openly style guide page (see C3). | S |
| A13 | `But`, `So` | `But.yml` uses `action: remove` with `params: [remove, '.?!']`, which is meaningless for `remove`. `So.yml` uses `edit` with an op named `remove`. Harmless today, but unverified; check against docs/actions. | Validate actions (`vale ls-config`, E201 errors) and simplify. | S |
| A14 | `Readability` | Whole-document Flesch only; one number per file, reported at line 1. No grade-level metric. | Use `vale-cli/readability` approach: multiple scores, `scope: paragraph` (Vale 3.22+) so the alert lands on the hard paragraph. | M |
| A15 | `Hedging` | `could`, `might`, `usually` flagged at warning: high false-positive rate in technical writing; `I believe`/`I think` capitalised variants inconsistent (`ignorecase` helps, but `from my point of view` vs `In my opinion` casing differs). | Move weak words (`could`, `might`, `usually`) to a suggestion-level list; keep strong hedges at warning. Compare with `dylan-k/hedgeclipper`. | S |
| A16 | `Clarity` | One entry: `help -> assist`. It is the opposite of plain-language advice ("assist" is longer). | Delete or replace with a real wordiness list (see B2). | S |

## B. Missing coverage versus common rule sets (P1)

Ordered by value for a "Grammarly-like" style.

| ID | New rule | Source of idea | Notes | Effort |
| --- | --- | --- | --- | --- |
| B1 | `Passive` | Google `Passive.yml`, Microsoft `Passive` | Regex: auxiliary verb + past participle list. Level suggestion. Heaviest-used Grammarly-style check and absent today. | M |
| B2 | `Wordiness` / `Redundancy` / `Jargon` | Microsoft `Wordiness`, `write-good` weasel/too-wordy, `proselint` | Substitution tables ("in order to" -> "to", "utilize" -> "use"). Replace `Clarity.yml`. | M |
| B3 | `Adverbs` / `Intensifiers` | Microsoft `Adverbs`, `write-good` | "very", "really", "extremely", `-ly` words as suggestions. | S |
| B4 | `Repetition` ("the the") and double spaces | Built-in `Vale.Repetition`, `Vale.Spelling` | Currently not active because the config uses only `BasedOnStyles = Openly`. Probe: "The the" not caught. Either document `BasedOnStyles = Vale, Openly` or add repetition rule in `Openly`. | S |
| B5 | `Contractions` | Google/Microsoft `Contractions` | Tone: prefer "don't" over "do not" in friendly docs. Note: conflicts with E-Prime; keep tone rules mutually exclusive via config groups (D3). | S |
| B6 | `Acronyms` | Google/Microsoft `Acronyms` (conditional check) | Spell out on first use. Needs an exceptions list. | M |
| B7 | `OxfordComma` | Google (long guarded regex) | Choose one convention first (Q4). European English usually omits it. | M |
| B8 | `Quotes`, `EmDash`, `Ellipses`, `Exclamation`, `Semicolons`, `Colons` | Google/Microsoft | Punctuation hygiene, mostly `existence` with `nonword: true`. Reuse the lookahead pattern from `Latin.yml`. | S each |
| B9 | `Dates`, `Units`, `Ordinal`, `Ranges`, `AMPM` | Google/Microsoft | European date/unit preferences make these natural to localise (24-hour clock, ISO dates). | M |
| B10 | `Inclusive language` / `Terms` | Microsoft `BiasFree`, `Terms`; `alex`; `HeyItsGilbert/vale-agentic` | master/slave, whitelist/blacklist, sanity check, dummy. Separate rule from `GenderBias`. | M |
| B11 | `FirstPerson` / `We` | Google `We`, Microsoft `FirstPerson`/`We` | Tone control for documentation. Opt-in. | S |
| B12 | `Slang` / `Exclamation` / `ExcessiveClaims` | Google | "simply", "just", "easy", "obviously" -> condescension; Grammarly flags these as tone. | S |
| B13 | `Gunning-Fog`, grade-level, `Polysyllables` | `vale-cli/readability` | Pair with A14. | S |
| B14 | `Sequence`-based rules | Vale `sequence` check (POS tags) | Could replace brittle regexes in `Anthropomorphism`, `VerbingNouns`, `Passive`. Needs testing (model download). | L |
| B15 | (Parked) AI-writing tells (separate package) | `tbhb/vale-ai-tells`, `jdkato/voices`, `eugeniughelbur/clearmode` | "delve", "tapestry", "it is worth noting", filler openers. Do as its own style (`Openly-AI`) so it can be switched off. | M |
| B16 | Non-English variants | `geensnor-stijl-vale`, `vale-style-es-rae`, Harper | Out of scope unless localisation is a goal. | L |

## C. Authoring-practice gaps (P1/P2)

Measured against docs.vale.sh/topics/styles.

| ID | Gap | Current state | Recommendation |
| --- | --- | --- | --- |
| C1 | `link:` on every rule | Only 4 rules have one; two are dead links | Add a short anchored page per rule group in README or a `docs/` file, link each rule to it. |
| C2 | `action:` fixes | Only ~5 rules provide fixes | Add `replace` actions to all `substitution` rules (so editors can quick-fix) and `remove` for hedges/intensifiers. |
| C3 | `scope:` | Mostly default `text` | Use `sentence`, `heading`, `link`, `summary`, `~code`, `~blockquote` deliberately. Rules like `Hedging` should skip headings and quoted text. |
| C4 | `exceptions:` | Used nowhere | Add per rule where it earns its keep (Titles, Hedging, A11Y). |
| C5 | Rule inheritance (`extends: Style.Rule`, Vale 3.20+) | Unused | Would let a strict/gentle variant share one definition. Verify min Vale version first. |
| C6 | `limit:` | Unused | Cap noisy rules (Hedging, E-Prime) per file. |
| C7 | `matchcase` / `capitalize` on substitution | Unused | Fixes capitalised replacements ("Press" -> "Select"). |
| C8 | `description:` | Unused | One line per rule for editors/LSP. |
| C9 | Levels | `error` on style preferences (A11Y, But, So, GenderBias, Spelling, QuoteType) | Only `error` fails CI. Reserve for objective errors (spelling, repeated words, broken terms); style choices go to warning/suggestion. |
| C10 | `---` and header consistency | Mixed | Settle on one header form; enforce in `.yamllint.yml`. |
| C11 | Dead rule wiring | `Spelling.ignore` lists 19 files, most empty | Collapse to vocab (D1). |
| C12 | Comments | Almost none | Follow Google: cite the false-positive that justifies each guard. |

## D. Packaging, configuration and docs (P1)

| ID | Item | Detail |
| --- | --- | --- |
| D1 | Vocabulary | Vale 3 supports `config/vocabularies/<Name>/accept.txt` and `reject.txt`; `accept` entries are exact-case and flow into every rule's exceptions. Replace `tech-terms/*.txt` + `Spelling.ignore`. Package shape: a zip with `Openly/` plus `config/vocabularies/...` (needs the "styles + config" layout, so the zip becomes `styles/Openly` + `.vale.ini`). Decide between "style-only" and "both" package shapes (Q5). |
| D2 | `meta.json` | Currently at repo root with `vale_version: v1.7.1` and a stale feed. Move into `Openly/`, set `vale_version` to the real minimum (3.x) and add a `releases` manifest or correct `feed`. Add `license_files: ["LICENSE"]` like Google; copy `LICENSE` into the zip at release time. |
| D3 | Preset configs | Ship example `.vale.ini` variants: `strict` (docs), `friendly` (blog/marketing), `minimal`. Because many tone rules conflict (contractions vs E-Prime, hedging vs conversational), grouping matters. Needs rule-level `NO/YES` documentation. |
| D4 | README | Stale: Travis badge, "Vale >= v1.7.0", owner mismatch, no rule list, no rationale per rule, no contributing guide (`CONTRIBUTING.md` is one line). Add rule table, severity philosophy, how to override levels. |
| D5 | CHANGELOG | Contains only a TODO. Switch to generated release notes or Keep a Changelog. |
| D6 | Dog-food | Run `vale README.md` in CI (Google does). |

## E. Testing and CI (P0/P1)

| ID | Item | Detail |
| --- | --- | --- |
| E1 | Test suite is broken and unused | See PROJECT.md: golden file mismatches on Vale 3.25.1, and CI never runs Cucumber. Either repair or replace. |
| E2 | Replace Cucumber/Aruba | Vale 3 has `vale test` and rule-level `tests:`. Google/Microsoft use one fixture dir per rule with isolated `.vale.ini` and golden `.ct` files via go-cmdtest. Recommend: per-rule fixtures with `pass`/`fail` cases, checked by a small shell script in CI. Drops Ruby (`Gemfile`, `.ruby-version`, `.travis.yml`). |
| E3 | Coverage manifest | Microsoft/Google keep a `coverage/` file mapping guideline topics to implementing rules, enforced by a test. Gives Openly a traceable "which Grammarly features do we cover" matrix. |
| E4 | Matrix across Vale versions | Test against minimum supported Vale and latest. |
| E5 | Real-world corpus | Google's Latin rule was tuned on a 950-file corpus. Add a few real docs under `fixtures/real/` to catch false positives (current `real.md` is 4 lines). |
| E6 | Lint the rules | `vale styles/Openly` (3.22+) and `vale ls-config` in CI to catch invalid keys/actions (E201). |
| E7 | CI hygiene | Covered by AUDIT-SECURITY. |

## F. Suggested roadmap

1. Phase 0 (fix what is broken): A1, A2, A3, A4, A12, E1/E2 minimal (get a green test), security S1 to S6.
2. Phase 1 (foundation): D1, D2, C9 (re-level), C1/C2/C3 (links, actions, scopes), A5, A6, A7.
3. Phase 2 (coverage): B1, B2, B3, B4, B5, B10, A14/B13 readability.
4. Phase 3 (polish): B6 to B9, B11/B12, D3 presets, E3 coverage manifest, D4/D5 docs.
5. Phase 4 (optional): B14 sequence-based rules, B15 AI-tells package, B16 localisation.

## G. Decisions (2026-10-30)

| Question | Decision | Consequence |
| --- | --- | --- |
| Audience | Product and technical documentation | Weak hedges, `We`, first person and future tense become suggestions or opt-in; no tone-for-marketing rules. |
| e.g./i.e. form | `e.g.,` and `i.e.,` | Reverse the `Punctuation` rule (currently forces `eg,`); keep `Spelling` from flagging them; Google `Latin.yml` lookahead pattern is the model. |
| English variant | US English with Oxford comma | Add `OxfordComma` (B7); `Hyphens` US entries (A10) stay valid; do not adopt British-spelling rules. Differs from the maintainer's personal preference, so it is project-specific. |
| Package shape | See recommendation below | |
| Repository | `ChrisChinchilla/Openly`, branch `main` | Update README, `meta.json` feed, badges. Local branches `develop` and `refactor` deleted (fully merged). Remote branch deletion is pending (see below). |
| `todo-issue.yml` | Keep | Pin by SHA and add `permissions: contents: read, issues: write` (S3/S4). |

### Recommendation: package shape (Q4)

Per the current Vale docs, use the "both" shape: a `styles/` directory that is itself a StylesPath, plus a `.vale.ini`, in one release zip named `Openly.zip`:

```
Openly/
  .vale.ini                      # StylesPath = styles; Vocab = Openly; BasedOnStyles = Vale, Openly
  styles/
    Openly/*.yml  meta.json  LICENSE
    config/vocabularies/Openly/accept.txt, reject.txt
```

Why: vocabularies (`accept.txt`/`reject.txt`) replace `tech-terms/*.txt` plus `Spelling.ignore`, apply to every rule and enforce exact case; the bundled `.vale.ini` can ship presets; `meta.json` with `vale_version` (3.23+) and a `releases` manifest lets `vale sync` pick a compatible release. Consumers still use `Packages = <release URL>`. Pin the minimum Vale to 3.23 unless a feature needs more. Rule inheritance (3.20+) lets strict and gentle variants share one definition. Retire the Cucumber harness for `vale test`-style fixtures.

Trade-off: consumers who copy the `Openly/` folder by hand (README option 2) need updated instructions. Pre-1.0, so a breaking change is acceptable; note it in the release notes.

### Pending

- Delete remote branches `master`, `develop`, `refactor`, `ChrisChinchilla-patch-1`, `ChrisChinchilla-patch-2`, `copilot/improve-e-g-i-e-rule` (all merged into `main`). Blocked by a permission denial in this session.
- `origin` still points at `git@github.com:testthedocs/Openly.git`; GitHub redirects to `ChrisChinchilla/Openly`. Run `git remote set-url origin git@github.com:ChrisChinchilla/Openly.git` when ready.

## H. Remaining open questions

Answered 2026-10-30:

- Minimum Vale version: 3.23 accepted as the floor.
- AI-tell detection (B15): parked. It means rules that flag wording typical of LLM output ("delve", "it's worth noting"). Revisit after Phase 3; if built, make it a separate optional style. Generic filler and wordiness checks (B2, B3) stay in the core.
- Grammarly feature list for the coverage manifest (E3): a future task. Not blocking.

Open: none.
