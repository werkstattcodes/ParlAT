#' Get items under negotiation ('Verhandlungsgegenstände')
#' @encoding UTF-8
#' @description
#' `get_items` searches for items ('Verhandlungsgegenstände') that are or were subject to negotiations
#' in the Austrian National Council ('Nationalrat') or the Federal Council ('Bundesrat'). The function
#' mirrors the search functionality offered on the Austrian Parliament's website (see <a href="https://www.parlament.gv.at/recherchieren/gegenstaende/index.html" target="_blank">here</a>).
#'
#' @param search_string Character string or `NULL`. General search term to filter results. Default is `NULL`.
#' @param topic (Thema) Character vector or `NULL`. Specifies the topic(s) to search for. See 'Details' for possible values. Default is `NULL`.
#' @param institution Character string. Either "NR" (Nationalrat, National Council) or "BR" (Bundesrat, Federal Council). Default is `NULL` which returns both chambers.
#' @param legis_period Character vector or `NULL`. Specifies the legislative period(s) to search in. See 'Details' for possible values. Default is `NULL`.
#' @param date_start Character string. Start date for the search period in format "dd-mm-yyyy", "dd.mm.yyyy", or "dd/mm/yyyy". Default is `NULL`.
#' @param date_end Character string. End date for the search period in format "dd-mm-yyyy", "dd.mm.yyyy", or "dd/mm/yyyy". Default is `NULL`.
#' @param item Character vector or `NULL`. Specifies the type(s) of parliamentary item(s) to search for. See 'Details' for possible values. Default is `NULL`.
#' @param doc_type Character vector or `NULL`. Specifies the type of parliamentary item(s) to search for. See 'Details' for possible values. Default is `NULL`.
#' @param person Character string or `NULL`. Name of a person to search for (family name, optionally followed by first name). Default is `NULL`.
#' @param number Character string, numeric, or `NULL`. Specific item number to search for. Numeric input will be converted to character. Default is `NULL`.
#' @param keyword Character vector or `NULL`. Keyword(s) to search for. Default is `NULL`.
#' @param eurovoc Character vector or `NULL`. EuroVoc term(s) to search for. Default is `NULL`.
#' @param parl_group Character vector or `NULL`. Parliamentary group(s) to search for. Default is `NULL`. Combine multiple groups in a vector, i.e. c("SPÖ", "ÖVP"). See Details.
#' @param parl_group_names_standard Logical. If `TRUE`, the function expands and standardizes parliamentary group names. Default is `FALSE`. See Details.
#' @param echo Logical. If `TRUE`, the function prints the used search parameters and the url to the pertaining search results on website of the Austrian Parliament.
#'
#' @details
#' ## Topic (Thema)
#  NULL, one, or multiple topics permissible.
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
#' * "Abfallwirtschaft", "Abgeordnete", "Abstimmungen, geheime", "Abstimmungen, namentliche"
#' * "Abstimmungsangelegenheiten", "Abweichende persönliche Stellungnahmen", "Aktuelle Europastunden"
#' * "Aktuelle Stunden", "Anfragebeantwortungen, Besprechung von", "Anfragen, Dringliche"
#' * "Anträge, Dringliche", "Apotheken", "Arbeiterkammern", "Arbeitsinspektion", "Arbeitsmarkt"
#' * "Arbeitsrecht I. österreichisches", "Arbeitsrecht II. internationales", "Archive", "Atomenergie"
#' * "Außenpolitik", "Ausländer", "Ausschüsse des Nationalrates", "Bauwesen", "Bergbau"
#' * "Betriebsräte", "Bibliotheken", "Bildungswesen I. Pflichtschulen", "Bildungswesen II. Mittlere Schulen"
#' * "Bildungswesen III. Höhere Schulen", "Bildungswesen IV. Universitäten und Hochschulen"
#' * "Bildungswesen V. Minderheitenschulwesen", "Bildungswesen VI. Schülerbeihilfen und Studienförderung"
#' * "Bildungswesen VII. Erwachsenenbildung", "Bildungswesen VIII. Sonstiges", "Bundesforste"
#' * "Bundesgesetzblatt", "Bundeshaushalt I. Bundesfinanzgesetze", "Bundeshaushalt II. Budgetüberschreitungen"
#' * "Bundeshaushalt III. Sonstiges", "Bundesländer", "Bundespräsident:in"
#' * "Bundesregierung I. Ernennungen, Enthebungen und Ableben", "Bundesregierung II. Regierungserklärungen"
#' * "Bundesregierung III. Sonstiges", "Bundesverfassung", "Bundesvermögen", "Bundeswappen"
#' * "Bürgerinitiativen", "Debattenanträge bzw. -verlangen", "Ehrenzeichen und Medaillen"
#' * "Einsprüche des Bundesrates", "Einspruchsfrist des Bundesrates", "Elektrizität", "Elementarpädagogik"
#' * "Energiewirtschaft", "Entwicklungszusammenarbeit", "Erklärungen Präsident/Präsidentin"
#' * "Erste Lesungen", "Erste Lesungen, Anträge/Verlangen", "Europäische Integration", "Europarat"
#' * "Familienlastenausgleich", "Familienpolitik", "Film", "Finanzausgleich", "Flüchtlinge"
#' * "Fragestunden", "Frauen und Gleichbehandlung", "Fremdenverkehr", "Fristsetzungen"
#' * "Geschäftsordnung des Nationalrates", "Gesundheit", "Glücksspiel", "Grenzen"
#' * "Handel, Gewerbe und Industrie", "II. Einberufung und Beendigung der Tagungen"
#' * "III. Präsidenten, Schriftführer und Ordner", "III. Sonstiges", "Immunität"
#' * "Information und Informationsverarbeitung", "Internet", "IV. Ansprachen Präsident/Präsidentin"
#' * "Jagd und Fischerei", "Jugend", "Kommuniques", "Kreditwesen", "Kunst und Kultur"
#' * "Land- und Forstwirtschaft", "Landesverteidigung", "Lebensmittel", "Löhne und Gehälter"
#' * "Maße und Gewichte", "Menschen mit Behinderung", "Menschenrechte", "Minderheitsberichte"
#' * "Misstrauensanträge", "Museen", "Nationalfeiertag", "Neutralität", "Öffentliche Unternehmen"
#' * "Öffentlicher Dienst", "Opferfürsorge und Opferschutz", "Ordnungsrufe", "Pässe und Ausweise"
#' * "Pensionssystem", "Personenstandsrecht", "Petitionen", "Pflege und Betreuung"
#' * "Politische Parteien", "Postwesen", "Preise", "Presse", "Prüfungsaufträge Rechnungshof"
#' * "Prüfungsaufträge Rechnungshofausschuss", "Raumordnung", "Rechnungshof", "Rechtsanwälte und Notare"
#' * "Rechtsbereinigung", "Rechtspflege", "Redezeitbeschränkungen", "Religion", "Rückverweisungen"
#' * "Rundfunk und Fernsehen", "Sicherheitswesen", "Sitzungsunterbrechung", "Sondersitzungen"
#' * "Sonstige Geschäftsordnungsangelegenheiten", "Sozialpolitik", "Sozialversicherung I. Allgemeine Sozialversicherung"
#' * "Sozialversicherung II. Gewerbliche Sozialversicherung", "Sozialversicherung III. Landwirtschaftliche Sozialversicherung"
#' * "Sozialversicherung IV. Kriegsopferversorgung", "Sozialversicherung V. Arbeitslosenversicherung"
#' * "Sozialversicherung VI. Sonstiges", "Sport", "Staatsbürger:in", "Staatsverträge", "Statistik"
#' * "Steuern und Gebühren", "Strafrecht", "Straßen- und Brückenbau", "Südtirol", "Tabak"
#' * "Tagesordnung", "Telekommunikation", "Theater", "Trauerkundgebungen", "Umweltschutz"
#' * "Untersuchungsausschüsse", "Unvereinbarkeit", "V. Sonstiges", "Vereinbarungen"
#' * "Vereins- und Versammlungsrecht", "Vereinte Nationen", "Verfassungs- und Verwaltungsgerichtsbarkeit"
#' * "Verkehr I. Straßenverkehr", "Verkehr II. Schienenverkehr", "Verkehr III. Luftfahrt"
#' * "Verkehr IV. Schifffahrt", "Verkehr V. Sonstiges", "Verkürztes Verfahren", "Vermessung"
#' * "Vermögenssicherung", "Vertragsversicherungen", "Verwaltungsorganisation", "Verwaltungsverfahren"
#' * "Veterinärwesen und Tierschutz", "Völkerrecht", "Völkerrechtliche Vertretungen", "Volksabstimmung"
#' * "Volksanwaltschaft", "Volksbefragung", "Volksbegehren", "Volksgruppen", "Volkszählung"
#' * "Wahlen", "Währung", "Wasserbauten", "Wasserrecht", "Wasserwirtschaft", "Weinwirtschaft"
#' * "Wirtschaftspolitik", "Wirtschaftstreuhänder:in", "Wissenschaft und Forschung", "Wohnungswesen"
#' * "Wortentziehung", "Wortmeldungen zur Geschäftsbehandlung", "Zivildienst", "Zivilrecht"
#' * "Zivilschutz", "Zollwesen"
#'
#' ## Parlamentary Group (Klub/Fraktion)
#' `parl_group` specifies the parliamentary group(s) to search for. The API of the Austrian Parliament accepts only specific abbreviations for each group:
#'
# #TODO complete abbreviations
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
#' - "NWB" (Nationaler Wirtschaftsblck und Landbund)
#' - "OF"
#' - "OK" (Ohne Klub)
#' - "ÖVP" (Österreichische Volkspartei)
#' - "PILZ" (Liste Pilz)
#' - "SdP"
#' - "SPÖ" (Sozialistische/Sozialdemokratische Partei Österreichs)
#' - "STRONACH" (Team Stronach)
#' - "VO" (Wahlgemeinschafft Österreichische Volksopposition)
#' - "WdU" (Wahlpartei der Unabhängigen (VdU, Verband der Unabhängigen))
#'
#' ## parl_group_names_standard
#' When `parl_group_names_standard = TRUE`, the function automatically converts common party names
#' to their official abbreviations used by the Austrian Parliament API. This feature helps users
#' who might not know the exact abbreviations required by the API. E.g. over the years the FPÖ
#' has featured different abbreviations for their parlamentary group: 'FPÖ','F', and 'F-BZÖ'. With
#' parl_group_names_standard set to TRUE, an input of 'F' (or any other) will return the
#' results for all three abbreviations.
#'
#' @return A data frame containing the search results. If no results are found, the function returns `NULL`
#' and displays a message.
#'
#' @note The API currently has a limitation of returning a maximum of 100,000 rows.
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
#' # General text search across all items
#' get_items(search_string = "Digitalisierung")
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
  search_string = NULL,
  topic = NULL, #Themen - Themen
  institution = NULL, #Gremium - NRBR
  legis_period = NULL, #Gesetzgebungsperiode - GB_Code
  date_start = NULL, #Datum_von - DATUM_VON
  date_end = NULL, #Datum_bis - DATUM_BIS
  item = NULL, #Gegenstand - VHG
  doc_type = NULL, #Art der Anfrage - DOKTYP
  person = NULL, #Person - PAD_intern (via person_input)
  number = NULL, #Nummer - INRUM PENDING
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
  checkmate::assert_subset(topic, choices_topic, empty.ok = T)

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

    if (institution == "BR") {
      checkmate::assert_subset(
        x = doc_type,
        choices = choices_doc_type_bnr_federal_council,
        empty.ok = FALSE
      )
    }
  }

  ##Gegenstand: schriftliche Anfragen
  ### Art der Anfrage
  if (!is.null(item) && any(item %in% "J_JPR_M")) {}

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

  # NUMBER (number)
  if (!is.null(number)) {
    # Convert numeric input to character first
    if (is.numeric(number)) {
      number <- as.character(number)
    }
    # Then validate as character
    checkmate::assert_character(number, len = 1)
  }

  # Basic validation for text parameters to prevent obvious issues
  validate_text_input <- function(text, param_name) {
    if (is.null(text)) {
      return(invisible(NULL))
    }

    # Check for suspicious patterns that might indicate injection attempts
    suspicious_patterns <- c(
      "<script",
      "</script",
      "javascript:",
      "data:text/html",
      "\\x00",
      "\\x08",
      "\\x0B",
      "\\x0C",
      "\\x0E",
      "\\x1F"
    )

    for (pattern in suspicious_patterns) {
      if (
        stringr::str_detect(
          stringr::str_to_lower(text),
          stringr::fixed(pattern, ignore_case = TRUE)
        )
      ) {
        stop(paste("Suspicious content detected in", param_name))
      }
    }

    # Check for extremely long inputs (potential DoS)
    if (nchar(text) > 1000) {
      stop(paste(param_name, "exceeds maximum length of 1000 characters"))
    }

    invisible(NULL)
  }

  # Apply validation to text parameters
  validate_text_input(search_string, "search_string")
  validate_text_input(person, "person")
  validate_text_input(number, "number")

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
  ## include scope testing?
  checkmate::assert_class(x = eurovoc, classes = "character", null.ok = TRUE)

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
  checkmate::assert_subset(parl_group, choices_parl_group, empty.ok = T)

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
    INRNUM = number,
    PAD_INTERN = person_input,
    SW = keyword,
    EUROVOC = eurovoc,
    FRAK_CODE = parl_group
  ) |>
    purrr::compact() |> #keep only non-empty elements
    jsonlite::toJSON()

  res <- get_item_api_request(body_params, search_string)

  df_res <- purrr::map(res, \(x) {
    vec_headings <- x |>
      httr2::resp_body_json(simplifyVector = T) |>
      purrr::pluck("header", "label") |>
      janitor::make_clean_names()

    # extract the actual substantive data
    df_res <- x |>
      httr2::resp_body_json(simplifyVector = T) |>
      purrr::pluck("rows") |>
      # tibble::as_tibble(.name_repair = "unique")
      as.data.frame()

    if (nrow(df_res) == 0) {
      message("No results found for the provided search criteria.")
      return(NULL)
    }

    colnames(df_res) <- vec_headings

    return(df_res)
  }) |>
    purrr::compact() |> #remove NULL results
    purrr::list_rbind()

  # RETURN ECHO
  if (echo == TRUE) {
    print(body_params)
    # print url to results / transparency reasons / add search string parameter
    body_params_li <- jsonlite::fromJSON(body_params) |>
      c("search" = search_string)

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

    print(nrow(df_res))
  }

  # STOP IF NO HITS
  if (nrow(df_res) == 0) {
    message("No results found for the provided search criteria.")
    return(NULL)
  }

  # PARSE CONTENT TO MAKE MORE AMENABLE FOR FURTHER ANALYSIS

  cols_pars <- c("personen", "themen", "fraktionen", "sw", "eurovoc")
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
        dplyr::all_of(cols_pars),
        \(x) purrr::map(x, \(y) fn_parse_content(y))
      )
    )

  #RENAME  & SELECT RELEVANT COLUMNS
  ## rename
  renaming_map <- c(
    "gp_code" = "legis_period",
    "inr" = "item_number",
    "datum" = "date",
    "art" = "item_type",
    "betreff" = "subject",
    "nummer" = "item_number_type",
    "phasen_bis" = "stages_n",
    "status" = "stage",
    "doktyp" = "doc_type",
    "doktyp_lang" = "doc_type_long",
    "his_url" = "item_url",
    "personen" = "persons",
    "fraktionen" = "parl_group",
    "themen" = "topics",
    "nrbr" = "institution"
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
    "item_url",
    "doc_type",
    "doc_type_long",
    "subject",
    "topics",
    "sw",
    "eurovoc",
    "persons",
    "parl_group",
    "vhg",
    "vhg2"
  )

  df_res <- df_res |>
    dplyr::select(dplyr::any_of(col_select)) |>
    dplyr::relocate(dplyr::any_of(col_select)) |> #ensures ordering of columns
    dplyr::mutate(date = lubridate::dmy(date))

  # RETURN RESULT
  return(df_res)
}

#search_string not included by body, but via url_query
#' Make an API request to parliament.at to get an item
#'
#' This function sends a request to the parliament.at API to retrieve data about a specific item.
#'
#' @param body_params JSON string or raw object containing the parameters to be sent in the request body
#'
#' @return An httr2 response object containing the API response
#'
#' @details
#' The function makes a request to the parliament.at API endpoint for filtering data.
#' It sets various query parameters and headers to properly format the request.
#'
#' @keywords internal
#' @noRd
get_item_api_request <- function(body_params, search_string) {
  req <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/101"
  ) |>
    httr2::req_method("POST") |>
    httr2::req_url_query(
      js = "eval",
      page = "1",
      pagesize = "1000",
      search = search_string,
      sortrnr = "17",
      ascDesc = "DESC"
    ) |>
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      dnt = "1",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i",
      # referer = "https://www.parlament.gv.at/recherchieren/gegenstaende/index.html?FP_001NRBR=NR&FP_001DATUM_VON=2024-02-01T01%3A00%3A00.000Z&FP_001DATUM_VON=2024-02-29T01%3A00%3A00.000Z&FP_001VHG=ANTR&FP_001search=gesundheit",
      `sec-ch-ua` = '"Chromium";v="134", "Not:A-Brand";v="24", "Google Chrome";v="134"',
      `sec-ch-ua-mobile` = "?0",
      `sec-ch-ua-platform` = '"Windows"',
      `sec-fetch-dest` = "empty",
      `sec-fetch-mode` = "cors",
      `sec-fetch-site` = "same-origin",
      `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36",
      # cookie = "JSESSIONID=cIGy7LD1aNKtp0tEQJfecl33xhjjA0K2wyRxrLDv.appsrv04e; JSESSIONID=cIGy7LD1aNKtp0tEQJfecl33xhjjA0K2wyRxrLDv.appsrv04e; JSESSIONID=cIGy7LD1aNKtp0tEQJfecl33xhjjA0K2wyRxrLDv.master:green1"
    ) |>
    httr2::req_body_raw(body_params, "application/json") |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
    httr2::req_verbose(
      body_req = F,
      header_req = F,
      header_resp = F,
      body_resp = F,
      info = F
    )

  is_complete <- function(resp) {
    df_resp_current <- resp |>
      httr2::resp_body_json(simplifyVector = T)

    df_resp_current <- df_resp_current |>
      purrr::pluck("rows") |>
      # tibble::as_tibble(.name_repair = "unique")
      as.data.frame()

    nrow(df_resp_current) < 1000 #dependent on page size parameter
  }

  resp <- httr2::req_perform_iterative(
    req,
    next_req = httr2::iterate_with_offset(
      param_name = "page",
      start = 1,
      offset = 1,
      resp_complete = \(resp) is_complete(resp)
    ),
    max_reqs = Inf
  )

  # return result
  return(resp)
}


# my_item_url <- "https://www.parlament.gv.at/gegenstand/XXVIII/BI/24?selectedStage=105"
# get_item_details(my_item_url)

#' Prepare or normalize an item URL for the Austrian Parliament site
#'
#' Ensure that an item URL is a full URL pointing to the Austrian Parliament
#' website (https://www.parlament.gv.at/). If a relative path is provided
#' (e.g., starting with one or more leading slashes), it will be converted
#' into an absolute URL by prefixing it with the site base.
#'
#' @param item_url Character. A single URL or path to an item on the Austrian
#'   Parliament website. Can be an absolute URL already starting with
#'   "https://www.parlament.gv.at/" or a relative path (with or without
#'   leading slashes).
#'
#' @return Character. The normalized URL(s) pointing to the Austrian Parliament
#'   site. The same length as \code{item_url}.
#'
#' @details
#' This function performs a simple normalization:
#' - If \code{item_url} already starts with "https://www.parlament.gv.at/",
#'   it is returned unchanged.
#' - Otherwise, any leading slashes are removed and the site prefix is prepended.
#'
#' The implementation relies on functions from the \pkg{stringr} package.
#'
#' @examples
#' \dontrun{
#' get_item_details("https://www.parlament.gv.at/WWER/PARL")
#' get_item_details("/WWER/PARL")
#' }
#'
#' @noRd
#' @keywords internal
get_item_details <- function(item_url) {
  prefix <- "https://www.parlament.gv.at/"

  if (!stringr::str_starts(item_url, prefix)) {
    item_url <- item_url %>%
      stringr::str_replace("^/+", "") %>%
      stringr::str_c(prefix, .)
  }

  page <- rvest::read_html(item_url)

  # Assume your html code is in a variable named 'html_code'
  # Pipe to extract and parse the data
  data_list <- page |>
    rvest::html_elements("script") |>
    rvest::html_text2() |>
    (\(x) x[stringr::str_detect(x, "props:")])() |>
    stringr::str_extract("(?s)props:.*") |>
    stringr::str_remove("props:\\s*") |>
    stringr::str_remove("\\}\\);\\s*$") |>
    jsonlite::fromJSON() |>
    (\(x) x$data)()

  return(data_list$content)

  # return(
  #   data_list$content$phase %>%
  #     tidyr::unnest(stages) %>%
  #     dplyr::mutate(
  #       text = map_chr(text, \(x) {
  #         paste0("<html><body>", x, "</body></html>") |>
  #           rvest::read_html() |>
  #           rvest::html_text()
  #       })
  #     )
  # )
}
