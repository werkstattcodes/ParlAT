# Get Current Members of Parliament

Fetches current members of parliament based on provided search criteria.
Depending on the chamber of interest, different search parameters are
applicable.

## Usage

``` r
get_mps_current(
  institution,
  gender = "all",
  position = NULL,
  party = NULL,
  parl_group = NULL,
  state = NULL,
  electoral_district = NULL,
  echo = TRUE
)
```

## Arguments

- institution:

  Character. The parliamentary institution, accepted values are "NR"
  (Nationalrat, National Council) or "BR" (Bundesrat, Federal Council).
  Note that "NR" and "BR" return all positions in the respective
  chamber, including presidents, secretaries etc.

- gender:

  Character. Gender filter to apply; options are "all", "female", or
  "male". Default is "all".

- position:

  Character. Position filter. For National Council (NR), acceptable
  values are:

  - "all": Alle Abgeordnete (all members of parliament)

  - "1PNR": Präsident des Nationalrates (President of the National
    Council)

  - "2PNR": Zweiter Präsident des Nationalrates (Second President of the
    National Council)

  - "3PNR": Dritter Präsident des Nationalrates (Third President of the
    National Council)

  - "PRAES": Präsidialkonferenz (Presidential Conference)

  - "ZON": Ordner des Nationalrates (Regulators of the National Council)

  - "ZSN": Schriftführer des Nationalrates (Secretary of the National
    Council)

  For Federal Council (BR), acceptable values are:

  - "all": Alle Mitglieder des Bundesrates (All Members of the Federal
    Council)

  - "PB": Präsident des Bundesrates (President of the Federal Council)

  - "SPB": Vizepräsident des Bundesrates (Vice-President of the Federal
    Council)

  - "PRAES": Präsidialkonferenz (Presidential Conference)

  - "ZOB": Ordner des Bundesrates (Usher/Sergeant-at-Arms of the Federal
    Council)

  - "ZSB": Schriftführer des Bundesrates (Secretary/Scrutineer of the
    Federal Council)

- party:

  Character vector of length 1. For National Council, acceptable values
  include "all", "SPÖ", "ÖVP", "FPÖ", "GRÜNE", "NEOS", and historical
  parties. For Federal Council, acceptable values are:

  - "all": Alle Wahlparteien (All Electoral Parties)

  - "GRÜNE": Die Grünen (The Greens)

  - "FPÖ": Freiheitliche Partei Österreichs (Freedom Party of Austria)

  - "NEOS": NEOS - Das neue Österreich und Liberales Forum

  - "ÖVP": Österreichische Volkspartei (Austrian People's Party)

  - "SPÖ": Sozialdemokratische Partei Österreichs (Social Democratic
    Party of Austria)

- parl_group:

  Character vector of length 1. Parliamentary group filter. For
  *National Council*, acceptable values are:

  - "all": All parliamentary groups

  - "LBd": Landbund

  - "CSP": Christlichsoziale Partei

  - "GRÜNE": Die Grünen

  - "SPÖ": Sozialdemokratische Partei Österreichs

  - "F-BZÖ": Freiheitliche und Bündnis Zukunft Österreich

  - "GdP": Großdeutsche Partei

  - "F": Freiheitliche

  - "FPÖ": Freiheitliche Partei Österreichs

  - "KuL": Kunst und Leben

  - "VO": Völkische Opposition

  - "WdU": Wahlpartei der Unabhängigen

  - "LB": Landbund

  - "NEOS-LIF": NEOS – Das Neue Österreich und Liberales Forum

  - "PILZ": Liste Peter Pilz

  - "NEOS": NEOS – Das Neue Österreich

  - "OK": Ohne Klub/Without parliamentary group

  - "HB": Heimatblock

  - "KPÖ": Kommunistische Partei Österreichs

  - "ÖVP": Österreichische Volkspartei

  - "BZÖ": Bündnis Zukunft Österreich

  - "JETZT": Liste Jetzt

  - "L": Liberale

  - "STRONACH": Team Stronach

  - "NWB": Nationale Wahlbewegung

  - "SdP": Sudetendeutsche Partei

  For *Federal Council*, acceptable values are:

  - "all": Alle Fraktionen (All Parliamentary Groups)

  - "ÖVP": Bundesratsfraktion der ÖVP

  - "SPÖ": Bundesratsfraktion der SPÖ

  - "FPÖ": Freiheitliche Bundesratsfraktion

  - "GRÜNE": Grüne Fraktion im Bundesrat

  - "OF": ohne Fraktionszugehörigkeit (Without Parliamentary Group
    Affiliation)

- state:

  Character vector of length 1. For National Council, acceptable values
  include "all", "B", "K", "N", "O", "S", "St", "T", "V", "W", and
  "BWV". For Federal Council, acceptable values are:

  - "all": Alle Bundesländer (All Federal States)

  - "B": Burgenland

  - "K": Kärnten (Carinthia)

  - "N": Niederösterreich (Lower Austria)

  - "O": Oberösterreich (Upper Austria)

  - "S": Salzburg

  - "St": Steiermark (Styria)

  - "T": Tirol (Tyrol)

  - "V": Vorarlberg

  - "W": Wien (Vienna)

- electoral_district:

  Character vector of length 1. Electoral district filter. Only
  applicable for National Council (NR). Valid electoral districts are:

  - "ALLE": Alle Wahlkreise (All Constituencies)

  - "FB": Bundeswahlvorschlag (Federal Electoral Proposal)

  - "F1": Burgenland

  - "F1A": Burgenland Nord (Burgenland North)

  - "F1B": Burgenland Süd (Burgenland South)

  - "F5B": Flachgau/Tennengau

  - "F6A": Graz und Umgebung (Graz and Surroundings)

  - "F4C": Hausruckviertel

  - "F7A": Innsbruck

  - "F7B": Innsbruck-Land (Innsbruck-Country)

  - "F4B": Innviertel

  - "F2": Kärnten (Carinthia)

  - "F2D": Kärnten Ost (Carinthia East)

  - "F2C": Kärnten West (Carinthia West)

  - "F2A": Klagenfurt

  - "F4A": Linz und Umgebung (Linz and Surroundings)

  - "F5C": Lungau/Pinzgau/Pongau

  - "F3C": Mostviertel

  - "F4E": Mühlviertel

  - "F3": Niederösterreich (Lower Austria)

  - "F3D": Niederösterreich Mitte (Lower Austria Central)

  - "F3G": Niederösterreich Ost (Lower Austria East)

  - "F3E": Niederösterreich Süd (Lower Austria South)

  - "F0": noch offen (still open/pending)

  - "F7D": Oberland (Oberland/Upper Country)

  - "F4": Oberösterreich (Upper Austria)

  - "F6D": Obersteiermark (Upper Styria)

  - "F6B": Oststeiermark (East Styria)

  - "F7E": Osttirol (East Tyrol)

  - "F5": Salzburg

  - "F5A": Salzburg Stadt (Salzburg City)

  - "F6": Steiermark (Styria)

  - "F3F": Thermenregion (Thermal Region)

  - "F7": Tirol (Tyrol)

  - "F4D": Traunviertel

  - "F7C": Unterland (Unterland/Lower Country)

  - "F2B": Villach

  - "F8": Vorarlberg

  - "F8A": Vorarlberg Nord (Vorarlberg North)

  - "F8B": Vorarlberg Süd (Vorarlberg South)

  - "F3B": Waldviertel

  - "F3A": Weinviertel

  - "F6C": Weststeiermark (West Styria)

  - "F9": Wien (Vienna)

  - "F9C": Wien Innen-Ost (Vienna Inner-East)

  - "F9A": Wien Innen-Süd (Vienna Inner-South)

  - "F9B": Wien Innen-West (Vienna Inner-West)

  - "F9G": Wien Nord (Vienna North)

  - "F9F": Wien Nord-West (Vienna North-West)

  - "F9D": Wien Süd (Vienna South)

  - "F9E": Wien Süd-West (Vienna South-West)

- echo:

  Logical. Whether to print debug information. Default is TRUE.

## Value

A data frame containing the list of current members of parliament that
match the search criteria with the following columns:

- `time_stamp`: Timestamp of when the data was retrieved

- `pad_intern`: Person's unique identification number

- `name`: Full name of the MP

- `gender`: Gender of the MP

- `parl_group`: Full name of the parliamentary group

- `parl_group_code`: Code/abbreviation of the parliamentary group

- `party_name`: Full name of the political party

- `party_code`: Code/abbreviation of the political party

- `state`: Federal state (Bundesland)

- `electoral_district_region_code`: Electoral district region code

- `chamber`: Chamber of Parliament ("NR" or "BR")

Returns NULL if no results are found.

## Examples

``` r
# \donttest{
  # Get all current National Council members
  nr_members <- get_mps_current(institution = "NR")
#> [1] 183
#> {"M":["M"],"W":["W"]} 
#> https://www.parlament.gv.at/recherchieren/personen/nationalrat/index.html?WFW_002M=M&WFW_002W=W
#> ⠙ Fetching MPs' names 2/183 | ETA:  3m
#> ⠹ Fetching MPs' names 3/183 | ETA:  3m
#> ⠸ Fetching MPs' names 6/183 | ETA:  3m
#> ⠼ Fetching MPs' names 10/183 | ETA:  2m
#> ⠴ Fetching MPs' names 14/183 | ETA:  2m
#> ⠦ Fetching MPs' names 17/183 | ETA:  2m
#> ⠧ Fetching MPs' names 21/183 | ETA:  2m
#> ⠇ Fetching MPs' names 24/183 | ETA:  2m
#> ⠏ Fetching MPs' names 28/183 | ETA:  2m
#> ⠋ Fetching MPs' names 32/183 | ETA:  2m
#> ⠙ Fetching MPs' names 35/183 | ETA:  2m
#> ⠹ Fetching MPs' names 39/183 | ETA:  2m
#> ⠸ Fetching MPs' names 42/183 | ETA:  2m
#> ⠼ Fetching MPs' names 46/183 | ETA:  2m
#> ⠴ Fetching MPs' names 50/183 | ETA:  2m
#> ⠦ Fetching MPs' names 53/183 | ETA:  2m
#> ⠧ Fetching MPs' names 57/183 | ETA:  2m
#> ⠇ Fetching MPs' names 60/183 | ETA:  2m
#> ⠏ Fetching MPs' names 64/183 | ETA:  2m
#> ⠋ Fetching MPs' names 68/183 | ETA:  2m
#> ⠙ Fetching MPs' names 71/183 | ETA:  2m
#> ⠹ Fetching MPs' names 75/183 | ETA:  2m
#> ⠸ Fetching MPs' names 78/183 | ETA:  1m
#> ⠼ Fetching MPs' names 82/183 | ETA:  1m
#> ⠴ Fetching MPs' names 86/183 | ETA:  1m
#> ⠦ Fetching MPs' names 89/183 | ETA:  1m
#> ⠧ Fetching MPs' names 93/183 | ETA:  1m
#> ⠇ Fetching MPs' names 96/183 | ETA:  1m
#> ⠏ Fetching MPs' names 100/183 | ETA:  1m
#> ⠋ Fetching MPs' names 103/183 | ETA:  1m
#> ⠙ Fetching MPs' names 107/183 | ETA:  1m
#> ⠹ Fetching MPs' names 111/183 | ETA:  1m
#> ⠸ Fetching MPs' names 114/183 | ETA:  1m
#> ⠼ Fetching MPs' names 118/183 | ETA:  1m
#> ⠴ Fetching MPs' names 121/183 | ETA:  1m
#> ⠦ Fetching MPs' names 125/183 | ETA: 48s
#> ⠧ Fetching MPs' names 129/183 | ETA: 45s
#> ⠇ Fetching MPs' names 132/183 | ETA: 43s
#> ⠏ Fetching MPs' names 136/183 | ETA: 39s
#> ⠋ Fetching MPs' names 140/183 | ETA: 36s
#> ⠙ Fetching MPs' names 143/183 | ETA: 33s
#> ⠹ Fetching MPs' names 147/183 | ETA: 30s
#> ⠸ Fetching MPs' names 150/183 | ETA: 28s
#> ⠼ Fetching MPs' names 154/183 | ETA: 24s
#> ⠴ Fetching MPs' names 158/183 | ETA: 21s
#> ⠦ Fetching MPs' names 161/183 | ETA: 18s
#> ⠧ Fetching MPs' names 165/183 | ETA: 15s
#> ⠇ Fetching MPs' names 168/183 | ETA: 13s
#> ⠏ Fetching MPs' names 172/183 | ETA:  9s
#> ⠋ Fetching MPs' names 175/183 | ETA:  7s
#> ⠙ Fetching MPs' names 179/183 | ETA:  3s
#> Fetched 183 MPs' names.
#> 
  dplyr::glimpse(nr_members)
#> Rows: 183
#> Columns: 10
#> $ time_stamp                     <dttm> 2026-04-04 07:57:31, 2026-04-04 07:57:…
#> $ name                           <chr> "Lisa Aldali", "Mag. Katrin Auer", "Mag…
#> $ pad_intern                     <chr> "38385", "30688", "30668", "30689", "19…
#> $ party                          <chr> "NEOS", "SPÖ", "NEOS", "SPÖ", "ÖVP", "S…
#> $ parl_group                     <chr> "NEOS Parlamentsklub", "Die Sozialdemok…
#> $ electoral_district_region_code <chr> "B", "4D", "3", "4A", "3G", "9D", "B", …
#> $ electoral_district_region      <chr> "Bundeswahlvorschlag", "Traunviertel", …
#> $ state                          <chr> "Bundeswahlvorschlag", "Oberösterreich"…
#> $ link                           <chr> "/person/38385", "/person/30688", "/per…
#> $ chamber                        <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR…

  # Get female Federal Council members from Vienna
  br_female_vienna <- get_mps_current(
    institution = "BR",
    gender = "female",
    state = "W"
  )
#> [1] 4
#> {"W":["W"],"BL":["W"]} 
#> https://www.parlament.gv.at/recherchieren/personen/bundesrat/index.html?WFW_005W=W&WFW_005BL=W
#> ⠙ Fetching MPs' names 3/4 | ETA:  1s
#> Fetched 4 MPs' names.
#> 
  dplyr::glimpse(br_female_vienna)
#> Rows: 4
#> Columns: 11
#> $ time_stamp                     <dttm> 2026-04-04 08:00:04, 2026-04-04 08:00:…
#> $ pad_intern                     <chr> "32831", "84868", "17881", "33455"
#> $ name                           <chr> "Mag. Dr. Julia Deutsch", "Mag. Daniela…
#> $ electoral_district_region_code <chr> "9 Wien", "9 Wien", "9 Wien", "9 Wien"
#> $ state                          <chr> "Wien", "Wien", "Wien", "Wien"
#> $ link                           <chr> "/person/32831", "/person/84868", "/per…
#> $ parl_group                     <chr> "ohne Fraktionszugehörigkeit", "Bundesr…
#> $ parl_group_code                <chr> "OF", "SPÖ", "OF", "SPÖ"
#> $ party_name                     <chr> "NEOS - Das neue Österreich und Liberal…
#> $ party_code                     <chr> "NEOS", "SPÖ", "Grüne", "SPÖ"
#> $ chamber                        <chr> "BR", "BR", "BR", "BR"

  # Get SPÖ members from National Council
  spo_nr <- get_mps_current(
    institution = "NR",
    party = "SPÖ"
  )
#> [1] 41
#> {"M":["M"],"W":["W"],"WP":["SPÖ"]} 
#> https://www.parlament.gv.at/recherchieren/personen/nationalrat/index.html?WFW_002M=M&WFW_002W=W&WFW_002WP=SP%C3%96
#> ⠙ Fetching MPs' names 2/41 | ETA: 33s
#> ⠹ Fetching MPs' names 6/41 | ETA: 29s
#> ⠸ Fetching MPs' names 9/41 | ETA: 27s
#> ⠼ Fetching MPs' names 13/41 | ETA: 23s
#> ⠴ Fetching MPs' names 16/41 | ETA: 21s
#> ⠦ Fetching MPs' names 20/41 | ETA: 18s
#> ⠧ Fetching MPs' names 24/41 | ETA: 14s
#> ⠇ Fetching MPs' names 27/41 | ETA: 12s
#> ⠏ Fetching MPs' names 31/41 | ETA:  8s
#> ⠋ Fetching MPs' names 34/41 | ETA:  6s
#> ⠙ Fetching MPs' names 38/41 | ETA:  3s
#> Fetched 41 MPs' names.
#> 
  dplyr::glimpse(spo_nr)
#> Rows: 41
#> Columns: 10
#> $ time_stamp                     <dttm> 2026-04-04 08:00:08, 2026-04-04 08:00:…
#> $ name                           <chr> "Mag. Katrin Auer", "Roland Baumann", "…
#> $ pad_intern                     <chr> "30688", "30689", "14835", "30693", "14…
#> $ party                          <chr> "SPÖ", "SPÖ", "SPÖ", "SPÖ", "SPÖ", "SPÖ…
#> $ parl_group                     <chr> "Die Sozialdemokratische Parlamentsfrak…
#> $ electoral_district_region_code <chr> "4D", "4A", "9D", "B", "9E", "8", "B", …
#> $ electoral_district_region      <chr> "Traunviertel", "Linz und Umgebung", "W…
#> $ state                          <chr> "Oberösterreich", "Oberösterreich", "Wi…
#> $ link                           <chr> "/person/30688", "/person/30689", "/per…
#> $ chamber                        <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR…
# }
```
