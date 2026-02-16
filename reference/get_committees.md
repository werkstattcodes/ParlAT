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
Data includes session dates, agendas, meeting overviews, and member
lists. The function partly mirrors the search functionality of the
Austrian Parliament's website for committees
[here](https://www.parlament.gv.at/recherchieren/ausschuesse/index.html)
and extends it by e.g. incorporating the extraction of data from
membership lists. Data available starting from the 20th legislative
period.

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic search for committees in National Council
get_committees(
  institution = "NR",
  legis_period = 27
)

# Search with specific text and extract member details
get_committees(
  search_string = "Ibiza",
  legis_period = 27,
  institution = "NR",
  details_type = "members"
)

# Search only permanent committees
get_committees(
  institution = "NR",
  legis_period = 28,
  permanent = TRUE
)

# Include subcommittees (only works when permanent = FALSE or NULL)
get_committees(
  institution = "NR",
  legis_period = 27,
  include_subcommittees = TRUE
)

# Federal Council committees
get_committees(
  institution = "BR",
  legis_period = 27
)
} # }
```
