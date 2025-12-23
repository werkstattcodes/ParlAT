# Retrieve Transcripts from the Austrian Parliament API

`get_transcripts()` retrieves the transcripts of parliamentary sessions
via Parliament's API (see
[here](https://www.parlament.gv.at/recherchieren/protokolle/index.html)).

## Usage

``` r
get_transcripts(
  search_string = NULL,
  legis_period = NULL,
  session_type = NULL,
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

- session_type:

  Optional character string specifying the type(s) of session.
  Permissible values are "NRSITZ" (National Council - Plenary sessions)
  and "BRSITZ" (Federal Council - Plenary sessions). Defaults to NULL,
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
  create it in interactive sessions.

## Value

A tibble containing transcript data with the following columns:

- date:

  Date of the session

- session_url:

  URL to the session page

- legis_period:

  Legislative period

- session_type:

  Type of session

- session_number:

  Session number/citation

- session:

  Session description

- session_transcript_html:

  URL to HTML transcript (if available)

- session_transcript_pdf:

  URL to PDF transcript (if available)

## Details

### Session Type ('Art der Sitzung')

Permissible values for `session_type`:

- NRSITZ: Nationalrat - Plenarsitzungen (National Council - Plenary
  sessions)

- BRSITZ: Bundesrat - Plenarsitzungen (Federal Council - Plenary
  sessions)

Note: Querying for other session types (Untersuchungsausschüsse,
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
sessions, users are prompted to create the destination folder if it
doesn't exist, and if prefered, to provide an alternative destination
name. PDF filenames follow the pattern:
`YYYY-MM-DD_LegislativePeriod_SessionType_SessionNumber.pdf`. A summary
of successful and failed downloads is printed at the conclusion of the
download.

## Examples

``` r
if (FALSE) { # \dontrun{
  # Get transcripts using a search string and specifying a legislative period.
  get_transcripts(search_string = "gesundheit",
                  legis_period = 28,
                  session_type = "NRSITZ",
                  echo=TRUE)

 # Get transcript data for a specific period of time.
 get_transcripts(session_type = "BRSITZ",
                 date_start = "01-01-2024",
                 date_end = "30-06-2024",
                 echo = TRUE)

  # Retrieve all transcripts of National Council plenary sessions
  # and download PDFs to default "transcripts" folder.
  get_transcripts(
    session_type = "NRSITZ",
    legis_period = 26,
    export = "pdf"
  )

} # }
```
