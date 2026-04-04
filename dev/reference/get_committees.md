# Retrieve Committee Data from the Austrian Parliament API

**\[experimental\]**

## Usage

``` r
get_committees(
  search_string = NULL,
  institution = NULL,
  legis_period,
  permanent = NULL,
  citation = NULL,
  include_subcommittees = NULL,
  details_type = NULL,
  echo = NULL
)
```

## Arguments

- search_string:

  A character string for free text search. Optional.

- institution:

  A character string specifying the institution. Either "NR"
  (Nationalrat, National Council) or "BR" (Bundesrat/Federal Council).
  Required.

- legis_period:

  A character or numeric vector of length 1 for a specific legislative
  period. Required. Data available starting from the 20th legislative
  period.

- permanent:

  A logical flag indicating whether only permanent committees should be
  queried. Default is NULL (both permanent and non-permanent).

- citation:

  A character vector for filtering results by committee citation code
  (e.g., "1/SA-BU"). This is applied as a post-processing filter after
  API results are retrieved. Default is NULL (no filtering).

- include_subcommittees:

  A logical flag to indicate whether subcommittees should be included in
  the search results. Search for subcommittees is only possible if
  `permanent` is not TRUE. Default is NULL.

- details_type:

  A character string specifying the type of details to retrieve.
  Currently supports "members" to extract committee membership
  information. Default is NULL (no additional details).

- echo:

  Logical. If TRUE, the function prints the used search parameters and
  the url to the pertaining search results on the website of the
  Austrian Parliament. Default is NULL.

## Value

A tibble (data frame) with different structures depending on
`details_type`:

**When `details_type = NULL` (default):**

- `legis_period`: Legislative period code (character)

- `committee`: Name of the committee

- `citation`: Citation information

- `id_number`: Committee ID number (integer)

- `url_committee`: URL to the committee page

**When `details_type = "members"`:**

- `legis_period`: Legislative period code (character, relocated to first
  column)

- `committee`: Name of the committee

- `citation`: Citation information

- `id_number`: Committee ID number (integer)

- `url_committee`: URL to the committee page

- `date_start`: Committee start date (POSIXct)

- `date_end`: Committee end date (POSIXct)

- `url_pdf`: URL to PDF version of member list (character, may be NA)

- `url_html`: URL to HTML version of member list (character, may be NA)

- `members`: List-column containing tibbles with member information.
  Each tibble has:

  - `name`: Member name (character)

  - `member_type`: Type of membership - "member", "substitute", or
    leadership role (character)

  - `party`: Party affiliation (character, may be NA)

  - `member_url`: URL to member's profile page (character)

Returns NULL if no results are found for the provided search criteria.

## Details

Get data on the committees ('Ausschüsse') of the Austrian Parliament.
Data includes meeting dates, agendas, meeting overviews, and member
lists. The function partly mirrors the search functionality of the
Austrian Parliament's website for committees
[here](https://www.parlament.gv.at/recherchieren/ausschuesse/index.html)
and extends it by e.g. incorporating the extraction of data from
membership lists. Data available starting from the 20th legislative
period.

## Examples

``` r
# \donttest{
# Basic search for committees in National Council
result <- get_committees(
  institution = "NR",
  legis_period = 27
)
dplyr::glimpse(result)
#> Rows: 43
#> Columns: 5
#> $ legis_period  <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "X…
#> $ committee     <chr> "Ausschuss für Arbeit und Soziales", "Außenpolitischer A…
#> $ citation      <chr> "A-AS/1", "A-AU/1", "A-BA/1", "A-BU/1", "SA-BU/1", "SA-E…
#> $ id_number     <int> 883, 884, 885, 867, 874, 875, 886, 887, 888, 873, 889, 8…
#> $ url_committee <chr> "https://www.parlament.gv.at/ausschuss/XXVII/A-AS/1/0088…

# Search with specific text and extract member details
result <- get_committees(
  search_string = "Ibiza",
  legis_period = 27,
  institution = "NR",
  details_type = "members"
)
dplyr::glimpse(result)
#> Rows: 40
#> Columns: 14
#> $ committee     <chr> "Ibiza-Untersuchungsausschuss eingesetzt am 22.01.2020 -…
#> $ url_committee <chr> "https://www.parlament.gv.at/ausschuss/XXVII/A-USA/2/009…
#> $ id_number     <int> 906, 906, 906, 906, 906, 906, 906, 906, 906, 906, 906, 9…
#> $ citation      <chr> "A-USA/2", "A-USA/2", "A-USA/2", "A-USA/2", "A-USA/2", "…
#> $ legis_period  <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "X…
#> $ date_start    <dttm> 2020-01-22, 2020-01-22, 2020-01-22, 2020-01-22, 2020-01…
#> $ date_end      <dttm> 2024-10-23, 2024-10-23, 2024-10-23, 2024-10-23, 2024-10…
#> $ title         <chr> "Verzeichnis: Mitglieder, Vorsitz, Verfahrensrichter/-in…
#> $ url_pdf       <chr> "/dokument/XXVII/A-USA/2/00906/MIT_00906.pdf", NA, NA, N…
#> $ url_html      <chr> NA, "/dokument/XXVII/A-USA/2/00906/MIT_00906.html", "/do…
#> $ name          <chr> NA, "Präsident Sobotka Wolfgang, Mag.", "Zweite Präsiden…
#> $ member_type   <chr> NA, "Vorsitzender", "Vorsitzender-Vertreterin", "Vorsitz…
#> $ party         <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ member_url    <chr> NA, "https://www.parlament.gv.at/person/88386", "https:/…

# Search only permanent committees
result <- get_committees(
  institution = "NR",
  legis_period = 28,
  permanent = TRUE
)
dplyr::glimpse(result)
#> Rows: 9
#> Columns: 5
#> $ legis_period  <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVII…
#> $ committee     <chr> "Ständiger Unterausschuss des Budgetausschusses", "Ständ…
#> $ citation      <chr> "SA-BU/1", "SA-ESM/1", "A-HA/1", "SA-HA/1", "SA-EU/1", "…
#> $ id_number     <int> 908, 909, 911, 912, 910, 925, 930, 934, 916
#> $ url_committee <chr> "https://www.parlament.gv.at/ausschuss/XXVIII/SA-BU/1/00…

# Include subcommittees (only works when permanent = FALSE or NULL)
result <- get_committees(
  institution = "NR",
  legis_period = 27,
  include_subcommittees = TRUE
)
dplyr::glimpse(result)
#> Rows: 46
#> Columns: 5
#> $ legis_period  <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "X…
#> $ committee     <chr> "Ausschuss für Arbeit und Soziales", "Unterausschuss des…
#> $ citation      <chr> "A-AS/1", "A-AU/3", "A-AU/2", "A-AU/1", "A-BA/1", "A-BU/…
#> $ id_number     <int> 883, 884, 884, 884, 885, 867, 867, 874, 875, 886, 887, 8…
#> $ url_committee <chr> "https://www.parlament.gv.at/ausschuss/XXVII/A-AS/1/0088…

# Federal Council committees
result <- get_committees(
  institution = "BR",
  legis_period = 27
)
dplyr::glimpse(result)
#> Rows: 25
#> Columns: 5
#> $ legis_period  <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "X…
#> $ committee     <chr> "Ausschuss für Arbeit, Soziales und Konsumentenschutz de…
#> $ citation      <chr> "/ausschuss/BR/A-AK-BR/1", "/ausschuss/BR/A-AA-BR/1", "/…
#> $ id_number     <int> 311, 1, 272, 37, 269, 53, 75, 64, 271, 108, 384, 114, 38…
#> $ url_committee <chr> "https://www.parlament.gv.at/ausschuss/BR/A-AK-BR/1/0031…
# }
```
