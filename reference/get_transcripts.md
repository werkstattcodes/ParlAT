# Retrieve Transcripts from the Austrian Parliament API

`get_transcripts()` retrieves the transcripts of parliamentary meetings
via Parliament's API (see
[here](https://www.parlament.gv.at/recherchieren/protokolle/index.html)).

## Usage

``` r
get_transcripts(
  search_string = NULL,
  legis_period = NULL,
  meeting_type = NULL,
  date_start = NULL,
  date_end = NULL,
  echo = TRUE,
  export = NULL,
  export_destination = "transcripts"
)
```

## Arguments

- search_string:

  Optional character string to filter transcripts by keywords. Defaults
  to NULL.

- legis_period:

  Legislative period(s). `NULL` (the default) queries all available
  legislative periods. Accepts numeric (`10`), character (`"10"`), or
  Roman numerals (`"X"`), as well as `"KN"` (Konstituierende
  Nationalversammlung) and `"PN"` (Provisorische Nationalversammlung).

- meeting_type:

  Optional character string specifying the type(s) of meeting.
  Permissible values are "NRSITZ" (National Council - Plenary meetings)
  and "BRSITZ" (Federal Council - Plenary meetings). Defaults to NULL,
  which queries both NRSITZ and BRSITZ. See Details for more
  information.

- date_start:

  Optional start date for filtering transcripts. Defaults to NULL. Date
  has to be in dmy-format (e.g. "01.05.2020", "01/05/2020",
  "01-05-2020", "01052020").

- date_end:

  Optional end date for filtering transcripts. Defaults to NULL. Date
  has to be in dmy-format (e.g. "01.05.2020", "01/05/2020",
  "01-05-2020", "01052020").

- echo:

  Logical. If `TRUE`, the function prints the URL to the corresponding
  search results on the website of the Austrian Parliament and the
  number of results. Default is `TRUE`.

- export:

  Optional character string to enable PDF downloads. Set to "pdf" to
  download transcript PDFs. Defaults to NULL (no export).

- export_destination:

  Character string specifying the directory path where PDFs will be
  saved. Defaults to "transcripts" (a folder in the current working
  directory). If the folder does not exist, the user will be prompted to
  create it in interactive meetings.

## Value

A tibble containing transcript data with the following columns:

- date:

  Date of the meeting

- meeting_url:

  URL to the meeting page

- legis_period:

  Legislative period

- meeting_type:

  Type of meeting

- meeting_number:

  Meeting number/citation

- meeting:

  Meeting description

- meeting_transcript_html:

  URL to HTML transcript (if available)

- meeting_transcript_pdf:

  URL to PDF transcript (if available)

## Details

### Meeting Type ('Art der Sitzung')

Permissible values for `meeting_type`:

- NRSITZ: Nationalrat - Plenarsitzungen (National Council - Plenary
  meetings)

- BRSITZ: Bundesrat - Plenarsitzungen (Federal Council - Plenary
  meetings)

Note: Querying for other meeting types (Untersuchungsausschüsse,
Enqueten, Bundesversammlung, Ausschüsse, EU-Ausschüsse,
Gedenk-/Fest-/Trauersitzungen, Jugend- und Lehrlingsparlament,
Veranstaltungen) is currently only possible via the Parliament's
website.

### Implementation Notes

Queries returning more than 10,000 results will raise an error; in these
cases it is recommended to cut your query into multiple steps (e.g. by
using the purrr package).

If `legis_period = NULL` and `echo = TRUE`, the website URL explicitly
selects every available period. This reproduces the unrestricted API
search instead of using the website's current-period default.

### PDF Export

When `export = "pdf"`, the function additionaly downloads the PDF files
of the transcripts. The default destination is the folder "transcripts",
which will be created in the root of the project. In interactive
meetings, users are prompted to create the destination folder if it
doesn't exist, and if prefered, to provide an alternative destination
name. PDF filenames follow the pattern:
`YYYY-MM-DD_LegislativePeriod_MeetingType_MeetingNumber.pdf`. A summary
of successful and failed downloads is printed at the conclusion of the
download.

## Examples

``` r
# \donttest{
  # Get transcripts using a search string and specifying a legislative period.
  result <- get_transcripts(search_string = "gesundheit",
                  legis_period = 28,
                  meeting_type = "NRSITZ",
                  echo = TRUE)
#> Results on the Parliament website:
#> https://www.parlament.gv.at/recherchieren/protokolle?STENO_211GP_CODE=XXVIII&STENO_211NBVS=NRSITZ&STENO_211search=gesundheit
#> Hits: 24
  dplyr::glimpse(result)
#> Rows: 24
#> Columns: 8
#> $ date                    <date> 2024-12-11, 2025-03-26, 2025-04-24, 2025-05-1…
#> $ meeting_url             <chr> "/gegenstand/XXVIII/NRSITZ/5", "/gegenstand/XX…
#> $ legis_period            <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVII…
#> $ meeting_type            <chr> "NRSITZ", "NRSITZ", "NRSITZ", "NRSITZ", "NRSIT…
#> $ meeting_number          <chr> "5/NRSITZ", "13/NRSITZ", "17/NRSITZ", "21/NRSI…
#> $ meeting                 <chr> "5. Sitzung (5/NRSITZ)", "13. Sitzung (13/NRSI…
#> $ meeting_transcript_html <chr> "https://www.parlament.gv.at/dokument/XXVIII/N…
#> $ meeting_transcript_pdf  <chr> "https://www.parlament.gv.at/dokument/XXVIII/N…

 # Get transcript data for a specific period of time.
 result <- get_transcripts(meeting_type = "BRSITZ",
                 date_start = "01-01-2024",
                 date_end = "30-06-2024",
                 echo = TRUE)
#> Results on the Parliament website:
#> https://www.parlament.gv.at/recherchieren/protokolle?STENO_211NBVS=BRSITZ&STENO_211DATUM=2024-01-01T00%3A00%3A00.000Z&STENO_211DATUM=2024-06-30T00%3A00%3A00.000Z&STENO_211GP_CODE=I&STENO_211GP_CODE=II&STENO_211GP_CODE=III&STENO_211GP_CODE=IV&STENO_211GP_CODE=V&STENO_211GP_CODE=VI&STENO_211GP_CODE=VII&STENO_211GP_CODE=VIII&STENO_211GP_CODE=IX&STENO_211GP_CODE=X&STENO_211GP_CODE=XI&STENO_211GP_CODE=XII&STENO_211GP_CODE=XIII&STENO_211GP_CODE=XIV&STENO_211GP_CODE=XV&STENO_211GP_CODE=XVI&STENO_211GP_CODE=XVII&STENO_211GP_CODE=XVIII&STENO_211GP_CODE=XIX&STENO_211GP_CODE=XX&STENO_211GP_CODE=XXI&STENO_211GP_CODE=XXII&STENO_211GP_CODE=XXIII&STENO_211GP_CODE=XXIV&STENO_211GP_CODE=XXV&STENO_211GP_CODE=XXVI&STENO_211GP_CODE=XXVII&STENO_211GP_CODE=XXVIII&STENO_211GP_CODE=KN&STENO_211GP_CODE=PN
#> Hits: 6
 dplyr::glimpse(result)
#> Rows: 6
#> Columns: 8
#> $ date                    <date> 2024-02-15, 2024-03-14, 2024-04-05, 2024-04-2…
#> $ meeting_url             <chr> "/gegenstand/BR/BRSITZ/963", "/gegenstand/BR/B…
#> $ legis_period            <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "…
#> $ meeting_type            <chr> "BRSITZ", "BRSITZ", "BRSITZ", "BRSITZ", "BRSIT…
#> $ meeting_number          <chr> "963/BRSITZ/2024", "964/BRSITZ/2024", "965/BRS…
#> $ meeting                 <chr> "963. Sitzung (963/BRSITZ/2024)", "964. Sitzun…
#> $ meeting_transcript_html <chr> "https://www.parlament.gv.at/dokument/BR/BRSIT…
#> $ meeting_transcript_pdf  <chr> "https://www.parlament.gv.at/dokument/BR/BRSIT…
# }
if (FALSE) { # \dontrun{
  # Retrieve all transcripts of National Council plenary meetings
  # and download PDFs to default "transcripts" folder.
  get_transcripts(
    meeting_type = "NRSITZ",
    legis_period = 26,
    export = "pdf"
  )
} # }
```
