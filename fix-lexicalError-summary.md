# Fix Summary: Live `get_item_details()` Lexical JSON Error

## Problem

The weekly live API tests failed on GitHub with repeated errors like:

```text
Error: lexical error: invalid char in json text.
                                       NA
                     (right here) ------^
```

All failures came from `get_item_details()` tests and stopped at the same line:

```r
jsonlite::fromJSON(json_text)
```

The important clue was that `jsonlite` was trying to parse the literal value
`NA` as JSON. That meant the problem was not a downstream assertion failure or
a changed data column. The JSON extraction step itself was failing and returning
`NA_character_`.

## Root Cause

`get_item_details()` previously fetched the public HTML detail page and extracted
embedded data from a legacy React boot script. The old helper looked for a
script containing `props:` and then parsed the following JavaScript object as
JSON.

The Austrian Parliament website changed its frontend. Current detail pages no
longer contain the old React `props:` payload. They now use a SvelteKit-style
boot script, so this lookup no longer finds a match:

```r
stringr::str_detect(x, "props:")
```

Because no `props:` script was found, the extractor returned `NA`. That `NA`
was then passed into `jsonlite::fromJSON()`, producing the lexical JSON error.

The same shared extractor was also used by `get_plenary_meeting_details()`, so
that function was vulnerable to the same site change even though the copied
GitHub failure output showed `get_item_details()` first.

## Fix

The fix avoids scraping frontend JavaScript entirely. Parliament detail pages
currently expose valid JSON directly through the same URL with `?json=TRUE`.

For example:

```text
https://www.parlament.gv.at/gegenstand/XXVIII/A/5?json=TRUE
```

### Shared JSON Helpers

`R/html_helpers.R` now contains shared helpers for detail-page JSON:

- `.parlat_detail_json_url()` removes any existing query string and appends
  `?json=TRUE`.
- `.parlat_fetch_detail_json_text()` performs the HTTP request and validates
  that the response body is not empty or `NA`.
- `.parlat_parse_detail_json()` parses the JSON and wraps it as
  `list(data = parsed_response)`.

That wrapper preserves the shape expected by the existing detail parsing code,
which had been written around the old embedded payload structure:

```r
x$data$content
```

The legacy `.parlat_extract_props_json()` helper was kept, but it now fails
explicitly with a clear message if the old `props:` payload is missing. This
prevents silent propagation of `NA` into `jsonlite::fromJSON()`.

### `get_item_details()`

`get_item_details()` now fetches and parses the `?json=TRUE` endpoint instead
of fetching HTML and extracting `props:`.

The helper `.get_item_details_code_path()` was updated the same way, so internal
structure detection also uses the JSON endpoint.

While recording and running the updated tests, another current-site change
surfaced: speech rows under `reden` are no longer always simple character
matrices. Some cells are now structured objects/data frames, especially protocol
links and video metadata.

`.parse_reden()` was broadened to handle both shapes:

- the old character matrix / HTML-string layout
- the current list-row layout with structured protocol and video fields

This preserved the existing public output columns:

- `speaker`
- `speaker_url`
- `position`
- `protocol_page`
- `protocol_url`
- `video_url`

### `get_plenary_meeting_details()`

`get_plenary_meeting_details()` also used the old embedded JavaScript extractor.
It now uses the same shared `?json=TRUE` helper path as `get_item_details()`.

This keeps the function aligned with the current Parliament detail-page data
source and avoids a future repeat of the same `fromJSON("NA")` failure.

## Fixtures

Because the HTTP request URL changed from the HTML page to the JSON endpoint,
new httptest2 fixtures were recorded.

New `get_item_details` fixtures:

- `tests/testthat/fixtures/get_item_details/www.parlament.gv.at/gegenstand/XX/I/1833-85d67d.json`
- `tests/testthat/fixtures/get_item_details/www.parlament.gv.at/gegenstand/XXVII/GAST/2-85d67d.json`
- `tests/testthat/fixtures/get_item_details/www.parlament.gv.at/gegenstand/XXVII/UEA/283-85d67d.json`
- `tests/testthat/fixtures/get_item_details/www.parlament.gv.at/gegenstand/XXVIII/A/5-85d67d.json`
- `tests/testthat/fixtures/get_item_details/www.parlament.gv.at/gegenstand/XXVIII/BI/24-85d67d.json`

New `get_plenary_meeting_details` fixtures:

- `tests/testthat/fixtures/get_plenary_meeting_details/www.parlament.gv.at/gegenstand/BR/BRSITZ/898-85d67d.json`
- `tests/testthat/fixtures/get_plenary_meeting_details/www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/2-85d67d.json`
- `tests/testthat/fixtures/get_plenary_meeting_details/www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50-85d67d.json`

The old `.html` fixtures were left in place. They are no longer used by these
updated code paths, but removing them was not necessary for the fix.

## Verification

Targeted mocked tests pass:

```r
devtools::test(filter = "get_item_details")
# 91 passed, 0 failed, 0 warnings

devtools::test(filter = "get_plenary_meeting_details")
# 48 passed, 0 failed, 0 warnings
```

Live smoke checks also passed for the URLs that represented the failing class:

```text
/gegenstand/XXVII/GAST/2
/gegenstand/XXVIII/A/5
/gegenstand/XXVII/UEA/283
```

Each returned a one-row `get_item_details()` result instead of failing during
JSON parsing.

Additional live smoke checks passed for plenary meeting details:

```text
XXVIII/NRSITZ/50
BR/BRSITZ/898
```

## Notes

`air format .` could not be run because `air` is not installed in the current
environment. The edited code was manually tightened to match the surrounding R
style.

Git continues to warn about:

```text
C:\Users\Roland\.config\git\ignore: Permission denied
```

That warning predates this fix and did not block implementation or tests.
