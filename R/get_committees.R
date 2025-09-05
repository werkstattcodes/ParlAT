#' Retrieve Committee Data from the Austrian Parliament API
#'
#' Get data on the committees ('Ausschüsse') of the Austrian Parliament. Data includes session dates, agendas, meeting overviews, and member lists.
#' The function mirrors the search functionality of the Austrian Parliament's website for committees
#' <a href="https://www.parlament.gv.at/recherchieren/ausschuesse/index.html" target="_blank">here</a>.
#'
#' @param search_string A character string for free text search. Optional.
#' @param institution A character string specifying the institution. Either "NR" (Nationalrat, National Council) or "BR" (Bundesrat/Federal Council). Required.
#' @param legis_period A character or numeric vector of length 1 for a specific legislative period. Required.
#' @param permanent A logical flag indicating whether only permanent committees should be queried. Default is NULL (both permanent and non-permanent).
#' @param include_subcommittees A logical flag to indicate whether subcommittees should be included
#'   in the search results. Search for subcommittees is only possible if `permanent` is not TRUE. Default is NULL.
#' @param details Logical. If TRUE, the function retrieves additional details for each committee, including members, documents, and reports. Default is FALSE.
#' @param echo Logical. If TRUE, the function prints the used search parameters and the url to the pertaining search results on the website of the Austrian Parliament. Default is NULL.
#'
#' @return A data frame with the following columns:
#' - `committee`: Name of the committee
#' - `url_committee`: URL to the committee page
#'
#' If `details = TRUE`, additional columns are included:
#' - `legis_period`: Legislative period code (relocated to first column)
#' - `title`: Full title of the committee
#' - `citation`: Citation information
#' - `committee_id`: Committee ID
#' - `date_start`: Committee start date
#' - `date_end`: Committee end date
#' - `names`: List column with committee member names
#' - `documents`: List column with committee documents
#' - `assignments`: List column with committee assignments
#' - `recentagenda`: List column with recent agenda items
#' - `recentreports`: List column with recent reports
#' - `stages`: List column with committee stages
#'
#' Returns NULL if no results are found.
#'
#' @examples
#' \dontrun{
#' # Basic search for committees in National Council
#' get_committees(
#'   institution = "NR",
#'   legis_period = 27
#' )
#'
#' # Search with specific text and details
#' get_committees(
#'   search_string = "Ibiza",
#'   legis_period = 27,
#'   institution = "NR",
#'   details = TRUE
#' )
#'
#' # Search only permanent committees
#' get_committees(
#'   institution = "NR",
#'   legis_period = 28,
#'   permanent = TRUE
#' )
#'
#' # Include subcommittees (only works when permanent = FALSE or NULL)
#' get_committees(
#'   institution = "NR",
#'   legis_period = 27,
#'   include_subcommittees = TRUE
#' )
#'
#' # Federal Council committees
#' get_committees(
#'   institution = "BR",
#'   legis_period = 27
#' )
#' }
#'
#' @export
get_committees <- function(
  search_string = NULL,
  institution = NULL,
  legis_period,
  permanent = NULL,
  include_subcommittees = NULL, #auch Unterausschüsse - UA
  details = FALSE,
  echo = NULL
) {
  # PARAMETER VALIDATION
  checkmate::assert_character(search_string, len = 1, null.ok = TRUE)
  checkmate::assert_subset(
    x = institution,
    choices = c("NR", "BR"),
    empty.ok = FALSE
  )
  checkmate::assert_logical(details, len = 1, null.ok = FALSE)
  checkmate::assert_logical(echo, len = 1, null.ok = TRUE)

  #LEGIS PERIOD
  checkmate::assert_false(
    is.null(legis_period),
    .var.name = "legis_period must not be NULL"
  )
  checkmate::assert_true(
    length(legis_period) == 1,
    .var.name = "legis_period must be of length 1"
  )

  legis_period <- purrr::map_chr(
    legis_period,
    \(x) fn_check_legis_period_elements(x)
  )

  #PERMANENT
  checkmate::assert_logical(x = permanent, null.ok = TRUE)

  if (!is.null(permanent) && permanent == TRUE) {
    permanent_input <- "J"
  } else if (is.null(permanent) || permanent == FALSE) {
    permanent_input <- NULL
  }

  #INCLUDE SUBCOMMITTEES
  ## if `permanent`==T => searching for subcommittees is not possible

  if (isTRUE(permanent) && isTRUE(include_subcommittees)) {
    stop(
      "Searching for subcommittees is only possible if `permanent` is not TRUE."
    )
  }

  checkmate::assert_logical(x = include_subcommittees, null.ok = TRUE)
  if (!is.null(include_subcommittees) && include_subcommittees == TRUE) {
    include_subcommittees_input <- "J"
  } else if (is.null(include_subcommittees) || include_subcommittees == FALSE) {
    include_subcommittees_input <- NULL
  }

  #DEFINE PARAMETERS
  body_params <- list(
    NRBR = institution,
    GP = legis_period,
    # GP_CODE = legis_period,
    PERM = permanent_input,
    UA = include_subcommittees_input,
    SUCH = search_string
  ) |>
    purrr::compact() |> #keep only non-empty elements
    jsonlite::toJSON()

  res <- get_committees_api_request(body_params)

  # Check if API request was successful
  if (httr2::resp_is_error(res)) {
    stop("API request failed with status: ", httr2::resp_status(res))
  }

  vec_headings <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("header", "label") |>
    janitor::make_clean_names()

  # extract the actual substantive data
  df_res <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("rows")
  #print(class(df_res))

  # Handle empty results
  if (length(df_res) == 0) {
    message("No results found for the provided search criteria.")
    return(NULL)
  }

  colnames(df_res) <- vec_headings
  df_res <- tidyr::as_tibble(df_res)

  #PARSE TAGESORDNUNG AND RSS DESCRIPTION TO PLAIN TEXT
  # df_res <- df_res |>
  #   dplyr::mutate(across(c("tagesordnung", "rss_description"), \(x) purrr::map_chr(x, \(x) aux_parse_html_text)))

  #SELECT RELEVANT COLUMNS
  df_res <- df_res |>
    dplyr::select(any_of(
      c(
        "committee" = "ausschuss",
        "url_committee" = "link"
      )
    )) |>
    dplyr::mutate(
      url_committee = paste0(
        "https://www.parlament.gv.at",
        url_committee
      )
    )

  #GET DETAILS
  if (isTRUE(details)) {
    df_res <- df_res |>
      dplyr::mutate(
        details = purrr::map(
          url_committee,
          \(x) {
            get_committee_details(x)
          },
          .progress = TRUE
        )
      ) |>
      tidyr::unnest_wider(details)

    #rename cols
    df_res <- df_res %>%
      dplyr::rename(
        citation = zitation,
        legis_period = gp_code,
        committee_id = aus_id,
        date_start = aus_von,
        date_end = aus_bis
      ) %>%
      dplyr::relocate(
        legis_period,
        .before = 1
      )
  }

  if (isFALSE(details)) {
    df_res <- df_res %>%
      dplyr::mutate(legis_period = legis_period, .before = 1)
  }

  # ECHO
  if (isTRUE(echo)) {
    print(body_params)
    # print url to results / transparency reasons
    body_params_li <- jsonlite::fromJSON(body_params)

    query_string <- purrr::imap(
      body_params_li,
      \(x, y) glue::glue("WFP_009{URLencode(y)}={URLencode(x)}")
    ) |>
      unlist() |>
      unname() |>
      paste0(collapse = "&")

    print(glue::glue(
      "https://www.parlament.gv.at/recherchieren/ausschuesse/index.html?{query_string}"
    ))

    print(nrow(df_res))
  }

  #RETURN RESULT
  return(df_res)
}


get_committees_api_request <- function(body_params) {
  res <- httr2::request("https://www.parlament.gv.at/Filter/api/json/post") |>
    httr2::req_method("POST") |>
    httr2::req_url_query(
      jsMode = "EVAL",
      FBEZ = "WFP_009",
      listeId = "undefined",
      # search = "Korruption",
      # pageNumber = "1",
      # pagesize = "10",
      showAll = TRUE,
      ascDesc = "ASC"
    ) |>
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      dnt = "1",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i",
      # referer = "https://www.parlament.gv.at/recherchieren/ausschuesse/index.html?WFP_009NRBR=NR&WFP_009GP=XXVIII",
      `sec-ch-ua` = '"Not(A:Brand";v="99", "Google Chrome";v="133", "Chromium";v="133"',
      `sec-ch-ua-mobile` = "?0",
      `sec-ch-ua-platform` = '"Windows"',
      `sec-fetch-dest` = "empty",
      `sec-fetch-mode` = "cors",
      `sec-fetch-site` = "same-origin",
      `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/133.0.0.0 Safari/537.36" #,
      # cookie = "JSESSIONID=9Isqueg-5URIe6uvivvFPlFPp7FoT4fb-r2V6Ee3.appsrv06e; JSESSIONID=cIGy7LD1aNKtp0tEQJfecl33xhjjA0K2wyRxrLDv.master:green1"
    ) |>
    httr2::req_body_raw(body_params, type = "application/json") |>
    httr2::req_perform()

  return(res)
}


get_committee_details <- function(url_committee) {
  # url_committee <- "https://www.parlament.gv.at/ausschuss/XXVII/A-USA/2/00906"

  url_committee_json <- paste0(
    url_committee,
    "?json=TRUE"
  )

  li_details <- tryCatch(
    {
      fromJSON(url_committee_json)
    },
    error = function(e) {
      warning("Failed to fetch committee details for URL: ", url_committee)
      return(NULL)
    }
  )

  # If li_details is NULL, return empty tibble
  if (is.null(li_details)) {
    return(tibble::tibble())
  }

  df_details <- tibble::tibble(
    title = li_details |>
      purrr::pluck("content", "title", .default = NA_character_),
    zitation = li_details |>
      purrr::pluck("content", "zitation", .default = NA_character_),
    gp_code = li_details |>
      purrr::pluck("content", "gp_code", .default = NA_character_),
    aus_id = li_details |>
      purrr::pluck("content", "aus_id", .default = NA_character_),
    aus_von = li_details |>
      purrr::pluck("content", "aus_von", .default = NA_character_),
    aus_bis = li_details |>
      purrr::pluck("content", "aus_bis", .default = NA_character_),
    names = list(
      li_details |> purrr::pluck("content", "names", .default = list())
    ),
    documents = list(
      li_details |> purrr::pluck("content", "documents", .default = list())
    ),
    assignments = list(
      li_details |> purrr::pluck("content", "assignments", .default = list())
    ),
    recentagenda = list(
      li_details |> purrr::pluck("content", "recentagenda", .default = list())
    ),
    recentreports = list(
      li_details |> purrr::pluck("content", "recentreports", .default = list())
    ),
    stages = list(
      li_details |>
        purrr::pluck("content", "phase", "stages", .default = list())
    )
  )

  cols_select <- c(
    "title",
    "zitation",
    "gp_code",
    "aus_id",
    "aus_von",
    "aus_bis",
    "names",
    "documents",
    "assignments",
    "recentagenda",
    "recentreports",
    "stages"
  )

  df_details <- df_details |>
    dplyr::select(any_of(cols_select))

  return(df_details)
}
