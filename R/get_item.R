#' Search for Parliamentary Items
#' @encoding UTF-8
#' @description
#' `get_item` searches for items ('Verhandlungsgegenstände') that are or were subject to negotiations
#' in the Austrian National Council ('Nationalrat') or Federal Council ('Bundesrat'). This function
#' mirrors the search functionality offered on the Austrian Parliament's website. See [here](https://www.parlament.gv.at/recherchieren/gegenstaende/index.html).
#'
#' @param topic Character vector or `NULL`. Specifies the topic(s) to search for. See 'Details' for possible values. Default is `NULL`.
#' @param institution Character string. Either "Nationalrat" (National Council) or "Bundesrat" (Federal Council). Default is "Nationalrat".
#' @param legis_period Character vector or `NULL`. Specifies the legislative period(s) to search in. See 'Details' for possible values. Default is `NULL`.
#' @param date_start Character string. Start date for the search period in format "dd-mm-yyyy". Default is `NULL`.
#' @param date_end Character string. End date for the search period in format "dd-mm-yyyy". Default is `NULL`.
#' @param item Character vector or `NULL`. Specifies the type(s) of parliamentary item(s) to search for. See 'Details' for possible values. Default is `NULL`.
#' @param doc_type Character vector or `NULL`. Specifies the type of parliamentary item(s) to search for. See 'Details' for possible values. Default is `NULL`.
#' @param person Character string or `NULL`. Name of a person to search for (family name, optionally followed by first name). Default is `NULL`.
#' @param number Character string or `NULL`. Specific item number to search for. Default is `NULL`.
#' @param keyword Character vector or `NULL`. Keyword(s) to search for. Default is `NULL`.
#' @param eurovoc Character vector or `NULL`. EuroVoc term(s) to search for. Default is `NULL`.
#' @param parl_group Character vector or `NULL`. Parliamentary group(s) to search for. Default is `NULL`. Combine multiple groups in a vector, i.e. c("SPÖ", "ÖVP"). See 'Details.'
#' @param parl_group_names_standard Logical. If `TRUE`, the function expands and standardizes parliamentary group names. Default is `FALSE`. See 'Details.'
# TODO: add parl_group_names_standard explentation to details
#' @param echo Logical. If `TRUE`, the function prints the used search parametes and the url to the  pertaining search results on website of the Austrian Parlament.
#'
#' @details
#' ## Topic ('Thema')
#' Possible values for `topic` include:
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
#' * "Provisorische Nationalversammlung" (Provisional National Assembly, 1918-1919),
#' * and/or "Konstituierende Nationalversammlung" (Constituent National Assembly, 1919-1920).
#'
#' ## item (Gegenstand)
#' Possible values for `item` include:
#'
#' * "ASEU" (Aktuelle Europastunden, Current European Hours)
#' * "AS" (Aktuelle Stunden, Current Hours)
#' * "J_JPR_M" (Anfragen, Inquiries)
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
#' Possible values for `doc_type` if institution=="Nationalrat" ('National Council'):
#' * A: Selbständiger Antrag
#' * A(E): Selbständiger Entschließungsantrag
#' * AA: Abänderungsantrag
#' * AEA: Selbständiger Ausschuss-Entschließungsantrag
#' * AMIN: Selbständiger Antrag - Ministeranklage
#' * ARH2: Verlangen auf Gebarungsüberprüfung durch den Rechnungshof
#' * AVB: Antrag auf Volksbefragung
#' * BUA: Bericht und Antrag
#' * UEA: Unselbständiger Entschließungsantrag #BUG
#' * UEA: Misstrauensantrag
#' * URH2: Verlangen auf Gebarungsüberprüfung durch den Ständigen UA des Rechnungshofausschusses
#'
#' Possible values for `doc_type` if institution=="Bundesrat" ('Federal Council'):
#' *  AA-BR: Abänderungsanträge
#' *  A-BR: Selbständiger Antrag Bundesrat
#' *  A(E): Selbständiger Entschließungsantrag Bundesrat
#' *  AEA-BR: Selbständige Entschließungsanträge von Ausschüssen
#' *  UEA-BR: Unselbständige Anträge
#'
#' Possible values for `doc_type` if *item=="BNR"*:
#' * BNR: Beschluss
#' * BS: Sonstiger Beschluss
#' * BSE: Beschluss-EU
#' * BSESM: Beschluss-ESM
#' * BS-BR: Sonstiger Beschluss (only if instituition=="Bundesrat")
#'
#' ## EuroVoc
#' EuroVoc is an international thesaurus developed primarily for use within the EU. It enables searches
#' using standardized keywords across Europe. The EuroVoc search is supported for all negotiation items
#' from the 20th legislative period onwards.
#'
#' ## Parlamentary Group (Klub/Fraktion)
#' `parl_group` specifies the parliamentary group(s) to search for. The API of the Austrian Parliament accepts only specific abbreviations for each group:
#'
# #TODO complete abbreviations
#' - BZÖ    Bündnis Zkunft Österreich
#' - CSP    Crhistlichsoziale Partei
#' - DnP    Deutsche Nationalpartei
#' - F      Freiheitliche Partei Österreichs
#' - F-BZÖ  Freiheitliche Partei Österreichs - Bündnis Zukunft Österreich
#' - FPÖ    Freiheitliche Partei Österreichs
#' - GdP    Großdeutsche Volkspartei
#' - GRÜNE  Die Grünen - Die Grüne Alternative
#' - HB     Heimatblock
#' - JETZT  Jetzt - Liste Pilz
#' - Konvent
#' - KPÖ    Kommunistische Partei Österreichs
#' - KuL
#' - L
#' - LB
#' - LBd    Landbund für Österreich
#' - NEOS   NEOS - Das Neue Österreich
#' - NEOS-LIF NEOS - Liberales Forum
#' - NSDAP  Nationalsozialistische Deutsche Arbeiterpartei
#' - NWB    Nationaler Wirtschaftsblck und Landbund
#' - OF
#' - OK     Ohne Klub
#' - ÖVP    Österreichische Volkspartei
#' - PILZ   Liste Pilz
#' - SdP
#' - SPÖ    Sozialistische/Sozialdemokratische Partei Österreichs
#' - STRONACH Team Stronach
#' - VO     Wahlgemeinschafft Österreichische Volksopposition
#' - WdU    Wahlpartei der Unabhängigen (VdU, Verband der Unabhängigen)
#'
#' @return A data frame containing the search results. If no results are found, the function returns `NULL`
#' and displays a message.
#'
#' @note The API currently has a limitation of returning a maximum of 100,000 rows.
#'
#' @export
#'
#' @examples \dontrun{
#' get_item(topic="Europäische Union", legis_period=28)
#' }
get_item <- function(
  search_string = NULL,
  topic = NULL, #Themen - Themen
  institution = "Nationalrat", #Gremium - NRBR
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
  choices_topic = c(
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
    choices = c("Bundesrat", "Nationalrat"),
    empty.ok = FALSE
  )
  ##encode
  institution_input <- switch(
    institution,
    Nationalrat = "NR",
    Bundesrat = "BR"
  )

  #LEGIS PERIOD
  legis_period <- purrr::map_chr(
    legis_period,
    \(x) fn_check_legis_period_elements(x)
  )

  #DATE START; DATE END
  ## TODO allow for different date types such as "yyyy-mm-dd", "mm/dd/yyyy", and "dd-mm-yyyy"
  # Date validation
  if (!is.null(date_start)) {
    # checkmate::assert_character(date_start, len = 1, null.ok = TRUE)?
    checkmate::assert_true(
      stringr::str_detect(date_start, "^\\d{2}-\\d{2}-\\d{4}$"),
      .var.name = "date_start must be in format dd-mm-yyyy"
    )
    date_start = as.Date(date_start, format = "%d-%m-%Y")
    date_start <- format(
      as.POSIXct(date_start),
      format = "%Y-%m-%dT%H:%M:%S.000Z",
      tz = "CET"
    )
  }

  #date end
  if (!is.null(date_end)) {
    checkmate::assert_character(date_end, len = 1, null.ok = TRUE)
    checkmate::assert_true(
      stringr::str_detect(date_end, "^\\d{2}-\\d{2}-\\d{4}$"),
      .var.name = "date_end must be in format dd-mm-yyyy"
    )
    date_end = as.Date(date_end, format = "%d-%m-%Y")
    date_end <- format(
      as.POSIXct(date_end),
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

    if (institution == "Nationalrat" || is.null(institution)) {
      checkmate::assert_subset(
        x = doc_type,
        choices = choices_doc_type_antr_national_council,
        empty.ok = TRUE
      )
    } else if (institution == "Bundesrat") {
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

    if (institution == "Nationalrat" || is.null(institution)) {
      checkmate::assert_subset(
        x = doc_type,
        choices = choices_doc_type_bnr_national_council,
        empty.ok = TRUE
      )
    }

    if (institution == "Bundesrat") {
      checkmate::assert_subset(
        x = doc_type,
        choices = choices_doc_type_bnr_federal_council,
        empty.ok = FALSE
      )
    }
  }

  ##Gegenstand: schriftliche Anfragen
  ### Art der Anfrage
  if (!is.null(item) && any(item %in% "J_JPR_M")) {
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

  # NUMBER (number)
  ## pending

  # KEYWORD (Schlagwort)
  ## choices_item_keyword defined in sysdata.rda
  ## disadvantage of defining keyword scope in vector: new keywords may be included in the future
  ### solution: no check as alternative? OR function to scrape keywords and update vector
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
    #INRNUM=number,
    PAD_INTERN = person_input,
    SW = keyword,
    EUROVOC = eurovoc,
    FRAK_CODE = parl_group
  ) |>
    purrr::compact() |> #keep only non-empty elements
    jsonlite::toJSON()

  res <- get_item_api_request(body_params, search_string) #move actual httr2 request to a distinct function
  # print(class(res))
  # print(length(res))
  # length(res[[1]])
  # print(class(res[[1]][[1]]))

  df_res <- purrr::map(res, \(x) {
    vec_headings <- x |>
      httr2::resp_body_json(simplifyVector = T) |>
      purrr::pluck("header", "label") |>
      janitor::make_clean_names()

    # extract the actual substantive data
    df_res <- x |>
      httr2::resp_body_json(simplifyVector = T) |>
      purrr::pluck("rows") %>%
      as.data.frame()

    colnames(df_res) <- vec_headings

    return(df_res)
  }) %>%
    purrr::list_rbind()

  checkmate::check_data_frame(df_res, min.rows = 1)

  if (length(df_res) == 0) {
    message("No results found for the provided search criteria.")
    return(NULL)
  }

  # colnames(df_res) <- vec_headings

  if (echo == TRUE) {
    print(body_params)
    # print url to results / transparency reasons / add search string parameter
    body_params_li <- jsonlite::fromJSON(body_params) %>%
      c(., "search" = search_string)

    query_string <- purrr::imap(
      body_params_li,
      \(x, y) glue::glue("FP_001{URLencode(y)}={URLencode(x)}")
    ) %>%
      unlist() %>%
      unname() %>%
      paste0(collapse = "&")

    print(glue::glue(
      "https://www.parlament.gv.at/recherchieren/gegenstaende/index.html?{query_string}"
    ))

    print(nrow(df_res))
  }

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
#'
#' @noRd
get_item_api_request <- function(body_params, search_string) {
  #TODO page iteration needed

  req <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/101"
  ) |>
    httr2::req_method("POST") |>
    httr2::req_url_query(
      js = "eval",
      page = "1",
      pagesize = "1000",
      search = search_string,
      # search = "Gesundheit",
      sortrnr = "17",
      ascDesc = "DESC"
    ) |>
    # httr2::req_url_path_append(search = search_string) |>
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
      body_req = T,
      header_req = F,
      header_resp = F,
      body_resp = F,
      info = F
    )

  is_complete <- function(resp) {
    df_resp_current <- resp |>
      httr2::resp_body_json(simplifyVector = T)

    # print(paste("Next page:", df_resp_current$pages))

    df_resp_current <- df_resp_current %>%
      purrr::pluck("rows") %>%
      as.data.frame()

    print(nrow(df_resp_current))

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
