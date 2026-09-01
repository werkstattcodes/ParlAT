#' @noRd
.empty_items_tibble <- function() {
  .parlat_empty_tibble(
    c(
      "legis_period", "institution", "date", "item_type", "item_number",
      "item_number_type", "stage", "item_url", "type_doc", "type_doc_long",
      "subject", "topics", "keywords", "eurovoc", "persons", "parl_group"
    ),
    date_cols = "date",
    list_cols = c("topics", "keywords", "eurovoc", "persons", "parl_group")
  )
}

#' @noRd
.align_get_items_export_rows <- function(rows, vec_headings, col_positions) {
  if (length(rows) == 0) {
    return(NULL)
  }

  df_res <- rows |>
    as.data.frame()

  if (ncol(df_res) <= length(vec_headings)) {
    # Compact: rows are already aligned to visible headers sequentially.
    # Some trailing headers may lack data (ncol < length(vec_headings)).
    colnames(df_res) <- vec_headings[seq_len(ncol(df_res))]
  } else {
    # Sparse: rows are keyed by rnr positions, possibly truncated at a
    # position lower than max(rnr). Select only positions within bounds.
    valid <- col_positions <= ncol(df_res)
    df_res <- df_res[, col_positions[valid], drop = FALSE]
    colnames(df_res) <- vec_headings[valid]
  }

  df_res
}

#' @noRd
.get_items_echo_request <- function(body_params, legis_period, n_results) {
  echo_body_params <- .parlat_echo_body_all_periods(
    body_params,
    legis_period,
    first_period = 5L
  )

  .parlat_echo_request(
    echo_body_params,
    url_base = "https://www.parlament.gv.at/recherchieren/gegenstaende",
    param_prefix = "FP_001",
    n_results = n_results
  )
}

.normalize_get_items_legis_period <- function(legis_period) {
  normalized <- purrr::map_chr(
    legis_period,
    \(x) fn_check_legis_period_elements(x)
  )

  if (length(normalized) == 0L) {
    return(normalized)
  }

  numeric_period <- suppressWarnings(as.integer(as.roman(normalized)))
  special_period <- normalized %in% c("ALLE", "KN", "PN")
  invalid <- !special_period & (is.na(numeric_period) | numeric_period < 5L)

  if (any(invalid)) {
    cli::cli_abort(
      paste(
        "Explicit numbered `legis_period` values are supported from the 5th",
        "legislative period onwards; `\"KN\"` and `\"PN\"` are also supported."
      ),
      arg = "legis_period"
    )
  }

  normalized
}

#' Get items under negotiation ('Verhandlungsgegenstände')
#' @encoding UTF-8
#' @description
#' `get_items` searches for items ('Verhandlungsgegenstände') that are or were subject to negotiations
#' in the Austrian National Council ('Nationalrat') or the Federal Council ('Bundesrat'). The function
#' mirrors the search functionality offered on the Austrian Parliament's website (see <a href="https://www.parlament.gv.at/recherchieren/gegenstaende" target="_blank">here</a>).
#'
#' @param topic (Thema) Character vector or `NULL`. Specifies the topic(s) to search for. See 'Details' for possible values. Default is `NULL`.
#' @param institution Character string. Either `"NR"` or `"Nationalrat"`
#'   (National Council), or `"BR"` or `"Bundesrat"` (Federal Council).
#'   Default is `NULL`, which returns both chambers. When combined with
#'   `person`, this filters the parliamentary items; it does not restrict the
#'   person's institutional affiliations.
#' @param legis_period Character or numeric vector, or `NULL`. Specifies the
#'   legislative period(s) to search in. If `NULL` (the default), no period
#'   restriction is applied. See 'Details' for possible values and the API
#'   result limit.
#' @param date_start Character string. Start date for the search period in format "dd-mm-yyyy", "dd.mm.yyyy", or "dd/mm/yyyy". Default is `NULL`.
#' @param date_end Character string. End date for the search period in format "dd-mm-yyyy", "dd.mm.yyyy", or "dd/mm/yyyy". Default is `NULL`.
#' @param item (Gegenstand) Character vector or `NULL`. Specifies the type(s) of parliamentary item(s) to search for. See 'Details' for possible values. Default is `NULL`.
#' @param type_doc (Art des Antrages / Art der Anfrage) Character vector or `NULL`. Specifies the document type for certain item types. Permissible values depend on both `item` and `institution`. See 'Details' for possible values. Default is `NULL`.
#' @param type_eu_submission (Art der EU-Vorlage) Character vector or `NULL`. Type(s) of EU submission to search for. Can only be specified when `item = "EU"`. See 'Details' for possible values. Default is `NULL`.
#' @param person Character string or `NULL`. Name of a person to search for
#'   (family name, optionally followed by first name). People are resolved
#'   across all institutional categories before other item filters are applied.
#'   Default is `NULL`.
#' @param keyword Character vector or `NULL`. Keyword(s) to search for. Default is `NULL`.
#' @param eurovoc Character vector or `NULL`. EuroVoc term(s) to search for. Default is `NULL`.
#' @param parl_group Character vector or `NULL`. Parliamentary group(s) to search for. Default is `NULL`. Combine multiple groups in a vector, i.e. c("SPÖ", "ÖVP"). See Details.
#' @param parl_group_names_standard Logical. If `TRUE`, the function expands and standardizes parliamentary group names. Default is `FALSE`. See Details.
#' @param echo Logical. If `TRUE`, the function prints the URL to the pertaining search results on the website of the Austrian Parliament and the number of results.
#'
#' @details
#' ## topic (Thema)
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
#' `legis_period` specifies the legislative period(s). It can be one or more of
#' the following values:
#' * number(s) or character(s) indicating the relevant period(s), i.e., "25",
#'   25, or "XXV";
#' * `"PN"` for the Provisional National Assembly; or
#' * `"KN"` for the Constituent National Assembly.
#'
#' Explicit numbered period filters are supported from the 5th legislative
#' period (V. GP, 1945) onwards; `"PN"` and `"KN"` are also supported. If
#' `legis_period = NULL`, no period restriction is applied. Broad searches can
#' still omit periods from the returned data when the API's 100,000-row export
#' limit is reached. When `echo = TRUE`, the website URL explicitly selects
#' every available period so it reproduces the unrestricted search instead of
#' using the website's current-period default.
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
#' Note: Querying for immunity matters ('Immunitätsangelegenheiten') is
#' currently only possible via the Parliament's website.
#'
#' ## type_doc (Art)
#' The `type_doc` parameter specifies different document types depending on the `item` parameter value.
#'
#' ### For `item = "ANTR"` (Motions, Anträge)
#' Possible values for `type_doc` depend on the institution.
#'
#' National Council (`institution = "NR"`):
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
#' Federal Council (`institution = "BR"`):
#' * "AA-BR" (Abänderungsanträge, Amendment Motions)
#' * "A-BR" (Selbständiger Antrag Bundesrat, Independent Motion Federal Council)
#' * "A(E)" (Selbständiger Entschließungsantrag Bundesrat, Independent Resolution Motion Federal Council)
#' * "AEA-BR" (Selbständiger Entschließungsantrag von Ausschüssen, Independent Committee Resolution Motion Federal Council)
#' * "UEA-BR" (Unselbständige Anträge)
#'
#' ### For `item = "J_JPR_M"` (Questions, Anfragen)
#' Possible values for `type_doc` depend on the institution.
#'
#' National Council (`institution = "NR"`):
#' * "J" (Mündliche Anfragen, Oral Questions)
#' * "JPR" (Schriftliche Anfragen an die Bundesregierung, Written Questions to Federal Government)
#' * "M" (Schriftliche Anfragen an Präsidenten des Bundesrates, Written Questions to Presidents of Federal Council)
#'
#' Federal Council (`institution = "BR"`):
#' * "M-BR" (Mündliche Anfragen, Oral Questions)
#' * "JMIN-BR" (Schriftliche Anfragen an die Bundesregierung, Written Questions to Federal Government)
#' * "JPRPR-BR" (Schriftliche Anfragen an Präsidenten des Bundesrates, Written Questions to Presidents of Federal Council)
#'
#' ### For `item = "BNR"` (Resolutions, Beschlüsse)
#' National Council (`institution = "NR"`):
#' * "BNR" (Beschluss, Resolution)
#' * "BS" (Sonstiger Beschluss, Other Resolution)
#' * "BSE" (Beschluss-EU, EU Resolution)
#' * "BSESM" (Beschluss-ESM, ESM Resolution)
#'
#' Federal Council (`institution = "BR"`):
#' * "BNR" (Beschluss, Resolution)
#' * "BS-BR" (Sonstiger Beschluss, Other Resolution)
#'
#' ## type_eu_submission (Art der EU-Vorlage)
#' The `type_eu_submission` parameter allows filtering for specific types of EU-related submissions.
#' Different codes are available depending on the institution.
#'
#' #### National Council Codes (institution = "NR")
#' These codes can only be used when `item = "EU"` AND `institution = "NR"`:
#'
#' * "BEU" (Berichte der Bundesregierung zu EU-Themen, Federal Government Reports on EU Topics)
#' * "EUBTG" (Berichte über Sitzungen von EU-Gremien, Reports on EU Committee Meetings)
#' * "JMINEU" (Dokumentenanfrage betr. EU an die Bundesregierung, Document Requests to Federal Government Regarding EU)
#' * "ABMINEU" (Dokumentenanfragebeantwortungen durch die Bundesregierung, Document Request Responses by Federal Government)
#' * "MTEU" (Mitteilungen des EU-Unterausschusses, Communications from EU Subcommittee)
#' * "EUD" (Politischer Dialog, Political Dialogue)
#' * "RGEU" (Regierungserklärungen zu EU-Themen, Government Statements on EU Topics)
#' * "SINF" (Schriftliche Informationen gem. § 6 EU-InfoG, Written Information According to § 6 EU Information Act)
#' * "S" (Stellungnahmen des Hauptausschusses, Opinions of the Main Committee)
#' * "SEU" (Stellungnahmen des UA des Hauptausschusses (EU), Opinions of the Main Committee Subcommittee (EU))
#' * "RVEU" (Vorlagen ü. Initiativen und Beschlüsse EU, Submissions on EU Initiatives and Resolutions)
#'
#' #### Federal Council Codes (institution = "BR")
#' These codes can only be used when `item = "EU"` AND `institution = "BR"`:
#'
#' * "AFEU-BR" (Ausschussfeststellungen, Committee Findings)
#' * "SBPL-BR" (Begründete Stellungnahmen des Bundesrates, Reasoned Opinions of the Federal Council)
#' * "SB-BR" (Begründete Stellungnahmen des EU-BR, Reasoned Opinions of the EU Federal Council). Note: Details on parlamentary procedures only available from 24th legis period onwards, see <a href="https://www.parlament.gv.at/recherchieren/open-data/daten-und-lizenz/begruendete-stellungnahmen-eu-ausschuss-br/index.html" target="_blank">here</a>
#' * "BEU-BR" (Berichte der Bundesregierung zu EU-Themen, Federal Government Reports on EU Topics)
#' * "MEU-BR" (EU-Vorblätter und Dossiers BR, EU Cover Sheets and Dossiers BR)
#' * "ADEU-BR" (IV der Beilagen, Addendum/Supplement IV)
#' * "MT-BR" (Mitteilungen des EU-BR, Communications from EU Federal Council). Note: Details on parlamentary procedures only available from 24th legis period onwards, see <a href="https://www.parlament.gv.at/recherchieren/open-data/daten-und-lizenz/stellungnahmen-eu-ausschuss-br/index.html" target="_blank">here</a>
#' * "EUD-BR" (Politischer Dialog BR, Political Dialogue BR)
#' * "SINF-BR" (Schriftliche Informationen BR gem. § 6 EU-InfoG BR, Written Information Federal Council According to § 6 EU Information Act)
#' * "SLT-BR" (Stellungnahmen der Landtage, Opinions of State Parliaments)
#' * "S-BR" (Stellungnahmen des EU-Ausschusses, Opinions of the EU Committee). Note: Details on parlamentary procedures only available from 24th legis period onwards, see <a href="https://www.parlament.gv.at/recherchieren/open-data/daten-und-lizenz/stellungnahmen-eu-ausschuss-br/index.html" target="_blank">here</a>
#'
#' ## eurovoc
#' EuroVoc is an international thesaurus developed primarily for use within the EU. It enables searches
#' using standardized keywords across Europe. The EuroVoc search is supported for all negotiation items
#' from the 20th legislative period onwards.
#'
#' ## keyword (Schlagwort)
#' In total, there are several hundred different keywords.
#' Here only a selection of possible values for `keyword`:
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
#' ## parl_group (Parliamentary Group, Klub/Fraktion)
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
#' ## Combining person and institution filters
#' When `person` and `institution` are supplied together, the person lookup is
#' performed across all institutional categories. The `institution` value then
#' filters the parliamentary items by chamber. The full German chamber names
#' and their abbreviations are equivalent. For example, a federal minister can
#' be associated with National Council items even if the person is not
#' categorized as a National Council member.
#'
#' @return
#' A tibble (data.frame) with one row per parliamentary item matching the search.
#' The returned object contains the most commonly used columns (some are optional
#' or returned as list-columns for multi-valued fields):
#'
#' -` legis_period` (character): legislative period (e.g. "XXVIII").
#' - `institution` (character): chamber code, typically "NR" (Nationalrat) or "BR" (Bundesrat).
#' - `date` (Date): date of the item (class Date).
#' - `item_type` (character): short item type code.
#' - `item_number` (character): numeric identifier of the item (stored as character).
#' - `item_number_type` (character): combined number/type string (e.g. "46/M").
#' - `stage` (character/integer): current stage code of the item.
#' - `item_url` (character): normalized URL pointing to the item on parlament.gv.at.
#' - `type_doc` (character): short document type code (when applicable).
#' - `type_doc_long` (character): human readable document type (when available).
#' - `subject` (character): subject / title of the item.
#' - `topics` (list): list-column; each element is a character vector of topics.
#' - `keywords` (list): list-column of keywords (Schlagwort).
#' - `eurovoc` (list): list-column of EuroVoc terms.
#' - `persons` (list): list-column of person identifiers (pad_intern) related to the item.
#' - `parl_group` (list): list-column of parliamentary group codes associated with the item.
#'
#' @note
#' ## Free Text Search
#' Due to limitations of the underlying API, this function does not currently support a general free text search across all fields. Search functionality is restricted to the specific parameters provided (e.g., `keyword`, `topic`, `person`).
#'
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
#' all_results <- periods %>%
#'   map(\(period) get_items(legis_period = period, echo = FALSE)) %>%
#'   list_rbind()
#' ```
#'
#' ## Data Availability
#' Numbered legislative periods are available from the 5th period (V. GP,
#' 1945) onwards. Historical material is also available for the Provisional
#' National Assembly (`"PN"`) and Constituent National Assembly (`"KN"`).
#' Coverage and completeness vary by document type.
#'
#' @seealso
#' * [get_persons()] for searching person identifiers used in the `person` parameter
#' * [get_legis_periods()] for retrieving available legislative periods
#' * [get_committees()] for committee information
#' * [get_plenary_meetings()] for plenary meeting data
#'
#' @export
#'
#' @examples \donttest{
#' # Search for EU-related items in the 28th legislative period
#' result <- get_items(topic = "Europäische Union", legis_period = 28)
#' dplyr::glimpse(result)
#'
#' # Search for motions (Antraege) in National Council from February 2024
#' result <- get_items(
#'   institution = "NR",
#'   item = "ANTR",
#'   date_start = "01-02-2024",
#'   date_end = "29-02-2024"
#' )
#' dplyr::glimpse(result)
#'
#' # Search for items by specific parliamentary groups
#' result <- get_items(
#'   parl_group = c("SPÖ", "ÖVP"),
#'   legis_period = 27,
#'   topic = "Bildung"
#' )
#' dplyr::glimpse(result)
#'
#' # Search for written questions with keyword
#' result <- get_items(
#'   item = "J_JPR_M",
#'   keyword = "Flüchtlinge",
#'   institution = "NR"
#' )
#' dplyr::glimpse(result)
#'
#' # Search by person (minister or MP)
#' result <- get_items(
#'   person = "Kurz Sebastian",
#'   institution = "Nationalrat", # "NR" is equivalent
#'   legis_period = 27
#' )
#' dplyr::glimpse(result)
#'
#' # Search historical items from the national assemblies of 1918-1920
#' historical_items <- get_items(
#'   institution = "NR",
#'   legis_period = c("PN", "KN")
#' )
#' dplyr::glimpse(historical_items)
#'
#' # Combine multiple search criteria
#' result <- get_items(
#'   topic = "Gesundheit und Ernährung",
#'   item = "RV",  # Government bills
#'   legis_period = 27,
#'   institution = "NR"
#' )
#' dplyr::glimpse(result)
#'
#' # Get all positions of the Hauptausschuss on EU related matters
#' result <- get_items(
#'   legis_period = 27,
#'   item = "EU",
#'   type_eu_submission = "S",
#'   institution = "NR"
#' )
#' dplyr::glimpse(result)
#'
#' # Get all statements of the sub-committee on EU affairs
#' # (EU-Unterausschuss) during the 27th legislative period.
#' result <- get_items(
#'   item = "EU",
#'   type_eu_submission = "MTEU",
#'   legis_period = 27,
#'   institution = "NR"
#' )
#' dplyr::glimpse(result)
#'
#' }
get_items <- function(
  topic = NULL, #Themen - Themen
  institution = NULL, #Gremium - NRBR
  legis_period = NULL, #Gesetzgebungsperiode - GB_Code
  date_start = NULL, #Datum_von - DATUM_VON
  date_end = NULL, #Datum_bis - DATUM_BIS
  item = NULL, #Gegenstand - VHG
  type_doc = NULL, #Art der Anfrage - DOKTYP
  type_eu_submission = NULL, #Art der EU-Vorlage - VHG2
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
    "Au\u00dfenpolitik",
    "Bildung",
    "Budget und Finanzen",
    "Europ\u00e4ische Union",
    "Familie und Generationen",
    "Frauen und Gleichbehandlung",
    "Gesundheit und Ern\u00e4hrung",
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
    choices = c("BR", "Bundesrat", "NR", "Nationalrat"),
    empty.ok = TRUE
  )
  if (!is.null(institution)) {
    institution <- dplyr::recode(
      institution,
      "Bundesrat" = "BR",
      "Nationalrat" = "NR"
    )
  }
  institution_input <- institution

  #LEGIS PERIOD
  legis_period <- .normalize_get_items_legis_period(legis_period)

  #DATE START; DATE END
  # Date validation using lubridate for flexible input formats
  date_start_parsed <- NULL
  date_end_parsed <- NULL

  if (!is.null(date_start)) {
    checkmate::assert_character(date_start, len = 1, null.ok = TRUE)
    date_start_parsed <- lubridate::dmy(date_start, quiet = TRUE)
    if (is.na(date_start_parsed)) {
      cli::cli_abort(
        "date_start must be a valid date in format dd-mm-yyyy, dd.mm.yyyy, or dd/mm/yyyy"
      )
    }
    date_start <- paste0(
      format(date_start_parsed, "%Y-%m-%d"),
      "T00:00:00.000Z"
    )
  }

  #date end
  if (!is.null(date_end)) {
    checkmate::assert_character(date_end, len = 1, null.ok = TRUE)
    date_end_parsed <- lubridate::dmy(date_end, quiet = TRUE)
    if (is.na(date_end_parsed)) {
      cli::cli_abort(
        "date_end must be a valid date in format dd-mm-yyyy, dd.mm.yyyy, or dd/mm/yyyy"
      )
    }
    date_end <- paste0(format(date_end_parsed, "%Y-%m-%d"), "T00:00:00.000Z")
  }

  # Validate date range
  if (!is.null(date_start_parsed) && !is.null(date_end_parsed)) {
    if (date_start_parsed > date_end_parsed) {
      cli::cli_abort("date_start must be before or equal to date_end")
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

  # type_doc (Art des Antrages / Art der Anfrage)
  if (!is.null(type_doc) && is.null(item)) {
    cli::cli_abort("'type_doc' can be only specified in combination with 'item'")
  }

  # Validation for item = "ANTR" (Motions)
  if (!is.null(item) && any(item %in% "ANTR")) {
    ## depending on institution, different set of permissble values
    choices_type_doc_antr_national_council <- c(
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
    choices_type_doc_antr_federal_council <- c(
      "AA-BR",
      "A-BR",
      "A(E)",
      "AEA-BR",
      "UEA-BR"
    )

    if (institution == "NR" || is.null(institution)) {
      checkmate::assert_subset(
        x = type_doc,
        choices = choices_type_doc_antr_national_council,
        empty.ok = TRUE
      )
    } else if (institution == "BR") {
      checkmate::assert_subset(
        x = type_doc,
        choices = choices_type_doc_antr_federal_council,
        empty.ok = FALSE
      )
    }
  }

  # Validation for item = "J_JPR_M" (Written Questions)
  if (!is.null(item) && any(item %in% "J_JPR_M")) {
    choices_type_doc_j_jpr_m_national_council <- c(
      "J",
      "JPR",
      "M"
    )
    choices_type_doc_j_jpr_m_federal_council <- c(
      "M-BR",
      "JMIN-BR",
      "JPRPR-BR"
    )

    if (institution == "NR" || is.null(institution)) {
      checkmate::assert_subset(
        x = type_doc,
        choices = choices_type_doc_j_jpr_m_national_council,
        empty.ok = TRUE
      )
    } else if (institution == "BR") {
      checkmate::assert_subset(
        x = type_doc,
        choices = choices_type_doc_j_jpr_m_federal_council,
        empty.ok = FALSE
      )
    }
  }

  # Validation for item = "BNR" (Resolutions)
  if (!is.null(item) && any(item %in% "BNR")) {
    choices_type_doc_bnr_national_council <- c("BNR", "BS", "BSE", "BSESM")
    choices_type_doc_bnr_federal_council <- c("BNR", "BS-BR")

    if (institution == "NR" || is.null(institution)) {
      checkmate::assert_subset(
        x = type_doc,
        choices = choices_type_doc_bnr_national_council,
        empty.ok = TRUE
      )
    }

    if (institution == "BR" && !is.null(institution)) {
      checkmate::assert_subset(
        x = type_doc,
        choices = choices_type_doc_bnr_federal_council,
        empty.ok = FALSE
      )
    }
  }

  # TYPE_EU_SUBMISSION (Art der EU-Vorlage)
  # Can only be specified when item = "EU"
  if (!is.null(type_eu_submission) && (is.null(item) || !any(item %in% "EU"))) {
    cli::cli_abort("'type_eu_submission' can only be specified when item = 'EU'")
  }

  if (!is.null(type_eu_submission)) {
    # Define NR-specific codes
    choices_type_eu_submission_nr <- c(
      "BEU",
      "EUBTG",
      "JMINEU",
      "ABMINEU",
      "MTEU",
      "EUD",
      "RGEU",
      "SINF",
      "S",
      "SEU",
      "RVEU"
    )

    # Define BR-specific codes
    choices_type_eu_submission_br <- c(
      "AFEU-BR",
      "SBPL-BR",
      "SB-BR",
      "BEU-BR",
      "MEU-BR",
      "ADEU-BR",
      "MT-BR",
      "EUD-BR",
      "SINF-BR",
      "SLT-BR",
      "S-BR"
    )

    # All valid codes (NR + BR)
    choices_type_eu_submission <- c(
      choices_type_eu_submission_nr,
      choices_type_eu_submission_br
    )

    # Validate against all valid codes
    checkmate::assert_subset(
      x = type_eu_submission,
      choices = choices_type_eu_submission,
      empty.ok = TRUE
    )

    # Check if NR-specific codes are used without institution="NR"
    if (any(type_eu_submission %in% choices_type_eu_submission_nr)) {
      if (is.null(institution) || institution != "NR") {
        cli::cli_abort(
          "National Council type_eu_submission codes can only be used when institution = 'NR'"
        )
      }
    }

    # Check if BR-specific codes are used without institution="BR"
    if (any(type_eu_submission %in% choices_type_eu_submission_br)) {
      if (is.null(institution) || institution != "BR") {
        cli::cli_abort(
          "Federal Council type_eu_submission codes can only be used when institution = 'BR'"
        )
      }
    }
  }

  # PERSON
  ## requires pad_intern as input => auxiliary function searching pad_intern based on name needed
  ## accepts multiple values
  ## pad_intern needs to be character, not numeric
  if (!is.null(person)) {
    person_matches <- suppressMessages(get_persons(names = person))
    person_input <- person_matches |>
      dplyr::pull("pad_intern") |>
      unique() |>
      as.character()

    if (length(person_input) == 0L) {
      cli::cli_inform(
        "No person found for the given search criteria; no items were requested."
      )
      return(.empty_items_tibble())
    }
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
    "Abweichende pers\u00f6nliche Stellungnahmen",
    "Aktuelle Europastunden",
    "Aktuelle Stunden",
    "Anfragebeantwortungen, Besprechung von",
    "Anfragen, Dringliche",
    "Antr\u00e4ge, Dringliche",
    "Apotheken",
    "Arbeiterkammern",
    "Arbeitsinspektion",
    "Arbeitsmarkt",
    "Arbeitsrecht I. \u00f6sterreichisches",
    "Arbeitsrecht II. internationales",
    "Archive",
    "Atomenergie",
    "Au\u00dfenpolitik",
    "Ausl\u00e4nder",
    "Aussch\u00fcsse des Nationalrates",
    "Bauwesen",
    "Bergbau",
    "Betriebsr\u00e4te",
    "Bibliotheken",
    "Bildungswesen I. Pflichtschulen",
    "Bildungswesen II. Mittlere Schulen",
    "Bildungswesen III. H\u00f6here Schulen",
    "Bildungswesen IV. Universit\u00e4ten und Hochschulen",
    "Bildungswesen V. Minderheitenschulwesen",
    "Bildungswesen VI. Sch\u00fclerbeihilfen und Studienf\u00f6rderung",
    "Bildungswesen VII. Erwachsenenbildung",
    "Bildungswesen VIII. Sonstiges",
    "Bundesforste",
    "Bundesgesetzblatt",
    "Bundeshaushalt I. Bundesfinanzgesetze",
    "Bundeshaushalt II. Budget\u00fcberschreitungen",
    "Bundeshaushalt III. Sonstiges",
    "Bundesl\u00e4nder",
    "Bundespr\u00e4sident:in",
    "Bundesregierung I. Ernennungen, Enthebungen und Ableben",
    "Bundesregierung II. Regierungserkl\u00e4rungen",
    "Bundesregierung III. Sonstiges",
    "Bundesverfassung",
    "Bundesverm\u00f6gen",
    "Bundeswappen",
    "B\u00fcrgerinitiativen",
    "Debattenantr\u00e4ge bzw. -verlangen",
    "Ehrenzeichen und Medaillen",
    "Einspr\u00fcche des Bundesrates",
    "Einspruchsfrist des Bundesrates",
    "Elektrizit\u00e4t",
    "Elementarp\u00e4dagogik",
    "Energiewirtschaft",
    "Entwicklungszusammenarbeit",
    "Erkl\u00e4rungen Pr\u00e4sident/Pr\u00e4sidentin",
    "Erste Lesungen",
    "Erste Lesungen, Antr\u00e4ge/Verlangen",
    "Europ\u00e4ische Integration",
    "Europarat",
    "Familienlastenausgleich",
    "Familienpolitik",
    "Film",
    "Finanzausgleich",
    "Fl\u00fcchtlinge",
    "Fragestunden",
    "Frauen und Gleichbehandlung",
    "Fremdenverkehr",
    "Fristsetzungen",
    "Gesch\u00e4ftsordnung des Nationalrates",
    "Gesundheit",
    "Gl\u00fccksspiel",
    "Grenzen",
    "Handel, Gewerbe und Industrie",
    "II. Einberufung und Beendigung der Tagungen",
    "III. Pr\u00e4sidenten, Schriftf\u00fchrer und Ordner",
    "III. Sonstiges",
    "Immunit\u00e4t",
    "Information und Informationsverarbeitung",
    "Internet",
    "IV. Ansprachen Pr\u00e4sident/Pr\u00e4sidentin",
    "Jagd und Fischerei",
    "Jugend",
    "Kommuniques",
    "Kreditwesen",
    "Kunst und Kultur",
    "Land- und Forstwirtschaft",
    "Landesverteidigung",
    "Lebensmittel",
    "L\u00f6hne und Geh\u00e4lter",
    "Ma\u00dfe und Gewichte",
    "Menschen mit Behinderung",
    "Menschenrechte",
    "Minderheitsberichte",
    "Misstrauensantr\u00e4ge",
    "Museen",
    "Nationalfeiertag",
    "Neutralit\u00e4t",
    "\u00d6ffentliche Unternehmen",
    "\u00d6ffentlicher Dienst",
    "Opferf\u00fcrsorge und Opferschutz",
    "Ordnungsrufe",
    "P\u00e4sse und Ausweise",
    "Pensionssystem",
    "Personenstandsrecht",
    "Petitionen",
    "Pflege und Betreuung",
    "Politische Parteien",
    "Postwesen",
    "Preise",
    "Presse",
    "Pr\u00fcfungsauftr\u00e4ge Rechnungshof",
    "Pr\u00fcfungsauftr\u00e4ge Rechnungshofausschuss",
    "Raumordnung",
    "Rechnungshof",
    "Rechtsanw\u00e4lte und Notare",
    "Rechtsbereinigung",
    "Rechtspflege",
    "Redezeitbeschr\u00e4nkungen",
    "Religion",
    "R\u00fcckverweisungen",
    "Rundfunk und Fernsehen",
    "Sicherheitswesen",
    "Sitzungsunterbrechung",
    "Sondersitzungen",
    "Sonstige Gesch\u00e4ftsordnungsangelegenheiten",
    "Sozialpolitik",
    "Sozialversicherung I. Allgemeine Sozialversicherung",
    "Sozialversicherung II. Gewerbliche Sozialversicherung",
    "Sozialversicherung III. Landwirtschaftliche Sozialversicherung",
    "Sozialversicherung IV. Kriegsopferversorgung",
    "Sozialversicherung V. Arbeitslosenversicherung",
    "Sozialversicherung VI. Sonstiges",
    "Sport",
    "Staatsb\u00fcrger:in",
    "Staatsvertr\u00e4ge",
    "Statistik",
    "Steuern und Geb\u00fchren",
    "Strafrecht",
    "Stra\u00dfen- und Br\u00fcckenbau",
    "S\u00fcdtirol",
    "Tabak",
    "Tagesordnung",
    "Telekommunikation",
    "Theater",
    "Trauerkundgebungen",
    "Umweltschutz",
    "Untersuchungsaussch\u00fcsse",
    "Unvereinbarkeit",
    "V. Sonstiges",
    "Vereinbarungen",
    "Vereins- und Versammlungsrecht",
    "Vereinte Nationen",
    "Verfassungs- und Verwaltungsgerichtsbarkeit",
    "Verkehr I. Stra\u00dfenverkehr",
    "Verkehr II. Schienenverkehr",
    "Verkehr III. Luftfahrt",
    "Verkehr IV. Schifffahrt",
    "Verkehr V. Sonstiges",
    "Verk\u00fcrztes Verfahren",
    "Vermessung",
    "Verm\u00f6genssicherung",
    "Vertragsversicherungen",
    "Verwaltungsorganisation",
    "Verwaltungsverfahren",
    "Veterin\u00e4rwesen und Tierschutz",
    "V\u00f6lkerrecht",
    "V\u00f6lkerrechtliche Vertretungen",
    "Volksabstimmung",
    "Volksanwaltschaft",
    "Volksbefragung",
    "Volksbegehren",
    "Volksgruppen",
    "Volksz\u00e4hlung",
    "Wahlen",
    "W\u00e4hrung",
    "Wasserbauten",
    "Wasserrecht",
    "Wasserwirtschaft",
    "Weinwirtschaft",
    "Wirtschaftspolitik",
    "Wirtschaftstreuh\u00e4nder:in",
    "Wissenschaft und Forschung",
    "Wohnungswesen",
    "Wortentziehung",
    "Wortmeldungen zur Gesch\u00e4ftsbehandlung",
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
    "BZ\u00d6",
    "CSP",
    "DnP",
    "F",
    "F-BZ\u00d6",
    "FP\u00d6",
    "GdP",
    "GR\u00dcNE",
    "HB",
    "JETZT",
    "Konvent",
    "KP\u00d6",
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
    "\u00d6VP",
    "PILZ",
    "SdP",
    "SP\u00d6",
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
    VHG2 = type_eu_submission,
    DOKTYP = type_doc,
    PAD_INTERN = person_input,
    SW = keyword,
    EUROVOC = eurovoc,
    FRAK_CODE = parl_group
  ) %>%
    purrr::compact() %>% #keep only non-empty elements
    jsonlite::toJSON()

  if (echo) cli::cli_alert_info("Fetching items from API...")

  req <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/101"
  ) %>%
    httr2::req_method("POST") %>%
    httr2::req_url_query(
      js = "eval",
      showAll = TRUE,
      # page = "1",
      # pagesize = "449",
      export = TRUE
    ) %>%
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
    ) %>%
    httr2::req_body_raw(body_params, "application/json") %>%
    # httr2::req_body_json(body_params) %>%
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
    httr2::req_retry(max_tries = 3)
  resp <- httr2::req_perform(req)
  resp_json <- httr2::resp_body_json(resp, simplifyVector = TRUE)
  vec_headings <- resp_json %>%
    purrr::pluck("header", "label") %>%
    stringr::str_to_snake() %>%
    make.unique(sep = "_")

  # rnr maps each header to its 1-based column position in the data rows
  col_positions <- purrr::pluck(resp_json, "header", "rnr")

  rows <- purrr::pluck(resp_json, "rows")

  # The API can return either sparse export rows keyed by `rnr` or compact rows
  # already aligned to the visible headers.
  df_res <- .align_get_items_export_rows(rows, vec_headings, col_positions)

  # STOP IF NO HITS
  if (is.null(df_res) || nrow(df_res) == 0) {
    cli::cli_inform("No results found for the provided search criteria.")
    return(.empty_items_tibble())
  }

  # WARN IF RESULT LIMIT REACHED
  if (nrow(df_res) >= 100000) {
    cli::cli_warn(c(
      "Query returned 100,000 rows (API maximum). Results are likely to be incomplete.",
      "i" = "Refine search criteria or split into multiple requests.",
      "i" = "See 'API Result Limits' in ?get_items for details."
    ))
  }

  # PARSE CONTENT TO MAKE MORE AMENABLE FOR FURTHER ANALYSIS

  cols_pars <- c(
    "personen_id",
    "personen",       # alternative column name used by some query types (e.g. J_JPR_M)
    "thema",
    "themen",         # alternative column name used by some query types (e.g. RV, J_JPR_M)
    "klub_fraktion",
    "fraktionen",     # alternative column name used by some query types (e.g. J_JPR_M)
    "schlagwort",
    "sw",             # alternative column name used by some query types (e.g. RV, J_JPR_M)
    "euro_voc"
  )
  fn_parse_content_vec <- function(x) {
    x |>
      stringr::str_remove_all("\\[|\\]|\"") |>
      stringr::str_split(",") |>
      purrr::map(stringr::str_trim)
  }

  df_res <- df_res |>
    dplyr::mutate(
      dplyr::across(
        dplyr::any_of(cols_pars),
        fn_parse_content_vec
      )
    )

  #RENAME  & SELECT RELEVANT COLUMNS
  ## rename
  renaming_map <- c(
    "gp" = "legis_period",
    "gp_code" = "legis_period",   # alternative column name used by some query types (e.g. J_JPR_M)
    "inr" = "item_number",
    "datum" = "date",
    "ityp" = "item_type",
    "betreff" = "subject",
    "nummer" = "item_number_type",
    "phasen_bis" = "stages_n", #no longer returned by API?
    "status" = "stage",
    "doktyp" = "type_doc",
    "doktyp_lang" = "type_doc_long",
    "his_url" = "item_url",       # legacy column name (API used this before renaming)
    "euro_voc" = "eurovoc",
    "geschichtsseite_url" = "item_url",
    "personen_id" = "persons",
    "personen" = "persons",       # alternative column name used by some query types (e.g. J_JPR_M)
    "fraktionen" = "parl_group",  # alternative column name used by some query types (e.g. J_JPR_M)
    "klub_fraktion" = "parl_group",
    "schlagwort" = "keywords",
    "sw" = "keywords",            # alternative column name used by some query types (e.g. RV, J_JPR_M)
    "thema" = "topics",
    "themen" = "topics",          # alternative column name used by some query types (e.g. RV, J_JPR_M)
    "nrbr" = "institution",       # alternative column name used by some query types (e.g. RV, J_JPR_M)
    "gremium" = "institution"
  )

  df_res <- .parlat_apply_renaming(df_res, renaming_map)

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
    "type_doc",
    "type_doc_long",
    "subject",
    "topics",
    "keywords",
    "eurovoc",
    "persons",
    "parl_group"
  )

  df_res <- df_res %>%
    dplyr::select(dplyr::any_of(col_select)) %>%
    dplyr::relocate(dplyr::any_of(col_select)) %>% #ensures ordering of columns
    dplyr::mutate(date = lubridate::dmy(.data$date)) |>
    dplyr::arrange(dplyr::desc(.data$date))

  if ("item_url" %in% names(df_res)) {
    df_res <- df_res |>
      dplyr::mutate(
        item_url = purrr::map_chr(
          .data$item_url,
          \(url) {
            if (is.na(url)) {
              return(NA_character_)
            }
            .normalise_item_url(url)
          }
        )
      )
  }

  # CHECK FOR DUPLICATES
  # Check for completely duplicate rows across all columns
  n_total_rows <- nrow(df_res)
  n_distinct_rows <- df_res %>%
    dplyr::distinct() %>%
    nrow()

  if (n_total_rows > n_distinct_rows) {
    n_duplicates <- n_total_rows - n_distinct_rows

    cli::cli_warn(
      "The result contains {n_duplicates} duplicate row{?s}. Total rows: {n_total_rows}, unique rows: {n_distinct_rows}. This may indicate data quality issues."
    )
  }

  # RETURN RESULT
  if (echo) {
    cli::cli_alert_success("Fetched {nrow(df_res)} item{?s}")
    .get_items_echo_request(
      body_params,
      legis_period = legis_period,
      n_results = nrow(df_res)
    )
  }

  return(df_res)
}
