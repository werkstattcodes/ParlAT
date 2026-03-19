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

  Logical. If `TRUE`, prints the API request body parameters, the
  constructed URL, and the number of results. Default is `FALSE`.

## Value

A data frame with one row per matching person and the columns
`pad_intern`, `name`, `gender`, `position`, and `link`. When
`mandates = TRUE`, the returned data frame additionally contains mandate
details for each person. Returns `NULL` with a message if no persons are
found.

## Details

Note that `get_persons` only returns matches for the latest name of an
individual. MPs' previous names (e.g., before marriage) do not return a
match. When `names` is `NULL`, the function returns all available
persons for the supplied filters.

## Examples

``` r
# \donttest{
get_persons(c("Kogler Werner", "Kurz Sebastian"))# }
#>   pad_intern                name gender
#> 1       8242 Kogler Werner, Mag.      M
#> 2      65321      Kurz Sebastian      M
#>                                                                                                     position
#> 1 Abgeordneter zum Nationalrat, Betraut mit der Vertretung der Bundesministerin, Bundesminister, Vizekanzler
#> 2                                Abgeordneter zum Nationalrat, Bundeskanzler, Bundesminister, Staatssekretär
#>            link
#> 1  /person/8242
#> 2 /person/65321
```
