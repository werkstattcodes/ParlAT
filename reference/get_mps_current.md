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
if (FALSE) { # \dontrun{
  # Get all current National Council members
  nr_members <- get_mps_current(institution = "NR")

  # Get female Federal Council members from Vienna
  br_female_vienna <- get_mps_current(
    institution = "BR",
    gender = "female",
    state = "W"
  )

  # Get SPÖ members from National Council
  spo_nr <- get_mps_current(
    institution = "NR",
    party = "SPÖ"
  )
} # }
```
