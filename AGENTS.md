# AGENTS.md

This file provides guidance to Codex, Claude Code, and other AI coding agents
working in this repository.

## Package Overview

ParlAT is an R package wrapping the Austrian Parliament Open Data and website
detail endpoints. It provides `get_*()` helpers that validate user inputs, call
`parlament.gv.at` endpoints with `httr2`, and return tibbles or tibbles with
list-columns for nested data.

The package is in active development. Upstream Parliament API and website data
shapes can change, so parsing code should be defensive and covered by fixtures.

Current package metadata lives in `DESCRIPTION`:

- Minimum R version: R >= 4.1.0
- License: GPL-3 + file LICENSE
- Main docs: <https://werkstattcodes.github.io/ParlAT/>
- Source: <https://github.com/werkstattcodes/ParlAT>

## Development Commands

```r
# Load package for local development
devtools::load_all()

# Run all mocked tests
devtools::test()

# Run a focused test subset
devtools::test(filter = "get_item_details")

# Update roxygen docs, NAMESPACE, and Rd files
devtools::document()

# Run package checks
devtools::check()

# Build pkgdown site
pkgdown::build_site()
```

If code is generated or heavily edited, run `air format .` when available. If
`air` is not installed, keep edits consistent with surrounding style manually.

## Repository Structure

- `R/`: package source code.
- `tests/testthat/`: tests.
- `tests/testthat/fixtures/`: `httptest2` fixtures, grouped by function.
- `tools/record_fixtures.R`: helper script for refreshing fixtures.
- `man/`: generated Rd files. Do not edit by hand.
- `vignettes/`: package vignette source.
- `_pkgdown.yml`: pkgdown reference index and site configuration.

## Exported Functions

The current exported API is defined in `NAMESPACE`:

- `get_committees()`
- `get_events()`
- `get_item_details()`
- `get_items()`
- `get_legis_periods()`
- `get_mandates()`
- `get_mps()`
- `get_mps_current()`
- `get_mps_details()`
- `get_names()`
- `get_pad_intern()`
- `get_participation()`
- `get_persons()`
- `get_plenary_meeting_details()`
- `get_plenary_meetings()`
- `get_transcripts()`

Do not document or reference removed/non-exported functions as part of the
public API unless you first verify they exist and are intentionally public.

## Core Implementation Patterns

Most search wrappers follow this flow:

1. Validate parameters with `checkmate` and explicit choices.
2. Normalize user-friendly inputs, especially legislative periods, dates,
   institutions, parliamentary groups, and item/document codes.
3. Build a JSON body for the relevant Parliament Filter API endpoint.
4. Use `httr2::request()` and related helpers for HTTP calls.
5. Parse JSON with `httr2::resp_body_json()` or `jsonlite`.
6. Rename and reshape columns into stable tibbles.

Common helpers:

- `aux_convert_legis_periods()` and `fn_check_legis_period_elements()` in
  `R/aux_check_legis_period.R`
- `aux_parl_group_names_standard()` for historical party/group aliases
- `aux_json_to_tibble()` for preserving nested JSON as list-columns
- `.parlat_detail_json_url()`, `.parlat_fetch_detail_json_text()`, and
  `.parlat_parse_detail_json()` in `R/html_helpers.R`

Use the base pipe `|>` for new code where practical, but preserve local style
when editing existing `%>%` pipelines.

## Fragile Areas

### Detail Pages

`get_item_details()` and `get_plenary_meeting_details()` depend on Parliament
detail pages. These used to scrape embedded frontend `props:` data, but the
site changed. The current code fetches the same detail URL with `?json=TRUE`
and parses that JSON directly.

When working in these functions:

- Do not reintroduce scraping of frontend boot scripts.
- Use the shared helpers in `R/html_helpers.R`.
- Preserve list-column output for nested metadata, stages, votes, speeches,
  decisions, and timelines.
- Treat speech and stage structures as heterogeneous. They may simplify to
  matrices, data frames, or lists depending on the response.

### Large Search Wrappers

`get_items()`, `get_mps_current()`, and `get_committees()` contain substantial
request-building and parsing logic. Make small, focused changes and add tests
next to the relevant existing test file.

## Testing Workflow

Tests use `testthat` edition 3 and `httptest2`.

`tests/testthat/helper-mock.R` defines three modes:

- Mocked mode: default. Uses recorded fixtures.
- Live mode: set `PARLAT_LIVE_API=true`.
- Recording mode: set `PARLAT_RECORD_FIXTURES=true`; makes live calls and
  records responses.

Use `run_api_call(expr, fixture_subdir = "<function>")` in tests that call
networked code. Fixture subdirectories live under:

```text
tests/testthat/fixtures/<function>/
```

Examples:

```r
devtools::test()
devtools::test(filter = "get_items")

Sys.setenv(PARLAT_LIVE_API = "true")
devtools::test(filter = "get_item_details")
Sys.unsetenv("PARLAT_LIVE_API")
```

To refresh fixtures, prefer the project helper:

```r
source("tools/record_fixtures.R")
```

You can limit fixture recording with `PARLAT_RECORD_TARGETS`, as implemented in
`tools/record_fixtures.R`.

## Documentation And NEWS

- User-facing functions should have roxygen2 documentation.
- Run `devtools::document()` after roxygen changes.
- If adding a new public topic, update `_pkgdown.yml`.
- User-facing behavior changes should get a concise `NEWS.md` bullet.
- Do not edit generated files in `man/` directly.

## Git And Local Notes

The working tree may contain user changes. Do not revert unrelated changes.

Git may warn about:

```text
C:\Users\Roland\.config\git\ignore: Permission denied
```

This warning is known and does not usually block package work.
