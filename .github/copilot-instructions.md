# ParlAT — Copilot instructions for coding agents

Purpose: quickly get an AI coding agent productive on this repository (an R package that wraps the Austrian parliament search API).

Quick context (big picture)
- This is an R package (package root: DESCRIPTION). Core code paths are in R/*.  Key entry points: R/get_items.R, R/get_events.R, R/get_mps.R, R/get_mps_details.R, R/get_plenary_sessions.R. Utilities: R/aux_json_to_tibble.R, R/aux_check_legis_period.R, R/aux_transform_event_date.R. Tests and fixtures live under tests/testthat/ and tests/testthat/www.parlament.gv.at/ (HTTP responses used as fixtures).
- The package queries https://www.parlament.gv.at Filter API endpoints (examples: data/600, data/409, data/101). Pattern: build JSON body -> httr2::request() -> req_perform() -> httr2::resp_body_json() -> flatten/convert to tibble.
- Important domain conventions: legis_periods can be numeric, roman ("XXVII"), or special tokens ("PN" = provisional nat. assembly, "KN"). Item codes like ANTR, BNR, ME, BI, PET, etc., are used as API filters.

Developer workflows & useful commands
- Start a live dev session: devtools::load_all()
- Run unit tests: devtools::test() or run specific test file: testthat::test_file("tests/testthat/test-get_events.R")
- Rebuild vignettes / site: devtools::build_vignettes(); pkgdown::build_site(lazy = FALSE, preview = TRUE)
- Check environment reproducibility: renv::status() (renv.lock present)
- Run a single function for debugging with network: call with echo = TRUE (many functions accept echo to show httr2 request/response), e.g.:

```r
# show underlying request/response
get_events(date_start = "01-01-2024", date_end = "31-01-2024", echo = TRUE)
```

Patterns & repository-specific conventions an agent must follow
- API requests use httr2 and often require building a JSON body and specific headers. Follow existing helper patterns in aux_json_to_tibble.R and in get_* files instead of inventing a new request flow.
- Date parsing: input dates accept multiple formats ("01.01.2024", "01/01/2024", "01-01-2024"); functions convert to ISO Z timestamps before sending. Reuse aux_convert_legis_periods and date conversion helpers.
- legis_period normalization: use aux_convert_legis_periods() — callers sometimes pass numeric, roman or tokens; keep support for PN/KN.
- Many functions accept item, parl_group, party arguments using domain codes (e.g. item = "ANTR", parl_group = "FPÖ"). Look at get_items.R tests to see exact expected values.
- echo = TRUE: several functions return the httr2 response object when echo is TRUE — use this for debugging and for reproducing fixtures.

Testing and fixtures
- Tests use local JSON fixtures under tests/testthat/www.parlament.gv.at/ to avoid live network calls. When adding tests, either:
  - Add a new fixture (recorded httr2 response JSON) to tests/testthat/www.parlament.gv.at/ and reference it in the test, or
  - Mark test as integration/network and skip on CRAN/CI (follow existing tests for examples).
- Keep tests deterministic: do not rely on live API for unit tests. See tests/testthat/setup.R for mocking/loading fixtures.

Where to look for behaviour examples
- R/get_events.R — shows how body_params are constructed and sent to endpoints (600). Use it as canonical request pattern.
- R/get_items.R — example of constructing the query string and mapping item codes.
- R/get_mps.R and R/get_mps_current.R — examples for handling mandates, name variants and pad_intern IDs.
- R/aux_json_to_tibble.R — canonical JSON -> tibble unpacking and flattening used across the package.
- vignettes/ParlAT.Rmd and parlat_check.qmd (repo root / vignettes) — lots of realistic example calls and parameter combinations; use them as integration examples.

Common failure modes observed in this repo
- API 500 errors: server-side. When seen during development prefer to reproduce with recorded fixture (tests fixtures) or use echo = TRUE and inspect resp headers + body (httr2::resp_body_json()).
- Mapping inconsistencies: legis_period inputs (numeric vs roman) and party/parl_group name variants cause different code paths. Use aux_convert_legis_periods() and aux_parl_group_names_standard() helpers.
- Tests that call the live API will make CI flaky — prefer adding fixtures.

Code-style & contribution hints for agents
- Follow existing tidyverse style and use the |> pipe. Functions return tibbles; avoid printing data frames — return them.
- Reuse helper functions in R/ rather than copying request logic across files.
- When adding a new API endpoint wrapper, add a unit test plus a recorded JSON fixture in tests/testthat/www.parlament.gv.at/.

If you need additional context
- Inspect: R/*.  Start with get_events.R and aux_json_to_tibble.R for the canonical request + parsing flow.
- Look at tests/testthat/*.R for expected function behaviour and fixtures usage.

If anything above is unclear or you want more detailed examples (e.g. how to create a new fixture, or how legis_period normalization works), tell me which section to expand and I will update this file.
