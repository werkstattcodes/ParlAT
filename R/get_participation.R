#' Get Participation Data from Austrian Parliament
#'
#' This function retrieves participation data from the Austrian Parliament's API based on various filter criteria.
#'
#' @param topic (*Themen*)Character vector. Optional. Specifies the topic(s) of interest. Must be one or more of: "Arbeit", "Außenpolitik", "Bildung", "Budget und Finanzen", "Europäische Union", "Familie und Generationen", "Frauen und Gleichbehandlung", "Gesundheit und Ernährung", "Information und Medien", "Inneres und Recht", "Innovation, Technologie und Forschung", "Klima, Umwelt und Energie", "Kultur", "Land- und Forstwirtschaft", "Landesverteidigung", "Parlament und Demokratie", "Soziales", "Sport", "Verkehr und Infrastruktur", "Wirtschaft".
#' @param legis_period (*Gesetzgebungsperiode*)Character vector. Optional. Specifies the legislative period(s).
#' @param active (*Aktuelle Beteiligung*) Character. Optional. If "J", only includes current participations.
#' @param review_type (*Gegenstand*) Character vector. Optional. Specifies the type of review. Must be one or more of: "RGES" (Gesetzesinitiativen), "ME" (Ministerialentwürfe), "BI" (Bürgerinitiativen), "PET" (Petitionen), "SN" (Stellungnahmen).
#' @param initiative_type (*Art der Gesetzesinitiative*) Character vector. Optional. Specifies the type of legislative initiative. Must be one or more of: "EBR" (Einsprüche des Bundesrats), "GABR" (Gesetzesanträge von Abgeordneten), "A" (Gesetzesanträge von Abgeordneten), "GABR13" (Gesetzesanträge von 1/3 der Mitglieder des Bundesrats), "RV" (Regierungsvorlagen), "VOLKBG" (Volksbegehren).
#' @param department (*Ressort*) Character vector. Optional. Only available if `review_type=='ME' (Ministerialentwürfe). Specifies the administrative unit which initiated the draft law.
#' Must be one or more of: "BMJ (BM f. Justiz)", "BMK (BM f. Klimaschutz, Umwelt, Energie, Mobilität, Innovation u. Technologie)", "BMNT (BM f. Nachhaltigkeit u. Tourismus)", "BMLV (BM f. Landesverteidigung)", "BMVRDJ (BM f. Verfassung, Reformen, Deregulierung u. Justiz)", "BML (BM f. Land- u. Forstwirtschaft, Regionen u. Wasserwirtschaft)", "BMLRT (BM f. Landwirtschaft, Regionen u. Tourismus)", "BMSGPK (BM f. Soziales, Gesundheit, Pflege u. Konsumentenschutz)", "BMI (BM f. Inneres)", "BMF (BM f. Finanzen)", "BMDW (BM f. Digitalisierung u. Wirtschaftsstandort)", "BMBWF (BM f. Bildung, Wissenschaft u. Forschung)", "BMAW (BM f. Arbeit u. Wirtschaft)", "BMASGK (BM f. Arbeit, Soziales, Gesundheit u. Konsumentenschutz)", "BMAFJ (BM f. Arbeit, Familie u. Jugend)", "BMA (BM f. Arbeit)", "BMEIA (BM f. europäische u. internationale Angelegenheiten)", "BMKÖS (BM f. Kunst, Kultur, öffentlichen Dienst u. Sport)", "BMFFIM (Büro der Bundesministerin f. Frauen, Familie, Integration u. Medien)", "BMEUV (Büro der Bundesministerin f. EU u. Verfassung)", "BKA (Bundeskanzleramt)")
#'
#' @return A data frame containing the participation data, or NULL if no results are found.
#'
#'
#' @details
#' This function sends a request to the Austrian Parliament's API to retrieve participation data based on the provided filter criteria. It performs input validation for each parameter and constructs the API request accordingly.
#'
#' @examples
#' # Get participation data for the topic "Bildung"
#' education_data <- get_participation(topic = "Bildung")
#'
#' # Get participation data for multiple topics and legislative periods
#' multi_data <- get_participation(
#'   topic = c("Arbeit", "Soziales"),
#'   legis_period = c("27", "26"),
#'   review_type = "RGES"
#' )
#'
#'
#' @export

get_participation <- function(
  topic=NULL, #Themen - THEMEN
  legis_period=NULL, #Gesetzgebungsperiode - GP_CODE
  active=NULL, #Aktuelle Beteiligung - AKTIV
  review_type=NULL, #Gegenstand - BEGUTTYP
  initiative_type=NULL #Art der Gesetzesinitiative - DOKTYPE
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

  #LEGIS PERIOD
  legis_period <- purrr::map_chr(legis_period, \(x) fn_check_legis_period_elements(x))

  #AKTIV
  checkmate::assert_subset(active, choices="J", empty.ok = TRUE)
  # J: Aktuelle Beteiligung möglich

  #REVIEW_TYPE (BEGUTTYP/Gegenstand)
  choices_review_type <- c("RGES","ME","BI","PET","SN")
  checkmate::assert_subset(review_type, choices_review_type, empty.ok = TRUE)

  # RGES: Gesetzesinitiativen
  # ME: Ministerialentwürfe
  # BI: Bürgerinitiativen
  # PET: Petitionen
  # SN: Stellungnahmen

  #INITIATIVE_TYPE (DOKTYPE/ART DER GESETZESINITATIVE)
  choices_initiative_type <- c("EBR", "GABR", "A", "GABR13", "RV", "VOLKBG")
  checkmate::assert_subset(initiative_type,choices_initiative_type, empty.ok = TRUE)

  # EBR: Einsprüche des Bundesrats
  # GABR: Gesetzesanträge von Abgeordneten
  # A: Gesetzesanträge von Abgeordneten
  # GABR13: Gesetzesanträge von 1/3 der Mitglieder des Bundesrats
  # RV: Regierungsvorlagen
  # VOLKBG: Volksbegehren

  body_params <- list(
      THEMEN=topic,
      GP_CODE=legis_period,
      AKTIV=active,
      BEGUTTYP=review_type,
      DOKTYP=initiative_type
    ) |>
      purrr::compact() |>  #keep only non-empty elements
      jsonlite::toJSON()

  res <- httr2::request("https://www.parlament.gv.at/Filter/api/filter/data/143") |>
    httr2::  req_url_query(
      js = "eval",
      # page = "1",
      # pagesize = "10",
      sortrnr = "22",
      showAll=TRUE,
      ascDesc = "DESC",
    ) |>
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      `content-type` = "application/json",
      cookie = "JSESSIONID=6SuuP4uN67Tzfy5YSSTebU_drcVJsXaonUCi2Ip2.appsrv05e; JSESSIONID=D5_fJZPk36M3KGFa5uvK-d3ze_hVKvOXxYHz-fZ2.appsrv04e; JSESSIONID=9-oz4HlqNiskyx82nuyPCA_jV-I4j7LaDQE6nxlz.appsrv06e; pddsgvo=j; _pk_id.1.26ca=7fce6f38a899aedc.1706609353.; _pk_ref.1.26ca=%5B%22%22%2C%22%22%2C1725286623%2C%22https%3A%2F%2Fwww.google.com%2F%22%5D; _pk_ses.1.26ca=1",
      dnt = "1",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i",
      `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36",
    ) |>
    httr2::req_body_raw(body_params, "application/json") |>
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








