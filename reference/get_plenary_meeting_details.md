# Get Details of a Plenary Meeting

Retrieves detailed information about a specific plenary meeting from the
Austrian Parliament website. The function scrapes the embedded
JavaScript data from the meeting's detail page.

Supply either `url` **or** the combination of `institution`,
`legis_period`, and `meeting_number` — not both.

## Usage

``` r
get_plenary_meeting_details(
  url = NULL,
  institution = NULL,
  legis_period = NULL,
  meeting_number = NULL,
  details_on = NULL,
  echo = FALSE
)
```

## Arguments

- url:

  Character or NULL. URL of the plenary meeting page on
  `parlament.gv.at`. Can be an absolute URL (with or without a
  `?selectedStage=` query parameter) or a relative path. The
  `selectedStage` parameter is ignored when fetching data — both
  `selectedStage=100` and `selectedStage=110` return the same embedded
  dataset. Mutually exclusive with `institution`, `legis_period`, and
  `meeting_number`.

- institution:

  Character or NULL. Parliamentary chamber: `"NR"` (Nationalrat) or
  `"BR"` (Bundesrat). Mutually exclusive with `url`.

- legis_period:

  Character, numeric, or NULL. Legislative period. Accepts numeric
  (`28`), Arabic character (`"28"`), or Roman numeral (`"XXVIII"`)
  formats. Mutually exclusive with `url`.

- meeting_number:

  Character, numeric, or NULL. Meeting number within the legislative
  period (e.g. `50` or `"50"`). Mutually exclusive with `url`.

- details_on:

  Character or NULL. Specifies which part of the meeting data to return.
  If `NULL` (default), returns a 1-row tibble with meeting metadata. Use
  `"speakers"` to return a multi-row tibble with one row per speech,
  including timing information. Use `"decisions"` to return a multi-row
  tibble with one row per agenda item (TOP). Use `"timeline"` to return
  a multi-row tibble with one row per Sitzungsverlauf event.

- echo:

  Logical. If `TRUE`, prints the URL being fetched and the number of
  rows returned. Default is `FALSE`.

## Value

A tibble. The structure depends on `details_on`:

If `details_on = NULL` (default):

- `meeting_url` (character): The URL used to fetch the data.

- `meeting_title` (character): Full title of the meeting.

- `meeting_citation` (character): Citation reference (e.g.
  `"50/NRSITZ"`).

- `legis_period` (character): Legislative period code (e.g. `"XXVIII"`).

- `meeting_type` (character): Meeting type label (e.g.
  `"Plenarsitzung"`).

- `meeting_type_short` (character): Short type code (e.g. `"NRSITZ"`).

- `meeting_nr` (integer): Meeting number within the legislative period.

- `date` (Date): Date of the meeting.

- `state` (character): Completion state (e.g. `"fertig"`).

- `start_time` (POSIXct): Start time of the meeting.

- `end_time` (POSIXct): End time of the meeting.

If `details_on = "speakers"`:

- `meeting_url` (character): The URL used to fetch the data.

- `meeting_title` (character): Full title of the meeting.

- `meeting_citation` (character): Citation reference (e.g.
  `"50/NRSITZ"`).

- `legis_period` (character): Legislative period code (e.g. `"XXVIII"`).

- `meeting_type` (character): Meeting type label (e.g.
  `"Plenarsitzung"`).

- `debate_id` (integer): Internal debate identifier.

- `debate_type` (character): Debate type code (`"AS"`, `"ND"`, `"DA"`,
  `"SU"`).

- `debate_typetext` (character): Human-readable debate type label.

- `debate_text` (character): Full debate heading text.

- `debate_starttime` (character): Debate start time (ISO 8601 or time
  string).

- `debate_endtime` (character): Debate end time (time string).

- `debate_limit` (integer): Default per-speech time limit in minutes.

- `debate_state` (character): Debate completion state.

- `speech_nr` (integer): Sequential speech number within the debate.

- `speech_state` (character): Speech completion state.

- `speaker_name` (character): Speaker name with party abbreviation.

- `pad_intern` (integer): Internal person identifier.

- `wm_type` (character): Speech type abbreviation (`"wm"`, `"un"`,
  `"sr"`, etc.).

- `start_time` (character): Speech start time (HH:MM).

- `duration` (character): Actual speech duration (MM:SS).

- `speech_limit` (integer): Individual speech time limit in minutes.

If `details_on = "decisions"`:

- `meeting_url` (character): The URL used to fetch the data.

- `meeting_title` (character): Full title of the meeting.

- `meeting_citation` (character): Citation reference (e.g.
  `"59/NRSITZ"`).

- `legis_period` (character): Legislative period code (e.g. `"XXVIII"`).

- `meeting_type` (character): Meeting type label (e.g.
  `"Plenarsitzung"`).

- `resolution_top` (character): Agenda item label (e.g. `"TOP 1"`).

- `resolution_title` (character): Agenda item title.

- `resolution_url` (character): Relative URL to the main document.

- `resolution_citation` (character): Citation of the main document (e.g.
  `"319 d.B."`).

If `details_on = "timeline"`:

- `meeting_url` (character): The URL used to fetch the data.

- `meeting_title` (character): Full title of the meeting.

- `meeting_citation` (character): Citation reference (e.g.
  `"59/NRSITZ"`).

- `legis_period` (character): Legislative period code (e.g. `"XXVIII"`).

- `meeting_type` (character): Meeting type label (e.g.
  `"Plenarsitzung"`).

- `stage_date` (character): Date of the event (`"DD.MM.YYYY"`), or `NA`
  for agenda-item rows. The Schriftführer row (no text) is excluded.

- `agenda_item` (character): Agenda item label (e.g. `"TOP 1"`) for TOP
  rows, or `NA` for dated rows.

- `stage_text` (character): Plain-text description of the event (HTML
  stripped).

- `statements` (list): For "Wortmeldungen in der Debatte" rows, a nested
  tibble with one row per speaker: `speaker_name` (character),
  `speaker_url` (character), `wm_type` (character, e.g. `"Pro"`,
  `"Contra"`), `protocol_ref` (character, e.g. `"RN/4"`), `protocol_url`
  (character). `NULL` for all other rows.

- `stage_fsth_url` (character): URL to the stenographic protocol
  reference, or `NA`.

- `stage_fsth_title` (character): Title of the stenographic protocol
  reference, or `NA`.

## See also

- [`get_plenary_meetings()`](https://werkstattcodes.github.io/ParlAT/reference/get_plenary_meetings.md)
  for retrieving meeting URLs.

## Examples

``` r
# \donttest{
# Via URL — meeting metadata (default)
get_plenary_meeting_details(
  url = "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50?selectedStage=100"
)
#> # A tibble: 1 × 11
#>   meeting_url           meeting_title meeting_citation legis_period meeting_type
#>   <chr>                 <chr>         <chr>            <chr>        <chr>       
#> 1 https://www.parlamen… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#> # ℹ 6 more variables: meeting_type_short <chr>, meeting_nr <int>, date <date>,
#> #   state <chr>, start_time <dttm>, end_time <dttm>

# Via structured arguments — numeric legis_period
get_plenary_meeting_details(institution = "NR", legis_period = 28, meeting_number = 50)
#> # A tibble: 1 × 11
#>   meeting_url           meeting_title meeting_citation legis_period meeting_type
#>   <chr>                 <chr>         <chr>            <chr>        <chr>       
#> 1 https://www.parlamen… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#> # ℹ 6 more variables: meeting_type_short <chr>, meeting_nr <int>, date <date>,
#> #   state <chr>, start_time <dttm>, end_time <dttm>

# Via structured arguments — Roman numeral legis_period, speakers mode
get_plenary_meeting_details(
  institution = "NR", legis_period = "XXVIII", meeting_number = 50,
  details_on = "speakers", echo = TRUE
)
#> Fetching URL: https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50
#> details_on: speakers
#> Returning 162 row(s).
#> # A tibble: 162 × 21
#>    meeting_url          meeting_title meeting_citation legis_period meeting_type
#>    <chr>                <chr>         <chr>            <chr>        <chr>       
#>  1 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  2 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  3 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  4 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  5 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  6 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  7 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  8 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  9 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#> 10 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#> # ℹ 152 more rows
#> # ℹ 16 more variables: debate_id <int>, debate_type <chr>,
#> #   debate_typetext <chr>, debate_text <chr>, debate_starttime <chr>,
#> #   debate_endtime <chr>, debate_limit <int>, debate_state <chr>,
#> #   speech_nr <int>, speech_state <chr>, speaker_name <chr>, pad_intern <int>,
#> #   wm_type <chr>, start_time <chr>, duration <chr>, speech_limit <int>

# Via URL — speaker list with timing information
get_plenary_meeting_details(
  url = "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50",
  details_on = "speakers"
)
#> # A tibble: 162 × 21
#>    meeting_url          meeting_title meeting_citation legis_period meeting_type
#>    <chr>                <chr>         <chr>            <chr>        <chr>       
#>  1 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  2 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  3 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  4 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  5 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  6 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  7 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  8 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#>  9 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#> 10 https://www.parlame… 50. Sitzung … 50/NRSITZ        XXVIII       Plenarsitzu…
#> # ℹ 152 more rows
#> # ℹ 16 more variables: debate_id <int>, debate_type <chr>,
#> #   debate_typetext <chr>, debate_text <chr>, debate_starttime <chr>,
#> #   debate_endtime <chr>, debate_limit <int>, debate_state <chr>,
#> #   speech_nr <int>, speech_state <chr>, speaker_name <chr>, pad_intern <int>,
#> #   wm_type <chr>, start_time <chr>, duration <chr>, speech_limit <int>
# }
```
