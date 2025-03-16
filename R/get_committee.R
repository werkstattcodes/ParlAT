#' Retrieve Committee Data from the Austrian Parliament API
#'
#' This function queries the Austrian Parliament's committee API using provided search criteria
#' and returns a data frame containing the committee information. The search parameters are validated,
#' encoded, and processed to match the API's expected input.
#'
#' @param search_string A character string for free text search within committee records. Optional.
#' @param institution A character string specifying the institution ("Bundesrat" or "Nationalrat").
#'   This parameter is mandatory and is internally encoded to "BR" or "NR" respectively.
#' @param legis_period A character vector representing one or more legislative period codes.
#'   Each element is validated using an internal helper function.
#' @param permanent A logical flag indicating whether only permanent committees should be queried.
#'   When set to TRUE, the corresponding API parameter is adjusted accordingly. Optional.
#' @param include_subcommittees A logical flag to indicate whether subcommittees should be included
#'   in the search results. Note that if permanent is TRUE, subcommittee search is disallowed.
#'
#' @details The function constructs a JSON request body by assembling the provided parameters
#'   (after validation and necessary encoding) and sends a POST request to the API endpoint.
#'   The API response is parsed, and the data is converted into a data frame with cleaned column names.
#'
#' @return A data frame containing the committee data if successful. If no results match the criteria,
#'   a message is printed and NULL is returned.
#'
#' @examples
#' \dontrun{
#'   # Retrieve data for the Nationalrat with a specified legislative period and permanent flag.
#'   df <- get_committee(
#'     search_string = "Finance",
#'     institution = "Nationalrat",
#'     legis_period = c("2019-2024"),
#'     permanent = TRUE,
#'     include_subcommittees = FALSE
#'   )
#'   if (!is.null(df)) {
#'     print(df)
#'   }
#' }
#'
#' @importFrom checkmate assert_subset assert_logical check_data_frame
#' @importFrom purrr map_chr compact pluck
#' @importFrom jsonlite toJSON
#' @importFrom httr2 request req_url_query req_headers req_body_raw req_user_agent req_verbose req_perform resp_body_json
#' @importFrom janitor make_clean_names
#'
#' @export
get_committee <- function(
  search_string = NULL, #Suchbegriff - SUCH
  institution = NULL, #Gremium - NBR
  legis_period = NULL, #Gesetzgebungsperiode - GP_CODE
  permanent = NULL, #Permanent tagende Ausschüsse - PERM
  include_subcommittees = NULL, #auch Unterausschüsse - UA
  echo = NULL
) {
  #INSTITUTION
  checkmate::assert_subset(
    x = institution,
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
    NRBR = institution_input,
    GP = legis_period,
    # GP_CODE = legis_period,
    PERM = permanent_input,
    UA = include_subcommittees_input,
    SUCH = search_string
  ) |>
    purrr::compact() |> #keep only non-empty elements
    jsonlite::toJSON()

  res <- get_committee_api_request(body_params)

  vec_headings <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("header", "label") |>
    janitor::make_clean_names()

  # extract the actual substantive data
  df_res <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("rows")
  #print(class(df_res))

  checkmate::check_data_frame(df_res, min.rows = 1)

  if (length(df_res) == 0) {
    message("No results found for the provided search criteria.")
    return(NULL)
  }

  colnames(df_res) <- vec_headings

  #parse tagesordnung and rss description to plain text
  # df_res <- df_res |>
  #   dplyr::mutate(across(c("tagesordnung", "rss_description"), \(x) purrr::map_chr(x, \(x) aux_parse_html_text)))

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

  #return result
  return(df_res)
}

get_committee_api_request <- function(body_params) {
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
