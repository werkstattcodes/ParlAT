# ParlAT `dev` to `master` Release Plan

## Summary

The substantive changes approved for `v0.1.0` are implemented on `dev`, and
all GitHub Actions checks pass at `bc582d3`. The academic-title heuristic is
intentionally deferred. A live documentation audit found several stale or
non-executable examples that must be corrected or explicitly accepted before
the release metadata and final release gate. This plan targets a GitHub-only
release; CRAN administrative requirements are out of scope.

## Current Status (2026-09-02)

Completed:

- `get_items()` person/institution semantics, unmatched-person behavior,
  institution aliases, documentation, examples, and regressions.
- Exact all-period website links for `get_items()`,
  `get_plenary_meetings()`, and `get_transcripts()` without changing their
  unrestricted API requests.
- The `get_events()` all-date API behavior and reproducible website link are
  implemented and documented. Its focused suite passed locally, but the pushed
  commit exposed a cross-platform date/timezone failure in Linux CI.
- The `get_events()` changes are committed as `b4cf07b`
  (`Fix all-date event searches and links`) and pushed to `origin/dev`.
- The `get_events()` timezone portability failure from GitHub Actions run
  33539804251 is corrected locally and covered by exact historical, winter,
  daylight-saving, and echo result-invariance tests.
- Commits `55a3a84`, `93470ca`, and `75c43ca` are pushed to `origin/dev`.
- R CMD check, test coverage, and pkgdown GitHub Actions pass at `75c43ca`.

Still required before release:

- Resolve the documentation-example findings recorded on 2026-09-03.
- Set the package and NEWS release version to `0.1.0`.
- Run the final documentation, full mocked tests, package check, and GitHub
  Actions release gate on the release-metadata commit.
- Merge `dev` into `master`, tag `v0.1.0`, and publish the GitHub release.

## Decision Log

### 2026-08-31

- Approved subitem 1A: when `person` and `institution` are both supplied to
  `get_items()`, resolve the person across all person-institution categories and
  apply `institution` only to the returned parliamentary items. Do not pass the
  item chamber to `get_persons()`.
- Document that distinction in the `institution` and `person` parameter text
  and in the function details. Add a `Kurz Sebastian` example combining
  `person = "Kurz Sebastian"` with `institution = "Nationalrat"`, noting that
  `"NR"` is equivalent.
- Implementation was initially deferred until the unmatched-person behavior in
  subitem 1B had also been decided.
- Approved subitem 1B: an unmatched `get_items(person = ...)` search emits an
  informational message, returns the standard typed zero-row item result, and
  does not call the item API.
- Implemented subitems 1A and 1B in code, documentation, examples, NEWS, and
  regression tests. The focused `get_items` suite passes with 96 tests, zero
  failures, zero warnings, and six expected live-only skips; roxygen help was
  regenerated without retaining unrelated roxygen-version changes. Committed
  on `dev` as `55a3a84` (`Fix get_items person filtering`).
- Approved a follow-up public-input enhancement: `get_items(institution =)`
  accepts `"Nationalrat"` and `"Bundesrat"` as aliases for `"NR"` and `"BR"`.
  All values are normalized to the existing API codes before downstream
  validation and request construction.
- Implemented the aliases in code, documentation, generated help, NEWS, and a
  network-free regression covering all four accepted values. The alias and
  person-filter regressions pass with seven expectations and no failures,
  warnings, or skips. The complete fixture-heavy `get_items` test file exceeded
  the two-minute command limit and will be rerun as part of the release gate.

### 2026-09-01

- The initial hypothesis that the stale `/gegenstaende/index.html` path alone
  caused the broken echo link was disproven: the equivalent
  `/gegenstaende?...` URL also shows no results.
- Confirmed a mismatch between API and website defaults. When `GP_CODE` is
  omitted, the data API interprets the request as all legislative periods, but
  the website restores its default `GP_CODE = "XXVIII"`. For NR and Sebastian
  Kurz (`PAD_INTERN = 65321`), the API returns 2,685 items without `GP_CODE` and
  zero items with `GP_CODE = "XXVIII"`.
- The website filter-form endpoint reproduces the UI observation: Kurz is not
  an available person under NR plus XXVIII, but is available when all periods
  are explicitly selected. That request also returns the expected 2,685 items.
- The recent person-filter and chamber-alias changes did not alter URL
  composition; they exposed an older semantic mismatch in echo links whenever
  `legis_period = NULL`.
- Rejected alternatives: do not suppress or weaken the website link, and do
  not use `GP_CODE=null`; the latter returns zero items.
- Decision: exact regeneration of package results on the Parliament website is
  a release requirement; do not suppress or weaken the echo link. When
  `legis_period = NULL`, generate an explicit all-period URL by repeating
  `FP_001GP_CODE` for every period with available data: V through XXVIII plus
  the special codes KN and PN. Add regression coverage for URL composition.
- Browser validation completed by the user: the candidate Sebastian Kurz URL
  with repeated all-period parameters opens the Parliament website with the
  expected results across all legislative periods.
- Implemented the validated echo behavior in `.get_items_echo_request()`.
  `get_items()` keeps omitting `GP_CODE` from the API body when
  `legis_period = NULL`, but its website URL explicitly repeats
  `FP_001GP_CODE` for V through XXVIII, KN, and PN. Explicit period selections
  remain unchanged, and the URL now uses the canonical `/gegenstaende` route.
- Updated the `legis_period` parameter and details documentation: `NULL` means
  an unrestricted search across all available periods, including records under
  KN and PN. Updated `NEWS.md` and regenerated `man/get_items.Rd`.
- Added focused regressions for the all-period URL and explicit-period
  preservation. Together with the chamber-alias and person/institution tests,
  47 focused expectations pass with no test failures or test warnings. `air`
  remains unavailable in the environment.
- Committed the chamber aliases, all-period website-link behavior,
  documentation, NEWS entry, and tests as `93470ca` (`Improve get_items
  institution and period handling`). The untracked release plan was excluded
  from the commit.
- Follow-up echo-link audit confirms the website-default mismatch is broader
  than `get_items()`:
  - `get_plenary_meetings(legis_period = NULL)` omits
    `PLENAR_701GP_CODE`, while the plenary website restores
    `GP_CODE = "XXVIII"`. For NR meetings, the API returns 3,889 rows without
    a period versus 93 for XXVIII. Explicitly selecting I through XXVIII plus
    KN and PN restores all 3,889. The same exact-total behavior was confirmed
    for BR (1,205) and BV (19).
  - `get_transcripts(legis_period = NULL)` omits `STENO_211GP_CODE`, while the
    transcript website restores XXVIII. The API returns 6,847 rows without a
    period versus 232 for XXVIII; I through XXVIII plus KN and PN restores the
    exact 6,847.
  - `get_events()` has the analogous non-period mismatch when neither a period
    nor dates are supplied: the API omits its date/view restrictions, while the
    website restores a today-onward date range plus `SICHT = "S"` and
    `VERFUEGBAR = "J"`.
  - The historical `get_mps()` search, `get_persons()`, and person-detail tabs
    have empty website defaults and are not affected by this period issue.
    Committee searches require a period, and current-MP searches intentionally
    use active-membership defaults.
- Treat exact echo-link reproduction as a cross-function release requirement.
  Approved sequencing: fix plenary meetings and transcripts together, then
  investigate and handle the different event-page date/view defaults
  separately.
- Implemented shared helpers in `R/utils-shared.R` for the Parliament website's
  complete period-code set and for augmenting echo-only JSON bodies. API request
  bodies remain unchanged. `get_items()` now uses the shared helper without
  changing its validated V-through-XXVIII-plus-KN/PN behavior.
- `get_plenary_meetings(legis_period = NULL)` now builds its website/referrer URL
  with repeated period parameters for I through XXVIII, KN, and PN. The same
  URL builder preserves explicit period vectors and covers NR, BR, and BV.
- `get_transcripts(legis_period = NULL)` now uses an echo-only body containing
  I through XXVIII, KN, and PN, and its URL uses the canonical `/protokolle`
  route. Explicit periods and the unrestricted API body remain unchanged.
- Updated roxygen documentation, generated Rd files, and `NEWS.md`. The plenary
  documentation now distinguishes explicit filters (20th period onward) from
  `NULL` (all available periods); transcript documentation explains the exact
  all-period website link and corrects the documented `echo` default to `TRUE`.
- Seven focused tests covering the shared helper, existing `get_items()` link,
  plenary URLs, transcript URLs, and the plenary NULL-period integration path
  pass with 57 expectations and no failures. `air` remains unavailable.
- Committed the shared all-period link infrastructure, plenary/transcript
  implementations, documentation, NEWS entry, and focused tests as `75c43ca`
  (`Fix all-period plenary and transcript links`). The untracked release plan
  was excluded from the commit.
- Pushed commits `55a3a84`, `93470ca`, and `75c43ca` to `origin/dev`. GitHub
  Actions passed for the resulting `75c43ca` branch head: R CMD check, test
  coverage, and pkgdown all completed successfully.
- Investigated the `get_events()` date/view-default mismatch. With NR and
  `event_type = "Plenarsitzung"`, the unrestricted API returns 3,949 events
  from 1920 through 2027, while the website's today-onward default returns 27.
  The website also restores `SICHT = "S"` and `VERFUEGBAR = "J"` when those
  URL parameters are absent.
- Approved a response-derived echo design. Keep the API request unrestricted,
  but build a separate website-only body using the earliest returned event date
  and every distinct `VERFUEGBAR` code present in the result. This suppresses
  the website defaults without a new public argument or network request and
  matched live totals exactly for the plenary example (3,949) and an unfiltered
  search (24,975).
- Include the related default-call repair: a completely empty event filter is
  currently serialized as JSON `[]`, which the live endpoint rejects; serialize
  it as `{}` so `get_events()` returns all events as documented. Preserve the
  user's concurrent roxygen link-text edit in `R/get_events.R`.
- Implemented the approved `get_events()` design. Empty filters now serialize
  as `{}`, while the website-only echo body derives its lower date bound and
  distinct availability codes from the returned rows. The canonical
  `/aktuelles/termine` route is used, with no new argument or network request.
- Updated the function documentation, generated Rd file, and `NEWS.md`, and
  added regression tests for empty JSON-object serialization, derived echo
  filters, explicit-date preservation, and empty responses. The focused
  `get_events()` suite passes 42 expectations with no failures or skips; `air`
  is not installed in the current environment.
- Historical-period checks confirm that the API is not limited to the latest
  period: NR plus Sebastian Kurz returns 872 items in XXVII, 391 in XXVI, zero
  in XXVIII, and 2,685 across all periods.
- An unfiltered NR comparison of API search totals confirms that V through
  XXVIII alone is not an exact substitute for an omitted `GP_CODE`: omission
  reports 358,837 matches, while V through XXVIII reports 356,624. Adding KN
  (1,897 matches) and PN (316 matches) restores the exact total of 358,837;
  periods I through IV add no matches.
- A follow-up live check clarifies that literal `get_items()` does not actually
  return KN or PN rows in its result: both the fully unfiltered call and NR-only
  call stop at the API's 100,000-row export maximum, and those truncated rows
  contain neither code. Period-unrestricted historical date slices do expose
  the underlying records: the PN date range returns 316 PN rows plus one KN
  row, and the KN date range returns 1,896 further KN rows.
- This established the PN/KN public-input decision: they are valid backend data
  categories and are needed in an all-period echo URL to reproduce the API's
  search total, but the documentation must not claim that the truncated
  no-filter R result itself contains them.
- The Parliament's current documentation does not support a general claim that
  `Gegenstände` data begins with the fifth legislative period. The official
  archive page explicitly states that digitized PN and KN materials are
  available as `Verhandlungsgegenstände` under `Gegenstände`. The current
  `Gegenstände` page also links to materials from 1918, while the Index page
  describes its separate 1945--1999 coverage and points to enhanced
  `Gegenstände` searching from 1996. Open-data availability is documented by
  selected document type, usually with later cutoffs, rather than by one global
  fifth-period boundary.
- Decision: accept `"PN"` and `"KN"` as explicit `legis_period` values in
  `get_items()`. Keep rejecting numbered periods I through IV, and do not alter
  the separate historical restrictions of other endpoints without checking
  them individually. Document that `NULL` removes the period filter but that a
  broad returned export may omit periods when it reaches the 100,000-row cap.
- Implemented explicit PN/KN support in `get_items()` with a testable internal
  normalizer. Numbered periods I through IV remain rejected, including when
  mixed with historical codes. Updated the function documentation, example,
  generated help, and `NEWS.md` to describe historical coverage and the export
  limit accurately.
- Live verification of `get_items(institution = "NR", legis_period =
  c("PN", "KN"))` returned 2,213 rows: 1,897 KN and 316 PN. The complete
  `get_items` test file passes 136 expectations with zero failures and warnings
  and six expected skips. The pkgdown reference check reports no problems;
  `air` is not installed.
- Committed explicit PN/KN support, documentation, NEWS, and regressions as
  `fbec566` (`Support historical periods in get_items`). The untracked release
  plan was excluded; the commit has not yet been pushed.
- GitHub Actions run 33539804251 tested pushed commit `b4cf07b`. The Windows
  release and macOS release jobs passed, but Linux devel, release, and oldrel-1
  each failed the same expectation in `test-get_events.R`: the derived lower
  bound represented 10 November 1920 as `1920-11-09T23:00:00Z`, while the test
  reduced the instant to a UTC date and expected 10 November. The helper uses
  the platform-sensitive timezone identifier `"CET"`; local Windows produced
  `1920-11-10T00:00:00Z`, confirming that serialization currently differs by
  platform. This is a portability blocker, not a Parliament API failure.
- Replaced the ambiguous `"CET"` conversion with `"Europe/Vienna"` and made
  the historical echo assertion compare the exact UTC timestamp. Added exact
  start/end regressions for historical, winter, and daylight-saving dates and
  verified that enabling echo does not change returned event data. The focused
  suite passes 45 expectations. The complete mocked suite passes 909
  expectations with 14 expected skips and only the already tracked committee
  warning. A live unrestricted call still returns the same 24,975 events from
  13 November 1918 through 17 July 2027.

### 2026-09-01 decisions

- Deferred the `aux_clean_person_name()` academic-title heuristic for later
  review; do not change it as part of the current schema work.
- Approved stable zero-result contracts: a zero-row result must have the same
  columns, order, and types as the corresponding non-empty output variant.
- Implementation in progress for `get_committees()`, `get_mandates()`, and
  `get_persons(mandates = TRUE)`. Committee member extraction remains a
  separate follow-up; this change establishes its documented list-column
  schema without inventing member data.
- The package-wide schema audit found three additional definite gaps covered by
  the same decision: `get_mps(date = ...)` typed its empty `date` as character,
  `get_mps_current()` used one empty schema that matched neither chamber, and
  `get_names()` omitted documented columns for people without former names.
  No other exported zero-result mismatch was demonstrated by current source,
  fixtures, or tests.
- Implemented canonical typed prototypes and exact schema regressions for
  `get_committees()`, `get_mandates()`, `get_persons()`, `get_mps()`,
  `get_mps_current()`, and `get_names()`. Updated roxygen output and `NEWS.md`.
  The complete mocked suite passes under a valid Windows UTF-8 locale with 14
  expected live-only skips. A clean-source package check completes with tests
  and code/documentation checks OK; its remaining two vignette warnings and
  non-portable-fixture-path note are pre-existing release-check items.
- Committed the stable zero-result schema implementation as `4c29f65`
  (`Stabilize empty result schemas`). The untracked release tracker and the
  metadata-only `NAMESPACE` status entry were excluded from the commit.

### 2026-09-02 decisions

- Rechecked `get_committees(details_type = "members")`. The earlier generic
  missing-column warning is no longer reproducible after `4c29f65`, but a live
  Federal Council member list still fails because its membership table is the
  second HTML table and the fallback parser assumes third and fourth tables.
- Approved one result row per committee. Combine the selected non-photo member
  document's PDF and HTML links and attach one typed `members` list-column.
- Approved warning plus a typed zero-row member tibble when an HTML membership
  page cannot be parsed. Do not return a fabricated `"Failed to extract
  members"` record.
- Accept exact committee citations in both number-first (`1/SA-BU`) and
  canonical (`SA-BU/1`) order; retain the canonical form in returned data and
  preserve regex filtering for other inputs.
- Implementation plan: fetch member HTML through `.parlat_fetch_html()`, select
  the actual membership table by content, preserve the two-column
  Hauptausschuss and explicit SA-P9 layouts, and remove blind positional
  fallback. Add mocked NR, BR, Hauptausschuss, special-layout, malformed-page,
  document-collapse, and citation compatibility regressions.
- Initial implementation passed 160 focused expectations and live NR, BR, and
  Hauptausschuss spot checks, but independent review found additional required
  cases before acceptance: anchor exact citations to avoid matching `/10`,
  retain ordinary links in flattened mixed photo/non-photo records, discover
  SA-P9 table pairs by content, exclude non-person Hauptausschuss anchors, align
  ordinary member URLs when `<th>` rows are present, and keep the no-document
  regression fully mocked. Corrections and regressions are in progress.
- **Resolved:** implemented and independently re-reviewed every committee
  correction. `details_type = "members"` now returns one row per committee,
  fetches HTML once with retries, dispatches all layouts by content, warns with
  typed empty member data on unsupported pages, and never fabricates a member.
  Exact citations accept both orders without prefix overmatching.
- Verification: 178 focused committee expectations pass with one intentional
  live-only skip; the complete mocked suite passes with 14 expected skips. Live
  NR, BR, Hauptausschuss, and SA-P9 lists returned 53, 31, 30, and 58 members,
  respectively, without warnings. Clean-source R CMD check passed with only the
  already tracked non-portable fixture-path note; `air` is unavailable.
- Committed the committee-member repair as `566d541`
  (`fix: stabilize committee member extraction`). The untracked tracker and
  metadata-only `NAMESPACE` status entry were excluded.
- Pushed `566d541` to `origin/dev`. The R CMD check, test-coverage, and pkgdown
  workflows for this branch head are currently running; their final results
  remain part of the release gate.
- **Resolved:** the preliminary person-page HEAD request in
  `aux_check_pad_intern_exists()` now uses native
  `httr2::req_retry(max_tries = 3)`. A focused regression verifies that the
  retry policy is attached before the request is performed. The focused suite
  passes 59 expectations, and the complete mocked suite passes 1,149
  expectations with 14 expected live-only skips under a Windows UTF-8 locale.
  `air` is unavailable. Committed as `50eb45f`
  (`fix: retry PAD_INTERN existence checks`) and pushed to `origin/dev`.
- GitHub Actions passed for `50eb45f`: all four R CMD check matrix jobs,
  test coverage, and pkgdown completed successfully.
- **Resolved:** shared echo URLs now
  percent-encode reserved characters in
  query values, while preserving repeated parameters and raw URL suffixes.
  `get_committees(echo = TRUE)` now prints the returned row count for
  non-empty, upstream-empty, and citation-filtered-empty results. Focused
  verification passes 221 expectations with one expected live-only skip; the
  complete mocked suite passes 1,157 expectations with 14 expected skips.
  `air` is unavailable. Committed as `f52d271`
  (`fix: encode echo URLs and report committee hits`) and pushed to
  `origin/dev`.
- Chrome DevTools verification of a live encoded `get_events()` echo URL
  confirmed that `Parlamentsdirektion%20%2F%20Klubs` restores the
  `Parlamentsdirektion / Klubs` filter on the Parliament website. The website
  displayed 1,704 hits for 2025, exactly matching the package result.
- GitHub Actions passed for `f52d271`: all four R CMD check matrix jobs,
  test coverage, and pkgdown completed successfully.
- **Resolved:** `get_events()` now converts non-empty parsed responses to a
  tibble, matching its documented class and existing typed empty-result path.
  Tests now require `tbl_df` for both non-empty and zero-row results. The
  focused suite passes 46 expectations; the complete mocked suite passes
  1,158 expectations with 14 expected live-only skips. `air` is unavailable.
  Committed as `1c7a4f5` (`fix: return event results as tibbles`) and pushed
  to `origin/dev`.
- **Resolved:** request-policy cleanup now removes the
  remaining Chrome/Edge client-hint, Fetch Metadata, browser user-agent,
  priority, and DNT headers from `get_items()` and both current-MP request
  builders. Transcript PDF downloads now use the ParlAT user agent and
  `httr2::req_retry(max_tries = 3)` through a testable internal helper.
- `NEWS.md` now accurately describes three total attempts for retryable
  responses. Static verification finds 20 httr2 request builders, 20 package
  user agents, and 20 retry policies, with no remaining Chrome/Edge client
  hints, Fetch Metadata headers, browser user agents, cookies, or session IDs.
- Verification passes 240 focused expectations with seven expected live-only
  skips and 1,173 complete-suite expectations with 14 expected live-only
  skips. Live smoke checks returned 872 Kurz items in XXVII, 183 current NR
  members, and 60 current BR members; two transcript PDFs downloaded
  successfully to a temporary directory. `air` is unavailable. Committed as
  `bc582d3` (`fix: standardize HTTP request policy`) and pushed to
  `origin/dev`.
- GitHub Actions passed for `bc582d3`: all five R CMD check matrix jobs
  (macOS release, Windows release, Ubuntu release, oldrel-1, and devel), test
  coverage, and pkgdown completed successfully.

### 2026-09-03 documentation audit

- Executed all generated help examples, including `\donttest{}` blocks, under
  a valid Windows UTF-8 locale. All 17 public help topics completed without an
  R error. The host's invalid `C.UTF-8` Windows environment corrupts accented
  literals in a fresh default session, so the audit explicitly used
  `English_United States.utf8`.
- The help examples contain three semantic defects despite completing:
  `get_items(institution = "NR", legis_period = c("PN", "KN"))` now returns
  zero rows although it returned 2,213 on 2026-09-01;
  `get_mandates(name = "Michael Pöck")` returns zero because the documented
  historical name is misspelled: it is Michael Pock, not Michael Pöck (and one
  comment also says "Micheal"); and the XXVII `MTEU` item example returns zero
  rows. The Pock finding is a documentation typo, not a name-resolution defect.
- Rendered all 23 R chunks in `vignettes/ParlAT.Rmd` successfully against the
  live API. `pkgdown::check_pkgdown()` reports no problems.
- Verified the deliberately `\dontrun{}` transcript export with a safe,
  one-result equivalent: one row downloaded one valid 1.08 MB PDF to a
  temporary directory. The exact documented query currently matches 90 PDFs
  and was not allowed to write all of them to the default project folder.
- Treated the README dataset-table calls as usage examples. Six are not
  executable as written: `get_plenary_meetings()` omits its required
  institution; both `get_mps_current()` calls use unsupported full chamber
  names; `get_committees()` omits required filters;
  `get_mps_details(...)` uses a placeholder; and the BR written-question call
  omits a required `type_doc`.
- Five additional README calls execute but return zero rows: `item = "BNR"`
  and the `MTEU`, `SBPL-BR`, `MT-BR`, and `S-BR` EU-submission variants. Adding
  the obvious chamber, period, or BR `type_doc` filters did not restore live
  results, so these examples need current known-result replacements rather
  than cosmetic argument additions.
- **Resolved:** corrected the Michael Pock example and all related comments in
  `get_mandates()` (including the separate "Micheal" typo), regenerated the Rd
  help, and verified live that the corrected query returns two mandate rows
  under Michael Bernhard. `pkgdown::check_pkgdown()` passes. Committed as
  `2316809` (`docs: correct Michael Pock example`).

## Required Changes

### Correctness blockers

- **Deferred by decision:** revisit the broad CamelCase-removal expression in
  `aux_clean_person_name()` after `v0.1.0`. Names such as `McDonald` and
  `McGrath` remain a known edge-case risk, accepted for this release.
- **Resolved 2026-09-01:** Make empty-result schemas match each public
  function's documented non-empty contract. Covered committee detail variants,
  mandate columns, `get_persons(mandates = TRUE)`, and the additional audited
  `get_mps()`, `get_mps_current()`, and `get_names()` variants.
- **Resolved 2026-09-02:** Fix `get_committees(details_type = "members")`
  parsing so member results are extracted from the actual response structure
  without the current missing-column warning.
- **Resolved 2026-09-02:** Apply retry behavior to the preliminary HEAD request
  in `aux_check_pad_intern_exists()` so transient upstream failures do not
  become false "not found" results.

### Release cleanup

- **Resolved 2026-09-02:** Encode
  echo-query values with reserved characters escaped, including `&`, `=`,
  `/`, and `?`, and include `n_results` in the committee echo output when
  documented.
- **Resolved 2026-09-02:** Make `get_events()` return a tibble as documented,
  consistently for non-empty and empty results.
- **Resolved 2026-09-02:** Reconcile `NEWS.md` with the implementation. All 20
  httr2 request builders now use the ParlAT user agent and allow at most three
  total attempts; stale browser-fingerprint headers are removed.
- Set `DESCRIPTION` and the `NEWS.md` release heading to version `0.1.0`.
- **Resolved 2026-09-02:** The previously identified trailing whitespace and
  extra end-of-file blank line are no longer present; `git diff --check` is
  clean.

### Documentation examples

- **Resolved 2026-09-03:** Removed the semantically stale PN/KN historical
  items example from the `get_items()` help.
- Replace or revise the remaining semantically stale XXVII `MTEU` help
  example identified in the 2026-09-03 audit.
- Make the six non-executable README usage snippets syntactically and
  semantically complete.
- Replace the five zero-result README dataset examples with verified queries,
  or label unsupported/unavailable datasets explicitly.
- Keep the transcript mass-download example in `\dontrun{}`, but consider
  narrowing it so users can verify PDF export without downloading 90 files.

## Public API and Compatibility

- Do not add or remove exported functions.
- Preserve existing argument names and normal successful-result structures.
- Treat typed empty results as part of the public contract: their columns and list-column types must match the corresponding requested output variant.
- Preserve defensive list-column handling for heterogeneous Parliament detail data.

## Test Plan

- Add regression tests for:
  - `get_items()` person filtering for both chambers and for a person with no match.
  - Surnames containing internal capitals, including `McDonald` and `McGrath`
    (deferred with the academic-title heuristic).
  - Every affected zero-row schema and detail variant.
  - Committee member extraction with no warning.
  - Retry behavior for the PAD_INTERN existence check.
  - Echo URLs containing reserved characters and committee hit counts.
  - The documented `get_events()` return class.
- Run `air format .` if available, then `devtools::document()`.
- Execute all help examples with `run_donttest = TRUE` and render the live
  vignette after documentation corrections.
- Run the full mocked test suite and `devtools::check()` with zero test warnings or failures.
- Require all GitHub Actions workflows to pass on the final release commit.
- For this GitHub-only release, accept the three currently known package-check notes--non-portable fixture paths, the vignette's relative reference link, and spelling-output mismatch--provided no new notes appear. Record them as follow-up maintenance debt.

## Release Procedure

1. Complete and review the required changes on `dev`.
2. Confirm the final diff, documentation, tests, package check, and GitHub Actions results.
3. Merge `dev` into `master` only after every gate above passes.
4. Tag the merge result as `v0.1.0` and publish the GitHub release using the finalized `NEWS.md` entry.

## Assumptions

- The release is distributed through GitHub only; no CRAN submission is planned now.
- The intended release version is `0.1.0`, based on the branch history and prior release-candidate commit.
- Existing unrelated user changes, if any appear during implementation, must be preserved.
