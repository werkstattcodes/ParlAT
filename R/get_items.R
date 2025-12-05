#' Get items under negotiation ('Verhandlungsgegenstände')
#' @encoding UTF-8
#' @description
#' `get_items` searches for items ('Verhandlungsgegenstände') that are or were subject to negotiations
#' in the Austrian National Council ('Nationalrat') or the Federal Council ('Bundesrat'). The function
#' mirrors the search functionality offered on the Austrian Parliament's website (see <a href="https://www.parlament.gv.at/recherchieren/gegenstaende/index.html" target="_blank">here</a>).
#'
#' @param topic (Thema) Character vector or `NULL`. Specifies the topic(s) to search for. See 'Details' for possible values. Default is `NULL`.
#' @param institution Character string. Either "NR" (Nationalrat, National Council) or "BR" (Bundesrat, Federal Council). Default is `NULL` which returns both chambers.
#' @param legis_period Character vector or `NULL`. Specifies the legislative period(s) to search in. See 'Details' for possible values. Default is `NULL`.
#' @param date_start Character string. Start date for the search period in format "dd-mm-yyyy", "dd.mm.yyyy", or "dd/mm/yyyy". Default is `NULL`.
#' @param date_end Character string. End date for the search period in format "dd-mm-yyyy", "dd.mm.yyyy", or "dd/mm/yyyy". Default is `NULL`.
#' @param item Character vector or `NULL`. Specifies the type(s) of parliamentary item(s) to search for. See 'Details' for possible values. Default is `NULL`.
#' @param doc_type Character vector or `NULL`. Specifies the type of parliamentary item(s) to search for. See 'Details' for possible values. Default is `NULL`.
#' @param person Character string or `NULL`. Name of a person to search for (family name, optionally followed by first name). Default is `NULL`.
#' @param keyword Character vector or `NULL`. Keyword(s) to search for. Default is `NULL`.
#' @param eurovoc Character vector or `NULL`. EuroVoc term(s) to search for. Default is `NULL`.
#' @param parl_group Character vector or `NULL`. Parliamentary group(s) to search for. Default is `NULL`. Combine multiple groups in a vector, i.e. c("SPÖ", "ÖVP"). See Details.
#' @param parl_group_names_standard Logical. If `TRUE`, the function expands and standardizes parliamentary group names. Default is `FALSE`. See Details.
#' @param echo Logical. If `TRUE`, the function prints the used search parameters and the url to the pertaining search results on website of the Austrian Parliament.
#'
#' @details
#'
#' ## Topic (Thema)
#' NULL, one, or multiple topics permissible.
#' Possible values for `topic` are:
#'
#' * "Arbeit" (work)
#' * "Außenpolitik" (foreign policy)
#' * "Bildung" (education)
#' * "Budget und Finanzen" (budget and finance)
#' * "Europäische Union" (European Union)
#' * "Familie und Generationen" (family and generations)
#' * "Frauen und Gleichbehandlung" (women and equality)
#' * "Gesundheit und Ernährung" (health and nutrition)
#' * "Information und Medien" (information and media)
#' * "Inneres und Recht" (interior and law)
#' * "Innovation, Technologie und Forschung" (innovation, technology and research)
#' * "Klima, Umwelt und Energie" (climate, environment and energy)
#' * "Kultur" (culture)
#' * "Land- und Forstwirtschaft" (agriculture and forestry)
#' * "Landesverteidigung" (national defense)
#' * "Parlament und Demokratie" (parliament and democracy)
#' * "Soziales" (social affairs)
#' * "Sport" (sports)
#' * "Verkehr und Infrastruktur" (transport and infrastructure)
#' * "Wirtschaft" (economy)
#'
#' ## legis_period (Gesetzgebungsperiode)
#' `legis_period` specifies the legislative period(s). Can be one or more of the following value(s):
#' * numbers indicating the relevant period(s),
#' * "PN" (Provisorische Nationalversammlung, Provisional National Assembly, 1918-1919),
#' * and/or "KN" (Konstituierende Nationalversammlung, Constituent National Assembly, 1919-1920).
#'
#' ## item (Gegenstand)
#' Possible values for `item` include:
#'
#' * "ASEU" (Aktuelle Europastunden, Current European Hours)
#' * "AS" (Aktuelle Stunden, Current Hours)
#' * "J_JPR_M" (Anfragen, Written Questions)
#' * "ANTR" (Anträge, Motions)
#' * "US" (Anträge/Verlangen auf Untersuchungsausschuss, Motions/Requests for Investigative Committee)
#' * "AUB" (Ausschussberichte, Committee Reports)
#' * "AB_ABPR_ABM" (Beantwortungen, Answers)
#' * "III" (Berichte an den Nationalrat, Reports to the National Council)
#' * "BNR" (Beschlüsse, Resolutions)
#' * "BI" (Bürgerinitiativen, Citizen Initiatives)
#' * "E" (Einsprüche des Bundesrates, Objections of the Federal Council)
#' * "EBR" (Entschließungen, Resolutions)
#' * "EU" (EU betreffende Vorlagen und Beschlüsse, EU-related Proposals and Resolutions)
#' * "FS" (Fragestunden, Question Time)
#' * "GO" (Geschäftsbehandlung, Rules of Procedure)
#' * "GABR" (Gesetzesanträge des Bundesrates, Legislative Proposals of the Federal Council)
#' * "GABR13" (Gesetzesanträge von einem Drittel des BR, Legislative Proposals of One-Third of the Federal Council)
#' * "IMM" (Immunitätsangelegenheiten, Immunity Matters)
#' * "KOMM" (Kommuniqués, Communiqués)
#' * "PET" (Petitionen, Petitions)
#' * "RGER" (Regierungserklärungen, Government Statements)
#' * "RV" (Regierungsvorlagen (Gesetze), Government Bills (Laws))
#' * "RVS" (Staatsverträge, State Treaties)
#' * "TRAU" (Trauerkundgebungen, Condolence Expressions)
#' * "RVS15" (Vereinbarungen gemäß Art. 15a B-VG, Agreements Pursuant to Article 15a of the Federal Constitutional Law)
#' * "VOLKBG" (Volksbegehren, Popular Initiatives)
#' * "W" (Wahlen, Elections)
#'
#' ## doc_type (Art des Antrages)
#' If item is "ANTR", the permissible values for doc_type depend on the
#' institution of interest.
#' Possible values for `doc_type` if institution=="NR" ('National Council'):
#' * "A" (Selbständiger Antrag, Independent Motion)
#' * "A(E)" (Selbständiger Entschließungsantrag, Independent Resolution Motion)
#' * "AA" (Abänderungsantrag, Amendment Motion)
#' * "AEA" (Selbständiger Ausschuss-Entschließungsantrag, Independent Committee Resolution Motion)
#' * "AMIN" (Selbständiger Antrag - Ministeranklage, Independent Motion - Ministerial Impeachment)
#' * "ARH2" (Verlangen auf Gebarungsüberprüfung durch den Rechnungshof, Request for Audit by the Court of Audit)
#' * "AVB" (Antrag auf Volksbefragung, Motion for Public Consultation)
#' * "BUA" (Bericht und Antrag, Report and Motion)
#' * "UEA" (Unselbständiger Entschließungsantrag, Dependent Resolution Motion)
#' * "UEAM" (Misstrauensantrag, Motion of No Confidence)
#' * "URH2" (Verlangen auf Gebarungsüberprüfung durch den Ständigen UA des Rechnungshofausschusses, Request for Audit by the Standing Subcommittee of the Court of Audit Committee)
#'
#' Possible values for `doc_type` if institution=="BR" ('Federal Council'):
#' *  "AA-BR" (Abänderungsanträge, Amendment Motions)
#' *  "A-BR" (Selbständiger Antrag Bundesrat, Independent Motion Federal Council)
#' *  "A(E)" (Selbständiger Entschließungsantrag Bundesrat, Independent Resolution Motion Federal Council)
#' *  "AEA-BR" (Selbständiger Entschließungsantrag von Ausschüssen, Independent Committee Resolution Motion Federal Council)
#' *  "UEA-BR" (Unselbständige Anträge)
#'
#' Possible values for `doc_type` if *item=="BNR"*:
#' * "BNR" (Beschluss, Resolution)
#' * "BS" (Sonstiger Beschluss, Other Resolution)
#' * "BSE" (Beschluss-EU, EU Resolution)
#' * "BSESM" (Beschluss-ESM, ESM Resolution)
#' * "BS-BR" (Sonstiger Beschluss, Other Resolution (only if institution=="Bundesrat"))
#'
#' ## EuroVoc
#' EuroVoc is an international thesaurus developed primarily for use within the EU. It enables searches
#' using standardized keywords across Europe. The EuroVoc search is supported for all negotiation items
#' from the 20th legislative period onwards.
#'
#' ## Keywords (Schlagwort)
#' Possible values for `keyword` include:
#'
#' * "Abfallwirtschaft"
#' * "Abgeordnete"
#' * "Abstimmungen, geheime"
#' * "Abstimmungen, namentliche"
#' * "Abstimmungsangelegenheiten"
#' * "Abweichende persönliche Stellungnahmen"
#' * "Aktuelle Europastunden"
#' * "Aktuelle Stunden"
#' * "Anfragebeantwortungen, Besprechung von"
#' * "Anfragen, Dringliche"
#' * "Anträge, Dringliche"
#' * "Apotheken"
#' * "Arbeiterkammern"
#' * "Arbeitsinspektion"
#' * "Arbeitsmarkt"
#' * "Arbeitsrecht I. österreichisches"
#' * "Arbeitsrecht II. internationales"
#' * "Archive"
#' * "Atomenergie"
#' * "Außenpolitik"
#' * "Ausländer"
#' * "Ausschüsse des Nationalrates"
#' * "Bauwesen"
#' * "Bergbau"
#' * "Betriebsräte"
#' * "Bibliotheken"
#' * "Bildungswesen I. Pflichtschulen"
#' * "Bildungswesen II. Mittlere Schulen"
#' * "Bildungswesen III. Höhere Schulen"
#' * "Bildungswesen IV. Universitäten und Hochschulen"
#' * "Bildungswesen V. Minderheitenschulwesen"
#' * "Bildungswesen VI. Schülerbeihilfen und Studienförderung"
#' * "Bildungswesen VII. Erwachsenenbildung"
#' * "Bildungswesen VIII. Sonstiges"
#' * "Bundesforste"
#' * "Bundesgesetzblatt"
#' * "Bundeshaushalt I. Bundesfinanzgesetze"
#' * "Bundeshaushalt II. Budgetüberschreitungen"
#' * "Bundeshaushalt III. Sonstiges"
#' * "Bundesländer"
#' * "Bundespräsident:in"
#' * "Bundesregierung I. Ernennungen, Enthebungen und Ableben"
#' * "Bundesregierung II. Regierungserklärungen"
#' * "Bundesregierung III. Sonstiges"
#' * "Bundesverfassung"
#' * "Bundesvermögen"
#' * "Bundeswappen"
#' * "Bürgerinitiativen"
#' * "Debattenanträge bzw. -verlangen"
#' * "Ehrenzeichen und Medaillen"
#' * "Einsprüche des Bundesrates"
#' * "Einspruchsfrist des Bundesrates"
#' * "Elektrizität"
#' * "Elementarpädagogik"
#' * "Energiewirtschaft"
#' * "Entwicklungszusammenarbeit"
#' * "Erklärungen Präsident/Präsidentin"
#' * "Erste Lesungen"
#' * "Erste Lesungen, Anträge/Verlangen"
#' * "Europäische Integration"
#' * "Europarat"
#' * "Familienlastenausgleich"
#' * "Familienpolitik"
#' * "Film"
#' * "Finanzausgleich"
#' * "Flüchtlinge"
#' * "Fragestunden"
#' * "Frauen und Gleichbehandlung"
#' * "Fremdenverkehr"
#' * "Fristsetzungen"
#' * "Geschäftsordnung des Nationalrates"
#' * "Gesundheit"
#' * "Glücksspiel"
#' * "Grenzen"
#' * "Handel, Gewerbe und Industrie"
#' * "II. Einberufung und Beendigung der Tagungen"
#' * "III. Präsidenten, Schriftführer und Ordner"
#' * "III. Sonstiges"
#' * "Immunität"
#' * "Information und Informationsverarbeitung"
#' * "Internet"
#' * "IV. Ansprachen Präsident/Präsidentin"
#' * "Jagd und Fischerei"
#' * "Jugend"
#' * "Kommuniques"
#' * "Kreditwesen"
#' * "Kunst und Kultur"
#' * "Land- und Forstwirtschaft"
#' * "Landesverteidigung"
#' * "Lebensmittel"
#' * "Löhne und Gehälter"
#' * "Maße und Gewichte"
#' * "Menschen mit Behinderung"
#' * "Menschenrechte"
#' * "Minderheitsberichte"
#' * "Misstrauensanträge"
#' * "Museen"
#' * "Nationalfeiertag"
#' * "Neutralität"
#' * "Öffentliche Unternehmen"
#' * "Öffentlicher Dienst"
#' * "Opferfürsorge und Opferschutz"
#' * "Ordnungsrufe"
#' * "Pässe und Ausweise"
#' * "Pensionssystem"
#' * "Personenstandsrecht"
#' * "Petitionen"
#' * "Pflege und Betreuung"
#' * "Politische Parteien"
#' * "Postwesen"
#' * "Preise"
#' * "Presse"
#' * "Prüfungsaufträge Rechnungshof"
#' * "Prüfungsaufträge Rechnungshofausschuss"
#' * "Raumordnung"
#' * "Rechnungshof"
#' * "Rechtsanwälte und Notare"
#' * "Rechtsbereinigung"
#' * "Rechtspflege"
#' * "Redezeitbeschränkungen"
#' * "Religion"
#' * "Rückverweisungen"
#' * "Rundfunk und Fernsehen"
#' * "Sicherheitswesen"
#' * "Sitzungsunterbrechung"
#' * "Sondersitzungen"
#' * "Sonstige Geschäftsordnungsangelegenheiten"
#' * "Sozialpolitik"
#' * "Sozialversicherung I. Allgemeine Sozialversicherung"
#' * "Sozialversicherung II. Gewerbliche Sozialversicherung"
#' * "Sozialversicherung III. Landwirtschaftliche Sozialversicherung"
#' * "Sozialversicherung IV. Kriegsopferversorgung"
#' * "Sozialversicherung V. Arbeitslosenversicherung"
#' * "Sozialversicherung VI. Sonstiges"
#' * "Sport"
#' * "Staatsbürger:in"
#' * "Staatsverträge"
#' * "Statistik"
#' * "Steuern und Gebühren"
#' * "Strafrecht"
#' * "Straßen- und Brückenbau"
#' * "Südtirol"
#' * "Tabak"
#' * "Tagesordnung"
#' * "Telekommunikation"
#' * "Theater"
#' * "Trauerkundgebungen"
#' * "Umweltschutz"
#' * "Untersuchungsausschüsse"
#' * "Unvereinbarkeit"
#' * "V. Sonstiges"
#' * "Vereinbarungen"
#' * "Vereins- und Versammlungsrecht"
#' * "Vereinte Nationen"
#' * "Verfassungs- und Verwaltungsgerichtsbarkeit"
#' * "Verkehr I. Straßenverkehr"
#' * "Verkehr II. Schienenverkehr"
#' * "Verkehr III. Luftfahrt"
#' * "Verkehr IV. Schifffahrt"
#' * "Verkehr V. Sonstiges"
#' * "Verkürztes Verfahren"
#' * "Vermessung"
#' * "Vermögenssicherung"
#' * "Vertragsversicherungen"
#' * "Verwaltungsorganisation"
#' * "Verwaltungsverfahren"
#' * "Veterinärwesen und Tierschutz"
#' * "Völkerrecht"
#' * "Völkerrechtliche Vertretungen"
#' * "Volksabstimmung"
#' * "Volksanwaltschaft"
#' * "Volksbefragung"
#' * "Volksbegehren"
#' * "Volksgruppen"
#' * "Volkszählung"
#' * "Wahlen"
#' * "Währung"
#' * "Wasserbauten"
#' * "Wasserrecht"
#' * "Wasserwirtschaft"
#' * "Weinwirtschaft"
#' * "Wirtschaftspolitik"
#' * "Wirtschaftstreuhänder:in"
#' * "Wissenschaft und Forschung"
#' * "Wohnungswesen"
#' * "Wortentziehung"
#' * "Wortmeldungen zur Geschäftsbehandlung"
#' * "Zivildienst"
#' * "Zivilrecht"
#' * "Zivilschutz"
#' * "Zollwesen"
#'
#' ## Parliamentary Group (Klub/Fraktion)
#' `parl_group` specifies the parliamentary group(s) to search for. The API of the Austrian Parliament accepts only specific abbreviations for each group:
#'
#' - "BZÖ" (Bündnis Zukunft Österreich)
#' - "CSP" (Christlichsoziale Partei)
#' - "DnP" (Deutsche Nationalpartei)
#' - "F" (Freiheitliche Partei Österreichs)
#' - "F-BZÖ" (Freiheitliche Partei Österreichs - Bündnis Zukunft Österreich)
#' - "FPÖ" (Freiheitliche Partei Österreichs)
#' - "GdP" (Großdeutsche Volkspartei)
#' - "GRÜNE" (Die Grünen - Die Grüne Alternative)
#' - "HB" (Heimatblock)
#' - "JETZT" (Jetzt - Liste Pilz)
#' - "Konvent"
#' - "KPÖ" (Kommunistische Partei Österreichs)
#' - "KuL"
#' - "L" (Liberales Forum)
#' - "LB"
#' - "LBd" (Landbund für Österreich)
#' - "NEOS" (NEOS - Das Neue Österreich)
#' - "NEOS-LIF" (NEOS - Liberales Forum)
#' - "NSDAP" (Nationalsozialistische Deutsche Arbeiterpartei)
#' - "NWB" (Nationaler Wirtschaftsblock und Landbund)
#' - "OF"
#' - "OK" (Ohne Klub)
#' - "ÖVP" (Österreichische Volkspartei)
#' - "PILZ" (Liste Pilz)
#' - "SdP"
#' - "SPÖ" (Sozialistische/Sozialdemokratische Partei Österreichs)
#' - "STRONACH" (Team Stronach)
#' - "VO" (Wahlgemeinschaft Österreichische Volksopposition)
#' - "WdU" (Wahlpartei der Unabhängigen (VdU, Verband der Unabhängigen))
#'
#' ## parl_group_names_standard
#' When `parl_group_names_standard = TRUE`, the function automatically converts common party names
#' to their official abbreviations used by the Austrian Parliament API. This feature helps users
#' who might not know the exact abbreviations required by the API. E.g. over the years the FPÖ
#' has featured different abbreviations for their parliamentary group: "FPÖ", "F", and "F-BZÖ". With
#' `parl_group_names_standard = TRUE`, an input of "F" (or any other variant) will return
#' the results for all three abbreviations.
#'
#' ## Free Text Search
#' Due to limitations of the underlying API, this function does not currently support a general free text search across all fields. Search functionality is restricted to the specific parameters provided (e.g., `keyword`, `topic`, `person`).

#' ## API Result Limits
#' The Austrian Parliament API imposes a maximum limit of **100,000 rows** per query. When a query
#' reaches this limit, the function issues a warning because the results may be incomplete.
#'
#' **Strategies to handle large result sets:**
#' * Refine search criteria (narrower date ranges, specific topics, individual legislative periods)
#' * Split queries into multiple requests and combine results using `purrr::map()` and `purrr::list_rbind()`
#'
#' **Example of splitting by legislative period:**
#' ```r
#' library(purrr)
#'
#' # Query items for multiple legislative periods separately
#' periods <- c(25, 26, 27, 28)
#' all_results <- periods |>
#'   map(\(period) get_items(legis_period = period, echo = FALSE)) |>
#'   list_rbind()
#' ```
#'
#' @return
#' A tibble (data.frame) with one row per parliamentary item matching the search.
#' The returned object contains the most commonly used columns (some are optional
#' or returned as list-columns for multi-valued fields):
#'
#' - legis_period (character): legislative period (e.g. "XXVIII").
#' - institution (character): chamber code, typically "NR" (Nationalrat) or "BR" (Bundesrat).
#' - date (Date): date of the item (class Date).
#' - item_type (character): short item type code.
#' - item_number (character): numeric identifier of the item (stored as character).
#' - item_number_type (character): combined number/type string (e.g. "46/M").
#' - stage (character/integer): current stage code of the item.
#' - item_url (character): normalized URL pointing to the item on parlament.gv.at.
#' - doc_type (character): short document type code (when applicable).
#' - doc_type_long (character): human readable document type (when available).
#' - subject (character): subject / title of the item.
#' - topics (list): list-column; each element is a character vector of topics.
#' - keywords (list): list-column of keywords (Schlagwort).
#' - eurovoc (list): list-column of EuroVoc terms.
#' - persons (list): list-column of person identifiers (pad_intern) related to the item.
#' - parl_group (list): list-column of parliamentary group codes associated with the item.
#'
#' The function returns a tibble (invisible) on success. If no matching rows are found
#' the function returns NULL and emits a message "No results found for the provided search criteria."
#'
#' @note Date columns are parsed into Date using lubridate::dmy().
#'
#' @seealso
#' * [get_persons()] for searching person identifiers used in the `person` parameter
#' * [get_legis_periods()] for retrieving available legislative periods
#' * [get_committees()] for committee information
#' * [get_plenary_sessions()] for plenary session data
#'
#' @export
#'
#' @examples \dontrun{
#' # Search for EU-related items in the 28th legislative period
#' get_items(topic = "Europäische Union", legis_period = 28)
#'
#' # Search for motions (Anträge) in National Council from February 2024
#' get_items(
#'   institution = "NR",
#'   item = "ANTR",
#'   date_start = "01-02-2024",
#'   date_end = "29-02-2024"
#' )
#'
#' # Search for items by specific parliamentary groups
#' get_items(
#'   parl_group = c("SPÖ", "ÖVP"),
#'   legis_period = 27,
#'   topic = "Bildung"
#' )
#'
#' # Search for written questions with keyword
#' get_items(
#'   item = "J_JPR_M",
#'   keyword = "Klimaschutz",
#'   institution = "NR"
#' )
#'
#' # Search by person (minister or MP)
#' get_items(
#'   person = "Nehammer",
#'   date_start = "01-01-2023",
#'   date_end = "31-12-2023"
#' )
#'
#' # Combine multiple search criteria
#' get_items(
#'   topic = "Gesundheit und Ernährung",
#'   item = "RV",  # Government bills
#'   legis_period = 27,
#'   institution = "NR"
#' )
#' }
get_items <- function(
  topic = NULL, #Themen - Themen
  institution = NULL, #Gremium - NRBR
  legis_period = NULL, #Gesetzgebungsperiode - GB_Code
  date_start = NULL, #Datum_von - DATUM_VON
  date_end = NULL, #Datum_bis - DATUM_BIS
  item = NULL, #Gegenstand - VHG
  doc_type = NULL, #Art der Anfrage - DOKTYP
  person = NULL, #Person - PAD_intern (via person_input)
  keyword = NULL, #Schlagwort - SW
  eurovoc = NULL, #EuroVoc - EUROVOC
  parl_group = NULL, #Klub/Fraktion - FRAK_CODE
  parl_group_names_standard = FALSE,
  echo = TRUE
) {
  #TOPIC
  choices_topic <- c(
    "Arbeit",
    "Außenpolitik",
    "Bildung",
    "Budget und Finanzen",
    "Europäische Union",
    "Familie und Generationen",
    "Frauen und Gleichbehandlung",
    "Gesundheit und Ernährung",
    "Information und Medien",
    "Inneres und Recht",
    "Innovation, Technologie und Forschung",
    "Klima, Umwelt und Energie",
    "Kultur",
    "Land- und Forstwirtschaft",
    "Landesverteidigung",
    "Parlament und Demokratie",
    "Soziales",
    "Sport",
    "Verkehr und Infrastruktur",
    "Wirtschaft"
  )
  # topic must be one of documented choices (allow NULL)
  checkmate::assert_subset(topic, choices_topic, empty.ok = TRUE)

  #INSTITUTION
  checkmate::assert_subset(
    institution,
    choices = c("BR", "NR"),
    empty.ok = TRUE
  )
  ##encode
  institution_input <- institution
  # institution_input <- switch(
  #   institution,
  #   Nationalrat = "NR",
  #   Bundesrat = "BR"
  # )

  #LEGIS PERIOD
  legis_period <- purrr::map_chr(
    legis_period,
    \(x) fn_check_legis_period_elements(x)
  )

  #DATE START; DATE END
  # Date validation using lubridate for flexible input formats
  date_start_parsed <- NULL
  date_end_parsed <- NULL

  if (!is.null(date_start)) {
    checkmate::assert_character(date_start, len = 1, null.ok = TRUE)
    date_start_parsed <- lubridate::dmy(date_start, quiet = TRUE)
    if (is.na(date_start_parsed)) {
      stop(
        "date_start must be a valid date in format dd-mm-yyyy, dd.mm.yyyy, or dd/mm/yyyy"
      )
    }
    date_start <- format(
      as.POSIXct(date_start_parsed),
      format = "%Y-%m-%dT%H:%M:%S.000Z",
      tz = "CET"
    )
  }

  #date end
  if (!is.null(date_end)) {
    checkmate::assert_character(date_end, len = 1, null.ok = TRUE)
    date_end_parsed <- lubridate::dmy(date_end, quiet = TRUE)
    if (is.na(date_end_parsed)) {
      stop(
        "date_end must be a valid date in format dd-mm-yyyy, dd.mm.yyyy, or dd/mm/yyyy"
      )
    }
    date_end <- format(
      as.POSIXct(date_end_parsed),
      format = "%Y-%m-%dT%H:%M:%S.000Z",
      tz = "CET"
    )
  }

  # Validate date range
  if (!is.null(date_start_parsed) && !is.null(date_end_parsed)) {
    if (date_start_parsed > date_end_parsed) {
      stop("date_start must be before or equal to date_end")
    }
  }

  # ITEM / VHG / Gegenstand
  ## checkmate::assert_subset does not show which element was not matched
  choices_item <- c(
    "ASEU",
    "AS",
    "J_JPR_M",
    "ANTR",
    "US",
    "AUB",
    "AB_ABPR_ABM",
    "III",
    "BNR",
    "BI",
    "E",
    "EBR",
    "EU",
    "FS",
    "GO",
    "GABR",
    "GABR13",
    "IMM",
    "KOMM",
    "PET",
    "RGER",
    "RV",
    "RVS",
    "TRAU",
    "RVS15",
    "VOLKBG",
    "W"
  )

  checkmate::assert_subset(x = item, choices = choices_item, empty.ok = TRUE)

  if (!is.null(item) && any(item %in% "ANTR")) {
    ## depending on institution, different set of permissble values
    choices_doc_type_antr_national_council <- c(
      "A",
      "A(E)",
      "AA",
      "AEA",
      "AMIN",
      "ARH2",
      "AVB",
      "BUA",
      "UEA",
      "UEAM",
      "URH2"
    )
    choices_doc_type_antr_federal_council <- c(
      "AA-BR",
      "A-BR",
      "A(E)",
      "AEA-BR",
      "UEA-BR"
    )

    if (institution == "NR" || is.null(institution)) {
      checkmate::assert_subset(
        x = doc_type,
        choices = choices_doc_type_antr_national_council,
        empty.ok = TRUE
      )
    } else if (institution == "BR") {
      checkmate::assert_subset(
        x = doc_type,
        choices = choices_doc_type_antr_federal_council,
        empty.ok = FALSE
      )
    }
  }

  # DOC_TYPE (Art des Antrages)
  if (!is.null(doc_type) && is.null(item)) {
    stop("'doc_type' can be only specified in combination with 'item'")
  }

  if (!is.null(item) && any(item %in% "BNR")) {
    choices_doc_type_bnr_national_council <- c("BNR", "BS", "BSE", "BSESM")
    choices_doc_type_bnr_federal_council <- c("BNR", "BS-BR")

    if (institution == "NR" || is.null(institution)) {
      checkmate::assert_subset(
        x = doc_type,
        choices = choices_doc_type_bnr_national_council,
        empty.ok = TRUE
      )
    }

    if (institution == "BR" && !is.null(institution)) {
      checkmate::assert_subset(
        x = doc_type,
        choices = choices_doc_type_bnr_federal_council,
        empty.ok = FALSE
      )
    }
  }

  # PERSON
  ## requires pad_intern as input => auxiliary function searching pad_intern based on name needed
  ## accepts multiple values
  ## pad_intern needs to be character, not numeric
  if (!is.null(person)) {
    person_input <- get_persons(names = person, institution = institution) |>
      dplyr::pull(pad_intern) |>
      unique() |>
      as.character()
  } else {
    person_input <- NULL
  }

  # KEYWORD (Schlagwort)
  choices_item_keyword <- c(
    "Abfallwirtschaft",
    "Abgeordnete",
    "Abstimmungen, geheime",
    "Abstimmungen, namentliche",
    "Abstimmungsangelegenheiten",
    "Abweichende persönliche Stellungnahmen",
    "Aktuelle Europastunden",
    "Aktuelle Stunden",
    "Anfragebeantwortungen, Besprechung von",
    "Anfragen, Dringliche",
    "Anträge, Dringliche",
    "Apotheken",
    "Arbeiterkammern",
    "Arbeitsinspektion",
    "Arbeitsmarkt",
    "Arbeitsrecht I. österreichisches",
    "Arbeitsrecht II. internationales",
    "Archive",
    "Atomenergie",
    "Außenpolitik",
    "Ausländer",
    "Ausschüsse des Nationalrates",
    "Bauwesen",
    "Bergbau",
    "Betriebsräte",
    "Bibliotheken",
    "Bildungswesen I. Pflichtschulen",
    "Bildungswesen II. Mittlere Schulen",
    "Bildungswesen III. Höhere Schulen",
    "Bildungswesen IV. Universitäten und Hochschulen",
    "Bildungswesen V. Minderheitenschulwesen",
    "Bildungswesen VI. Schülerbeihilfen und Studienförderung",
    "Bildungswesen VII. Erwachsenenbildung",
    "Bildungswesen VIII. Sonstiges",
    "Bundesforste",
    "Bundesgesetzblatt",
    "Bundeshaushalt I. Bundesfinanzgesetze",
    "Bundeshaushalt II. Budgetüberschreitungen",
    "Bundeshaushalt III. Sonstiges",
    "Bundesländer",
    "Bundespräsident:in",
    "Bundesregierung I. Ernennungen, Enthebungen und Ableben",
    "Bundesregierung II. Regierungserklärungen",
    "Bundesregierung III. Sonstiges",
    "Bundesverfassung",
    "Bundesvermögen",
    "Bundeswappen",
    "Bürgerinitiativen",
    "Debattenanträge bzw. -verlangen",
    "Ehrenzeichen und Medaillen",
    "Einsprüche des Bundesrates",
    "Einspruchsfrist des Bundesrates",
    "Elektrizität",
    "Elementarpädagogik",
    "Energiewirtschaft",
    "Entwicklungszusammenarbeit",
    "Erklärungen Präsident/Präsidentin",
    "Erste Lesungen",
    "Erste Lesungen, Anträge/Verlangen",
    "Europäische Integration",
    "Europarat",
    "Familienlastenausgleich",
    "Familienpolitik",
    "Film",
    "Finanzausgleich",
    "Flüchtlinge",
    "Fragestunden",
    "Frauen und Gleichbehandlung",
    "Fremdenverkehr",
    "Fristsetzungen",
    "Geschäftsordnung des Nationalrates",
    "Gesundheit",
    "Glücksspiel",
    "Grenzen",
    "Handel, Gewerbe und Industrie",
    "II. Einberufung und Beendigung der Tagungen",
    "III. Präsidenten, Schriftführer und Ordner",
    "III. Sonstiges",
    "Immunität",
    "Information und Informationsverarbeitung",
    "Internet",
    "IV. Ansprachen Präsident/Präsidentin",
    "Jagd und Fischerei",
    "Jugend",
    "Kommuniques",
    "Kreditwesen",
    "Kunst und Kultur",
    "Land- und Forstwirtschaft",
    "Landesverteidigung",
    "Lebensmittel",
    "Löhne und Gehälter",
    "Maße und Gewichte",
    "Menschen mit Behinderung",
    "Menschenrechte",
    "Minderheitsberichte",
    "Misstrauensanträge",
    "Museen",
    "Nationalfeiertag",
    "Neutralität",
    "Öffentliche Unternehmen",
    "Öffentlicher Dienst",
    "Opferfürsorge und Opferschutz",
    "Ordnungsrufe",
    "Pässe und Ausweise",
    "Pensionssystem",
    "Personenstandsrecht",
    "Petitionen",
    "Pflege und Betreuung",
    "Politische Parteien",
    "Postwesen",
    "Preise",
    "Presse",
    "Prüfungsaufträge Rechnungshof",
    "Prüfungsaufträge Rechnungshofausschuss",
    "Raumordnung",
    "Rechnungshof",
    "Rechtsanwälte und Notare",
    "Rechtsbereinigung",
    "Rechtspflege",
    "Redezeitbeschränkungen",
    "Religion",
    "Rückverweisungen",
    "Rundfunk und Fernsehen",
    "Sicherheitswesen",
    "Sitzungsunterbrechung",
    "Sondersitzungen",
    "Sonstige Geschäftsordnungsangelegenheiten",
    "Sozialpolitik",
    "Sozialversicherung I. Allgemeine Sozialversicherung",
    "Sozialversicherung II. Gewerbliche Sozialversicherung",
    "Sozialversicherung III. Landwirtschaftliche Sozialversicherung",
    "Sozialversicherung IV. Kriegsopferversorgung",
    "Sozialversicherung V. Arbeitslosenversicherung",
    "Sozialversicherung VI. Sonstiges",
    "Sport",
    "Staatsbürger:in",
    "Staatsverträge",
    "Statistik",
    "Steuern und Gebühren",
    "Strafrecht",
    "Straßen- und Brückenbau",
    "Südtirol",
    "Tabak",
    "Tagesordnung",
    "Telekommunikation",
    "Theater",
    "Trauerkundgebungen",
    "Umweltschutz",
    "Untersuchungsausschüsse",
    "Unvereinbarkeit",
    "V. Sonstiges",
    "Vereinbarungen",
    "Vereins- und Versammlungsrecht",
    "Vereinte Nationen",
    "Verfassungs- und Verwaltungsgerichtsbarkeit",
    "Verkehr I. Straßenverkehr",
    "Verkehr II. Schienenverkehr",
    "Verkehr III. Luftfahrt",
    "Verkehr IV. Schifffahrt",
    "Verkehr V. Sonstiges",
    "Verkürztes Verfahren",
    "Vermessung",
    "Vermögenssicherung",
    "Vertragsversicherungen",
    "Verwaltungsorganisation",
    "Verwaltungsverfahren",
    "Veterinärwesen und Tierschutz",
    "Völkerrecht",
    "Völkerrechtliche Vertretungen",
    "Volksabstimmung",
    "Volksanwaltschaft",
    "Volksbefragung",
    "Volksbegehren",
    "Volksgruppen",
    "Volkszählung",
    "Wahlen",
    "Währung",
    "Wasserbauten",
    "Wasserrecht",
    "Wasserwirtschaft",
    "Weinwirtschaft",
    "Wirtschaftspolitik",
    "Wirtschaftstreuhänder:in",
    "Wissenschaft und Forschung",
    "Wohnungswesen",
    "Wortentziehung",
    "Wortmeldungen zur Geschäftsbehandlung",
    "Zivildienst",
    "Zivilrecht",
    "Zivilschutz",
    "Zollwesen"
  )

  checkmate::assert_subset(
    x = keyword,
    choices = choices_item_keyword,
    empty.ok = TRUE
  )

  # EUROVOC
  ## ensure eurovoc is a character vector (or NULL)
  checkmate::assert_character(x = eurovoc, null.ok = TRUE)

  # PARL_GROUP (Klub/Fraktion)
  ## web: option "Klub/Fraktion" only visible after selecting legislative period; party options depend on chosen legislative period
  ## scope-checking: would require list of all parties: checks only if input is subset of all parl groups;
  ## documentation: list of all possible parities plus abbreviations;

  choices_parl_group <- c(
    "BZÖ",
    "CSP",
    "DnP",
    "F",
    "F-BZÖ",
    "FPÖ",
    "GdP",
    "GRÜNE",
    "HB",
    "JETZT",
    "Konvent",
    "KPÖ",
    "KuL",
    "L",
    "LB",
    "LBd",
    "NEOS",
    "NEOS-LIF",
    "NSDAP",
    "NWB",
    "OF",
    "OK",
    "ÖVP",
    "PILZ",
    "SdP",
    "SPÖ",
    "STRONACH",
    "VO",
    "WdU"
  )
  checkmate::assert_subset(parl_group, choices_parl_group, empty.ok = TRUE)

  if (parl_group_names_standard == TRUE) {
    parl_group <- aux_parl_group_names_standard(parl_group)
  }

  # COLLECT PARAMETERS
  body_params <- list(
    THEMEN = topic,
    NRBR = institution_input,
    GP_CODE = legis_period,
    DATUM_VON = c(date_start, date_end),
    VHG = item,
    DOKTYP = doc_type,
    PAD_INTERN = person_input,
    SW = keyword,
    EUROVOC = eurovoc,
    FRAK_CODE = parl_group
  ) |>
    purrr::compact() |> #keep only non-empty elements
    jsonlite::toJSON()

  req <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/101"
  ) |>
    httr2::req_method("POST") |>
    httr2::req_url_query(
      js = "eval",
      showAll = TRUE,
      # page = "1",
      # pagesize = "449",
      export = TRUE
    ) |>
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      dnt = "1",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i",
      `sec-ch-ua` = '"Chromium";v="134", "Not:A-Brand";v="24", "Google Chrome";v="134"',
      `sec-ch-ua-mobile` = "?0",
      `sec-ch-ua-platform` = '"Windows"',
      `sec-fetch-dest` = "empty",
      `sec-fetch-mode` = "cors",
      `sec-fetch-site` = "same-origin",
      `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36"
    ) |>
    httr2::req_body_raw(body_params, "application/json") |>
    # httr2::req_body_json(body_params) |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)")

  resp <- httr2::req_perform(req)
  resp_json <- httr2::resp_body_json(resp, simplifyVector = TRUE)

  vec_headings <- resp_json |>
    purrr::pluck("header", "label") |>
    janitor::make_clean_names()

  rows <- purrr::pluck(resp_json, "rows")

  if (length(rows) == 0) {
    df_res <- NULL
  } else {
    df_res <- rows |>
      as.data.frame()

    #patch: API returns colums and header labels of different lenghts. Those
    #labels which exceed the number of cols appear to be irrelevant; not clear why
    #they were included

    if (ncol(df_res) != length(vec_headings)) {
      # print("Warning: Columns and labels of different length!")

      vec_headings <- vec_headings[1:ncol(df_res)]
    }

    colnames(df_res) <- vec_headings
  }

  # RETURN ECHO
  if (echo == TRUE) {
    print(body_params)
    # print url to results / transparency reasons / add search string parameter
    body_params_li <- jsonlite::fromJSON(body_params)

    query_string <- purrr::imap(
      body_params_li,
      \(x, y) glue::glue("FP_001{URLencode(y)}={URLencode(x)}")
    ) |>
      unlist() |>
      unname() |>
      paste0(collapse = "&")

    print(glue::glue(
      "https://www.parlament.gv.at/recherchieren/gegenstaende/index.html?{query_string}"
    ))

    print(if (is.null(df_res)) 0 else nrow(df_res))
  }

  # STOP IF NO HITS
  if (is.null(df_res) || nrow(df_res) == 0) {
    message("No results found for the provided search criteria.")
    return(NULL)
  }

  # WARN IF RESULT LIMIT REACHED
  if (nrow(df_res) >= 100000) {
    warning(
      "Query returned 100,000 rows (API maximum). Results are likely to be incomplete. ",
      "Refine search criteria or split into multiple requests. ",
      "See 'API Result Limits' in ?get_items for details.",
      call. = FALSE
    )
  }

  # PARSE CONTENT TO MAKE MORE AMENABLE FOR FURTHER ANALYSIS

  cols_pars <- c(
    "personen_id",
    "thema",
    "klub_fraktion",
    "schlagwort",
    "euro_voc"
  )
  fn_parse_content <- function(x) {
    x |>
      stringr::str_remove_all("\\[|\\]|\"") |>
      stringr::str_split(",") |>
      unlist() |>
      stringr::str_trim()
  }

  df_res <- df_res |>
    dplyr::mutate(
      dplyr::across(
        dplyr::any_of(cols_pars),
        \(x) purrr::map(x, \(y) fn_parse_content(y))
      )
    )

  #RENAME  & SELECT RELEVANT COLUMNS
  ## rename
  renaming_map <- c(
    "gp" = "legis_period",
    "inr" = "item_number",
    "datum" = "date",
    "ityp" = "item_type",
    "betreff" = "subject",
    "nummer" = "item_number_type",
    "phasen_bis" = "stages_n", #no longer returned by API?
    "status" = "stage",
    "doktyp" = "doc_type",
    "doktyp_lang" = "doc_type_long",
    # "his_url" = "item_url",
    "euro_voc" = "eurovoc",
    "geschichtsseite_url" = "item_url",
    "personen_id" = "persons",
    "klub_fraktion" = "parl_group",
    "schlagwort" = "keywords",
    "thema" = "topics",
    "gremium" = "institution"
  )

  df_res <- df_res |>
    dplyr::rename_with(
      .fn = \(x) renaming_map[x],
      .cols = any_of(names(renaming_map))
    )

  ##select
  col_select <- c(
    "legis_period",
    "institution",
    "date",
    "item_type",
    "item_number",
    "item_number_type",
    "stage",
    "item_url",
    "doc_type",
    "doc_type_long",
    "subject",
    "topics",
    "keywords",
    "eurovoc",
    "persons",
    "parl_group"
  )

  df_res <- df_res |>
    dplyr::select(dplyr::any_of(col_select)) |>
    dplyr::relocate(dplyr::any_of(col_select)) |> #ensures ordering of columns
    dplyr::mutate(date = lubridate::dmy(date))

  # CHECK FOR DUPLICATES
  # Check for completely duplicate rows across all columns
  n_total_rows <- nrow(df_res)
  n_distinct_rows <- df_res |>
    dplyr::distinct() |>
    nrow()

  if (n_total_rows > n_distinct_rows) {
    n_duplicates <- n_total_rows - n_distinct_rows

    warning(
      "The result contains ",
      n_duplicates,
      " duplicate row(s). ",
      "Total rows: ",
      n_total_rows,
      ", unique rows: ",
      n_distinct_rows,
      ". ",
      "This may indicate data quality issues.",
      call. = FALSE
    )
  }

  # RETURN RESULT
  return(df_res)
}

#' Get detailed stage information for a parliamentary item
#'
#' `r lifecycle::badge("experimental")`
#'
#' Retrieves detailed stage information for a specific parliamentary item by
#' scraping its detail page on the Austrian Parliament website. The function
#' extracts structured data about the item's progression through different
#' legislative stages.
#'
#' @param item_url Character. A single URL or path to an item on the Austrian
#'   Parliament website. Can be an absolute URL starting with
#'   "https://www.parlament.gv.at/" or a relative path (with or without
#'   leading slashes). The function will normalize relative paths automatically.
#'
#' @return A tibble containing detailed information about each stage of the
#'   parliamentary item, including stage text and metadata.
#'
#' @details
#' The function performs the following steps:
#' 1. Normalizes the URL (prepends "https://www.parlament.gv.at/" if needed)
#' 2. Scrapes the item's detail page
#' 3. Extracts structured data from embedded JavaScript
#' 4. Parses HTML content within stage text fields
#' 5. Returns a tibble with stage information
#'
#' @seealso
#' * [get_items()] for searching parliamentary items and retrieving URLs
#'
#' @examples
#' \dontrun{
#' # Get details for a specific item
#' item_url <- "https://www.parlament.gv.at/gegenstand/XXVIII/BI/24"
#' stages <- get_item_details(item_url)
#'
#' # Also works with relative paths
#' stages <- get_item_details("/gegenstand/XXVIII/BI/24")
#' }
#'
#' @export
get_item_details <- function(item_url, type = "stages") {
  prefix <- "https://www.parlament.gv.at/"

  if (!stringr::str_starts(item_url, prefix)) {
    item_url <- item_url |>
      stringr::str_replace("^/+", "") |>
      (\(x) stringr::str_c(prefix, x))()
  }

  page <- rvest::read_html(item_url)

  # Extract and parse embedded data from JavaScript
  data_list <- page |>
    rvest::html_elements("script") |>
    rvest::html_text2() |>
    (\(x) x[stringr::str_detect(x, "props:")])() |>
    stringr::str_extract("(?s)props:.*") |>
    stringr::str_remove("props:\\s*") |>
    stringr::str_remove("\\}\\);\\s*$") |>
    jsonlite::fromJSON() |>
    (\(x) x$data)()

  #GET METADATA ON ITEM
  df_res <- tibble(
    item_url = item_url,
    type = data_list$content$type,
    title = data_list$content$title,
    item_number = data_list$content$zitation,
    item_description = data_list$content$description,
    state_statements = data_list$content$statementsstage,
    state_approval = data_list$content$approvalstate
  )

  #GET STAGES DETAILS - IF STRUCTURE IS PHASE/STAGES
  if (type == "stages" && !is.null(data_list$content$phase$stages)) {
    df_stages <- data_list$content$phase |>
      dplyr::rename(stage = stages) |>
      tidyr::unnest_longer(stage) |>
      tidyr::unnest_wider(stage, names_sep = "_") |>
      dplyr::rename(phase = name, stage_name = stage_text)

    df_stages <- df_stages |>
      dplyr::mutate(
        stage_name = purrr::map_chr(stage_name, \(x) {
          tryCatch(
            {
              x |> rvest::read_html() |> rvest::html_text2()
            },
            error = function(e) {
              # If it fails, it's probably plain text already
              x
            }
          )
        })
      )

    # Expand df_res to match df_stages and combine
    result <- df_res |>
      dplyr::slice(rep(1:dplyr::n(), length.out = nrow(df_stages))) |>
      dplyr::bind_cols(df_stages)

    return(result)
  }

  #GET STAGES DETAILS - IF STRUCTURE IS STAGES
  if (type == "stages" && !is.null(data_list$content$stages)) {
    df_stages <- data_list$content$stages |>
      tidyr::unnest_longer(fsth) |>
      tidyr::unnest_wider(fsth, names_sep = "_") %>%
      dplyr::rename(session_number = fsth_sitzung_id) %>%
      dplyr::select(-fsth_fund_von, -fsth_fund_bis)

    df_stages <- df_stages |>
      dplyr::mutate(
        text = purrr::map_chr(text, \(x) {
          tryCatch(
            {
              x |> rvest::read_html() |> rvest::html_text2()
            },
            error = function(e) {
              # If it fails, it's probably plain text already
              x
            }
          )
        })
      )

    # browser()

    # Expand df_res to match df_stages and combine
    result <- df_res |>
      dplyr::slice(rep(1:dplyr::n(), length.out = nrow(df_stages))) |>
      dplyr::bind_cols(df_stages)

    return(result)
  }

  return(NULL)
}
