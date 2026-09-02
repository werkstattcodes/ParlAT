# Get items under negotiation ('Verhandlungsgegenstände')

`get_items` searches for items ('Verhandlungsgegenstände') that are or
were subject to negotiations in the Austrian National Council
('Nationalrat') or the Federal Council ('Bundesrat'). The function
mirrors the search functionality offered on the Austrian Parliament's
website (see
[here](https://www.parlament.gv.at/recherchieren/gegenstaende)).

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

  Character string. Either `"NR"` or `"Nationalrat"` (National Council),
  or `"BR"` or `"Bundesrat"` (Federal Council). Default is `NULL`, which
  returns both chambers. When combined with `person`, this filters the
  parliamentary items; it does not restrict the person's institutional
  affiliations.

- legis_period:

  Character or numeric vector, or `NULL`. Specifies the legislative
  period(s) to search in. If `NULL` (the default), no period restriction
  is applied. See 'Details' for possible values and the API result
  limit.

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
  name, optionally followed by first name). People are resolved across
  all institutional categories before other item filters are applied.
  Default is `NULL`.

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

  Logical. If `TRUE`, the function prints the URL to the pertaining
  search results on the website of the Austrian Parliament and the
  number of results.

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

`legis_period` specifies the legislative period(s). It can be one or
more of the following values:

- number(s) or character(s) indicating the relevant period(s), i.e.,
  "25", 25, or "XXV";

- `"PN"` for the Provisional National Assembly; or

- `"KN"` for the Constituent National Assembly.

Explicit numbered period filters are supported from the 5th legislative
period (V. GP, 1945) onwards; `"PN"` and `"KN"` are also supported. If
`legis_period = NULL`, no period restriction is applied. Broad searches
can still omit periods from the returned data when the API's 100,000-row
export limit is reached. When `echo = TRUE`, the website URL explicitly
selects every available period so it reproduces the unrestricted search
instead of using the website's current-period default.

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

### Combining person and institution filters

When `person` and `institution` are supplied together, the person lookup
is performed across all institutional categories. The `institution`
value then filters the parliamentary items by chamber. The full German
chamber names and their abbreviations are equivalent. For example, a
federal minister can be associated with National Council items even if
the person is not categorized as a National Council member.

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

Numbered legislative periods are available from the 5th period (V. GP,
1945) onwards. Historical material is also available for the Provisional
National Assembly (`"PN"`) and Constituent National Assembly (`"KN"`).
Coverage and completeness vary by document type.

## See also

- [`get_persons()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_persons.md)
  for searching person identifiers used in the `person` parameter

- [`get_legis_periods()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_legis_periods.md)
  for retrieving available legislative periods

- [`get_committees()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_committees.md)
  for committee information

- [`get_plenary_meetings()`](https://werkstattcodes.github.io/ParlAT/dev/reference/get_plenary_meetings.md)
  for plenary meeting data

## Examples

``` r
# \donttest{
# Search for EU-related items in the 28th legislative period
result <- get_items(topic = "Europäische Union", legis_period = 28)
#> ℹ Fetching items from API...
#> ✔ Fetched 825 items
#> Results on the Parliament website:
#> https://www.parlament.gv.at/recherchieren/gegenstaende?FP_001THEMEN=Europ%C3%A4ische%20Union&FP_001GP_CODE=XXVIII
#> Hits: 825
dplyr::glimpse(result)
#> Rows: 825
#> Columns: 16
#> $ legis_period     <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XX…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR",…
#> $ date             <date> 2026-08-18, 2026-08-17, 2026-08-17, 2026-08-17, 2026…
#> $ item_type        <chr> "AB", "AB", "AB", "AB", "AB", "AB", "AB", "J", "J", "…
#> $ item_number      <chr> "5724", "5717", "5720", "5718", "5669", "5668", "5649…
#> $ item_number_type <chr> "5724/AB", "5717/AB", "5720/AB", "5718/AB", "5669/AB"…
#> $ stage            <chr> "5", "5", "5", "5", "5", "5", "5", "3", "3", "3", "3"…
#> $ item_url         <chr> "https://www.parlament.gv.at/gegenstand/XXVIII/AB/572…
#> $ type_doc         <chr> "AB", "AB", "AB", "AB", "AB", "AB", "AB", "J", "J", "…
#> $ type_doc_long    <chr> "Anfragebeantwortung", "Anfragebeantwortung", "Anfrag…
#> $ subject          <chr> "Wie unabhängig war Österreichs Pandemiepolitik tatsä…
#> $ topics           <list> <"Außenpolitik", "Europäische Union", "Gesundheit un…
#> $ keywords         <list> <"Gesundheit", "Europäische Integration", "Vereinte …
#> $ eurovoc          <chr> "[\"Europäische Union\",\"Gesundheit\",\"Vereinte Nat…
#> $ persons          <list> "3677", "23963", "83122", "20445", "3677", "83122", …
#> $ parl_group       <list> "SPÖ", "SPÖ", "NEOS", "ÖVP", "SPÖ", "NEOS", "ÖVP", "…

# Search for motions (Antraege) in National Council from February 2024
result <- get_items(
  institution = "NR",
  item = "ANTR",
  date_start = "01-02-2024",
  date_end = "29-02-2024"
)
#> ℹ Fetching items from API...
#> ✔ Fetched 97 items
#> Results on the Parliament website:
#> https://www.parlament.gv.at/recherchieren/gegenstaende?FP_001NRBR=NR&FP_001DATUM_VON=2024-02-01T00:00:00.000Z&FP_001DATUM_VON=2024-02-29T00:00:00.000Z&FP_001VHG=ANTR&FP_001GP_CODE=V&FP_001GP_CODE=VI&FP_001GP_CODE=VII&FP_001GP_CODE=VIII&FP_001GP_CODE=IX&FP_001GP_CODE=X&FP_001GP_CODE=XI&FP_001GP_CODE=XII&FP_001GP_CODE=XIII&FP_001GP_CODE=XIV&FP_001GP_CODE=XV&FP_001GP_CODE=XVI&FP_001GP_CODE=XVII&FP_001GP_CODE=XVIII&FP_001GP_CODE=XIX&FP_001GP_CODE=XX&FP_001GP_CODE=XXI&FP_001GP_CODE=XXII&FP_001GP_CODE=XXIII&FP_001GP_CODE=XXIV&FP_001GP_CODE=XXV&FP_001GP_CODE=XXVI&FP_001GP_CODE=XXVII&FP_001GP_CODE=XXVIII&FP_001GP_CODE=KN&FP_001GP_CODE=PN
#> Hits: 97
dplyr::glimpse(result)
#> Rows: 97
#> Columns: 16
#> $ legis_period     <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII",…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR",…
#> $ date             <date> 2024-02-28, 2024-02-28, 2024-02-28, 2024-02-28, 2024…
#> $ item_type        <chr> "UEA", "UEA", "UEA", "UEA", "UEA", "UEA", "UEA", "A",…
#> $ item_number      <chr> "1196", "1192", "1193", "1194", "1195", "1191", "1197…
#> $ item_number_type <chr> "1196/UEA", "1192/UEA", "1193/UEA", "1194/UEA", "1195…
#> $ stage            <chr> "5", "5", "5", "5", "5", "5", "5", "3", "3", "3", "3"…
#> $ item_url         <chr> "https://www.parlament.gv.at/gegenstand/XXVII/UEA/119…
#> $ type_doc         <chr> "UEA", "UEA", "UEA", "UEA", "UEA", "UEA", "UEA", "A(E…
#> $ type_doc_long    <chr> "Unselbständiger Entschließungsantrag", "Unselbständi…
#> $ subject          <chr> "bessere Gesundheitsversorgung durch mehr Kassenärzt:…
#> $ topics           <list> "Gesundheit und Ernährung", <"Bildung", "Frauen und …
#> $ keywords         <list> "Gesundheit", <"Frauen und Gleichbehandlung", "Bildu…
#> $ eurovoc          <chr> "[\"Gesundheit\"]", "[\"Bildung\",\"Frau\",\"Gleichbe…
#> $ persons          <list> "83113", "87002", "1944", "2189", "2309", "5646", "8…
#> $ parl_group       <list> "SPÖ", "FPÖ", "FPÖ", "SPÖ", "SPÖ", "SPÖ", "SPÖ", "NE…

# Search for items by specific parliamentary groups
result <- get_items(
  parl_group = c("SPÖ", "ÖVP"),
  legis_period = 27,
  topic = "Bildung"
)
#> ℹ Fetching items from API...
#> ✔ Fetched 1658 items
#> Results on the Parliament website:
#> https://www.parlament.gv.at/recherchieren/gegenstaende?FP_001THEMEN=Bildung&FP_001GP_CODE=XXVII&FP_001FRAK_CODE=SP%C3%96&FP_001FRAK_CODE=%C3%96VP
#> Hits: 1658
dplyr::glimpse(result)
#> Rows: 1,658
#> Columns: 16
#> $ legis_period     <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII",…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "BR", "NR", "NR", "NR", "NR",…
#> $ date             <date> 2024-10-21, 2024-10-18, 2024-10-11, 2024-10-04, 2024…
#> $ item_type        <chr> "AB", "AB", "III", "III", "AS-BR", "AB", "AB", "UEA",…
#> $ item_number      <chr> "18775", "18772", "1238", "1235", "118", "18750", "18…
#> $ item_number_type <chr> "18775/AB", "18772/AB", "III-1238 d.B.", "III-1235 d.…
#> $ stage            <chr> "5", "5", "3", "3", "5", "5", "5", "5", "5", "5", "5"…
#> $ item_url         <chr> "https://www.parlament.gv.at/gegenstand/XXVII/AB/1877…
#> $ type_doc         <chr> "AB", "AB", "BRG", "BRG", "AS-BR", "AB", "AB", "UEA",…
#> $ type_doc_long    <chr> "Anfragebeantwortung", "Anfragebeantwortung", "Berich…
#> $ subject          <chr> "OeAD finanziert linksextreme Aktivitäten – Folgeanfr…
#> $ topics           <list> <"Bildung", "Budget und Finanzen", "Innovation", "Te…
#> $ keywords         <list> <"Bildungswesen VIII. Sonstiges", "Bundeshaushalt II…
#> $ eurovoc          <chr> "[\"Bildung\",\"Forschung und geistiges Eigentum\",\"…
#> $ persons          <list> "20449", "20449", "20449", "20449", "20449", "20449"…
#> $ parl_group       <list> "ÖVP", "ÖVP", "ÖVP", "ÖVP", "ÖVP", "ÖVP", "ÖVP", "SP…

# Search for written questions with keyword
result <- get_items(
  item = "J_JPR_M",
  keyword = "Flüchtlinge",
  institution = "NR"
)
#> ℹ Fetching items from API...
#> ✔ Fetched 2920 items
#> Results on the Parliament website:
#> https://www.parlament.gv.at/recherchieren/gegenstaende?FP_001NRBR=NR&FP_001VHG=J_JPR_M&FP_001SW=Fl%C3%BCchtlinge&FP_001GP_CODE=V&FP_001GP_CODE=VI&FP_001GP_CODE=VII&FP_001GP_CODE=VIII&FP_001GP_CODE=IX&FP_001GP_CODE=X&FP_001GP_CODE=XI&FP_001GP_CODE=XII&FP_001GP_CODE=XIII&FP_001GP_CODE=XIV&FP_001GP_CODE=XV&FP_001GP_CODE=XVI&FP_001GP_CODE=XVII&FP_001GP_CODE=XVIII&FP_001GP_CODE=XIX&FP_001GP_CODE=XX&FP_001GP_CODE=XXI&FP_001GP_CODE=XXII&FP_001GP_CODE=XXIII&FP_001GP_CODE=XXIV&FP_001GP_CODE=XXV&FP_001GP_CODE=XXVI&FP_001GP_CODE=XXVII&FP_001GP_CODE=XXVIII&FP_001GP_CODE=KN&FP_001GP_CODE=PN
#> Hits: 2920
dplyr::glimpse(result)
#> Rows: 2,920
#> Columns: 16
#> $ legis_period     <chr> "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XXVIII", "XX…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR",…
#> $ date             <date> 2026-08-05, 2026-07-31, 2026-07-30, 2026-07-22, 2026…
#> $ item_type        <chr> "J", "J", "J", "J", "J", "J", "J", "J", "J", "J", "J"…
#> $ item_number      <chr> "6760", "6751", "6746", "6695", "6711", "6657", "6634…
#> $ item_number_type <chr> "6760/J", "6751/J", "6746/J", "6695/J", "6711/J", "66…
#> $ stage            <chr> "3", "3", "3", "3", "3", "3", "3", "3", "3", "3", "3"…
#> $ item_url         <chr> "https://www.parlament.gv.at/gegenstand/XXVIII/J/6760…
#> $ type_doc         <chr> "J", "J", "J", "J", "J", "J", "J", "J", "J", "J", "J"…
#> $ type_doc_long    <chr> "Schriftliche Anfrage", "Schriftliche Anfrage", "Schr…
#> $ subject          <chr> "Sozialleistungsbetrug durch einzelnen jordanischen A…
#> $ topics           <list> <"Außenpolitik", "Inneres und Recht", "Soziales">, <…
#> $ keywords         <list> <"Flüchtlinge", "Sozialpolitik", "Sozialversicherung…
#> $ eurovoc          <chr> "[\"Flüchtling\",\"soziale Sicherheit\",\"Sozialpolit…
#> $ persons          <list> <"20445", "30664">, <"20445", "35469">, <"6502", "20…
#> $ parl_group       <list> "FPÖ", "FPÖ", "GRÜNE", "FPÖ", "FPÖ", "FPÖ", "FPÖ", "…

# Search by person (minister or MP)
result <- get_items(
  person = "Kurz Sebastian",
  institution = "Nationalrat", # "NR" is equivalent
  legis_period = 27
)
#> ℹ Fetching items from API...
#> ✔ Fetched 872 items
#> Results on the Parliament website:
#> https://www.parlament.gv.at/recherchieren/gegenstaende?FP_001NRBR=NR&FP_001GP_CODE=XXVII&FP_001PAD_INTERN=65321
#> Hits: 872
dplyr::glimpse(result)
#> Rows: 872
#> Columns: 16
#> $ legis_period     <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII",…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR",…
#> $ date             <date> 2021-11-26, 2021-10-14, 2021-10-08, 2021-10-08, 2021…
#> $ item_type        <chr> "J", "IMM", "J", "J", "J", "J", "AB", "III", "J", "J"…
#> $ item_number      <chr> "8772", "11", "8203", "8178", "8131", "8156", "7462",…
#> $ item_number_type <chr> "8772/J", "11/IMM", "8203/J", "8178/J", "8131/J", "81…
#> $ stage            <chr> "5", "5", "5", "5", "5", "5", "5", "3", "5", "5", "5"…
#> $ item_url         <chr> "https://www.parlament.gv.at/gegenstand/XXVII/J/8772"…
#> $ type_doc         <chr> "J", "IMM", "J", "J", "J", "J", "AB", "BRG", "J", "J"…
#> $ type_doc_long    <chr> "Schriftliche Anfrage", "Ersuchen von Behörden", "Sch…
#> $ subject          <chr> "Vorbereitung von Aktenlieferungen an den ÖVP-Korrupt…
#> $ topics           <list> <"Inneres und Recht", "Parlament und Demokratie">, "…
#> $ keywords         <list> <"Geschäftsordnung des Nationalrates", "Untersuchung…
#> $ eurovoc          <chr> "[\"Exekutive\",\"Geschäftsordnung des Parlaments\",\…
#> $ persons          <list> <"14842", "65321">, "65321", <"65321", "83125">, <"6…
#> $ parl_group       <list> "SPÖ", "ÖVP", "NEOS", "NEOS", "FPÖ", "FPÖ", "ÖVP", "…

# Search historical items from the national assemblies of 1918-1920
historical_items <- get_items(
  institution = "NR",
  legis_period = c("PN", "KN")
)
#> ℹ Fetching items from API...
#> ✔ Fetched 2213 items
#> Results on the Parliament website:
#> https://www.parlament.gv.at/recherchieren/gegenstaende?FP_001NRBR=NR&FP_001GP_CODE=PN&FP_001GP_CODE=KN
#> Hits: 2213
dplyr::glimpse(historical_items)
#> Rows: 2,213
#> Columns: 16
#> $ legis_period     <chr> "KN", "KN", "KN", "KN", "KN", "KN", "KN", "KN", "KN",…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR", "NR",…
#> $ date             <date> 1920-10-30, 1920-10-16, 1920-10-01, 1920-10-01, 1920…
#> $ item_type        <chr> "AB-KN", "AB-KN", "UEA-KN", "I-KN", "AB-KN", "AB-KN",…
#> $ item_number      <chr> "178", "182", "113", "1000", "180", "181", "418", "41…
#> $ item_number_type <chr> "178/AB-KN", "182/AB-KN", "113/UEA-KN", "1000 d.B./AU…
#> $ stage            <chr> "5", "5", "5", "5", "5", "5", "3", "3", "5", "3", "5"…
#> $ item_url         <chr> "https://www.parlament.gv.at/gegenstand/KN/AB-KN/178"…
#> $ type_doc         <chr> "AB-KN", "AB-KN", "UEA-KN", "AUB-KN", "AB-KN", "AB-KN…
#> $ type_doc_long    <chr> "Anfragebeantwortung Konst. Nationalversammlung", "An…
#> $ subject          <chr> "Gewährung von Zuwendungen an die katholischen Geistl…
#> $ topics           <list> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
#> $ keywords         <list> NA, NA, "Amnestie", NA, NA, NA, "Krankenanstalten", …
#> $ eurovoc          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
#> $ persons          <list> "64227", "208", <"20", "487", "1161">, "1262", "6442…
#> $ parl_group       <list> "", "SdP", <"CSP", "GdP", "SdP">, "SdP", "OK", "OK",…

# Combine multiple search criteria
result <- get_items(
  topic = "Gesundheit und Ernährung",
  item = "RV",  # Government bills
  legis_period = 27,
  institution = "NR"
)
#> ℹ Fetching items from API...
#> ✔ Fetched 61 items
#> Results on the Parliament website:
#> https://www.parlament.gv.at/recherchieren/gegenstaende?FP_001THEMEN=Gesundheit%20und%20Ern%C3%A4hrung&FP_001NRBR=NR&FP_001GP_CODE=XXVII&FP_001VHG=RV
#> Hits: 61
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
#> $ item_url         <chr> "https://www.parlament.gv.at/gegenstand/XXVII/I/2551"…
#> $ type_doc         <chr> "RV", "RV", "RV", "RV", "RV", "RV", "RV", "RV", "RV",…
#> $ type_doc_long    <chr> "Regierungsvorlage: Bundes(verfassungs)gesetz", "Regi…
#> $ subject          <chr> "Medizinproduktegesetz, Änderung", "Gesundheitstelema…
#> $ topics           <list> "Gesundheit und Ernährung", <"Gesundheit und Ernähru…
#> $ keywords         <list> "Gesundheit", <"Gesundheit", "Sozialversicherung I. …
#> $ eurovoc          <chr> "[\"Gesundheit\"]", "[\"Gesundheit\",\"soziale Sicher…
#> $ persons          <list> "21029", "21029", "21029", "21029", "21029", "21029"…
#> $ parl_group       <list> "", "", "", "", "", "", "", "", "", "", "", "", "", …

# Get all positions of the Hauptausschuss on EU related matters
result <- get_items(
  legis_period = 27,
  item = "EU",
  type_eu_submission = "S",
  institution = "NR"
)
#> ℹ Fetching items from API...
#> ✔ Fetched 7 items
#> Results on the Parliament website:
#> https://www.parlament.gv.at/recherchieren/gegenstaende?FP_001NRBR=NR&FP_001GP_CODE=XXVII&FP_001VHG=EU&FP_001VHG2=S
#> Hits: 7
dplyr::glimpse(result)
#> Rows: 7
#> Columns: 16
#> $ legis_period     <chr> "XXVII", "XXVII", "XXVII", "XXVII", "XXVII", "XXVII",…
#> $ institution      <chr> "NR", "NR", "NR", "NR", "NR", "NR", "NR"
#> $ date             <date> 2022-03-24, 2021-05-20, 2020-10-12, 2020-10-12, 2020-…
#> $ item_type        <chr> "S", "S", "S", "S", "S", "S", "S"
#> $ item_number      <chr> "7", "6", "4", "5", "3", "2", "1"
#> $ item_number_type <chr> "7/S", "6/S", "4/S", "5/S", "3/S", "2/S", "1/S"
#> $ stage            <chr> "5", "5", "5", "5", "5", "5", "5"
#> $ item_url         <chr> "https://www.parlament.gv.at/gegenstand/XXVII/S/7", …
#> $ type_doc         <chr> "S", "S", "S", "S", "S", "S", "S"
#> $ type_doc_long    <chr> "Stellungnahme des Hauptausschusses", "Stellungnahme …
#> $ subject          <chr> "European Council meeting (24 and 25 March 2022) – Dr…
#> $ topics           <list> NA, NA, NA, NA, NA, NA, NA
#> $ keywords         <list> NA, NA, NA, NA, NA, NA, NA
#> $ eurovoc          <chr> NA, NA, NA, NA, NA, NA, NA
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
#> Results on the Parliament website:
#> https://www.parlament.gv.at/recherchieren/gegenstaende?FP_001NRBR=NR&FP_001GP_CODE=XXVII&FP_001VHG=EU&FP_001VHG2=MTEU
#> Hits: 6
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
#> $ item_url         <chr> "https://www.parlament.gv.at/gegenstand/XXVII/MTEU/6…
#> $ type_doc         <chr> "MTEU", "MTEU", "MTEU", "MTEU", "MTEU", "MTEU"
#> $ type_doc_long    <chr> "Mitteilung Ständiger Unterausschuss des Hauptausschu…
#> $ subject          <chr> "Bekämpfung der Korruption, zur Ersetzung des Rahmenb…
#> $ topics           <list> NA, NA, NA, NA, NA, NA
#> $ keywords         <list> NA, NA, NA, NA, NA, NA
#> $ eurovoc          <chr> NA, NA, NA, NA, NA, NA
#> $ persons          <list> "", "", "", "", "", ""
#> $ parl_group       <list> "", "", "", "", "", ""

# }
```
