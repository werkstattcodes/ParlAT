# Search persons in Austrian political institutions

The `get_persons` function searches for current and former individuals
active in the Austrian parliament as well as other related political
institutions of Austria. It allows filtering by specific institutions
and gender and mirrors the "Personen" search on the website of the
Austrian Parliament (see
[here](https://www.parlament.gv.at/recherchieren/personen/)).

## Usage

``` r
get_persons(
  names = NULL,
  institution = NULL,
  mandates = FALSE,
  gender = "all",
  echo = FALSE
)
```

## Arguments

- names:

  A character vector of name(s) in the format "Surname Givenname".
  Defaults to `NULL`.

- institution:

  A character vector specifying one or more institutions to search
  within. Possible values are `"Bundespräsident"`, `"Bundesrat"`,
  `"Bundesregierung"`, `"Europäisches Parlament"`,
  `"Konstituierende Nationalversammlung"`, `"Landeshauptleute"`,
  `"Nationalrat"`, `"Politische Mandate"`,
  `"Provisorische Nationalversammlung"`, `"Rechnungshof"`, and
  `"Volksanwaltschaft"`. Defaults to all institutions.

- mandates:

  Logical. If `TRUE`, mandates are retrieved for each person. Default is
  `FALSE`.

- gender:

  A character string. Possible values are `"all"`, `"female"`, or
  `"male"`. Default is `"all"`.

- echo:

  Logical. If `TRUE`, prints the URL to the corresponding search results
  on the Parliament website and the number of results. Default is
  `FALSE`.

## Value

A data frame with one row per matching person and the columns
`pad_intern`, `name`, `gender`, `position`, and `link`. When
`mandates = TRUE`, the returned data frame additionally contains every
column returned by
[`get_mandates()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_mandates.md),
prefixed with `mandates_`. If no persons are found, a zero-row tibble
with the same columns and column types as the requested output mode is
returned with a message.

## Details

Note that `get_persons` only returns matches for the latest name of an
individual. MPs' previous names (e.g., before marriage) do not return a
match. When `names` is `NULL`, the function returns all available
persons for the supplied filters.

## Examples

``` r
# \donttest{
result <- get_persons(c("Kogler Werner", "Kurz Sebastian"))
dplyr::glimpse(result)
#> Rows: 2
#> Columns: 5
#> $ pad_intern <chr> "8242", "65321"
#> $ name       <chr> "Kogler Werner, Mag.", "Kurz Sebastian"
#> $ gender     <chr> "M", "M"
#> $ position   <chr> "Abgeordneter zum Nationalrat, Betraut mit der Vertretung d…
#> $ link       <chr> "/person/8242", "/person/65321"
# }
```
