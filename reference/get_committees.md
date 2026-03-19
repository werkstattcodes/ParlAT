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
get_committees(
  institution = "NR",
  legis_period = 27
)
#> # A tibble: 43 × 5
#>    legis_period committee                       citation id_number url_committee
#>    <chr>        <chr>                           <chr>        <int> <chr>        
#>  1 XXVII        Ausschuss für Arbeit und Sozia… A-AS/1         883 https://www.…
#>  2 XXVII        Außenpolitischer Ausschuss      A-AU/1         884 https://www.…
#>  3 XXVII        Ausschuss für Bauten und Wohnen A-BA/1         885 https://www.…
#>  4 XXVII        Budgetausschuss                 A-BU/1         867 https://www.…
#>  5 XXVII        Ständiger Unterausschuss des B… SA-BU/1        874 https://www.…
#>  6 XXVII        Ständiger Unterausschuss in ES… SA-ESM/1       875 https://www.…
#>  7 XXVII        Ausschuss für Familie und Juge… A-FA/1         886 https://www.…
#>  8 XXVII        Finanzausschuss                 A-FI/1         887 https://www.…
#>  9 XXVII        Ausschuss für Forschung, Innov… A-FO/1         888 https://www.…
#> 10 XXVII        Geschäftsordnungsausschuss      A-GO/1         873 https://www.…
#> # ℹ 33 more rows

# Search with specific text and extract member details
get_committees(
  search_string = "Ibiza",
  legis_period = 27,
  institution = "NR",
  details_type = "members"
)
#> # A tibble: 40 × 14
#>    committee   url_committee id_number citation legis_period date_start         
#>    <chr>       <chr>             <int> <chr>    <chr>        <dttm>             
#>  1 Ibiza-Unte… https://www.…       906 A-USA/2  XXVII        2020-01-22 00:00:00
#>  2 Ibiza-Unte… https://www.…       906 A-USA/2  XXVII        2020-01-22 00:00:00
#>  3 Ibiza-Unte… https://www.…       906 A-USA/2  XXVII        2020-01-22 00:00:00
#>  4 Ibiza-Unte… https://www.…       906 A-USA/2  XXVII        2020-01-22 00:00:00
#>  5 Ibiza-Unte… https://www.…       906 A-USA/2  XXVII        2020-01-22 00:00:00
#>  6 Ibiza-Unte… https://www.…       906 A-USA/2  XXVII        2020-01-22 00:00:00
#>  7 Ibiza-Unte… https://www.…       906 A-USA/2  XXVII        2020-01-22 00:00:00
#>  8 Ibiza-Unte… https://www.…       906 A-USA/2  XXVII        2020-01-22 00:00:00
#>  9 Ibiza-Unte… https://www.…       906 A-USA/2  XXVII        2020-01-22 00:00:00
#> 10 Ibiza-Unte… https://www.…       906 A-USA/2  XXVII        2020-01-22 00:00:00
#> # ℹ 30 more rows
#> # ℹ 8 more variables: date_end <dttm>, title <chr>, url_pdf <chr>,
#> #   url_html <chr>, name <chr>, member_type <chr>, party <chr>,
#> #   member_url <chr>

# Search only permanent committees
get_committees(
  institution = "NR",
  legis_period = 28,
  permanent = TRUE
)
#> # A tibble: 9 × 5
#>   legis_period committee                        citation id_number url_committee
#>   <chr>        <chr>                            <chr>        <int> <chr>        
#> 1 XXVIII       Ständiger Unterausschuss des Bu… SA-BU/1        908 https://www.…
#> 2 XXVIII       Ständiger Unterausschuss in ESM… SA-ESM/1       909 https://www.…
#> 3 XXVIII       Hauptausschuss                   A-HA/1         911 https://www.…
#> 4 XXVIII       Ständiger Unterausschuss des Ha… SA-HA/1        912 https://www.…
#> 5 XXVIII       Ständiger Unterausschuss in Ang… SA-EU/1        910 https://www.…
#> 6 XXVIII       Ständiger Unterausschuss des Au… SA-IA/1        925 https://www.…
#> 7 XXVIII       Ständiger Unterausschuss des La… SA-LV/1        930 https://www.…
#> 8 XXVIII       Ständiger Unterausschuss des Re… SA-RH/1        934 https://www.…
#> 9 XXVIII       Ständiger gemeinsamer Ausschuss… SA-P9/1        916 https://www.…

# Include subcommittees (only works when permanent = FALSE or NULL)
get_committees(
  institution = "NR",
  legis_period = 27,
  include_subcommittees = TRUE
)
#> # A tibble: 46 × 5
#>    legis_period committee                       citation id_number url_committee
#>    <chr>        <chr>                           <chr>        <int> <chr>        
#>  1 XXVII        Ausschuss für Arbeit und Sozia… A-AS/1         883 https://www.…
#>  2 XXVII        Unterausschuss des Außenpoliti… A-AU/3         884 https://www.…
#>  3 XXVII        Unterausschuss des Außenpoliti… A-AU/2         884 https://www.…
#>  4 XXVII        Außenpolitischer Ausschuss      A-AU/1         884 https://www.…
#>  5 XXVII        Ausschuss für Bauten und Wohnen A-BA/1         885 https://www.…
#>  6 XXVII        Budgetausschuss                 A-BU/1         867 https://www.…
#>  7 XXVII        Unterausschuss des Budgetaussc… A-BU/2         867 https://www.…
#>  8 XXVII        Ständiger Unterausschuss des B… SA-BU/1        874 https://www.…
#>  9 XXVII        Ständiger Unterausschuss in ES… SA-ESM/1       875 https://www.…
#> 10 XXVII        Ausschuss für Familie und Juge… A-FA/1         886 https://www.…
#> # ℹ 36 more rows

# Federal Council committees
get_committees(
  institution = "BR",
  legis_period = 27
)
#> # A tibble: 25 × 5
#>    legis_period committee                       citation id_number url_committee
#>    <chr>        <chr>                           <chr>        <int> <chr>        
#>  1 XXVII        Ausschuss für Arbeit, Soziales… /aussch…       311 https://www.…
#>  2 XXVII        Ausschuss für auswärtige Angel… /aussch…         1 https://www.…
#>  3 XXVII        Ausschuss für BürgerInnenrecht… /aussch…       272 https://www.…
#>  4 XXVII        EU-Ausschuss des Bundesrates    /aussch…        37 https://www.…
#>  5 XXVII        Ausschuss für Familie und Juge… /aussch…       269 https://www.…
#>  6 XXVII        Finanzausschuss des Bundesrates /aussch…        53 https://www.…
#>  7 XXVII        Geschäftsordnungsausschuss des… /aussch…        75 https://www.…
#>  8 XXVII        Gesundheitsausschuss des Bunde… /aussch…        64 https://www.…
#>  9 XXVII        Gleichbehandlungsausschuss des… /aussch…       271 https://www.…
#> 10 XXVII        Ausschuss für innere Angelegen… /aussch…       108 https://www.…
#> # ℹ 15 more rows
# }
```
