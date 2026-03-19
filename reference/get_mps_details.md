# Get detailed information about Members of Parliament

The function retrieves details on Members of Parliament (MPs) in three
categories:

- speeches held in plenary meetings ("plenary"),

- other relevant activities ("activities"), and

- their participation in committees ("committees").

Depending on the requested details category, different function
parameters are available. For an example of the data source on the
website of the Austrian Parliament, see the different tabs e.g.,
[here.](https://www.parlament.gv.at/person/145?selectedtab=PLENUM)

## Usage

``` r
get_mps_details(
  pad_intern,
  detail_type,
  institution = NULL,
  legis_period = NULL,
  item = NULL,
  search_string = NULL,
  committee = NULL,
  committee_position = NULL,
  echo = TRUE
)
```

## Arguments

- pad_intern:

  ID of MP. Vector of length 1. See
  [`get_pad_intern()`](https://werkstattcodes.github.io/ParlAT/reference/get_pad_intern.md)
  for more details.

- detail_type:

  Character string specifying the type of details to retrieve:
  "plenary", "activities", or "committees". For examples see here:
  [plenary](https://www.parlament.gv.at/person/145?selectedtab=PLENUM) ;
  [activities](https://www.parlament.gv.at/person/145?selectedtab=AKT);
  [committees](https://www.parlament.gv.at/person/145?selectedtab=AUS).

- institution:

  Character string specifying the parliamentary house. Permissible
  inputs are "NR" (Nationalrat/National Council), "BR"
  (Bundesrat/Federal Council ) or NULL (which returns results for both
  houses). Defaults to NULL.

- legis_period:

  Numeric or character vector specifying one or more legislative periods
  (optional). Accepts numeric values (e.g., 27 or c(26, 27)), Roman
  numerals (e.g., "XXVII"), or historical abbreviations. Must be \>= 20
  for valid periods. Defaults to NULL.

- item:

  Character string specifying the item type (Art des
  Verhandlungsgegenstandes) (optional). Defaults to NULL. Used only for
  details category "activities". See Details below.

- search_string:

  Character string for searching within activities (optional). Defaults
  to NULL. Currently only implemented for details category "activities".

- committee:

  Character string specifying the committee name (optional). Only if
  `detail_type == "committees"`. See Details section for valid committee
  names.

- committee_position:

  Character string specifying the committee position (optional). Only if
  `detail_type == "committees"`. Common values include "Mitglied",
  "Vorsitzende/r", "Stellvertretende/r Vorsitzende/r".

- echo:

  Logical indicating whether to print the API request and response
  details. Defaults to TRUE.

## Value

A data frame containing the requested MP details. The structure depends
on the `detail_type` parameter:

For `detail_type = "plenary"`: Returns all speeches of the person in the
specified house, regardless of their mandate at the time of the speech.
For example, querying all plenary activities of Doris Bures in the
National Council will return not only her speeches as an MP, but also as
President of the National Council and as Minister. Columns returned:

- `pad_intern`: Unique identifier for the MP

- `name`: Full name of the MP

- `position_name`: List of mandates/positions held at the time of speech

- `date`: Date of the speech

- `legis_period`: Legislative period (Roman numeral)

- `institution`: Chamber of Parliament: "NR" (National Council) or "BR"
  (Federal Council)

- `speech_title`: Title of the speech

- `meeting_url`: URL to the meeting details page

- `meeting_name`: Name of the parliamentary meeting

- `speech_transcript_url`: URL to the speech transcript

- `speech_media_url`: URL to speech recordings, if available

For `detail_type = "activities"`: Returns parliamentary activities and
legislative items associated with the MP. Columns returned:

- `pad_intern`: Unique identifier for the MP

- `legis_period`: Legislative period

- `institution`: Chamber of Parliament: "NR" (National Council) or "BR"
  (Federal Council)

- `frmdate`: Date field

- `ityp_komm`: Item type comment

- `item_number`: Number of the parliamentary item

- `item_type`: Type of parliamentary item (e.g., "A", "JMIN")

- `title`: Title/subject of the item

- `date_updated`: Last update date of the item

- `item_url`: URL to the item details

- `status_text`: Current status description

- `status_numeric`: Numeric status code

For `detail_type = "committees"`: Returns committee memberships and
participation. Columns returned:

- `pad_intern`: Unique identifier for the MP

- `name`: Full name of the MP

- `legis_period`: Legislative period

- `committee_name`: Name of the committee

- `committee_position`: Position in the committee (e.g., "Mitglied",
  "Vorsitzende/r")

- `institution`: Chamber of Parliament: "NR" (National Council) or "BR"
  (Federal Council)

- `committee_position_start`: Start date of committee membership

- `committee_position_end`: End date of committee membership (NA if
  still active)

- `committee_active`: Logical indicating if membership is currently
  active

- `committee_url`: URL to committee details

Returns `NULL` invisibly if no data is found for the given parameters.

## Details

### Item type (Art des Verhandlungsgegenstandes)

Possible values for `item` are:

- "A" (Gesetzesanträge, Legislative proposals)

- "AA" (Abänderungsanträge, Amendment Motion)

- "ABMIN" (Anfragebeantwortung durch die Bundesregierung, Responses by
  the Federal Government)

- "ABMIN-BR" (Anfragebeantwortung durch die Bundesregierung im
  Bundesrat, Responses by the Federal Government in the Federal Council)

- "ABPRPR" (Anfragebeantwortung durch den Präsidenten des Nationalrates,
  Responses by the President of the National Council)

- "AE" (Selbständige Entschließungen, Independent Resolutions)

- "ARH1" (Anträge gemäß \$ 99 Abs. 1, Motions according to § 99 Abs. 1)

- "JMIN" (Schriftliche Anfrage an die Bundesregierung, Written Questions
  to the Federal Government)

- "JPRPR" (Schriftliche Anfrage an den Präsidenten des Nationalrates,
  Written Questions to the President of the National Council)

- "M" (Mündliche Anfrage an die Bundesregierung, Oral Questions to the
  Federal Government)

- "UEA" (Unselbständige Entschließungen, Dependent Resolution Motion)

- "AVB" (Anträge auf Volksbefragung)

- "JHR" (Schriftliche Anfrage an den RechnungshofpräsidentInnen, Written
  Questions to the President of the Court of Auditors)

- "PET" (Petitionen, Petitions)

### Committees

Possible values for `committee` are:

- Ausschuss für Arbeit und Soziales

- Ausschuss für Bauten und Wohnen

- Ausschuss für Familie und Jugend

- Ausschuss für Forschung, Innovation und Digitalisierung

- Ausschuss für innere Angelegenheiten

- Ausschuss für Konsumentenschutz

- Ausschuss für Land- und Forstwirtschaft

- Ausschuss für Menschenrechte

- Ausschuss für Petitionen und Bürgerinitiativen

- Ausschuss für Wirtschaft, Industrie und Energie

- Außenpolitischer Ausschuss

- Budgetausschuss

- COFAG-Untersuchungsausschuss eingesetzt am 15.12.2023 - beendet am
  03.07.2024

- Finanzausschuss

- Geschäftsordnungsausschuss

- Gesundheitsausschuss

- Gleichbehandlungsausschuss

- Hauptausschuss

- Untersuchungsauschuss: Ibiza-Untersuchungsausschuss

- Immunitätsausschuss

- Justizausschuss

- Kulturausschuss

- Landesverteidigungsausschuss

- ÖVP-Korruptions-Untersuchungsausschuss eingesetzt am 09.12.2021 -
  beendet am 27.04.2023

- Rechnungshofausschuss

- "ROT-BLAUER Machtmissbrauch-Untersuchungsausschuss" eingesetzt am
  15.12.2023 - beendet am 03.07.2024

- Sportausschuss

- Ständiger gemeinsamer Ausschuss im Sinne des § 9 des
  Finanz-Verfassungsgesetzes 1948

- Ständiger Unterausschuss des Ausschusses für innere Angelegenheiten

- Ständiger Unterausschuss des Budgetausschusses

- Ständiger Unterausschuss des Hauptausschusses

- Ständiger Unterausschuss des Landesverteidigungsausschusses

- Ständiger Unterausschuss des Rechnungshofausschusses

- Ständiger Unterausschuss in Angelegenheiten der Europäischen Union

- Ständiger Unterausschuss in ESM-Angelegenheiten

- Tourismusausschuss

- Umweltausschuss

- Unterrichtsausschuss

- Unvereinbarkeitsausschuss

- Verfassungsausschuss

- Verkehrsausschuss

- Volksanwaltschaftsausschuss

- Wissenschaftsausschuss

## Examples

``` r
# \donttest{
# Get Stephanie Krisper's plenary speeches in National Council only for the 27th legislative period
plenary_nr <- get_mps_details(
  pad_intern = 2344,
  detail_type = "plenary",
  institution = "NR",
  legis_period = 27
)
#> {"PAD_INTERN":[2344],"GREMIUM":["N"],"GP_CODE":["XXVII"]} 
#> https://www.parlament.gv.at/person/2344?BIO_250PAD_INTERN=2344&BIO_250GREMIUM=N&BIO_250GP_CODE=XXVII&selectedtab=PLENUM
#> [1] 84
dplyr::glimpse(plenary_nr)
#> Rows: 84
#> Columns: 11
#> $ pad_intern            <chr> "2344", "2344", "2344", "2344", "2344", "2344", …
#> $ name                  <chr> "Dr. Stephanie Krisper", "Dr. Stephanie Krisper"…
#> $ position_name         <list> "Abgeordnete zum Nationalrat", "Abgeordnete zum…
#> $ date                  <date> 2019-10-23, 2019-11-13, 2019-11-26, 2019-12-11,…
#> $ legis_period          <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XX…
#> $ institution           <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", …
#> $ speech_title          <chr> "Wahl der Präsidentin/des Präsidenten, der Zweit…
#> $ meeting_url           <chr> "https://www.parlament.gv.at/sitzung/XXVII/NRSIT…
#> $ meeting_name          <chr> "1. Sitzung (23.10.2019) des Nationalrats der XX…
#> $ speech_transcript_url <chr> "https://www.parlament.gv.at/dokument/XXVII/NRSI…
#> $ speech_media_url      <chr> "https://www.parlament.gv.at/aktuelles/mediathek…

# Get plenary speeches for multiple legislative periods
plenary_multiple <- get_mps_details(
  pad_intern = 2344,
  detail_type = "plenary",
  legis_period = c(26, 27)
)
#> {"PAD_INTERN":[2344],"GP_CODE":["XXVI","XXVII"]} 
#> https://www.parlament.gv.at/person/2344?BIO_250PAD_INTERN=2344&BIO_250GP_CODE=XXVI&BIO_250GP_CODE=XXVII&selectedtab=PLENUM
#> [1] 122
dplyr::glimpse(plenary_multiple)
#> Rows: 122
#> Columns: 11
#> $ pad_intern            <chr> "2344", "2344", "2344", "2344", "2344", "2344", …
#> $ name                  <chr> "Dr. Stephanie Krisper", "Dr. Stephanie Krisper"…
#> $ position_name         <list> "Abgeordnete zum Nationalrat", "Abgeordnete zum…
#> $ date                  <date> 2018-01-31, 2018-01-31, 2018-02-28, 2018-03-19,…
#> $ legis_period          <chr> "XXVI", "XXVI", "XXVI", "XXVI", "XXVI", "XXVI", …
#> $ institution           <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", …
#> $ speech_title          <chr> "Erklärungen des Bundesministers für Bildung, Wi…
#> $ meeting_url           <chr> "https://www.parlament.gv.at/sitzung/XXVI/NRSITZ…
#> $ meeting_name          <chr> "7. Sitzung (31.01.2018) des Nationalrats der XX…
#> $ speech_transcript_url <chr> "https://www.parlament.gv.at/dokument/XXVI/NRSIT…
#> $ speech_media_url      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …

# Get only legislative proposals (item type "A")
proposals <- get_mps_details(
  pad_intern = 2344,
  detail_type = "activities",
  item = "A",
  legis_period = 27
)
#> {"PAD_INTERN":[2344],"gp_text_full":["XXVII"],"vhg4":["A"]} 
#> https://www.parlament.gv.at/person/2344?PERS_AKTIVIT_025PAD_INTERN=2344&PERS_AKTIVIT_025gp_text_full=XXVII&PERS_AKTIVIT_025vhg4=A&selectedtab=AKT
#> [1] 25
dplyr::glimpse(proposals)
#> Rows: 25
#> Columns: 10
#> $ pad_intern     <chr> "2344", "2344", "2344", "2344", "2344", "2344", "2344",…
#> $ legis_period   <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "…
#> $ institution    <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "…
#> $ item_number    <chr> "3489/A", "3267/A", "787/A", "76/A und Zu 76/A", "3275/…
#> $ item_type      <chr> "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", "A", …
#> $ title          <chr> "Staatsanwaltschaftsgesetz, Änderung ", "Strafgesetzbuc…
#> $ date_updated   <chr> "29.05.2024", "28.02.2024", "31.01.2024", "19.10.2023",…
#> $ item_url       <chr> "/gegenstand/XXVII/A/3489", "/gegenstand/XXVII/A/3267",…
#> $ status_numeric <chr> "2", "2", "2", "5", "2", "5", "2", "2", "2", "5", "2", …
#> $ status_text    <chr> "Justizausschuss: auf Tagesordnung in der 27. Sitzung d…

# Get committee memberships for Stephanie Krisper
committees <- get_mps_details(
  pad_intern = 2344,
  detail_type = "committees",
  legis_period = 27
)
#> {"PAD_INTERN":[2344],"GP_TEXT_FULL":["23.10.2019 - 23.10.2024: XXVII. Gesetzgebungsperiode des NR"]} 
#> https://www.parlament.gv.at/person/2344?AUSSCHUSS_BIO_250PAD_INTERN=2344&AUSSCHUSS_BIO_250GP_TEXT_FULL=23.10.2019%20-%2023.10.2024:%20XXVII.%20Gesetzgebungsperiode%20des%20NR&selectedtab=AUS
#> [1] 11
dplyr::glimpse(committees)
#> Rows: 11
#> Columns: 10
#> $ pad_intern               <dbl> 2344, 2344, 2344, 2344, 2344, 2344, 2344, 234…
#> $ name                     <chr> "Dr. Stephanie Krisper", "Dr. Stephanie Krisp…
#> $ legis_period             <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", …
#> $ committee_name           <chr> "Volksanwaltschaftsausschuss", "Ausschuss für…
#> $ committee_position       <chr> "Obfraustellvertreterin", "Mitglied", "Mitgli…
#> $ institution              <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR…
#> $ committee_position_start <chr> "10.01.2020", "11.12.2019", "11.12.2019", "10…
#> $ committee_position_end   <chr> "23.10.2024", "23.10.2024", "23.10.2024", "23…
#> $ committee_active         <lgl> FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FAL…
#> $ committee_url            <chr> "https://www.parlament.gv.at//PAKT/VHG/XXVII/…
# }
```
