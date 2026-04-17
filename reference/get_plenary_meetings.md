# Get Data on Plenary Meetings of the Austrian Parliament

Retrieves information about plenary meetings from the Austrian
Parliament's API (see
[here](https://www.parlament.gv.at/recherchieren/plenarsitzungen/index.html)).
Data available from 20th legislative period onwards.

## Usage

``` r
get_plenary_meetings(
  institution = NULL,
  legis_period = NULL,
  meeting_and_activities = NULL,
  session_type = NULL,
  meeting_type = NULL,
  echo = FALSE
)
```

## Arguments

- institution:

  A character string specifying the institution. "BR" (Bundesrat/Federal
  Council), "NR" (Nationalrat/National Council), or "BV"
  (Bundesversammlung/Federal Assembly).

- legis_period:

  Numeric value or vector specifying the legislative period(s). Can also
  be NULL to retrieve all periods from 20th onwards. **Must be NULL when
  institution is "BV"** (Bundesversammlung does not use legislative
  periods).

- meeting_and_activities:

  A character string. One of 'meetings' or 'activities'. 'meetings'
  returns plenary meeting entries; 'activities' returns parliamentary
  items submitted or acted upon in meetings. Not applicable when
  institution is "BV" (Bundesversammlung); must be NULL for BV
  institution.

- session_type:

  A character string or vector. Filter by meeting period type.
  Permissible values: `"N"` (Ordentliche Tagung / Ordinary session),
  `"A"` (Ausserordentliche Tagung / Extraordinary session). Can be NULL
  to retrieve all meeting period types. Not applicable when institution
  is "BV".

- meeting_type:

  A character string or vector. Filter by sitting type. Permissible
  values: `"S"` (Sitzung / Regular sitting), `"SO"` (Sondersitzung /
  Special sitting), `"ZU"` (Zuweisungssitzung / Assignment sitting),
  `"N"` (Nachtrag / Addendum). Can be NULL to retrieve all sitting
  types. Only applicable when `meeting_and_activities = "meetings"`.

- echo:

  Logical. If `TRUE`, prints the API request body parameters and the
  number of results. Default is `FALSE`.

## Value

A data frame containing plenary meeting details, or NULL if no results
found. The structure depends on the `meeting_and_activities` parameter:

If *`meeting_and_activities = "meetings"`*:

- `institution`: parliamentary institution (e.g., "NR", "BR")

- `legis_period`: legislative period (not returned if institution is
  'BV')

- `date`: date of the meeting

- `meeting_number`: number of the meeting

- `meeting_url`: URL to the meeting page

- `meeting_type`: sitting type abbreviation (`"S"`, `"SO"`, `"ZU"`, or
  `"N"`)

- `meeting_title`: full title of the meeting

- `session_type`: meeting period type (e.g., "N" for Ordentliche Tagung)

- `agenda_url_html`: URL to the agenda in HTML format (NA if not yet
  published)

- `agenda_url_pdf`: URL to the agenda in PDF format (NA if not yet
  published)

If *`meeting_and_activities = "activities"`*:

- `institution`: parliamentary institution

- `legis_period`: legislative period

- `date`: date of the activity

- `title`: title of the parliamentary item

- `url_item`: URL to the parliamentary item

- `meeting_number`: number of the meeting in which the item appeared

- `url_meeting`: URL to the meeting

- `session_type`: meeting period type of the meeting

- `activity_type`: type of activity (e.g., "Sonstiges")

- `doc_type`: document type description

- `citation`: item citation string

For *BV (Bundesversammlung) institution*:

- Returns basic meeting information without activity filtering

- Does NOT include `legis_period` column (not applicable for Federal
  Assembly)

- Columns returned: `institution`, `date`, `meeting_number`,
  `meeting_url`, `meeting_type`, `meeting_title`, `session_type`,
  `agenda_url_html`, `agenda_url_pdf`

## Examples

``` r
# \donttest{
# Basic usage: meetings of the National Council for legislative period 28
result <- get_plenary_meetings(
  institution = "NR",
  legis_period = 28,
  meeting_and_activities = "meetings"
)
dplyr::glimpse(result)
#> Rows: 75
#> Columns: 10
#> $ institution     <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", …
#> $ legis_period    <chr> "28", "28", "28", "28", "28", "28", "28", "28", "28", …
#> $ date            <date> 2024-10-24, 2024-10-24, 2024-11-20, 2024-11-20, 2024-…
#> $ meeting_number  <chr> "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11…
#> $ meeting_url     <chr> "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/…
#> $ meeting_type    <chr> "S", "ZU", "S", "ZU", "S", "ZU", "S", "ZU", "S", "ZU",…
#> $ meeting_title   <chr> "1. Sitzung des Nationalrats vom 24. Oktober 2024", "2…
#> $ session_type    <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N",…
#> $ agenda_url_html <chr> "https://www.parlament.gv.at/dokument/XXVIII/NRSITZ/1/…
#> $ agenda_url_pdf  <chr> "https://www.parlament.gv.at/dokument/XXVIII/NRSITZ/1/…

# Parliamentary activities during meetings
result <- get_plenary_meetings(
  institution = "NR",
  legis_period = 27,
  meeting_and_activities = "activities"
)
dplyr::glimpse(result)
#> Rows: 3,628
#> Columns: 11
#> $ institution    <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "…
#> $ legis_period   <chr> "27", "27", "27", "27", "27", "27", "27", "27", "27", "…
#> $ date           <date> 2019-10-23, 2019-10-23, 2019-10-23, 2019-10-23, 2019-1…
#> $ title          <chr> "Einberufung zur XXVII. GP und zugleich zur ordentliche…
#> $ url_item       <chr> "https://www.parlament.gv.at/gegenstand/XXVII/GO/1", "h…
#> $ meeting_number <chr> "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", …
#> $ url_meeting    <chr> "https://www.parlament.gv.at/gegenstand/XXVII/NRSITZ/1"…
#> $ session_type   <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", …
#> $ activity_type  <chr> "Sonstiges", "Sonstiges", "Sonstiges", "Sonstiges", "De…
#> $ doc_type       <chr> "Einberufung einer Tagung", "Zuschrift", "Sonstige Gesc…
#> $ citation       <chr> "1/GO", "2/GO", "3/GO", "6/GO", "7/GO", "8/GO", "9/GO",…

# Federal Council meetings
result <- get_plenary_meetings(
  institution = "BR",
  legis_period = 28,
  meeting_and_activities = "meetings"
)
dplyr::glimpse(result)
#> Rows: 19
#> Columns: 10
#> $ institution     <chr> "BR", "BR", "BR", "BR", "BR", "BR", "BR", "BR", "BR", …
#> $ legis_period    <chr> "28", "28", "28", "28", "28", "28", "28", "28", "28", …
#> $ date            <date> 2024-12-05, 2024-12-19, 2025-01-30, 2025-03-13, 2025-…
#> $ meeting_number  <chr> "972", "973", "974", "975", "976", "977", "978", "979"…
#> $ meeting_url     <chr> "https://www.parlament.gv.at/gegenstand/BR/BRSITZ/972"…
#> $ meeting_type    <chr> "S", "S", "S", "S", "S", "S", "S", "S", "S", "S", "S",…
#> $ meeting_title   <chr> "972. Sitzung des Bundesrats vom 5. Dezember 2024", "9…
#> $ session_type    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ agenda_url_html <chr> "https://www.parlament.gv.at/dokument/BR/BRSITZ/972/TO…
#> $ agenda_url_pdf  <chr> "https://www.parlament.gv.at/dokument/BR/BRSITZ/972/TO…

# Multiple legislative periods
result <- get_plenary_meetings(
  institution = "NR",
  legis_period = c(26, 27),
  meeting_and_activities = "meetings"
)
dplyr::glimpse(result)
#> Rows: 366
#> Columns: 10
#> $ institution     <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", …
#> $ legis_period    <chr> "26", "26", "26", "26", "26", "26", "26", "26", "26", …
#> $ date            <date> 2017-11-09, 2017-12-13, 2017-12-13, 2017-12-13, 2017-…
#> $ meeting_number  <chr> "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11…
#> $ meeting_url     <chr> "https://www.parlament.gv.at/gegenstand/XXVI/NRSITZ/1"…
#> $ meeting_type    <chr> "S", "S", "ZU", "S", "S", "ZU", "S", "ZU", "S", "ZU", …
#> $ meeting_title   <chr> "1. Sitzung des Nationalrats vom 9. November 2017", "2…
#> $ session_type    <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N",…
#> $ agenda_url_html <chr> "https://www.parlament.gv.at/dokument/XXVI/NRSITZ/1/TO…
#> $ agenda_url_pdf  <chr> "https://www.parlament.gv.at/dokument/XXVI/NRSITZ/1/TO…

# Federal Assembly (no legis_period, no meeting_and_activities)
result <- get_plenary_meetings(institution = "BV", legis_period = NULL)
dplyr::glimpse(result)
#> Rows: 19
#> Columns: 9
#> $ institution     <chr> "BV", "BV", "BV", "BV", "BV", "BV", "BV", "BV", "BV", …
#> $ date            <date> 1920-12-08, 1924-12-09, 1928-12-05, 1931-10-09, 1945-…
#> $ meeting_number  <chr> "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11…
#> $ meeting_url     <chr> "https://www.parlament.gv.at/gegenstand/BV/BVSITZ/1", …
#> $ meeting_type    <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N",…
#> $ meeting_title   <chr> "1. Bundesversammlung vom 8. und 9. Dezember 1920", "2…
#> $ session_type    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ agenda_url_html <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ agenda_url_pdf  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
# }
```
