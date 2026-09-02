# Get Event Data from Austrian Parliament API

This function retrieves event data based on search parameters from the
Austrian Parliament API. It mirrors the search functionality on the
Austrian Parliament website at [the 'Termine'
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
  `date_end` are NULL. When all three parameters are NULL, events from
  all available dates are returned.

- date_start:

  Optional character string representing the start date in
  day-month-year (DMY) format (e.g., "26-10-2025", "26.10.2025", or
  "26/10/2025"). Default is NULL.

- date_end:

  Optional character string representing the end date in day-month-year
  (DMY) format (e.g., "26-10-2025", "26.10.2025", or "26/10/2025").
  Default is NULL.

- echo:

  Logical indicating whether to print the link to the corresponding
  results on the Parliament website and the number of hits. Default is
  TRUE.

## Value

A tibble containing event details with the following columns (zero rows
if no results are found):

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

When `legis_period`, `date_start`, and `date_end` are all NULL, the API
search is unrestricted by date. The echoed Parliament website URL
derives an explicit lower date bound and availability values from the
returned rows so that the website reproduces the unrestricted API
results instead of applying its current-events defaults.

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
#> Results on the Parliament website:
#> https://www.parlament.gv.at/aktuelles/termine?TERMIN_01GREMIUM=Nationalrat&TERMIN_01DATERANGE=1918-11-12T23%3A00%3A00.000Z&TERMIN_01VERFUEGBAR=J&TERMIN_01VERFUEGBAR=V
#> Hits: 11306
  dplyr::glimpse(events)
#> Rows: 11,306
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
#> Results on the Parliament website:
#> https://www.parlament.gv.at/aktuelles/termine?TERMIN_01DATERANGE=2023-12-31T23%3A00%3A00.000Z&TERMIN_01DATERANGE=2024-01-31T22%3A59%3A59.000Z&TERMIN_01GREMIUM=Nationalrat&TERMIN_01VERFUEGBAR=J
#> Hits: 16
  dplyr::glimpse(events)
#> Rows: 16
#> Columns: 15
#> $ date            <date> 2024-01-31, 2024-01-31, 2024-01-31, 2024-01-31, 2024-…
#> $ date_time_end   <dttm> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ title           <chr> "250.&nbsp;Sitzung des Nationalrates", "249.&nbsp;Sitz…
#> $ event_type      <chr> "Plenarsitzung", "Plenarsitzung", "Ausschusssitzung od…
#> $ location        <chr> "Nationalratssaal", "Nationalratssaal", "Lokal 1  |  E…
#> $ topic           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ institution     <chr> "Nationalrat", "Nationalrat", "Nationalrat", "National…
#> $ media_relevance <chr> "J", "J", "J", "J", "J", "J", "J", "J", "J", "J", "J",…
#> $ group           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ view            <chr> "[\"S\"]", "[\"S\"]", "[\"S\"]", "[\"S\"]", "[\"S\"]",…
#> $ fully_booked    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ registration    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ livestream_url  <chr> "<a href=\"/aktuelles/mediathek/XXVII/NRSITZ/250\" tit…
#> $ language        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ link            <chr> "/gegenstand/XXVII/NRSITZ/250", "/gegenstand/XXVII/NRS…

  # Get plenary meetings in the National Council chamber
  events <- get_events(
    institution = "NR",
    event_type = "Plenarsitzung",
    location = "Nationalratssaal"
  )
#> Results on the Parliament website:
#> https://www.parlament.gv.at/aktuelles/termine?TERMIN_01GREMIUM=Nationalrat&TERMIN_01TERMINART=Plenarsitzung&TERMIN_01ORT=Nationalratssaal&TERMIN_01DATERANGE=2023-01-24T23%3A00%3A00.000Z&TERMIN_01VERFUEGBAR=J
#> Hits: 196
  dplyr::glimpse(events)
#> Rows: 196
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
#> Results on the Parliament website:
#> https://www.parlament.gv.at/aktuelles/termine?TERMIN_01DATERANGE=2024-10-23T22%3A00%3A00.000Z&TERMIN_01DATERANGE=2026-09-02T21%3A59%3A59.000Z&TERMIN_01GREMIUM=Nationalrat&TERMIN_01VERFUEGBAR=J&TERMIN_01VERFUEGBAR=V
#> Hits: 657
  dplyr::glimpse(events)
#> Rows: 657
#> Columns: 15
#> $ date            <date> 2026-07-10, 2026-07-10, 2026-07-10, 2026-07-10, 2026-…
#> $ date_time_end   <dttm> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ title           <chr> "93.&nbsp;Sitzung des Nationalrates", "92.&nbsp;Sitzun…
#> $ event_type      <chr> "Plenarsitzung", "Plenarsitzung", "Plenarsitzung", "Be…
#> $ location        <chr> NA, NA, "Nationalratssaal", "Parlament", "Parlament", …
#> $ topic           <chr> NA, NA, NA, "[\"Parlament und Demokratie\"]", "[\"Parl…
#> $ institution     <chr> "Nationalrat", "Nationalrat", "Nationalrat", "National…
#> $ media_relevance <chr> "J", "J", "J", "N", "N", "N", "N", "N", "N", "N", "N",…
#> $ group           <chr> NA, NA, NA, "N", "N", "N", "N", "N", "N", "N", "N", "N…
#> $ view            <chr> "[\"S\"]", "[\"S\"]", "[\"S\"]", "[\"S\"]", "[\"S\"]",…
#> $ fully_booked    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ registration    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA…
#> $ livestream_url  <chr> "<a href=\"/aktuelles/mediathek/XXVIII/NRSITZ/93\" tit…
#> $ language        <chr> NA, NA, NA, "[\"Deutsch\"]", "[\"Deutsch\"]", "[\"Deut…
#> $ link            <chr> "/gegenstand/XXVIII/NRSITZ/93", "/gegenstand/XXVIII/NR…
# }
```
