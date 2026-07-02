#' Get Participation Data from Austrian Parliament
#'
#' This function retrieves participation data from the Austrian Parliament's API based on various filter criteria.
#' For the pertaining website by the Austrian Parliament see <a href="https://www.parlament.gv.at/beteiligen/stellung-nehmen/?FP_143SNFLAG=J" target="_blank">here</a>.<br>
#' Once a legislative initiative, citizens' initiative, or petition has been submitted to Parliament, pertaining statements
#' expressing the author's opinion regarding the pending issue can be submitted.
#' This allows the author to express his/her opinion and participate in the parliamentary process.
#' For ministerial drafts, statements can be submitted during the pre-parliamentary process.
#' Furthermore, statements of other authors can be supported.
#'
#' @param topic (*Themen*) Character vector. Optional. Specifies the topic(s) of interest. See details for valid values.
#' @param legis_period (*Gesetzgebungsperiode*) Character vector. Optional. Specifies the legislative period(s).
#' @param active (*Aktuelle Beteiligung*) Character. Optional. If "J", only includes current participations.
#' @param item (*Gegenstand*) Character vector. Optional. Specifies the type of review. See details for valid values.
#' @param initiative_type (*Art der Gesetzesinitiative*) Optional character vector. Only if item="RGES" (Gesetzesinitiativen/Legislative Initiatives). Specifies the type of legislative initiative. See details for valid values.
#' @param statement_type (*Art der Stellungnahme*) Optional character vector. Only if item="SN" (Stellungnahmen/Statements). Specifies the type of statement. See details for valid values.
#' @return A tibble containing the participation data with the following columns:
#' * `legis_period`: Legislative period
#' * `date`: Date of the participation item (Date class)
#' * `active`: Indicates if current participation is possible
#' * `item_id`: Item identifier
#' * `item_code`: Item type code
#' * `item`: Description of the item type
#' * `title`: Title of the participation item
#' * `type_doc`: Document type
#' * `topic`: Topic(s) associated with the item
#' * `item_url`: URL to the item on the Parliament website
#' * `statements`: Number of statements submitted
#' * `support`: Number of supporters
#' * `ministry`: Responsible ministry
#'
#' Returns a zero-row tibble with the documented columns if no results are found.
#'
#' @details
#' This function sends a request to the Austrian Parliament's API to retrieve participation data based on the provided filter criteria. It performs input validation for each parameter and constructs the API request accordingly.
#'
#' **Valid values for `topic`:**
#' * "Arbeit" (Labor)
#' * "Außenpolitik" (Foreign Policy)
#' * "Bildung" (Education)
#' * "Budget und Finanzen" (Budget and Finance)
#' * "Europäische Union" (European Union)
#' * "Familie und Generationen" (Family and Generations)
#' * "Frauen und Gleichbehandlung" (Women and Equal Treatment)
#' * "Gesundheit und Ernährung" (Health and Nutrition)
#' * "Information und Medien" (Information and Media)
#' * "Inneres und Recht" (Interior and Justice)
#' * "Innovation, Technologie und Forschung" (Innovation, Technology and Research)
#' * "Klima, Umwelt und Energie" (Climate, Environment and Energy)
#' * "Kultur" (Culture)
#' * "Land- und Forstwirtschaft" (Agriculture and Forestry)
#' * "Landesverteidigung" (National Defense)
#' * "Parlament und Demokratie" (Parliament and Democracy)
#' * "Soziales" (Social Affairs)
#' * "Sport" (Sports)
#' * "Verkehr und Infrastruktur" (Transport and Infrastructure)
#' * "Wirtschaft" (Economy)
#'
#' Setting `topic = NULL` returns values for all topics listed above.
#'
#' **Valid values for `item`:**
#' * "RGES" (Gesetzesinitiativen / Legislative Initiatives)
#' * "ME" (Ministerialentwürfe / Ministerial Drafts)
#' * "BI" (Bürgerinitiativen / Citizens' Initiatives)
#' * "PET" (Petitionen / Petitions)
#' * "SN" (Stellungnahmen / Statements)
#' Setting `item = NULL` returns values for all review types listed above.
#'
#' **Valid values for `initiative_type`** (Only if item=="RGES"):
#' * "A" (Gesetzesanträge von Abgeordneten / Legislative Motions by Members)
#' * "BUA" (Gesetzesanträge von Ausschüssen / Legislative Motions by Committees)
#' * "RV" (Regierungsvorlagen / Government Bills)
#'
#' Setting `initiative_type = NULL` returns values for all initiative types listed above.
#'
#' **Valid values for `statement_type`** (Only if item=="SN"):
#' * "SNME" (Stellungnahme Ministerialentwurf / Statement on Ministerial Draft)
#' * "SN" (Stellungnahme Gesetzesinitiative / Statement on Legislative Initiative)
#' * "SPET" (Stellungnahme zur Petition / Statement on Petition)
#' * "SPET-BR" (Stellungnahme zur Petition Bundesrat / Statement on Petition Federal Council)
#' * "SBI" (Stellungnahme Bürgerinitiative / Statement on Citizens' Initiative)
#'
#' Setting `statement_type = NULL` returns values for all statement types listed above.
#'
#' @examples
#' \donttest{
#' # Get participation data for the topic "Bildung"
#' result <- get_participation(topic = "Bildung")
#' dplyr::glimpse(result)
#'
#' # Get participation data for multiple topics and legislative periods
#' result <- get_participation(
#'   topic = c("Arbeit", "Soziales"),
#'   legis_period = c("27", "26"),
#'   item = "RGES"
#' )
#' dplyr::glimpse(result)
#'
#' # Get participation data on all ministerial drafts for legislative periods 26 and 27
#' result <- get_participation(
#'   legis_period = c(26, 27),
#'   item = "ME"
#' )
#' dplyr::glimpse(result)
#'
#' # Get participation data on legislative initiatives with specific initiative type
#' result <- get_participation(
#'   item = "RGES",
#'   initiative_type = "RV"
#' )
#' dplyr::glimpse(result)
#' }
#'
#' @export

get_participation <- function(
  topic = NULL, #Themen - THEMEN
  legis_period = NULL, #Gesetzgebungsperiode - GP_CODE
  active = NULL, #Aktuelle Beteiligung - AKTIV
  item = NULL, #Gegenstand - BEGUTTYP
  initiative_type = NULL, #Art der Gesetzesinitiative - DOKTYPE
  statement_type = NULL #Art der Stellungnahme - SNTYP
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
  checkmate::assert_subset(topic, choices_topic, empty.ok = TRUE)

  #LEGIS PERIOD
  legis_period <- purrr::map_chr(
    legis_period,
    \(x) fn_check_legis_period_elements(x)
  )

  #AKTIV
  checkmate::assert_subset(active, choices = "J", empty.ok = TRUE)
  # J: Aktuelle Beteiligung möglich

  #item (BEGUTTYP/Gegenstand)
  choices_item <- c("RGES", "ME", "BI", "PET", "SN")
  checkmate::assert_subset(item, choices_item, empty.ok = TRUE)

  # RGES: Gesetzesinitiativen
  # ME: Ministerialentwürfe
  # BI: Bürgerinitiativen
  # PET: Petitionen
  # SN: Stellungnahmen

  #CHECK
  #INITIATIVE_TYPE (DOKTYPE/ART DER GESETZESINITATIVE)
  # Only allowed when item = "RGES"
  if (!is.null(initiative_type) && (is.null(item) || !("RGES" %in% item))) {
    cli::cli_abort('initiative_type can only be specified when item = "RGES"')
  }

  choices_initiative_type <- c("A", "BUA", "RV")
  checkmate::assert_subset(
    initiative_type,
    choices_initiative_type,
    empty.ok = TRUE
  )

  # A: Gesetzesanträge von Abgeordneten
  # BUA: Gesetzesanträge von Ausschüssen
  # RV: Regierungsvorlagen

  #STATEMENT_TYPE (SNTYP/ART DER STELLUNGNAHME)
  # Only allowed when item = "SN"
  if (!is.null(statement_type) && (is.null(item) || !("SN" %in% item))) {
    cli::cli_abort('statement_type can only be specified when item = "SN"')
  }

  choices_statement_type <- c("SNME", "SN", "SPET", "SPET-BR", "SBI")
  checkmate::assert_subset(
    statement_type,
    choices_statement_type,
    empty.ok = TRUE
  )

  # SNME: Stellungnahme Ministerialentwurf
  # SN: Stellungnahme Gesetzesinitiative
  # SPET: Stellungnahme zur Petition
  # SPET-BR: Stellungnahme zur Petition Bundesrat
  # SBI: Stellungnahme Bürgerinitiative

  body_params <- list(
    THEMEN = topic,
    GP_CODE = legis_period,
    AKTIV = active,
    BEGUTTYP = item,
    DOKTYP = initiative_type,
    SNTYP = statement_type
  ) %>%
    purrr::compact() %>% #keep only non-empty elements
    jsonlite::toJSON()

  res <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/143"
  ) %>%
    httr2::req_url_query(
      js = "eval",
      # page = "1",
      # pagesize = "10",
      sortrnr = "22",
      showAll = TRUE,
      ascDesc = "DESC",
    ) %>%
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      origin = "https://www.parlament.gv.at"
    ) %>%
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") %>%
    httr2::req_retry(max_tries = 3) %>%
    httr2::req_body_raw(body_params, "application/json") %>%
    httr2::req_perform()

  vec_headings <- res %>%
    httr2::resp_body_json(simplifyVector = TRUE) %>%
    purrr::pluck("header", "label") %>%
    stringr::str_to_snake() %>%
    make.unique(sep = "_")

  # extract the actual substantive data
  df_res <- res %>%
    httr2::resp_body_json(simplifyVector = TRUE) %>%
    purrr::pluck("rows") %>%
    as.data.frame()

  #assign more meaningful col names/translate

  renaming_map <- c(
    "gp_code" = "legis_period",
    "datum" = "date",
    "aktiv" = "active",
    "nr" = "item_id",
    "ityp" = "item_code",
    "gegenstand" = "item",
    "betreff" = "title",
    "doktype" = "type_doc",
    # "beteiligen"?
    "themen" = "topic",
    "b" = "item_url",
    "stellungnahmen" = "statements",
    "unterstutzungen" = "support",
    "ressort" = "ministry"
  )

  if (NROW(df_res) == 0 || length(df_res) == 0) {
    cli::cli_inform("No results found for the provided search criteria.")
    return(.parlat_empty_tibble(unname(renaming_map), date_cols = "date"))
  }

  #assign column names
  colnames(df_res) <- vec_headings

  df_res <- .parlat_apply_renaming(df_res, renaming_map)

  df_res <- df_res %>%
    dplyr::select(dplyr::any_of(unname(renaming_map))) %>%
    dplyr::mutate(date = lubridate::dmy(date)) %>%
    tibble::as_tibble()

  return(df_res)
}
