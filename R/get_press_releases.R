#' Get parliamentary correspondence ('Parlamentskorrespondenz')
#' @encoding UTF-8
#' @description
#' `get_press_releases` retrieves press releases and reports published as part of the
#' Austrian Parliament's parliamentary correspondence ('Parlamentskorrespondenz'). The function
#' mirrors the search functionality offered on the Austrian Parliament's website (see <a href="https://www.parlament.gv.at/recherchieren/parlamentskorrespondenz" target="_blank">here</a>).
#'
#' @param search_string Character string or `NULL`. Free-text search across title, subtitle, and content. Default is `NULL`.
#' @param topic Character vector or `NULL`. Topic(s) to filter by. See 'Details' for possible values. Default is `NULL`.
#' @param category Character vector or `NULL`. Category (Sachbereich) of correspondence to filter by. See 'Details' for possible values. Default is `NULL`.
#' @param year Character or numeric vector or `NULL`. Year(s) to filter results by (e.g., `2024` or `"2024"`). Default is `NULL`.
#' @param keyword Character vector or `NULL`. Keyword(s) (Stichworte) to filter by. Default is `NULL`.
#' @param echo Logical. If `TRUE`, the function prints progress messages. Default is `TRUE`.
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
#' ## category (SACHB)
#' NULL, one, or multiple values permissible.
#' Possible values for `category` are:
#'
#' * "Ausschusssitzungen des Nationalrats" (Committee sessions of the National Council)
#' * "Bundesrat" (Federal Council)
#' * "Features"
#' * "Festsitzungen, Gedenkveranstaltungen" (Ceremonial sessions, commemorations)
#' * "Parlament international" (Parliament international)
#' * "Parlamentarische Materialien" (Parliamentary materials)
#' * "Plenarsitzungen des Nationalrats" (Plenary sessions of the National Council)
#' * "Veranstaltungen" (Events)
#' * "Vermischtes" (Miscellaneous)
#'
#' ## search_string and keyword
#' `search_string` performs a broad full-text search across title, subtitle, and content.
#' `keyword` filters by structured Stichworte tags assigned by parliamentary editors.
#' Both can be combined with the other filter parameters.
#'
#' @return
#' A tibble (data.frame) with one row per correspondence item matching the search:
#'
#' - `date` (Date): publication date.
#' - `number` (character): correspondence number (e.g., "PK1108").
#' - `title` (character): title of the press release.
#' - `subtitle` (character): subtitle or teaser text.
#' - `url` (character): full URL to the detail page on parlament.gv.at.
#' - `topics` (list): list-column of topic strings.
#' - `category` (list): list-column of category strings (Sachbereich).
#' - `keywords` (list): list-column of keyword strings (Stichworte).
#'
#' @seealso
#' * [get_items()] for parliamentary items under negotiation
#' * [get_plenary_meetings()] for plenary meeting data
#'
#' @export
#'
#' @examples \donttest{
#' # Search for correspondence about the budget in 2024
#' result <- get_press_releases(search_string = "Budget", year = 2024)
#' dplyr::glimpse(result)
#'
#' # Filter by category (Federal Council coverage only)
#' result <- get_press_releases(category = "Bundesrat", year = 2024)
#' dplyr::glimpse(result)
#'
#' # Combine topic and year filters
#' result <- get_press_releases(
#'   topic = "Klima, Umwelt und Energie",
#'   year = c(2023, 2024)
#' )
#' dplyr::glimpse(result)
#'
#' # Search by keyword
#' result <- get_press_releases(keyword = "Nationalrat", year = 2024)
#' dplyr::glimpse(result)
#' }
get_press_releases <- function(
  search_string = NULL,
  topic = NULL,
  category = NULL,
  year = NULL,
  keyword = NULL,
  echo = TRUE
) {
  # SEARCH STRING
  checkmate::assert_character(search_string, len = 1, null.ok = TRUE)

  # TOPIC
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
  checkmate::assert_subset(topic, choices_topic, empty.ok = TRUE)

  # FORMAT (SACHB)
  choices_category <- c(
    "Ausschusssitzungen des Nationalrats",
    "Bundesrat",
    "Features",
    "Festsitzungen, Gedenkveranstaltungen",
    "Parlament international",
    "Parlamentarische Materialien",
    "Plenarsitzungen des Nationalrats",
    "Veranstaltungen",
    "Vermischtes"
  )
  checkmate::assert_subset(category, choices_category, empty.ok = TRUE)

  # YEAR
  if (!is.null(year)) {
    year <- as.character(year)
    checkmate::assert_character(year)
  }

  # KEYWORD
  checkmate::assert_character(keyword, null.ok = TRUE)

  # COLLECT PARAMETERS
  body_params <- list(
    THEMEN = topic,
    SACHB = category,
    JAHR = year,
    STW = keyword
  ) %>%
    purrr::compact() %>%
    jsonlite::toJSON()

  if (echo) cli::cli_alert_info("Fetching correspondence from API...")

  req <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/110"
  ) %>%
    httr2::req_method("POST") %>%
    httr2::req_url_query(
      js = "eval",
      showAll = TRUE,
      export = TRUE,
      search = search_string
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
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)")

  resp <- httr2::req_perform(req)
  resp_json <- httr2::resp_body_json(resp, simplifyVector = TRUE)

  vec_headings <- resp_json %>%
    purrr::pluck("header", "label") %>%
    stringr::str_to_snake() %>%
    make.unique(sep = "_")

  col_positions <- purrr::pluck(resp_json, "header", "rnr")
  rows <- purrr::pluck(resp_json, "rows")

  df_res <- .align_get_items_export_rows(rows, vec_headings, col_positions)

  # STOP IF NO HITS
  if (is.null(df_res) || nrow(df_res) == 0) {
    cli::cli_alert_warning("No results found for the provided search criteria.")
    return(NULL)
  }

  # PARSE list columns (JSON array strings → R lists)
  cols_list <- c("abo_themen", "format", "stichworte")  # "format" is the raw API column name
  fn_parse_content_vec <- function(x) {
    x |>
      stringr::str_remove_all("\\[|\\]|\"") |>
      stringr::str_split(",") |>
      purrr::map(stringr::str_trim)
  }

  df_res <- df_res |>
    dplyr::mutate(
      dplyr::across(dplyr::any_of(cols_list), fn_parse_content_vec)
    )

  # RENAME columns to English names
  renaming_map <- c(
    "datum"      = "date",
    "nr"         = "number",
    "titel"      = "title",
    "untertitel" = "subtitle",
    "link"       = "url",
    "abo_themen" = "topics",
    "format"     = "category",
    "stichworte" = "keywords"
  )

  df_res <- df_res %>%
    dplyr::rename_with(
      .fn = \(x) renaming_map[x],
      .cols = dplyr::any_of(names(renaming_map))
    )

  # SELECT, ORDER, AND COERCE TYPES
  col_select <- c(
    "date", "number", "title", "subtitle", "url", "topics", "category", "keywords"
  )

  df_res <- df_res %>%
    dplyr::select(dplyr::any_of(col_select)) %>%
    dplyr::relocate(dplyr::any_of(col_select)) %>%
    dplyr::mutate(
      date = lubridate::dmy(.data$date),
      url  = paste0("https://www.parlament.gv.at", .data$url)
    ) %>%
    dplyr::arrange(dplyr::desc(.data$date))

  if (echo) cli::cli_alert_success("Fetched {nrow(df_res)} correspondence item{?s}")

  return(df_res)
}
