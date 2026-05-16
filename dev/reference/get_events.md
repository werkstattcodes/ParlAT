# Get Event Data from Austrian Parliament API

This function retrieves event data based on search parameters from the
Austrian Parliament API. It mirrors the search functionality on the
Austrian Parliament website at [this
page](https://www.parlament.gv.at/aktuelles/termine/index.html), and
additionally facilitates searches by legislative period.

## Usage

``` r
get_events(
  institution = NULL,
  event_type = NULL,
  location = NULL,
  legis_period = NULL,
  date_start = NULL,
  date_end = NULL,
  echo = TRUE
)
```

## Arguments

- institution:

  Character vector specifying the institution(s) to query. Must be "NR"
  (Nationalrat/National Council), "BR" (Bundesrat/Federal Council), or
  "ParlDir/Klub" ("Parliamentary Directorate/Caucus"). Can be a single
  value or vector for multiple institutions. NULL covers all
  institutions.

- event_type:

  Optional character string indicating the event type. Must be one of
  the predefined event types (see Details). Default is NULL (all types).

- location:

  Optional character string to filter events by location. Must be one of
  the predefined locations (see Details). Default is NULL (all
  locations).

- legis_period:

  Character or numeric value of length 1, or NULL. Specifies the
  legislative period to search in. Only available if `date_start` and
  `date_end` are NULL.

- date_start:

  Optional character string representing the start date in
  day-month-year (DMY) format (e.g., "26-10-2025", "26.10.2025", or
  "26/10/2025"). Default is NULL.

- date_end:

  Optional character string representing the end date in day-month-year
  (DMY) format (e.g., "26-10-2025", "26.10.2025", or "26/10/2025").
  Default is NULL.

- echo:

  Logical indicating whether to print used search parameters, number of
  hits, and link to results on website of parliament. Default is TRUE.

## Value

A data frame containing event details with the following columns, or
NULL if no results are found:

- `date`: Event date (parsed as Date)

- `date_time_start`: Event start date and time (parsed as POSIXct)

- `date_time_end`: Event end date and time (parsed as POSIXct)

- `title`: Event title/name

- `event_type`: Type of event

- `location`: Event location/venue

- `topic`: Event topic/subject

- `institution`: Institution hosting the event

- `media_relevance`: Media relevance indicator

- `guidance_type`: Type of guidance (if applicable)

- `group`: Group information

- `view`: View/visibility settings

- `fully_booked`: Whether the event is fully booked

- `registration`: Registration information

- `livestream_url`: URL for livestream (if available)

- `available`: Availability status

- `language`: Event language

- `link`: Primary link to event details

- `link2`: Secondary link (if available)

## Details

### event_type

Allowed event types are:

- "Plenarsitzung" (Plenary Meeting)

- "Ausschusssitzung oder Ausschuss" (Committee Meeting or Committee)

- "Besuch einer Plenarsitzung" (Visit to a Plenary Meeting)

- "Demokratiebildung" (Democracy Education)

- "Fest-/Gedenksitzung" (Ceremonial/Commemorative Meeting)

- "Führung" (Guided Tour)

- "Internationales" (International)

- "Klubveranstaltung" (Club Event)

- "Konferenz" (Conference)

- "Parlamentarische Enquete" (Parliamentary Inquiry)

- "Pressekonferenz" (Press Conference)

- "Sitzung der Bundesversammlung" (Federal Assembly Meeting)

- "Sonstiger Termin" (Other Event)

- "Veranstaltung" (Event)

### location

Allowed locations are:

- "Abgeordneten-Sprechzimmer (alt)"

- "Auditorium"

- "Außer Haus"

- "Bertha von Suttner \| Lokal 4"

- "Blauer Salon (Epstein E1)"

- "Bundesratssaal"

- "Bundesrats-Sitzungssaal (alt)"

- "Bundesversammlungssaal"

- "Burgraum (Hofburg)"

- "Camineum (ÖNB)"

- "Dachfoyer (Hofburg)"

- "Egon Schiele \| Lokal 7"

- "Elise Richter \| Lokal 2"

- "Empfangssalon"

- "Epstein Beletage"

- "Epstein Innenhof"

- "Erwin Schrödinger \| Lokal 1"

- "Extern"

- "Festsaal (Epstein E3)"

- "Großer Prunksaal (1. OG Stubenring)"

- "Großer Redoutensaal"

- "Heldenplatz"

- "Historischer Sitzungssaal (alt)"

- "Kunschak-Saal"

- "Lise Meitner \| Lokal 6"

- "Lokal I (Ministerratszimmer, alt)"

- "Lokal II (alt)"

- "Lokal III (alt)"

- "Lokal IV (alt)"

- "Lokal V (alt)"

- "Lokal VI (Budgetsaal, alt)"

- "Lokal VII (alt)"

- "Lokal VIII (alt)"

- "Lokal 1 Medienraum (EG Bibliothekshof)"

- "Lokal 2 (EG Bibliothekshof)"

- "Lokal 3 (EG Bibliothekshof)"

- "Lokal 4 (2. OG Bibliothekshof)"

- "Lokal 5 (3. OG Bibliothekshof)"

- "Lokal 6 (3. OG Bibliothekshof)"

- "Lokal 7 (Hofburg Segmentbogen)"

- "Ludwig Wittgenstein \| Lokal 5"

- "Nationalratssaal"

- "Nationalrats-Sitzungssaal (alt)"

- "Palais Epstein"

- "Parlament"

- "Parliament"

- "Plenar-Lounge"

- "Portikus"

- "Pressezentrum"

- "Roter Salon (Epstein E4)"

- "Säulenhalle"

- "Säulenhalle (alt)"

- "Spielsalon (Epstein E5)"

- "Teamentwicklung"

- "Theophil Hansen \| Lokal 3"

- "virtuell"

## Note

Free Text Search: Due to limitations of the underlying API, this
function does not currently support a general free text search across
all fields. Search functionality is restricted to the specific
parameters provided.

## Examples

``` r
# \donttest{
  # Basic example: Get all National Council events
  events <- get_events(institution = "NR")
#> {"GREMIUM":["Nationalrat"]} 
#> https://www.parlament.gv.at/aktuelles/termine/index.html?TERMIN_01GREMIUM=Nationalrat
#> [1] 11293
  dplyr::glimpse(events)
#> Rows: 11,293
#> Columns: 15
#> $ date            <date> 2027-07-09, 2027-07-09, 2027-07-09, 2027-07-09, 2027-…
#> $ date_time_end   <dttm> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ title           <chr> "...&nbsp;(Reserviert für Sitzung des Nationalrates)",…
#> $ event_type      <chr> "Plenarsitzung", "Besuch einer Plenarsitzung", "Besuch…
#> $ location        <chr> NA, "Parlament", "Parlament", "Parlament", "Parlament"…
#> $ topic           <chr> NA, "[\"Parlament und Demokratie\"]", "[\"Parlament un…
#> $ institution     <chr> "Nationalrat", "Nationalrat", "Nationalrat", "National…
#> $ media_relevance <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N",…
#> $ group           <chr> NA, "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", …
#> $ view            <chr> "[\"S\"]", "[\"S\"]", "[\"S\"]", "[\"S\"]", "[\"S\"]",…
#> $ fully_booked    <chr> NA, "noch nicht verfügbar", "noch nicht verfügbar", "n…
#> $ registration    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ livestream_url  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "<div clas…
#> $ language        <chr> NA, "[\"Deutsch\"]", "[\"Deutsch\"]", "[\"Deutsch\"]",…
#> $ link            <chr> NA, "/erleben/fuehrungen/266085", "/erleben/fuehrungen…

  # Get events with specific date range
  events <- get_events(
    institution = "NR",
    date_start = "01-01-2024",
    date_end = "31-01-2024"
  )
#> {"DATERANGE":["2023-12-31T23:00:00.000Z","2024-01-31T22:59:59.000Z"],"GREMIUM":["Nationalrat"]} 
#> https://www.parlament.gv.at/aktuelles/termine/index.html?TERMIN_01DATERANGE=2023-12-31T23:00:00.000Z&TERMIN_01DATERANGE=2024-01-31T22:59:59.000Z&TERMIN_01GREMIUM=Nationalrat
#> [1] 16
  dplyr::glimpse(events)
#> Rows: 16
#> Columns: 15
#> $ date            <date> 2024-01-31, 2024-01-31, 2024-01-31, 2024-01-31, 2024-…
#> $ date_time_end   <dttm> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ title           <chr> "250.&nbsp;Sitzung des Nationalrates", "2. Sitzung &qu…
#> $ event_type      <chr> "Plenarsitzung", "Ausschusssitzung oder Ausschuss", "P…
#> $ location        <chr> "Nationalratssaal", "Lokal 1  |  Erwin Schrödinger", "…
#> $ topic           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ institution     <chr> "Nationalrat", "Nationalrat", "Nationalrat", "National…
#> $ media_relevance <chr> "J", "J", "J", "J", "J", "J", "J", "J", "J", "J", "J",…
#> $ group           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ view            <chr> "[\"S\"]", "[\"S\"]", "[\"S\"]", "[\"S\"]", "[\"S\"]",…
#> $ fully_booked    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ registration    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ livestream_url  <chr> "<a href=\"/aktuelles/mediathek/XXVII/NRSITZ/250\" tit…
#> $ language        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ link            <chr> "/gegenstand/XXVII/NRSITZ/250", "/ausschuss/XXVII/A-US…

  # Get plenary meetings in the National Council chamber
  events <- get_events(
    institution = "NR",
    event_type = "Plenarsitzung",
    location = "Nationalratssaal"
  )
#> {"GREMIUM":["Nationalrat"],"TERMINART":["Plenarsitzung"],"ORT":["Nationalratssaal"]} 
#> https://www.parlament.gv.at/aktuelles/termine/index.html?TERMIN_01GREMIUM=Nationalrat&TERMIN_01TERMINART=Plenarsitzung&TERMIN_01ORT=Nationalratssaal
#> [1] 189
  dplyr::glimpse(events)
#> Rows: 189
#> Columns: 15
#> $ date            <date> 2027-07-08, 2027-07-07, 2027-06-17, 2027-06-16, 2027-…
#> $ date_time_end   <dttm> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ title           <chr> "...&nbsp;Sitzung des Nationalrates", "...&nbsp;Sitzun…
#> $ event_type      <chr> "Plenarsitzung", "Plenarsitzung", "Plenarsitzung", "Pl…
#> $ location        <chr> "Nationalratssaal", "Nationalratssaal", "Nationalratss…
#> $ topic           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ institution     <chr> "Nationalrat", "Nationalrat", "Nationalrat", "National…
#> $ media_relevance <chr> "N", "N", "N", "N", "N", "N", "N", "N", "N", "N", "N",…
#> $ group           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ view            <chr> "[\"S\"]", "[\"S\"]", "[\"S\"]", "[\"S\"]", "[\"S\"]",…
#> $ fully_booked    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ registration    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ livestream_url  <chr> "<div class=\"live-container svelte-mxjsp1\"><i aria-h…
#> $ language        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ link            <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…

  # Get events for a specific legislative period
  events <- get_events(
    institution = "NR",
    legis_period = 28
  )
#> {"DATERANGE":["2024-10-23T22:00:00.000Z","2026-05-16T21:59:59.000Z"],"GREMIUM":["Nationalrat"]} 
#> https://www.parlament.gv.at/aktuelles/termine/index.html?TERMIN_01DATERANGE=2024-10-23T22:00:00.000Z&TERMIN_01DATERANGE=2026-05-16T21:59:59.000Z&TERMIN_01GREMIUM=Nationalrat
#> [1] 578
  dplyr::glimpse(events)
#> Rows: 578
#> Columns: 15
#> $ date            <date> 2026-05-13, 2026-05-13, 2026-05-13, 2026-05-12, 2026-…
#> $ date_time_end   <dttm> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ title           <chr> "20. Sitzung Pilnacek-Untersuchungsausschuss", "8. Sit…
#> $ event_type      <chr> "Ausschusssitzung oder Ausschuss", "Ausschusssitzung o…
#> $ location        <chr> "Lokal 1  |  Erwin Schrödinger", "Lokal 6  |  Lise Mei…
#> $ topic           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ institution     <chr> "Nationalrat", "Nationalrat", "Nationalrat", "National…
#> $ media_relevance <chr> "J", "J", "J", "J", "J", "J", "J", "J", "J", "J", "J",…
#> $ group           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ view            <chr> "[\"S\"]", "[\"S\"]", "[\"S\"]", "[\"S\"]", "[\"S\"]",…
#> $ fully_booked    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ registration    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ livestream_url  <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ language        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ link            <chr> "/ausschuss/XXVIII/A-USA/2/00944?selectedSession=20&se…
# }
```
