# ParlAT — Copilot instructions for coding agents

Purpose: give an AI coding agent the minimum, high-value knowledge to
work productively on ParlAT (an R package wrapping the Austrian
parliament Filter API).

Quick context - Package root: contains `DESCRIPTION`, `R/`, `man/`,
`tests/`, `vignettes/`. Core code lives in `R/`. - Key entry points:
`R/get_events.R`, `R/get_items.R`, `R/get_mps.R`,
`R/get_plenary_sessions.R`. - Canonical parsing helper:
`R/aux_json_to_tibble.R` (flatten JSON -\> tibble).

Core patterns you must follow - HTTP flow: build JSON body -\>
[`httr2::request()`](https://httr2.r-lib.org/reference/request.html) -\>
`req_perform()` -\>
[`httr2::resp_body_json()`](https://httr2.r-lib.org/reference/resp_body_raw.html)
-\> transform via `aux_json_to_tibble()`. - Date and period handling:
use `aux_convert_legis_periods()` for numeric/roman/special tokens
(e.g. `PN`, `KN`). - Party/parl-group normalization: use
`aux_parl_group_names_standard()` where relevant. - Return values:
public `get_*()` functions return tibbles (use tidyverse style and the
`|>` pipe). Avoid printing side-effects.

Developer workflows (fast commands) - Start development session:
[`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html) -
Run tests:
[`devtools::test()`](https://devtools.r-lib.org/reference/test.html) or
a single file:
`testthat::test_file("tests/testthat/test-get_events.R")`. - Inspect
package internals / docs:
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html);
build vignettes:
[`devtools::build_vignettes()`](https://devtools.r-lib.org/reference/build_vignettes.html);
site:
[`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html). -
Reproducible environment: check
[`renv::status()`](https://rstudio.github.io/renv/reference/status.html)
(project uses `renv`).

Debugging and network calls - Prefer recorded fixtures for unit tests
(see `tests/testthat/www.parlament.gv.at/`). - To inspect a live
request/response for debugging, call a function with `echo = TRUE`.
Example:

``` r
# returns the httr2 response object and prints request/response
get_events(date_start = "2024-01-01", date_end = "2024-01-31", echo = TRUE)
```

Testing conventions - Use `httptest2`/mocked fixtures for unit tests.
Add new fixtures to `tests/testthat/www.parlament.gv.at/` when you
record a successful API response. - Integration tests that hit the live
API should be flagged/skipped on CI (follow existing tests/setup.R
patterns).

Adding or modifying an endpoint (concrete checklist) 1. Create
`R/get_<thing>.R` following patterns in `get_events.R` and
`get_items.R`. 2. Reuse helpers in `R/` (`aux_json_to_tibble.R`,
date/period helpers, name normalizers). 3. Add a unit test in
`tests/testthat/` and a JSON fixture in
`tests/testthat/www.parlament.gv.at/` (or mark as integration). 4.
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
to update `NAMESPACE`/Rd files.

Files to inspect first - `R/get_events.R`, `R/get_items.R`,
`R/get_mps.R` - `R/aux_json_to_tibble.R`, `R/aux_check_legis_period.R`,
`R/aux_transform_event_date.R` - `tests/testthat/setup.R` and
`tests/testthat/www.parlament.gv.at/` (fixtures)

Common pitfalls - Mapping differences caused by legis_period formats
(numeric vs Roman) and party name variants; use the aux helpers. - API
500s are server-side: reproduce with fixture or `echo = TRUE` rather
than making repeated live calls.

If anything here is unclear or you want more example snippets (fixtures,
recording requests, or a short how-to for `httptest2`), tell me which
section to expand.
