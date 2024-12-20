#' Search for Parliamentary Items
#'
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
#' @param person Character string or `NULL`. Name of a person to search for (family name, optionally followed by first name). Default is `NULL`.
#' @param number Character string or `NULL`. Specific item number to search for. Default is `NULL`.
#' @param keyword Character vector or `NULL`. Keyword(s) to search for. Default is `NULL`.
#' @param eurovoc Character vector or `NULL`. EuroVoc term(s) to search for. Default is `NULL`.
#' @param parl_group Character vector or `NULL`. Parliamentary group(s) to search for. Default is `NULL`.
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
#' If item=="ANTR".
#' Possible values for `doc_type` if institution=="Nationalrat" ('National Council')
#'
#' * A: Selbständiger Antrag
#' * A(E): Selbständiger Entschließungsantrag
#' * AA: Abänderungsantrag
#' * AEA: Selbständiger Ausschuss-Entschließungsantrag
#' * AMIN: Selbständiger Antrag - Ministeranklage
#' * ARH2: Verlangen auf Gebarungsüberprüfung durch den Rechnungshof
#' * AVB: Antrag auf Volksbefragung
#' * BUA: Bericht und Antrag
#' * UEA: Unselbständiger Entschließungsantrag
#' * UEA: Misstrauensantrag
#' * URH2: Verlangen auf Gebarungsüberprüfung durch den Ständigen UA des Rechnungshofausschusses
#'
#' Possible values for `doc_type` if institution=="Bundesrat" ('Federal Council')
#' *  AA-BR: Abänderungsanträge
#' *  A-BR: Selbständiger Antrag Bundesrat
#' *  A(E): Selbständiger Entschließungsantrag Bundesrat
#' *  AEA-BR: Selbständige Entschließungsanträge von Ausschüssen
#' *  UEA-BR: Unselbständige Anträge
#'
#' if item=="BNR"
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
#' @return A data frame containing the search results. If no results are found, the function returns `NULL`
#' and displays a message.
#'
#' @note The API currently has a limitation of returning a maximum of 100,000 rows.
#'
#' @export
#'
#' @examples
get_item <- function(
    topic=NULL, #Themen - Themen
    institution = "Nationalrat", #Gremium - NRBR
    legis_period=NULL, #Gesetzgebungsperiode - GB_Code
    date_start=NULL, #Datum_von - DATUM_VON
    date_end=NULL, #Datum_bis - DATUM_BIS
    item=NULL, #Gegenstand - VHG
    doc_type=NULL, #Art der Anfrage - DOKTYP
    person=NULL, #Person - PAD_intern (via person_input)
    number=NULL, #Nummer - INRUM PENDING
    keyword=NULL, #Schlagwort - SW
    eurovoc=NULL, #EuroVoc - EUROVOC
    parl_group=NULL #Klub/Fraktion - FRAK_CODE
) {

  #TOPIC
  choices_topic=c("Arbeit", "Außenpolitik", "Bildung", "Budget und Finanzen",
                  "Europäische Union", "Familie und Generationen", "Frauen und Gleichbehandlung",
                  "Gesundheit und Ernährung", "Information und Medien", "Inneres und Recht",
                  "Innovation, Technologie und Forschung", "Klima, Umwelt und Energie",
                  "Kultur", "Land- und Forstwirtschaft", "Landesverteidigung",
                  "Parlament und Demokratie", "Soziales", "Sport",
                  "Verkehr und Infrastruktur", "Wirtschaft")
 checkmate::assert_subset(topic, choices_topic, empty.ok=T)

  #INSTITUTION
  checkmate::assert_subset(institution, choices = c("Bundesrat", "Nationalrat"), empty.ok=FALSE)
  ##encode
  institution_input <- switch(
    institution,
    Nationalrat = "NR",
    Bundesrat = "BR"
  )

  #LEGIS PERIOD
  legis_period <- purrr::map_chr(legis_period, \(x) fn_check_legis_period_elements(x))

  #DATE START; DATE END
  ## todo allow for different date types such as "yyyy-mm-dd", "mm/dd/yyyy", and "dd-mm-yyyy"
  date_start=as.Date(date_start, format="%d-%m-%Y")
  date_start <- format(as.POSIXct(date_start), format = "%Y-%m-%dT%H:%M:%S.000Z", tz = "UTC")

  date_end=as.Date(date_end, format="%d-%m-%Y")
  date_end <- format(as.POSIXct(date_end), format = "%Y-%m-%dT%H:%M:%S.000Z", tz = "UTC")

  # ITEM / VHG / Gegenstand
  ## _todo_ what about multi-value choices
  ## checkmate::assert_subset does not show which element was not matched
  choices_item <- c("ASEU", "AS", "J_JPR_M", "ANTR", "US", "AUB", "AB_ABPR_ABM", "III", "BNR", "BI", "E", "EBR", "EU", "FS", "GO", "GABR", "GABR13", "IMM", "KOMM", "PET", "RGER", "RV", "RVS", "TRAU", "RVS15", "VOLKBG", "W")
  checkmate::assert_subset(x=item, choices = choices_item, empty.ok=TRUE)

  if (!is.null(item) && item=="ANTR") {
  ## depending on institution, different set of permissble values
  choices_doc_type_antr_national_council <- c("A", "A(E)", "AA", "AEA", "AMIN", "ARH2", "AVB", "BUA", "UEA", "URH2")
  choices_doc_type_antr_federal_council <- c("AA-BR", "A-BR", "A(E)", "AEA-BR", "UEA-BR")

  if (institution=="Nationalrat"||is.null(institution)) {
    checkmate::assert_subset(x=doc_type, choices = choices_doc_type_antr_national_council, empty.ok=TRUE)
  } else if (institution=="Bundesrat") {
      checkmate::assert_subset(x=doc_type, choices = choices_doc_type_antr_federal_council, empty.ok=FALSE)
    }
  }

  # DOC_TYPE (Art des Antrages)
  if (!is.null(doc_type) && is.null(item)) {
    stop("'doc_type' can be only specified in combination with 'item'")
  }

  if (!is.null(item) && item=="BNR") {
    choices_doc_type_bnr_national_council <- c("BNR", "BS", "BSE", "BSESM")
    choices_doc_type_bnr_federal_council <- c("BNR", "BS", "BSE", "BSESM")

    if (institution=="Nationalrat"||is.null(institution)){
      checkmate::assert_subset(x=doc_type, choices = choices_doc_type_bnr_national_council, empty.ok=TRUE)
    }

    if (institution=="Bundesrat"){
      checkmate::assert_subset(x=doc_type, choices = choices_doc_type_bnr_federal_council, empty.ok=FALSE)
    }
  }

  ##Gegenstand: schriftliche Anfragen
  ### Art der Anfrage
  if (!is.null(item) && item=="J_JPR_M") {
  }



  # PERSON
  ## requires pad_intern as input => auxiliary function searching pad_intern based on name needed
  ## accepts multiple values
  ## pad_intern needs to be character, not numeric
  if (!is.null(person)) {
  person_input <- get_persons(names=person, institution=institution) |> dplyr::pull(pad_intern) |> unique() |> as.character()
  } else {
    person_input <- NULL
  }

  # NUMBER (number)
  ## pending

  # KEYWORD (Schlagwort)
  ## choices_item_keyword defined in sysdata.rda
  ## disadvantage of defining keyword scope in vector: new keywords may be included in the future
  ### solution: no check as alternative? OR function to scrape keywords and update vector
  checkmate::assert_subset(x=keyword, choices = choices_item_keyword, empty.ok=TRUE)

  # EUROVOC
  ## include scope testing?
  checkmate::assert_class(x=eurovoc, classes="character", null.ok=TRUE)

  # PARL_GROUP (Klub/Fraktion)
  ## web: option "Klub/Fraktion" only visible after selecting legislative period; party options depend on chosen legislative period
  ## scope-checking: would require list of all parties
  ## documentation: list of all possible parities plus abbreviations;

  body_params <- list(
    THEMEN=topic,
    NRBR = institution_input,
    GP_CODE = legis_period,
    DATUM_VON=c(date_start, date_end),
    VHG=item,
    DOKTYP=doc_type,
    #INRNUM=number,
    PAD_INTERN=person_input,
    SW=keyword,
    EUROVOC=eurovoc,
    FRAK_CODE=parl_group
  ) |>
    purrr::compact() |>  #keep only non-empty elements
    jsonlite::toJSON()

  res <- httr2::request("https://www.parlament.gv.at/Filter/api/filter/data/101") |>
    httr2::req_url_query(
      js = "eval",
      # page = "1",
      # pagesize = "10",
      showAll=TRUE,
      sortrnr = "17",
      ascDesc = "DESC",
    ) |>
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      `content-type` = "application/json",
      cookie = "JSESSIONID=6SuuP4uN67Tzfy5YSSTebU_drcVJsXaonUCi2Ip2.appsrv05e; JSESSIONID=D5_fJZPk36M3KGFa5uvK-d3ze_hVKvOXxYHz-fZ2.appsrv04e; JSESSIONID=ed1JSdqiLIKgiFtm_wJhD78ib7UZWk3qfkL8Ayrl.appsrv04e; pddsgvo=j; _pk_id.1.26ca=7fce6f38a899aedc.1706609353.; _pk_ref.1.26ca=%5B%22%22%2C%22%22%2C1724424995%2C%22https%3A%2F%2Fwww.google.com%2F%22%5D; _pk_ses.1.26ca=1",
      dnt = "1",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i"
    ) |>
    httr2::req_body_raw(body_params, "application/json") |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
    httr2::req_verbose(body_req = T,
                       header_req = F,
                       header_resp = F) |>
    httr2::req_perform()

  vec_headings <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("header", "label") |>
    janitor::make_clean_names()

  # extract the actual substantive data
  df_res <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("rows")
  #print(class(df_res))

  checkmate::check_data_frame(df_res, min.rows=1)

  if (length(df_res)==0) {
    message("No results found for the provided search criteria.")
    return(NULL)
  }

  colnames(df_res) <- vec_headings

  print(nrow(df_res))

  return(df_res)

}
