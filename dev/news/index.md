# Changelog

## ParlAT 0.0.4.9000

- [`get_item_details()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_item_details.md)
  now accepts `votes = TRUE` by default and returns vote information
  from National Council item pages in a `votes` list-column. Set
  `votes = FALSE` to omit vote extraction.
- [`get_item_details()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_item_details.md)
  now returns the raw item and document type codes as `item_type` and
  `type_doc`.
- [`get_item_details()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_item_details.md)
  now returns the human-readable document type as `type_doc_long`
  instead of `type`.
- [`get_item_details()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_item_details.md)
  now returns the legislative period as `legis_period` instead of
  `gp_code`.

## ParlAT 0.0.4

### Bug fixes

- [`get_items()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_items.md):
  Restored fallback mappings for legacy and renamed Parliament API
  export columns (`his_url`, `personen`, `fraktionen`, `themen`, `sw`,
  `gp_code`, `nrbr`), ensuring live queries return stable `item_url`,
  topic, keyword, person, parliamentary group, and institution columns
  ([\#27](https://github.com/werkstattcodes/ParlAT/issues/27)).
- [`get_plenary_meeting_details()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_plenary_meeting_details.md):
  Fixed handling of sparse plenary meetings that are missing speakers,
  decisions, or timeline data.
- Live API testing: Updated the scheduled workflow against `master`, and
  relaxed the duplicate-row assertion for
  [`get_items()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_items.md)
  to reflect non-deterministic upstream duplicates.

### Documentation

- [`get_mps()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_mps.md):
  Documented inclusive date boundary edge case.

## ParlAT 0.0.3

### Breaking changes

- `get_plenary_sessions()` has been renamed to
  [`get_plenary_meetings()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_plenary_meetings.md)
  to align with the Austrian Parliament API terminology.
- `get_plenary_sessions_details()` has been renamed to
  [`get_plenary_meeting_details()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_plenary_meeting_details.md).

### New functions

- [`get_item_details()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_item_details.md):
  Retrieve detailed information for parliamentary items, including
  speech/debate data extraction and stage-level metadata.
- [`get_plenary_meeting_details()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_plenary_meeting_details.md):
  Retrieve detailed data for individual plenary meetings, with support
  for both URL-based and parameter-based input.

### Enhancements

- [`get_items()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_items.md):
  Significant performance improvements and better handling of compact
  vs. sparse API export rows. Added CLI progress messages for
  long-running requests.
- [`get_mps()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_mps.md):
  New `date` column in output when date parameter is provided. Improved
  documentation for `gender` and `mandate_detail` fields.
- [`get_mandates()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_mandates.md):
  Enforced mutual exclusivity of `name` and `pad_intern` parameters with
  clearer documentation.

### Internal changes

- Removed `tidyselect` from dependencies.
- Removed `R/sysdata.rda`.
- R CMD check compliance: replaced `T`/`F` with `TRUE`/`FALSE`,
  converted `\dontrun{}` to `\donttest{}`, fixed non-ASCII string
  literals.
- Expanded test coverage for new and existing functions.
- Added `inst/WORDLIST` for spell checking and `CONTRIBUTING.md`.

## ParlAT 0.0.2

- Minor improvements to input checks and error handling in several data
  retrieval functions.
- Progress messages during longer requests are now shown with `cli`, for
  more consistent feedback.
- Tests were significantly expanded and cleaned up to improve package
  reliability.

## ParlAT 0.0.1

- Initial release of the ParlAT package providing wrappers around the
  Austrian Parliament Open Data API, including helpers to retrieve
  committees, events, mandates, members of parliament, plenary meetings,
  transcripts, and related datasets.
- Added convenience utilities to harmonize names, expand legislative
  period identifiers, and query participation or item-specific datasets
  with consistent parameter handling.
- Published introductory documentation and reference listings to guide
  users through available endpoints and usage patterns.
