#' @title Get Committee Memberships for Members of the Austrian Parliament
#'
#' @description
#' Retrieves committee membership information for members of the Austrian Parliament.
#' Data includes committee assignments, roles/functions, legislative periods, and
#' membership durations. The function mirrors the data available on individual
#' biography pages under the "Ausschüsse" (Committees) tab on the Austrian Parliament's
#' website (see <a href="https://www.parlament.gv.at/recherchieren/open-data/daten-und-lizenz/datensatz-ausschussmitgliedschaften/index.html" target="_blank" rel="noopener">here</a>).
#'
#' @param name Character string specifying the person's name to search for. Optional if
#'   `pad_intern` is provided. If multiple persons match the name, memberships for all
#'   matching persons will be returned. Only matches the latest names of individuals
#'   (previous names, e.g., before marriage, may not return matches).
#' @param pad_intern Character or numeric vector of person identifier(s) (PAD_INTERN).
#'   Optional if `name` is provided. Allows direct lookup by person ID. Can be obtained
#'   from `get_persons()` or `get_mps()`. Numeric values will be automatically converted
#'   to character.
#' @param echo Logical. If `TRUE`, prints the API request parameters and number of
#'   results found. Default is `FALSE`.
#'
#' @return A tibble containing committee membership information with the following columns:
#' \describe{
#'   \item{pad_intern}{Person identifier (PAD_INTERN)}
#'   \item{name}{Person's name}
#'   \item{legis_period}{Legislative period (Roman numerals)}
#'   \item{institution}{Chamber designation ("NR" for National Council, "BR" for Federal Council)}
#'   \item{committee_function}{Role/function within the committee (e.g., "Mitglied", "Vorsitzende")}
#'   \item{committee_name}{Name of the committee}
#'   \item{committee_date_start}{Start date of committee membership}
#'   \item{committee_date_end}{End date of committee membership (NA if currently active)}
#'   \item{committee_url}{URL to the committee page}
#' }
#'
#' Returns NULL if no committee memberships are found.
#'
#' @keywords internal
#' @noRd
#' @details
#' ## Parameter Usage
#'
#' You must provide either `name` OR `pad_intern` (but not both):
#' - **Search by name**: Provide `name`. The function will look up
#'   matching persons and retrieve their committee memberships.
#' - **Search by person ID**: Provide `pad_intern` directly.
#'
#' ## Data Coverage
#'
#' Data is available from the 20th legislative period onwards. Committee structures vary
#' across legislative periods, and investigation committees (Untersuchungsausschüsse) are
#' established during specific periods.
#'#'
#' ## Multiple Matches
#'
#' If the `name` parameter matches multiple persons, committee memberships for all
#' matching individuals will be returned and combined in the result.
#'
#' @examples
#' \dontrun{
#' # Search by name
#' get_committee_memberships(
#'   name = "Maurer"
#' )
#'
#' # Search by person ID (PAD_INTERN) - character or numeric
#' get_committee_memberships(pad_intern = "2344")
#' get_committee_memberships(pad_intern = 12345)  # Numeric also works
#' }
get_committee_memberships <- function(
  name = NULL,
  pad_intern = NULL,
  echo = FALSE
) {
  # PARAMETER VALIDATION

  # Exactly one of name or pad_intern must be provided
  if (is.null(name) && is.null(pad_intern)) {
    stop("Either 'name' or 'pad_intern' must be provided.")
  }

  if (!is.null(name) && !is.null(pad_intern)) {
    stop("Provide either 'name' OR 'pad_intern', not both.")
  }

  # Validate name
  checkmate::assert_character(name, min.len = 1, null.ok = TRUE)

  # Validate pad_intern (allow both character and numeric)
  checkmate::assert(
    checkmate::check_character(pad_intern, min.len = 1, null.ok = TRUE),
    checkmate::check_numeric(pad_intern, min.len = 1, null.ok = TRUE),
    combine = "or"
  )

  ## allow numeric/integer pad_intern inputs by coercing to character
  if (
    !is.null(pad_intern) && (is.numeric(pad_intern) || is.integer(pad_intern))
  ) {
    pad_intern <- as.character(pad_intern)
  }

  checkmate::assert_character(
    pad_intern,
    min.len = 1,
    min.chars = 1,
    null.ok = TRUE
  )

  # Validate echo
  checkmate::assert_logical(echo, len = 1, null.ok = FALSE)

  # PERSON LOOKUP

  if (!is.null(name)) {
    # Search by name using get_pad_intern()
    df_persons <- get_pad_intern(name)

    if (is.null(df_persons) || nrow(df_persons) == 0) {
      message(
        "No persons found with name '",
        name,
        "'."
      )
      return(NULL)
    }

    vec_pad_intern <- df_persons |>
      dplyr::pull(pad_intern) |>
      unique()

    if (echo) {
      message(
        "Found ",
        length(vec_pad_intern),
        " person(s) matching '",
        name,
        "': ",
        paste(df_persons$names_variants, collapse = "; ")
      )
    }

    # Prepare df_persons for join later (rename names_variants to name)
    df_persons <- df_persons |>
      dplyr::rename(name = names_variants)
  } else {
    # Use provided pad_intern directly
    vec_pad_intern <- unique(pad_intern)
  }

  # API REQUEST

  body_params <- list(
    PAD_INTERN = vec_pad_intern
  ) |>
    purrr::compact() |>
    jsonlite::toJSON()

  if (echo) {
    message("API request parameters: ", body_params)
  }

  res <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/250"
  ) |>
    httr2::req_url_query(
      `1` = "1",
      showAll = TRUE,
      sortrnr = "2",
      ascDesc = "ASC"
    ) |>
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      `content-type` = "application/json",
      dnt = "1",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i"
    ) |>
    httr2::req_body_raw(body_params, "application/json") |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
    httr2::req_perform()

  # Check for API errors
  if (httr2::resp_is_error(res)) {
    stop("API request failed with status: ", httr2::resp_status(res))
  }

  # EXTRACT DATA

  vec_headings <- res |>
    httr2::resp_body_json(simplifyVector = TRUE) |>
    purrr::pluck("header", "label") |>
    janitor::make_clean_names()

  df_res <- res |>
    httr2::resp_body_json(simplifyVector = TRUE) |>
    purrr::pluck("rows") |>
    as.data.frame()

  # Handle empty results
  if (nrow(df_res) == 0) {
    message("No committee memberships found for the given search criteria.")
    return(NULL)
  }

  colnames(df_res) <- vec_headings

  # DATA PROCESSING

  # Parse HTML content in committee names
  safe_parse_text <- purrr::possibly(
    aux_parse_html_text,
    otherwise = NA_character_
  )

  # Rename columns to package conventions
  renaming_map <- c(
    "gp" = "legis_period",
    "funktion" = "committee_function",
    "ausschuss_2" = "committee_name",
    "nrbr" = "institution",
    "url" = "committee_url",
    "from_date" = "committee_date_start"
  )

  df_res <- df_res |>
    dplyr::rename_with(
      .fn = \(x) renaming_map[x],
      .cols = any_of(names(renaming_map))
    )

  # Extract dates from committee_name if they're embedded (format: "von dd.mm.yyyy bis dd.mm.yyyy")
  df_res <- df_res %>%
    dplyr::mutate(
      date_membership = stringr::str_extract(
        ausschuss,
        stringr::regex("\\([^\\(]+\\)$")
      )
    ) %>%
    dplyr::mutate(
      date_membership_start = stringr::str_extract(
        date_membership,
        stringr::regex("(?<=\\()\\d{2}\\.\\d{2}\\.\\d{4}")
      )
    ) %>%
    dplyr::mutate(
      date_membership_end = stringr::str_extract(
        date_membership,
        stringr::regex("\\d{2}\\.\\d{2}\\.\\d{4}(?=\\)$)")
      )
    )

  # Parse dates to Date class
  df_res <- df_res %>%
    dplyr::mutate(across(
      c("date_membership_start", "date_membership_end"),
      \(x) lubridate::dmy(x)
    ))

  # Add URL prefix
  if ("committee_url" %in% colnames(df_res)) {
    df_res <- df_res |>
      dplyr::mutate(
        committee_url = dplyr::case_when(
          is.na(committee_url) | committee_url == "" ~ NA_character_,
          TRUE ~ paste0("https://www.parlament.gv.at", committee_url)
        )
      )
  }

  # Convert to tibble
  df_res <- tidyr::as_tibble(df_res)

  # SELECT AND ORDER COLUMNS

  cols_select <- c(
    "pad_intern",
    "name",
    "legis_period",
    "institution",
    "committee_name",
    "committee_function",
    # "committee_date_start",
    "committee_date_end",
    "committee_url",
    "date_membership_start",
    "date_membership_end"
  )

  df_res <- df_res |>
    dplyr::select(any_of(c(cols_select))) |>
    dplyr::relocate(any_of(cols_select))

  # ECHO OUTPUT

  if (echo) {
    message("Results found: ", nrow(df_res), " committee membership(s)")
  }

  # RETURN

  return(df_res)
}
