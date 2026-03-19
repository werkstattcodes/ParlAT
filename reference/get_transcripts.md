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

  Legislative period(s). Default NULL queries for all legislative
  periods. Accepts numeric (10), character ("10") or roman numerals in
  character format ("X") as well as "KN" (Konstituierende
  Nationalversammlung) and "PN" (Provisorische Nationalversammlung).

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

  Logical. If TRUE, the function prints the used search parameters and
  the url to the pertaining search results on the website of the
  Austrian Parliament. Default is NULL.

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
  get_transcripts(search_string = "gesundheit",
                  legis_period = 28,
                  meeting_type = "NRSITZ",
                  echo=TRUE)
#> {"GP_CODE":["XXVIII"],"NBVS":["NRSITZ"]} 
#> https://www.parlament.gv.at/recherchieren/protokolle/index.html?STENO_211GP_CODE=XXVIII&STENO_211NBVS=NRSITZ&STENO_211search=gesundheit
#> [1] 16
#> # A tibble: 16 × 8
#>    date       meeting_url       legis_period meeting_type meeting_number meeting
#>    <date>     <chr>             <chr>        <chr>        <chr>          <chr>  
#>  1 2024-12-11 /gegenstand/XXVI… XXVIII       NRSITZ       5/NRSITZ       5. Sit…
#>  2 2025-03-26 /gegenstand/XXVI… XXVIII       NRSITZ       13/NRSITZ      13. Si…
#>  3 2025-04-24 /gegenstand/XXVI… XXVIII       NRSITZ       17/NRSITZ      17. Si…
#>  4 2025-05-13 /gegenstand/XXVI… XXVIII       NRSITZ       21/NRSITZ      21. Si…
#>  5 2025-06-16 /gegenstand/XXVI… XXVIII       NRSITZ       32/NRSITZ      32. Si…
#>  6 2025-07-09 /gegenstand/XXVI… XXVIII       NRSITZ       35/NRSITZ      35. Si…
#>  7 2025-07-10 /gegenstand/XXVI… XXVIII       NRSITZ       37/NRSITZ      37. Si…
#>  8 2025-07-11 /gegenstand/XXVI… XXVIII       NRSITZ       39/NRSITZ      39. Si…
#>  9 2025-09-24 /gegenstand/XXVI… XXVIII       NRSITZ       41/NRSITZ      41. Si…
#> 10 2025-10-15 /gegenstand/XXVI… XXVIII       NRSITZ       44/NRSITZ      44. Si…
#> 11 2025-10-16 /gegenstand/XXVI… XXVIII       NRSITZ       46/NRSITZ      46. Si…
#> 12 2025-11-19 /gegenstand/XXVI… XXVIII       NRSITZ       50/NRSITZ      50. Si…
#> 13 2025-12-10 /gegenstand/XXVI… XXVIII       NRSITZ       55/NRSITZ      55. Si…
#> 14 2025-12-11 /gegenstand/XXVI… XXVIII       NRSITZ       57/NRSITZ      57. Si…
#> 15 2025-12-12 /gegenstand/XXVI… XXVIII       NRSITZ       59/NRSITZ      59. Si…
#> 16 2026-02-25 /gegenstand/XXVI… XXVIII       NRSITZ       66/NRSITZ      66. Si…
#> # ℹ 2 more variables: meeting_transcript_html <chr>,
#> #   meeting_transcript_pdf <chr>

 # Get transcript data for a specific period of time.
 get_transcripts(meeting_type = "BRSITZ",
                 date_start = "01-01-2024",
                 date_end = "30-06-2024",
                 echo = TRUE)
#> {"NBVS":["BRSITZ"],"DATUM":["2024-01-01T00:00:00.000Z","2024-06-30T00:00:00.000Z"]} 
#> https://www.parlament.gv.at/recherchieren/protokolle/index.html?STENO_211NBVS=BRSITZ&STENO_211DATUM=2024-01-01T00:00:00.000Z&STENO_211DATUM=2024-06-30T00:00:00.000Z
#> [1] 6
#> # A tibble: 6 × 8
#>   date       meeting_url        legis_period meeting_type meeting_number meeting
#>   <date>     <chr>              <chr>        <chr>        <chr>          <chr>  
#> 1 2024-02-15 /gegenstand/BR/BR… XXVII        BRSITZ       963/BRSITZ/20… 963. S…
#> 2 2024-03-14 /gegenstand/BR/BR… XXVII        BRSITZ       964/BRSITZ/20… 964. S…
#> 3 2024-04-05 /gegenstand/BR/BR… XXVII        BRSITZ       965/BRSITZ/20… 965. S…
#> 4 2024-04-24 /gegenstand/BR/BR… XXVII        BRSITZ       966/BRSITZ/20… 966. S…
#> 5 2024-05-29 /gegenstand/BR/BR… XXVII        BRSITZ       967/BRSITZ/20… 967. S…
#> 6 2024-06-27 /gegenstand/BR/BR… XXVII        BRSITZ       968/BRSITZ/20… 968. S…
#> # ℹ 2 more variables: meeting_transcript_html <chr>,
#> #   meeting_transcript_pdf <chr>
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
