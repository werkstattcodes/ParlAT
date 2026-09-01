# ParlAT (development version)

## New features

- `get_party_colors()` provides a reusable plotting palette for Austrian
  parties and parliamentary groups, including common aliases and historical
  ÖVP colors.

## Breaking changes

- All exported `get_*()` functions now return a **zero-row tibble with their
  documented columns** instead of `NULL` (or `invisible(NULL)`) when the API
  finds no results, accompanied by an informative message. Code that checked
  `is.null(result)` should check `nrow(result) == 0` instead.
- `get_persons()`, `get_names()`, `get_plenary_meetings()`, and the
  `get_mps_details()` modes now return tibbles instead of plain data frames.
- `get_mps()` no longer returns a grouped tibble.
- All user-facing errors, warnings, and messages are now signalled via the
  cli package; message wording may differ slightly.

## Bug fixes

- `get_items()`: combining `person` with `institution` now resolves the person
  across all institutional categories and applies the institution filter only
  to the returned items. `institution` accepts both `"NR"`/`"BR"` and the full
  German names `"Nationalrat"`/`"Bundesrat"`. When `legis_period = NULL`, the
  echoed Parliament website URL now explicitly selects all available periods
  so it reproduces the package results instead of defaulting to the current
  period. An unmatched person returns a typed zero-row result instead of
  sending an unfiltered item request.
- `get_participation()`: the graceful empty-result path was unreachable due
  to an internal assertion that errored first; empty results now return a
  typed zero-row tibble.
- `get_plenary_meetings()`: when `legis_period = NULL`, the echoed Parliament
  website URL now explicitly selects every available period instead of
  defaulting to the current period.
- `get_transcripts()`: the row-limit error message incorrectly said the limit
  was 10,000 (the actual limit is 100,000); a misplaced `sprintf()` argument
  in the PDF-export error message was fixed. All-period searches now echo a
  website URL that explicitly selects every available period instead of
  defaulting to the current period.
- `get_mps_current()`: no longer errors when a search returns no members
  (previously `NULL` was piped into `mutate()`).
- `get_names()`: no longer returns a bare `NA` when the person-detail fetch
  fails, which could break its own vectorized path.
- `get_mps_details(detail_type = "committees")`: no longer errors for MPs
  with multiple name variants.
- `get_mps()`: removed ~160 lines of unreachable dead code after an early
  `return()`.
- `get_mps_details(detail_type = "activities")`: the `institution` filter
  silently matched nothing, and the `institution` column leaked the raw
  German names `"Nationalrat"`/`"Bundesrat"` instead of the documented
  `"NR"`/`"BR"`. The upstream API changed its `gremium` vocabulary from
  short codes to full names. Both directions now speak the new vocabulary,
  so the filter works again and the column values are as documented. Code
  that worked around this by matching `"Nationalrat"` should match `"NR"`.

## Enhancements

- `echo = TRUE` no longer prints the raw JSON request body; it prints the
  URL to the corresponding search results on the Parliament website and the
  number of results. The URL carries the same filter information in a
  directly usable form.
- All API requests now retry up to three times on transient failures
  (`httr2::req_retry()`).
- Stale hardcoded browser cookies/session IDs and browser fingerprint
  headers were removed from all requests; every request now sends the ParlAT
  package user agent.
- Person-detail JSON fetches (`get_mandates()`, `get_names()`,
  `get_committees()` details) now go through httr2, so they are covered by
  the httptest2 mock layer in tests.
- `get_pad_intern()` now removes academic titles from name searches before
  looking up matching Parliament person identifiers. Previously academic titles 
  could cause searches to fail.

## Documentation

- Reference pages gained Examples sections, and the `get_party_colors()`
  examples now render the actual color swatches.
- Fixed dropdown styling in the pkgdown navbar on the package website.

## Internal changes

- New shared internal helpers (`R/utils-shared.R`) replace duplicated
  rename-map and echo/URL-reconstruction blocks across the package.
- Debug `print()` calls, commented `browser()` calls, no-op `req_verbose()`
  blocks, and two large dead functions were removed.
- New unit tests for `get_names()`, `get_mps_current()`, the detail-page
  JSON helpers, and the pure auxiliary converters.
- `T`/`F` abbreviations expanded; superseded `purrr::map_dfr()` replaced.
- Live tests skip count-sensitive assertions while the Parliament search
  index is degraded (`skip_if_api_index_degraded()`), and row-count
  assertions tolerate ±10% drift in live mode (`expect_row_count()`), so
  upstream outages no longer look like package regressions. Adds
  `tools/check_api_index.sh` for a manual health check and a daily workflow
  that monitors index health.
- Non-standard-evaluation pronouns declared via `globalVariables()`;
  remaining R CMD check NOTEs resolved.

# ParlAT 0.0.6

## Bug fixes

- Fixed errors in detail-page parsing caused by upstream changes on the
  Austrian Parliament website.

# ParlAT 0.0.5

- `get_item_details()` now accepts `votes = TRUE` by default and returns vote
  information from National Council item pages in a `votes` list-column. Set
  `votes = FALSE` to omit vote extraction.
- `get_item_details()` now returns the raw item and document type codes as
  `item_type` and `type_doc`.
- `get_item_details()` now returns the human-readable document type as
  `type_doc_long` instead of `type`.
- `get_item_details()` now returns the legislative period as `legis_period`
  instead of `gp_code`.

# ParlAT 0.0.4

## Bug fixes

- `get_items()`: Restored fallback mappings for legacy and renamed Parliament
  API export columns (`his_url`, `personen`, `fraktionen`, `themen`, `sw`,
  `gp_code`, `nrbr`), ensuring live queries return stable `item_url`, topic,
  keyword, person, parliamentary group, and institution columns (#27).
- `get_plenary_meeting_details()`: Fixed handling of sparse plenary meetings
  that are missing speakers, decisions, or timeline data.
- Live API testing: Updated the scheduled workflow against
  `master`, and relaxed the duplicate-row assertion for `get_items()` to
  reflect non-deterministic upstream duplicates.

## Documentation

- `get_mps()`: Documented inclusive date boundary edge case.

# ParlAT 0.0.3

## Breaking changes

- `get_plenary_sessions()` has been renamed to `get_plenary_meetings()` to align
  with the Austrian Parliament API terminology.
- `get_plenary_sessions_details()` has been renamed to
  `get_plenary_meeting_details()`.

## New functions

- `get_item_details()`: Retrieve detailed information for parliamentary items,
  including speech/debate data extraction and stage-level metadata.
- `get_plenary_meeting_details()`: Retrieve detailed data for individual plenary
  meetings, with support for both URL-based and parameter-based input.

## Enhancements

- `get_items()`: Significant performance improvements and better handling of
  compact vs. sparse API export rows. Added CLI progress messages for
  long-running requests.
- `get_mps()`: New `date` column in output when date parameter is provided.
  Improved documentation for `gender` and `mandate_detail` fields.
- `get_mandates()`: Enforced mutual exclusivity of `name` and `pad_intern`
  parameters with clearer documentation.

## Internal changes

- Removed `tidyselect` from dependencies.
- Removed `R/sysdata.rda`.
- R CMD check compliance: replaced `T`/`F` with `TRUE`/`FALSE`, converted
  `\dontrun{}` to `\donttest{}`, fixed non-ASCII string literals.
- Expanded test coverage for new and existing functions.
- Added `inst/WORDLIST` for spell checking and `CONTRIBUTING.md`.

# ParlAT 0.0.2

- Minor improvements to input checks and error handling in several data retrieval functions.
- Progress messages during longer requests are now shown with `cli`, for more consistent feedback.
- Tests were significantly expanded and cleaned up to improve package reliability.

# ParlAT 0.0.1

- Initial release of the ParlAT package providing wrappers around the Austrian Parliament Open Data API, including helpers to retrieve committees, events, mandates, members of parliament, plenary meetings, transcripts, and related datasets.
- Added convenience utilities to harmonize names, expand legislative period identifiers, and query participation or item-specific datasets with consistent parameter handling.
- Published introductory documentation and reference listings to guide users through available endpoints and usage patterns.
