# Get items under negotiation ('Verhandlungsgegenstände')

`get_items` searches for items ('Verhandlungsgegenstände') that are or
were subject to negotiations in the Austrian National Council
('Nationalrat') or the Federal Council ('Bundesrat'). The function
mirrors the search functionality offered on the Austrian Parliament's
website (see
[here](https://www.parlament.gv.at/recherchieren/gegenstaende/index.html)).

## Usage

``` r
get_items(
  topic = NULL,
  institution = NULL,
  legis_period = NULL,
  date_start = NULL,
  date_end = NULL,
  item = NULL,
  type_doc = NULL,
  type_eu_submission = NULL,
  person = NULL,
  keyword = NULL,
  eurovoc = NULL,
  parl_group = NULL,
  parl_group_names_standard = FALSE,
  echo = TRUE
)
```

## Arguments

- topic:

  (Thema) Character vector or `NULL`. Specifies the topic(s) to search
  for. See 'Details' for possible values. Default is `NULL`.

- institution:

  Character string. Either "NR" (Nationalrat, National Council) or "BR"
  (Bundesrat, Federal Council). Default is `NULL` which returns both
  chambers.

- legis_period:

  Character vector or `NULL`. Specifies the legislative period(s) to
  search in. See 'Details' for possible values. Default is `NULL`.

- date_start:

  Character string. Start date for the search period in format
  "dd-mm-yyyy", "dd.mm.yyyy", or "dd/mm/yyyy". Default is `NULL`.

- date_end:

  Character string. End date for the search period in format
  "dd-mm-yyyy", "dd.mm.yyyy", or "dd/mm/yyyy". Default is `NULL`.

- item:

  (Gegenstand) Character vector or `NULL`. Specifies the type(s) of
  parliamentary item(s) to search for. See 'Details' for possible
  values. Default is `NULL`.

- type_doc:

  (Art des Antrages / Art der Anfrage) Character vector or `NULL`.
  Specifies the document type for certain item types. Permissible values
  depend on both `item` and `institution`. See 'Details' for possible
  values. Default is `NULL`.

- type_eu_submission:

  (Art der EU-Vorlage) Character vector or `NULL`. Type(s) of EU
  submission to search for. Can only be specified when `item = "EU"`.
  See 'Details' for possible values. Default is `NULL`.

- person:

  Character string or `NULL`. Name of a person to search for (family
  name, optionally followed by first name). Default is `NULL`.

- keyword:

  Character vector or `NULL`. Keyword(s) to search for. Default is
  `NULL`.

- eurovoc:

  Character vector or `NULL`. EuroVoc term(s) to search for. Default is
  `NULL`.

- parl_group:

  Character vector or `NULL`. Parliamentary group(s) to search for.
  Default is `NULL`. Combine multiple groups in a vector, i.e. c("SPÖ",
  "ÖVP"). See Details.

- parl_group_names_standard:

  Logical. If `TRUE`, the function expands and standardizes
  parliamentary group names. Default is `FALSE`. See Details.

- echo:

  Logical. If `TRUE`, the function prints the used search parameters and
  the url to the pertaining search results on website of the Austrian
  Parliament.

## Value

A tibble (data.frame) with one row per parliamentary item matching the
search. The returned object contains the most commonly used columns
(some are optional or returned as list-columns for multi-valued fields):

\-` legis_period` (character): legislative period (e.g. "XXVIII").

- `institution` (character): chamber code, typically "NR" (Nationalrat)
  or "BR" (Bundesrat).

- `date` (Date): date of the item (class Date).

- `item_type` (character): short item type code.

- `item_number` (character): numeric identifier of the item (stored as
  character).

- `item_number_type` (character): combined number/type string (e.g.
  "46/M").

- `stage` (character/integer): current stage code of the item.

- `item_url` (character): normalized URL pointing to the item on
  parlament.gv.at.

- `type_doc` (character): short document type code (when applicable).

- `type_doc_long` (character): human readable document type (when
  available).

- `subject` (character): subject / title of the item.

- `topics` (list): list-column; each element is a character vector of
  topics.

- `keywords` (list): list-column of keywords (Schlagwort).

- `eurovoc` (list): list-column of EuroVoc terms.

- `persons` (list): list-column of person identifiers (pad_intern)
  related to the item.

- `parl_group` (list): list-column of parliamentary group codes
  associated with the item.

## Details

### topic (Thema)

NULL, one, or multiple topics permissible. Possible values for `topic`
are:

- "Arbeit" (work)

- "Außenpolitik" (foreign policy)

- "Bildung" (education)

- "Budget und Finanzen" (budget and finance)

- "Europäische Union" (European Union)

- "Familie und Generationen" (family and generations)

- "Frauen und Gleichbehandlung" (women and equality)

- "Gesundheit und Ernährung" (health and nutrition)

- "Information und Medien" (information and media)

- "Inneres und Recht" (interior and law)

- "Innovation, Technologie und Forschung" (innovation, technology and
  research)

- "Klima, Umwelt und Energie" (climate, environment and energy)

- "Kultur" (culture)

- "Land- und Forstwirtschaft" (agriculture and forestry)

- "Landesverteidigung" (national defense)

- "Parlament und Demokratie" (parliament and democracy)

- "Soziales" (social affairs)

- "Sport" (sports)

- "Verkehr und Infrastruktur" (transport and infrastructure)

- "Wirtschaft" (economy)

### legis_period (Gesetzgebungsperiode)

`legis_period` specifies the legislative period(s). Can be one or more
of the following value(s):

- number(s) or character(s) indicating the relevant period(s), i.e.,
  "25", 25, or "XXV".

Only periods from the 5th legislative period (V. GP, 1945) onwards are
supported. Earlier periods (including special codes like "PN" and "KN")
do not return data and will be rejected.

### item (Gegenstand)

Possible values for `item` include:

- "ASEU" (Aktuelle Europastunden, Current European Hours)

- "AS" (Aktuelle Stunden, Current Hours)

- "J_JPR_M" (Anfragen, Written Questions)

- "ANTR" (Anträge, Motions)

- "US" (Anträge/Verlangen auf Untersuchungsausschuss, Motions/Requests
  for Investigative Committee)

- "AUB" (Ausschussberichte, Committee Reports)

- "AB_ABPR_ABM" (Beantwortungen, Answers)

- "III" (Berichte an den Nationalrat, Reports to the National Council)

- "BNR" (Beschlüsse, Resolutions)

- "BI" (Bürgerinitiativen, Citizen Initiatives)

- "E" (Einsprüche des Bundesrates, Objections of the Federal Council)

- "EBR" (Entschließungen, Resolutions)

- "EU" (EU betreffende Vorlagen und Beschlüsse, EU-related Proposals and
  Resolutions)

- "FS" (Fragestunden, Question Time)

- "GO" (Geschäftsbehandlung, Rules of Procedure)

- "GABR" (Gesetzesanträge des Bundesrates, Legislative Proposals of the
  Federal Council)

- "GABR13" (Gesetzesanträge von einem Drittel des BR, Legislative
  Proposals of One-Third of the Federal Council)

- "KOMM" (Kommuniqués, Communiqués)

- "PET" (Petitionen, Petitions)

- "RGER" (Regierungserklärungen, Government Statements)

- "RV" (Regierungsvorlagen (Gesetze), Government Bills (Laws))

- "RVS" (Staatsverträge, State Treaties)

- "TRAU" (Trauerkundgebungen, Condolence Expressions)

- "RVS15" (Vereinbarungen gemäß Art. 15a B-VG, Agreements Pursuant to
  Article 15a of the Federal Constitutional Law)

- "VOLKBG" (Volksbegehren, Popular Initiatives)

- "W" (Wahlen, Elections)

Note: Querying for immunity matters ('Immunitätsangelegenheiten') is
currently only possible via the Parliament's website.

### type_doc (Art)

The `type_doc` parameter specifies different document types depending on
the `item` parameter value.

#### For `item = "ANTR"` (Motions, Anträge)

Possible values for `type_doc` depend on the institution.

National Council (`institution = "NR"`):

- "A" (Selbständiger Antrag, Independent Motion)

- "A(E)" (Selbständiger Entschließungsantrag, Independent Resolution
  Motion)

- "AA" (Abänderungsantrag, Amendment Motion)

- "AEA" (Selbständiger Ausschuss-Entschließungsantrag, Independent
  Committee Resolution Motion)

- "AMIN" (Selbständiger Antrag - Ministeranklage, Independent Motion -
  Ministerial Impeachment)

- "ARH2" (Verlangen auf Gebarungsüberprüfung durch den Rechnungshof,
  Request for Audit by the Court of Audit)

- "AVB" (Antrag auf Volksbefragung, Motion for Public Consultation)

- "BUA" (Bericht und Antrag, Report and Motion)

- "UEA" (Unselbständiger Entschließungsantrag, Dependent Resolution
  Motion)

- "UEAM" (Misstrauensantrag, Motion of No Confidence)

- "URH2" (Verlangen auf Gebarungsüberprüfung durch den Ständigen UA des
  Rechnungshofausschusses, Request for Audit by the Standing
  Subcommittee of the Court of Audit Committee)

Federal Council (`institution = "BR"`):

- "AA-BR" (Abänderungsanträge, Amendment Motions)

- "A-BR" (Selbständiger Antrag Bundesrat, Independent Motion Federal
  Council)

- "A(E)" (Selbständiger Entschließungsantrag Bundesrat, Independent
  Resolution Motion Federal Council)

- "AEA-BR" (Selbständiger Entschließungsantrag von Ausschüssen,
  Independent Committee Resolution Motion Federal Council)

- "UEA-BR" (Unselbständige Anträge)

#### For `item = "J_JPR_M"` (Questions, Anfragen)

Possible values for `type_doc` depend on the institution.

National Council (`institution = "NR"`):

- "J" (Mündliche Anfragen, Oral Questions)

- "JPR" (Schriftliche Anfragen an die Bundesregierung, Written Questions
  to Federal Government)

- "M" (Schriftliche Anfragen an Präsidenten des Bundesrates, Written
  Questions to Presidents of Federal Council)

Federal Council (`institution = "BR"`):

- "M-BR" (Mündliche Anfragen, Oral Questions)

- "JMIN-BR" (Schriftliche Anfragen an die Bundesregierung, Written
  Questions to Federal Government)

- "JPRPR-BR" (Schriftliche Anfragen an Präsidenten des Bundesrates,
  Written Questions to Presidents of Federal Council)

#### For `item = "BNR"` (Resolutions, Beschlüsse)

National Council (`institution = "NR"`):

- "BNR" (Beschluss, Resolution)

- "BS" (Sonstiger Beschluss, Other Resolution)

- "BSE" (Beschluss-EU, EU Resolution)

- "BSESM" (Beschluss-ESM, ESM Resolution)

Federal Council (`institution = "BR"`):

- "BNR" (Beschluss, Resolution)

- "BS-BR" (Sonstiger Beschluss, Other Resolution)

### type_eu_submission (Art der EU-Vorlage)

The `type_eu_submission` parameter allows filtering for specific types
of EU-related submissions. Different codes are available depending on
the institution.

#### National Council Codes (institution = "NR")

These codes can only be used when `item = "EU"` AND
`institution = "NR"`:

- "BEU" (Berichte der Bundesregierung zu EU-Themen, Federal Government
  Reports on EU Topics)

- "EUBTG" (Berichte über Sitzungen von EU-Gremien, Reports on EU
  Committee Meetings)

- "JMINEU" (Dokumentenanfrage betr. EU an die Bundesregierung, Document
  Requests to Federal Government Regarding EU)

- "ABMINEU" (Dokumentenanfragebeantwortungen durch die Bundesregierung,
  Document Request Responses by Federal Government)

- "MTEU" (Mitteilungen des EU-Unterausschusses, Communications from EU
  Subcommittee)

- "EUD" (Politischer Dialog, Political Dialogue)

- "RGEU" (Regierungserklärungen zu EU-Themen, Government Statements on
  EU Topics)

- "SINF" (Schriftliche Informationen gem. § 6 EU-InfoG, Written
  Information According to § 6 EU Information Act)

- "S" (Stellungnahmen des Hauptausschusses, Opinions of the Main
  Committee)

- "SEU" (Stellungnahmen des UA des Hauptausschusses (EU), Opinions of
  the Main Committee Subcommittee (EU))

- "RVEU" (Vorlagen ü. Initiativen und Beschlüsse EU, Submissions on EU
  Initiatives and Resolutions)

#### Federal Council Codes (institution = "BR")

These codes can only be used when `item = "EU"` AND
`institution = "BR"`:

- "AFEU-BR" (Ausschussfeststellungen, Committee Findings)

- "SBPL-BR" (Begründete Stellungnahmen des Bundesrates, Reasoned
  Opinions of the Federal Council)

- "SB-BR" (Begründete Stellungnahmen des EU-BR, Reasoned Opinions of the
  EU Federal Council). Note: Details on parlamentary procedures only
  available from 24th legis period onwards, see
  [here](https://www.parlament.gv.at/recherchieren/open-data/daten-und-lizenz/begruendete-stellungnahmen-eu-ausschuss-br/index.html)

- "BEU-BR" (Berichte der Bundesregierung zu EU-Themen, Federal
  Government Reports on EU Topics)

- "MEU-BR" (EU-Vorblätter und Dossiers BR, EU Cover Sheets and Dossiers
  BR)

- "ADEU-BR" (IV der Beilagen, Addendum/Supplement IV)

- "MT-BR" (Mitteilungen des EU-BR, Communications from EU Federal
  Council). Note: Details on parlamentary procedures only available from
  24th legis period onwards, see
  [here](https://www.parlament.gv.at/recherchieren/open-data/daten-und-lizenz/stellungnahmen-eu-ausschuss-br/index.html)

- "EUD-BR" (Politischer Dialog BR, Political Dialogue BR)

- "SINF-BR" (Schriftliche Informationen BR gem. § 6 EU-InfoG BR, Written
  Information Federal Council According to § 6 EU Information Act)

- "SLT-BR" (Stellungnahmen der Landtage, Opinions of State Parliaments)

- "S-BR" (Stellungnahmen des EU-Ausschusses, Opinions of the EU
  Committee). Note: Details on parlamentary procedures only available
  from 24th legis period onwards, see
  [here](https://www.parlament.gv.at/recherchieren/open-data/daten-und-lizenz/stellungnahmen-eu-ausschuss-br/index.html)

### eurovoc

EuroVoc is an international thesaurus developed primarily for use within
the EU. It enables searches using standardized keywords across Europe.
The EuroVoc search is supported for all negotiation items from the 20th
legislative period onwards.

### keyword (Schlagwort)

In total, there are several hundred different keywords. Here only a
selection of possible values for `keyword`:

- "Abfallwirtschaft"

- "Abgeordnete"

- "Abstimmungen, geheime"

- "Abstimmungen, namentliche"

- "Abstimmungsangelegenheiten"

- "Abweichende persönliche Stellungnahmen"

- "Aktuelle Europastunden"

- "Aktuelle Stunden"

- "Anfragebeantwortungen, Besprechung von"

- "Anfragen, Dringliche"

- "Anträge, Dringliche"

- "Apotheken"

- "Arbeiterkammern"

- "Arbeitsinspektion"

- "Arbeitsmarkt"

- "Arbeitsrecht I. österreichisches"

- "Arbeitsrecht II. internationales"

- "Archive"

- "Atomenergie"

- "Außenpolitik"

- "Ausländer"

- "Ausschüsse des Nationalrates"

- "Bauwesen"

- "Bergbau"

- "Betriebsräte"

- "Bibliotheken"

- "Bildungswesen I. Pflichtschulen"

- "Bildungswesen II. Mittlere Schulen"

- "Bildungswesen III. Höhere Schulen"

- "Bildungswesen IV. Universitäten und Hochschulen"

- "Bildungswesen V. Minderheitenschulwesen"

- "Bildungswesen VI. Schülerbeihilfen und Studienförderung"

- "Bildungswesen VII. Erwachsenenbildung"

- "Bildungswesen VIII. Sonstiges"

- "Bundesforste"

- "Bundesgesetzblatt"

- "Bundeshaushalt I. Bundesfinanzgesetze"

- "Bundeshaushalt II. Budgetüberschreitungen"

- "Bundeshaushalt III. Sonstiges"

- "Bundesländer"

- "Bundespräsident:in"

- "Bundesregierung I. Ernennungen, Enthebungen und Ableben"

- "Bundesregierung II. Regierungserklärungen"

- "Bundesregierung III. Sonstiges"

- "Bundesverfassung"

- "Bundesvermögen"

- "Bundeswappen"

- "Bürgerinitiativen"

- "Debattenanträge bzw. -verlangen"

- "Ehrenzeichen und Medaillen"

- "Einsprüche des Bundesrates"

- "Einspruchsfrist des Bundesrates"

- "Elektrizität"

- "Elementarpädagogik"

- "Energiewirtschaft"

- "Entwicklungszusammenarbeit"

- "Erklärungen Präsident/Präsidentin"

- "Erste Lesungen"

- "Erste Lesungen, Anträge/Verlangen"

- "Europäische Integration"

- "Europarat"

- "Familienlastenausgleich"

- "Familienpolitik"

- "Film"

- "Finanzausgleich"

- "Flüchtlinge"

- "Fragestunden"

- "Frauen und Gleichbehandlung"

- "Fremdenverkehr"

- "Fristsetzungen"

- "Geschäftsordnung des Nationalrates"

- "Gesundheit"

- "Glücksspiel"

- "Grenzen"

- "Handel, Gewerbe und Industrie"

- "II. Einberufung und Beendigung der Tagungen"

- "III. Präsidenten, Schriftführer und Ordner"

- "III. Sonstiges"

- "Immunität"

- "Information und Informationsverarbeitung"

- "Internet"

- "IV. Ansprachen Präsident/Präsidentin"

- "Jagd und Fischerei"

- "Jugend"

- "Kommuniques"

- "Kreditwesen"

- "Kunst und Kultur"

- "Land- und Forstwirtschaft"

- "Landesverteidigung"

- "Lebensmittel"

- "Löhne und Gehälter"

- "Maße und Gewichte"

- "Menschen mit Behinderung"

- "Menschenrechte"

- "Minderheitsberichte"

- "Misstrauensanträge"

- "Museen"

- "Nationalfeiertag"

- "Neutralität"

- "Öffentliche Unternehmen"

- "Öffentlicher Dienst"

- "Opferfürsorge und Opferschutz"

- "Ordnungsrufe"

- "Pässe und Ausweise"

- "Pensionssystem"

- "Personenstandsrecht"

- "Petitionen"

- "Pflege und Betreuung"

- "Politische Parteien"

- "Postwesen"

- "Preise"

- "Presse"

- "Prüfungsaufträge Rechnungshof"

- "Prüfungsaufträge Rechnungshofausschuss"

- "Raumordnung"

- "Rechnungshof"

- "Rechtsanwälte und Notare"

- "Rechtsbereinigung"

- "Rechtspflege"

- "Redezeitbeschränkungen"

- "Religion"

- "Rückverweisungen"

- "Rundfunk und Fernsehen"

- "Sicherheitswesen"

- "Sitzungsunterbrechung"

- "Sondersitzungen"

- "Sonstige Geschäftsordnungsangelegenheiten"

- "Sozialpolitik"

- "Sozialversicherung I. Allgemeine Sozialversicherung"

- "Sozialversicherung II. Gewerbliche Sozialversicherung"

- "Sozialversicherung III. Landwirtschaftliche Sozialversicherung"

- "Sozialversicherung IV. Kriegsopferversorgung"

- "Sozialversicherung V. Arbeitslosenversicherung"

- "Sozialversicherung VI. Sonstiges"

- "Sport"

- "Staatsbürger:in"

- "Staatsverträge"

- "Statistik"

- "Steuern und Gebühren"

- "Strafrecht"

- "Straßen- und Brückenbau"

- "Südtirol"

- "Tabak"

- "Tagesordnung"

- "Telekommunikation"

- "Theater"

- "Trauerkundgebungen"

- "Umweltschutz"

- "Untersuchungsausschüsse"

- "Unvereinbarkeit"

- "V. Sonstiges"

- "Vereinbarungen"

- "Vereins- und Versammlungsrecht"

- "Vereinte Nationen"

- "Verfassungs- und Verwaltungsgerichtsbarkeit"

- "Verkehr I. Straßenverkehr"

- "Verkehr II. Schienenverkehr"

- "Verkehr III. Luftfahrt"

- "Verkehr IV. Schifffahrt"

- "Verkehr V. Sonstiges"

- "Verkürztes Verfahren"

- "Vermessung"

- "Vermögenssicherung"

- "Vertragsversicherungen"

- "Verwaltungsorganisation"

- "Verwaltungsverfahren"

- "Veterinärwesen und Tierschutz"

- "Völkerrecht"

- "Völkerrechtliche Vertretungen"

- "Volksabstimmung"

- "Volksanwaltschaft"

- "Volksbefragung"

- "Volksbegehren"

- "Volksgruppen"

- "Volkszählung"

- "Wahlen"

- "Währung"

- "Wasserbauten"

- "Wasserrecht"

- "Wasserwirtschaft"

- "Weinwirtschaft"

- "Wirtschaftspolitik"

- "Wirtschaftstreuhänder:in"

- "Wissenschaft und Forschung"

- "Wohnungswesen"

- "Wortentziehung"

- "Wortmeldungen zur Geschäftsbehandlung"

- "Zivildienst"

- "Zivilrecht"

- "Zivilschutz"

- "Zollwesen"

### parl_group (Parliamentary Group, Klub/Fraktion)

`parl_group` specifies the parliamentary group(s) to search for. The API
of the Austrian Parliament accepts only specific abbreviations for each
group:

- "BZÖ" (Bündnis Zukunft Österreich)

- "CSP" (Christlichsoziale Partei)

- "DnP" (Deutsche Nationalpartei)

- "F" (Freiheitliche Partei Österreichs)

- "F-BZÖ" (Freiheitliche Partei Österreichs - Bündnis Zukunft
  Österreich)

- "FPÖ" (Freiheitliche Partei Österreichs)

- "GdP" (Großdeutsche Volkspartei)

- "GRÜNE" (Die Grünen - Die Grüne Alternative)

- "HB" (Heimatblock)

- "JETZT" (Jetzt - Liste Pilz)

- "Konvent"

- "KPÖ" (Kommunistische Partei Österreichs)

- "KuL"

- "L" (Liberales Forum)

- "LB"

- "LBd" (Landbund für Österreich)

- "NEOS" (NEOS - Das Neue Österreich)

- "NEOS-LIF" (NEOS - Liberales Forum)

- "NSDAP" (Nationalsozialistische Deutsche Arbeiterpartei)

- "NWB" (Nationaler Wirtschaftsblock und Landbund)

- "OF"

- "OK" (Ohne Klub)

- "ÖVP" (Österreichische Volkspartei)

- "PILZ" (Liste Pilz)

- "SdP"

- "SPÖ" (Sozialistische/Sozialdemokratische Partei Österreichs)

- "STRONACH" (Team Stronach)

- "VO" (Wahlgemeinschaft Österreichische Volksopposition)

- "WdU" (Wahlpartei der Unabhängigen (VdU, Verband der Unabhängigen))

### parl_group_names_standard

When `parl_group_names_standard = TRUE`, the function automatically
converts common party names to their official abbreviations used by the
Austrian Parliament API. This feature helps users who might not know the
exact abbreviations required by the API. E.g. over the years the FPÖ has
featured different abbreviations for their parliamentary group: "FPÖ",
"F", and "F-BZÖ". With `parl_group_names_standard = TRUE`, an input of
"F" (or any other variant) will return the results for all three
abbreviations.

## Note

### Free Text Search

Due to limitations of the underlying API, this function does not
currently support a general free text search across all fields. Search
functionality is restricted to the specific parameters provided (e.g.,
`keyword`, `topic`, `person`).

### API Result Limits

The Austrian Parliament API imposes a maximum limit of **100,000 rows**
per query. When a query reaches this limit, the function issues a
warning because the results may be incomplete.

**Strategies to handle large result sets:**

- Refine search criteria (narrower date ranges, specific topics,
  individual legislative periods)

- Split queries into multiple requests and combine results using
  [`purrr::map()`](https://purrr.tidyverse.org/reference/map.html) and
  [`purrr::list_rbind()`](https://purrr.tidyverse.org/reference/list_c.html)

**Example of splitting by legislative period:**

    library(purrr)

    # Query items for multiple legislative periods separately
    periods <- c(25, 26, 27, 28)
    all_results <- periods %>%
      map(\(period) get_items(legis_period = period, echo = FALSE)) %>%
      list_rbind()

### Data Availability

The API only returns data from the 5th legislative period (V. GP, 1945)
onwards, i.e. for the Second Republic.

## See also

- [`get_persons()`](https://werkstattcodes.github.io/ParlAT/reference/get_persons.md)
  for searching person identifiers used in the `person` parameter

- [`get_legis_periods()`](https://werkstattcodes.github.io/ParlAT/reference/get_legis_periods.md)
  for retrieving available legislative periods

- [`get_committees()`](https://werkstattcodes.github.io/ParlAT/reference/get_committees.md)
  for committee information

- [`get_plenary_meetings()`](https://werkstattcodes.github.io/ParlAT/reference/get_plenary_meetings.md)
  for plenary meeting data

## Examples

``` r
# \donttest{
# Search for EU-related items in the 28th legislative period
result <- get_items(topic = "Europäische Union", legis_period = 28)
#> ℹ Fetching items from API...
#> ✔ Fetched 639 items
#> {"THEMEN":["Europäische Union"],"GP_CODE":["XXVIII"]} 
#> https://www.parlament.gv.at/recherchieren/gegenstaende/index.html?FP_001THEMEN=Europ%C3%A4ische%20Union&FP_001GP_CODE=XXVIII
#> [1] 639
dplyr::glimpse(result)
#> Rows: 639
#> Columns: 16
#> $ legis_period     <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XX…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "BR", "NR",…
#> $ date             <date> 2026-03-19, 2026-03-18, 2026-03-18, 2026-03-18, 2026…
#> $ item_type        <chr> "KOMM", "KOMM", "KOMM", "I", "KOMM", "KOMM", "AB", "G…
#> $ item_number      <chr> "109", "108", "110", "428", "107", "105", "4002", "25…
#> $ item_number_type <chr> "109/KOMM", "108/KOMM", "110/KOMM", "428 d.B.", "107/…
#> $ stage            <chr> "5", "5", "5", "5", "5", "5", "5", "5", "5", "5", "3"…
#> $ item_url         <chr> "/gegenstand/XXVIII/KOMM/109", "/gegenstand/XXVIII/KO…
#> $ type_doc         <chr> "KOMM", "KOMM", "KOMM", "AUB", "KOMM", "KOMM", "AB", …
#> $ type_doc_long    <chr> "Kommunique", "Kommunique", "Kommunique", "Ausschussb…
#> $ subject          <chr> "Bericht der Bundesministerin für Frauen, Wissenschaf…
#> $ topics           <list> <"Europäische Union", "Frauen und Gleichbehandlung",…
#> $ keywords         <list> <"Europäische Integration", "Kommuniques", "Frauen u…
#> $ eurovoc          <list> <"Ausschussbericht", "Europäische Union", "Forschung…
#> $ persons          <list> "", "", "", "30684", "", "", "6485", "", <"5626", "5…
#> $ parl_group       <list> "", "", "", "NEOS", "", "", "ÖVP", "", <"ÖVP", "GRÜN…

# Search for motions (Antraege) in National Council from February 2024
result <- get_items(
  institution = "NR",
  item = "ANTR",
  date_start = "01-02-2024",
  date_end = "29-02-2024"
)
#> ℹ Fetching items from API...
#> ✔ Fetched 97 items
#> {"NRBR":["NR"],"DATUM_VON":["2024-02-01T00:00:00.000Z","2024-02-29T00:00:00.000Z"],"VHG":["ANTR"]} 
#> https://www.parlament.gv.at/recherchieren/gegenstaende/index.html?FP_001NRBR=NR&FP_001DATUM_VON=2024-02-01T00:00:00.000Z&FP_001DATUM_VON=2024-02-29T00:00:00.000Z&FP_001VHG=ANTR
#> [1] 97
dplyr::glimpse(result)
#> Rows: 97
#> Columns: 16
#> $ legis_period     <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII",…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR",…
#> $ date             <date> 2024-02-28, 2024-02-28, 2024-02-28, 2024-02-28, 2024…
#> $ item_type        <chr> "UEA", "UEA", "UEA", "UEA", "UEA", "UEA", "UEA", "A",…
#> $ item_number      <chr> "1195", "1196", "1192", "1193", "1194", "1191", "1197…
#> $ item_number_type <chr> "1195/UEA", "1196/UEA", "1192/UEA", "1193/UEA", "1194…
#> $ stage            <chr> "5", "5", "5", "5", "5", "5", "5", "3", "3", "3", "3"…
#> $ item_url         <chr> "/gegenstand/XXVII/UEA/1195", "/gegenstand/XXVII/UEA/…
#> $ type_doc         <chr> "UEA", "UEA", "UEA", "UEA", "UEA", "UEA", "UEA", "A(E…
#> $ type_doc_long    <chr> "Unselbständiger Entschließungsantrag", "Unselbständi…
#> $ subject          <chr> "Nationaler Aktionsplan Frauengesundheit dringend erf…
#> $ topics           <list> <"Frauen und Gleichbehandlung", "Gesundheit und Ernä…
#> $ keywords         <list> <"Frauen und Gleichbehandlung", "Gesundheit">, "Gesu…
#> $ eurovoc          <list> <"Frau", "Gesundheit", "Gleichbehandlung">, "Gesundh…
#> $ persons          <list> "2309", "83113", "87002", "1944", "2189", "5646", "8…
#> $ parl_group       <list> "SPÖ", "SPÖ", "FPÖ", "FPÖ", "SPÖ", "SPÖ", "SPÖ", "NE…

# Search for items by specific parliamentary groups
result <- get_items(
  parl_group = c("SPÖ", "ÖVP"),
  legis_period = 27,
  topic = "Bildung"
)
#> ℹ Fetching items from API...
#> ✔ Fetched 1656 items
#> {"THEMEN":["Bildung"],"GP_CODE":["XXVII"],"FRAK_CODE":["SPÖ","ÖVP"]} 
#> https://www.parlament.gv.at/recherchieren/gegenstaende/index.html?FP_001THEMEN=Bildung&FP_001GP_CODE=XXVII&FP_001FRAK_CODE=SP%C3%96&FP_001FRAK_CODE=%C3%96VP
#> [1] 1656
dplyr::glimpse(result)
#> Rows: 1,656
#> Columns: 16
#> $ legis_period     <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII",…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "BR", "NR", "NR", "NR", "NR",…
#> $ date             <date> 2024-10-21, 2024-10-18, 2024-10-11, 2024-10-04, 2024…
#> $ item_type        <chr> "AB", "AB", "III", "III", "AS-BR", "AB", "AB", "UEA",…
#> $ item_number      <chr> "18775", "18772", "1238", "1235", "118", "18750", "18…
#> $ item_number_type <chr> "18775/AB", "18772/AB", "III-1238 d.B.", "III-1235 d.…
#> $ stage            <chr> "5", "5", "3", "3", "5", "5", "5", "5", "5", "5", "5"…
#> $ item_url         <chr> "/gegenstand/XXVII/AB/18775", "/gegenstand/XXVII/AB/1…
#> $ type_doc         <chr> "AB", "AB", "BRG", "BRG", "AS-BR", "AB", "AB", "UEA",…
#> $ type_doc_long    <chr> "Anfragebeantwortung", "Anfragebeantwortung", "Berich…
#> $ subject          <chr> "OeAD finanziert linksextreme Aktivitäten – Folgeanfr…
#> $ topics           <list> <"Bildung", "Budget und Finanzen", "Innovation", "Te…
#> $ keywords         <list> <"Bildungswesen VIII. Sonstiges", "Bundeshaushalt II…
#> $ eurovoc          <list> <"Bildung", "Forschung und geistiges Eigentum", "Öff…
#> $ persons          <list> "20449", "20449", "20449", "20449", "20449", "20449"…
#> $ parl_group       <list> "ÖVP", "ÖVP", "ÖVP", "ÖVP", "ÖVP", "ÖVP", "ÖVP", "SP…

# Search for written questions with keyword
result <- get_items(
  item = "J_JPR_M",
  keyword = "Flüchtlinge",
  institution = "NR"
)
#> ℹ Fetching items from API...
#> ✔ Fetched 2837 items
#> {"NRBR":["NR"],"VHG":["J_JPR_M"],"SW":["Flüchtlinge"]} 
#> https://www.parlament.gv.at/recherchieren/gegenstaende/index.html?FP_001NRBR=NR&FP_001VHG=J_JPR_M&FP_001SW=Fl%C3%BCchtlinge
#> [1] 2837
dplyr::glimpse(result)
#> Rows: 2,837
#> Columns: 16
#> $ legis_period     <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XX…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR",…
#> $ date             <date> 2026-01-28, 2026-01-20, 2026-01-20, 2026-01-19, 2026…
#> $ item_type        <chr> "J", "J", "J", "J", "J", "J", "J", "J", "J", "J", "J"…
#> $ item_number      <chr> "4784", "4579", "4581", "4575", "4493", "4389", "4374…
#> $ item_number_type <chr> "4784/J", "4579/J", "4581/J", "4575/J", "4493/J", "43…
#> $ stage            <chr> "3", "3", "3", "3", "5", "5", "5", "5", "5", "5", "5"…
#> $ item_url         <chr> "/gegenstand/XXVIII/J/4784", "/gegenstand/XXVIII/J/45…
#> $ type_doc         <chr> "J", "J", "J", "J", "J", "J", "J", "J", "J", "J", "J"…
#> $ type_doc_long    <chr> "Schriftliche Anfrage", "Schriftliche Anfrage", "Schr…
#> $ subject          <chr> "Feiern auf Kosten der Steuerzahler? Rechtmäßigkeit, …
#> $ topics           <list> <"Außenpolitik", "Budget und Finanzen", "Inneres und…
#> $ keywords         <list> <"Bundesregierung III. Sonstiges", "Bundeshaushalt I…
#> $ eurovoc          <list> <"Exekutive", "Flüchtling", "Öffentliche Finanzen un…
#> $ persons          <list> <"20445", "30650">, <"2295", "30663">, <"3677", "306…
#> $ parl_group       <list> "FPÖ", "FPÖ", "FPÖ", "FPÖ", "FPÖ", "FPÖ", "FPÖ", "FP…

# Search by person (minister or MP)
result <- get_items(
  person = "Nehammer",
  date_start = "01-01-2023",
  date_end = "31-12-2023"
)
#> ℹ Fetching items from API...
#> ✔ Fetched 382 items
#> {"DATUM_VON":["2023-01-01T00:00:00.000Z","2023-12-31T00:00:00.000Z"],"PAD_INTERN":["2136"]} 
#> https://www.parlament.gv.at/recherchieren/gegenstaende/index.html?FP_001DATUM_VON=2023-01-01T00:00:00.000Z&FP_001DATUM_VON=2023-12-31T00:00:00.000Z&FP_001PAD_INTERN=2136
#> [1] 382
dplyr::glimpse(result)
#> Rows: 382
#> Columns: 16
#> $ legis_period     <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII",…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR",…
#> $ date             <date> 2023-12-22, 2023-12-22, 2023-12-22, 2023-12-22, 2023…
#> $ item_type        <chr> "III", "III", "III", "AB", "AB", "AB", "AB", "AB", "A…
#> $ item_number      <chr> "1083", "1082", "1085", "16229", "16230", "16227", "1…
#> $ item_number_type <chr> "III-1083 d.B.", "III-1082 d.B.", "III-1085 d.B.", "1…
#> $ stage            <chr> "5", "5", "5", "5", "5", "5", "5", "5", "5", "5", "5"…
#> $ item_url         <chr> "/gegenstand/XXVII/III/1083", "/gegenstand/XXVII/III/…
#> $ type_doc         <chr> "BRG", "BRG", "BRG", "AB", "AB", "AB", "AB", "AB", "A…
#> $ type_doc_long    <chr> "Bericht der Bundesregierung", "Bericht der Bundesreg…
#> $ subject          <chr> "Achter Bericht zur Lage der Jugend in Österreich", "…
#> $ topics           <list> "Familie und Generationen", <"Familie und Generation…
#> $ keywords         <list> "Jugend", <"Jugend", "Sozialpolitik">, "Bundeshausha…
#> $ eurovoc          <list> "junger Mensch", <"junger Mensch", "Sozialpolitik">,…
#> $ persons          <list> "2136", "2136", "2136", "2136", "2136", "2136", "213…
#> $ parl_group       <list> "ÖVP", "ÖVP", "ÖVP", "ÖVP", "ÖVP", "ÖVP", "ÖVP", "ÖV…

# Combine multiple search criteria
result <- get_items(
  topic = "Gesundheit und Ernährung",
  item = "RV",  # Government bills
  legis_period = 27,
  institution = "NR"
)
#> ℹ Fetching items from API...
#> ✔ Fetched 61 items
#> {"THEMEN":["Gesundheit und Ernährung"],"NRBR":["NR"],"GP_CODE":["XXVII"],"VHG":["RV"]} 
#> https://www.parlament.gv.at/recherchieren/gegenstaende/index.html?FP_001THEMEN=Gesundheit%20und%20Ern%C3%A4hrung&FP_001NRBR=NR&FP_001GP_CODE=XXVII&FP_001VHG=RV
#> [1] 61
dplyr::glimpse(result)
#> Rows: 61
#> Columns: 16
#> $ legis_period     <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII",…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR",…
#> $ date             <date> 2024-05-15, 2024-04-17, 2024-03-20, 2024-01-31, 2023…
#> $ item_type        <chr> "I", "I", "I", "I", "I", "I", "I", "I", "I", "I", "I"…
#> $ item_number      <chr> "2551", "2530", "2503", "2433", "2303", "2310", "2271…
#> $ item_number_type <chr> "2551 d.B.", "2530 d.B.", "2503 d.B.", "2433 und Zu 2…
#> $ stage            <chr> "5", "5", "5", "5", "5", "5", "5", "5", "5", "5", "5"…
#> $ item_url         <chr> "/gegenstand/XXVII/I/2551", "/gegenstand/XXVII/I/2530…
#> $ type_doc         <chr> "RV", "RV", "RV", "RV", "RV", "RV", "RV", "RV", "RV",…
#> $ type_doc_long    <chr> "Regierungsvorlage: Bundes(verfassungs)gesetz", "Regi…
#> $ subject          <chr> "Medizinproduktegesetz, Änderung", "Gesundheitstelema…
#> $ topics           <list> "Gesundheit und Ernährung", <"Gesundheit und Ernähru…
#> $ keywords         <list> "Gesundheit", <"Gesundheit", "Sozialversicherung I. …
#> $ eurovoc          <list> "Gesundheit", <"Gesundheit", "soziale Sicherheit">, …
#> $ persons          <list> "21029", "21029", "21029", "21029", "21029", "21029"…
#> $ parl_group       <list> <"null", "null">, <"null", "null">, <"null", "null">…

# Get all positions of the Hauptausschuss on EU related matters
result <- get_items(
  legis_period = 27,
  item = "EU",
  type_eu_submission = "S",
  institution = "NR"
)
#> ℹ Fetching items from API...
#> ✔ Fetched 7 items
#> {"NRBR":["NR"],"GP_CODE":["XXVII"],"VHG":["EU"],"VHG2":["S"]} 
#> https://www.parlament.gv.at/recherchieren/gegenstaende/index.html?FP_001NRBR=NR&FP_001GP_CODE=XXVII&FP_001VHG=EU&FP_001VHG2=S
#> [1] 7
dplyr::glimpse(result)
#> Rows: 7
#> Columns: 16
#> $ legis_period     <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII",…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR"
#> $ date             <date> 2022-03-24, 2021-05-20, 2020-10-12, 2020-10-12, 2020-…
#> $ item_type        <chr> "S", "S", "S", "S", "S", "S", "S"
#> $ item_number      <chr> "7", "6", "5", "4", "3", "2", "1"
#> $ item_number_type <chr> "7/S", "6/S", "5/S", "4/S", "3/S", "2/S", "1/S"
#> $ stage            <chr> "5", "5", "5", "5", "5", "5", "5"
#> $ item_url         <chr> "/gegenstand/XXVII/S/7", "/gegenstand/XXVII/S/6", "/…
#> $ type_doc         <chr> "S", "S", "S", "S", "S", "S", "S"
#> $ type_doc_long    <chr> "Stellungnahme des Hauptausschusses", "Stellungnahme …
#> $ subject          <chr> "European Council meeting (24 and 25 March 2022) – Dr…
#> $ topics           <list> NA, NA, NA, NA, NA, NA, NA
#> $ keywords         <list> NA, NA, NA, NA, NA, NA, NA
#> $ eurovoc          <list> NA, NA, NA, NA, NA, NA, NA
#> $ persons          <list> "", "", "", "", "", "", ""
#> $ parl_group       <list> "", "", "", "", "", "", ""

# Get all statements of the sub-committee on EU affairs
# (EU-Unterausschuss) during the 27th legislative period.
result <- get_items(
  item = "EU",
  type_eu_submission = "MTEU",
  legis_period = 27,
  institution = "NR"
)
#> ℹ Fetching items from API...
#> ✔ Fetched 6 items
#> {"NRBR":["NR"],"GP_CODE":["XXVII"],"VHG":["EU"],"VHG2":["MTEU"]} 
#> https://www.parlament.gv.at/recherchieren/gegenstaende/index.html?FP_001NRBR=NR&FP_001GP_CODE=XXVII&FP_001VHG=EU&FP_001VHG2=MTEU
#> [1] 6
dplyr::glimpse(result)
#> Rows: 6
#> Columns: 16
#> $ legis_period     <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII"
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR"
#> $ date             <date> 2023-10-04, 2022-12-05, 2022-09-14, 2021-07-06, 2021-…
#> $ item_type        <chr> "MTEU", "MTEU", "MTEU", "MTEU", "MTEU", "MTEU"
#> $ item_number      <chr> "6", "5", "4", "3", "2", "1"
#> $ item_number_type <chr> "6/MTEU", "5/MTEU", "4/MTEU", "3/MTEU", "2/MTEU", "1/…
#> $ stage            <chr> "5", "5", "5", "5", "5", "5"
#> $ item_url         <chr> "/gegenstand/XXVII/MTEU/6", "/gegenstand/XXVII/MTEU/…
#> $ type_doc         <chr> "MTEU", "MTEU", "MTEU", "MTEU", "MTEU", "MTEU"
#> $ type_doc_long    <chr> "Mitteilung Ständiger Unterausschuss des Hauptausschu…
#> $ subject          <chr> "Bekämpfung der Korruption, zur Ersetzung des Rahmenb…
#> $ topics           <list> NA, NA, NA, NA, NA, NA
#> $ keywords         <list> NA, NA, NA, NA, NA, NA
#> $ eurovoc          <list> NA, NA, NA, NA, NA, NA
#> $ persons          <list> "", "", "", "", "", ""
#> $ parl_group       <list> "", "", "", "", "", ""

# }
```
