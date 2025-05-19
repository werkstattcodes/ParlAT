#' Retrieve Committee Data from the Austrian Parliament API
#'
#'  Get data on the committees ('Ausschüsse') of the Austrian Parliament. Data includes session dates, agendas, meeting overviews, and member lists.
#' The function mirrors the search functionality of the Austrian Parliament's website for committees
#' <a href="https://www.parlament.gv.at/recherchieren/ausschuesse/index.html" target="_blank">here</a>.
#'
#' @param search_string A character string for free text search.
#' @param institution A character string specifying the institution. Either NR (Nationalrat, National Council) or BR (Bundesrat/Federal Council).
#' @param legis_period A character or numeric vector of length 1 for a specific legislative period. Required.
#' @param permanent A logical flag indicating whether only permanent committees should be queried.
#' @param include_subcommittees A logical flag to indicate whether subcommittees should be included
#'   in the search results. Search for subcommittees is only possible if `permanent` is not TRUE.
#' @param details Logical. If TRUE, the function retrieves additional details for each committee, including members, documents, and reports.
#' @param echo Logical. If TRUE, the function prints the used search parametes and the url to the pertaining search results on the website of the Austrian Parlament.
#'
#' @return A data frame
#'
#' @examples
#' \dontrun{
#'  get_committees(
#'  search_string = "Ibiza",
#' legis_period=27,
#'  institution = "NR",
#'  echo=TRUE)
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
  #INSTITUTION
  checkmate::assert_subset(
    x = institution,
    choices = c("NR", "BR"),
    empty.ok = FALSE
  )

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

  vec_headings <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("header", "label") |>
    janitor::make_clean_names()

  # extract the actual substantive data
  df_res <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("rows")
  #print(class(df_res))

  colnames(df_res) <- vec_headings
  df_res <- tidyr::as_tibble(df_res)

  checkmate::check_data_frame(df_res, min.rows = 1)

  if (length(df_res) == 0) {
    message("No results found for the provided search criteria.")
    return(NULL)
  }

  #PARSE TAGESORDNUNG AND RSS DESCRIPTION TO PLAIN TEXT
  # df_res <- df_res |>
  #   dplyr::mutate(across(c("tagesordnung", "rss_description"), \(x) purrr::map_chr(x, \(x) aux_parse_html_text)))

  #SELECT RELEVANT COLUMNS
  df_res <- df_res %>%
    dplyr::select(any_of(
      c(
        "committee" = "ausschuss",
        "url_committee" = "link"
      )
    )) %>%
    dplyr::mutate(
      url_committee = paste0(
        "https://www.parlament.gv.at",
        url_committee
      )
    )

  #GET DETAILS
  if (details == TRUE) {
    df_res <- df_res %>%
      dplyr::mutate(
        details = purrr::map(url_committee, \(x) {
          get_committee_details(x)
        })
      ) %>%
      tidyr::unnest_wider(details)
  }

  # ECHO
  if (echo == TRUE) {
    print(body_params)
    # print url to results / transparency reasons
    body_params_li <- jsonlite::fromJSON(body_params)

    query_string <- purrr::imap(
      body_params_li,
      \(x, y) glue::glue("WFP_009{URLencode(y)}={URLencode(x)}")
    ) %>%
      unlist() %>%
      unname() %>%
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
  li_details <- fromJSON(url_committee_json)
  listviewer::jsonedit(li_details)

  df_details <- tibble::tibble(
    title = li_details %>% purrr::pluck("content", "title"),
    zitation = li_details %>% purrr::pluck("content", "zitation"),
    gp_code = li_details %>% purrr::pluck("content", "gp_code"),
    aus_id = li_details %>% purrr::pluck("content", "aus_id"),
    aus_von = li_details %>% purrr::pluck("content", "aus_von"),
    aus_bis = li_details %>% purrr::pluck("content", "aus_bis"),
    names = list(li_details %>% purrr::pluck("content", "names")),
    documents = list(li_details %>% purrr::pluck("content", "documents")),
    assignments = list(li_details %>% purrr::pluck("content", "assignments")),
    recentagenda = list(li_details %>% purrr::pluck("content", "recentagenda")),
    recentreports = list(
      li_details %>% purrr::pluck("content", "recentreports")
    ),
    stages = list(
      li_details %>% purrr::pluck("content", "phase", "stages")
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

  df_details <- df_details %>%
    dplyr::select(any_of(cols_select))
  print(class(df_details))

  return(df_details)
}
