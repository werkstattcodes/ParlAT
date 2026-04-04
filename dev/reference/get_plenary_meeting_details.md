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

A tibble. The structure depends on `details_on`. For short constitutive
sessions (e.g. committee-election meetings) that had no debates, the
`"speakers"`, `"decisions"`, and `"timeline"` modes may return a 0-row
tibble with the documented columns.

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

- [`get_plenary_meetings()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_plenary_meetings.md)
  for retrieving meeting URLs.

## Examples

``` r
# \donttest{
# Via URL — meeting metadata (default)
result <- get_plenary_meeting_details(
  url = "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50?selectedStage=100"
)
dplyr::glimpse(result)
#> Rows: 1
#> Columns: 11
#> $ meeting_url        <chr> "https://www.parlament.gv.at/gegenstand/XXVIII/NRSI…
#> $ meeting_title      <chr> "50. Sitzung des Nationalrats vom 19. November 2025"
#> $ meeting_citation   <chr> "50/NRSITZ"
#> $ legis_period       <chr> "XXVIII"
#> $ meeting_type       <chr> "Plenarsitzung"
#> $ meeting_type_short <chr> "NRSITZ"
#> $ meeting_nr         <int> 50
#> $ date               <date> 2025-11-19
#> $ state              <chr> "fertig"
#> $ start_time         <dttm> 2025-11-19 09:05:00
#> $ end_time           <dttm> 2025-11-19 21:37:00

# Via structured arguments — numeric legis_period
result <- get_plenary_meeting_details(
  institution = "NR", legis_period = 28, meeting_number = 50
)
dplyr::glimpse(result)
#> Rows: 1
#> Columns: 11
#> $ meeting_url        <chr> "https://www.parlament.gv.at/gegenstand/XXVIII/NRSI…
#> $ meeting_title      <chr> "50. Sitzung des Nationalrats vom 19. November 2025"
#> $ meeting_citation   <chr> "50/NRSITZ"
#> $ legis_period       <chr> "XXVIII"
#> $ meeting_type       <chr> "Plenarsitzung"
#> $ meeting_type_short <chr> "NRSITZ"
#> $ meeting_nr         <int> 50
#> $ date               <date> 2025-11-19
#> $ state              <chr> "fertig"
#> $ start_time         <dttm> 2025-11-19 09:05:00
#> $ end_time           <dttm> 2025-11-19 21:37:00

# Via structured arguments — Roman numeral legis_period, speakers mode
result <- get_plenary_meeting_details(
  institution = "NR", legis_period = "XXVIII", meeting_number = 50,
  details_on = "speakers", echo = TRUE
)
#> Fetching URL: https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50
#> details_on: speakers
#> Returning 162 row(s).
dplyr::glimpse(result)
#> Rows: 162
#> Columns: 21
#> $ meeting_url      <chr> "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ…
#> $ meeting_title    <chr> "50. Sitzung des Nationalrats vom 19. November 2025",…
#> $ meeting_citation <chr> "50/NRSITZ", "50/NRSITZ", "50/NRSITZ", "50/NRSITZ", "…
#> $ legis_period     <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XX…
#> $ meeting_type     <chr> "Plenarsitzung", "Plenarsitzung", "Plenarsitzung", "P…
#> $ debate_id        <int> 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150…
#> $ debate_type      <chr> "AS", "AS", "AS", "AS", "AS", "AS", "AS", "AS", "AS",…
#> $ debate_typetext  <chr> "Aktuelle Stunde", "Aktuelle Stunde", "Aktuelle Stund…
#> $ debate_text      <chr> "Aktuelle Stunde: \"Schluss mit der Zwangsfinanzierun…
#> $ debate_starttime <chr> "2025-11-19T09:07:00", "2025-11-19T09:07:00", "2025-1…
#> $ debate_endtime   <chr> "10:20", "10:20", "10:20", "10:20", "10:20", "10:20",…
#> $ debate_limit     <int> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 20, 20, 20, 20, 2…
#> $ debate_state     <chr> "fertig", "fertig", "fertig", "fertig", "fertig", "fe…
#> $ speech_nr        <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5,…
#> $ speech_state     <chr> "fertig", "fertig", "fertig", "fertig", "fertig", "fe…
#> $ speaker_name     <chr> "Michael Schnedlitz (F)", "BM Mag. Dr. Wolfgang Hattm…
#> $ pad_intern       <int> 64022, 30720, 30647, 2122, 30693, 5687, 5653, 35520, …
#> $ wm_type          <chr> "un", "sr", "wm", "wm", "wm", "wm", "wm", "wm", "wm",…
#> $ start_time       <chr> "09:08", "09:19", "09:25", "09:31", "09:37", "09:42",…
#> $ duration         <chr> "9:55", "6:27", "5:00", "5:00", "4:48", "5:00", "4:55…
#> $ speech_limit     <int> 10, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 3, 4, 5, 4, 3…

# Via URL — speaker list with timing information
result <- get_plenary_meeting_details(
  url = "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50",
  details_on = "speakers"
)
dplyr::glimpse(result)
#> Rows: 162
#> Columns: 21
#> $ meeting_url      <chr> "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ…
#> $ meeting_title    <chr> "50. Sitzung des Nationalrats vom 19. November 2025",…
#> $ meeting_citation <chr> "50/NRSITZ", "50/NRSITZ", "50/NRSITZ", "50/NRSITZ", "…
#> $ legis_period     <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XX…
#> $ meeting_type     <chr> "Plenarsitzung", "Plenarsitzung", "Plenarsitzung", "P…
#> $ debate_id        <int> 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150…
#> $ debate_type      <chr> "AS", "AS", "AS", "AS", "AS", "AS", "AS", "AS", "AS",…
#> $ debate_typetext  <chr> "Aktuelle Stunde", "Aktuelle Stunde", "Aktuelle Stund…
#> $ debate_text      <chr> "Aktuelle Stunde: \"Schluss mit der Zwangsfinanzierun…
#> $ debate_starttime <chr> "2025-11-19T09:07:00", "2025-11-19T09:07:00", "2025-1…
#> $ debate_endtime   <chr> "10:20", "10:20", "10:20", "10:20", "10:20", "10:20",…
#> $ debate_limit     <int> 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 20, 20, 20, 20, 2…
#> $ debate_state     <chr> "fertig", "fertig", "fertig", "fertig", "fertig", "fe…
#> $ speech_nr        <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5,…
#> $ speech_state     <chr> "fertig", "fertig", "fertig", "fertig", "fertig", "fe…
#> $ speaker_name     <chr> "Michael Schnedlitz (F)", "BM Mag. Dr. Wolfgang Hattm…
#> $ pad_intern       <int> 64022, 30720, 30647, 2122, 30693, 5687, 5653, 35520, …
#> $ wm_type          <chr> "un", "sr", "wm", "wm", "wm", "wm", "wm", "wm", "wm",…
#> $ start_time       <chr> "09:08", "09:19", "09:25", "09:31", "09:37", "09:42",…
#> $ duration         <chr> "9:55", "6:27", "5:00", "5:00", "4:48", "5:00", "4:55…
#> $ speech_limit     <int> 10, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 4, 3, 4, 5, 4, 3…
# }
```
