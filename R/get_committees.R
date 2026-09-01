.parlat_empty_committee_members <- function() {
  .parlat_empty_tibble(
    c("name", "member_type", "party", "member_url")
  )
}

.parlat_empty_committees <- function(details_type = NULL) {
  cols <- c(
    "legis_period",
    "committee",
    "citation",
    "id_number",
    "url_committee"
  )

  if (identical(details_type, "members")) {
    cols <- c(
      cols,
      "date_start",
      "date_end",
      "url_pdf",
      "url_html",
      "members"
    )
  }

  .parlat_empty_tibble(
    cols,
    int_cols = "id_number",
    datetime_cols = intersect(c("date_start", "date_end"), cols),
    list_cols = intersect("members", cols)
  )
}

.parlat_normalize_committee_members <- function(members) {
  if (is.null(members) || !is.data.frame(members) || nrow(members) == 0) {
    return(.parlat_empty_committee_members())
  }

  member_cols <- c("name", "member_type", "party", "member_url")
  members <- tibble::as_tibble(members)

  for (col in setdiff(member_cols, names(members))) {
    members[[col]] <- NA_character_
  }

  members <- members |>
    dplyr::mutate(dplyr::across(dplyr::all_of(member_cols), as.character)) |>
    dplyr::select(dplyr::all_of(member_cols))

  if (nrow(members) == 1 && all(is.na(members))) {
    return(.parlat_empty_committee_members())
  }

  members
}

.parlat_normalize_committees <- function(
  committees,
  legis_period,
  details_type = NULL
) {
  if (nrow(committees) == 0) {
    return(.parlat_empty_committees(details_type))
  }

  if (!"legis_period" %in% names(committees)) {
    committees$legis_period <- as.character(legis_period)
  }

  committees <- committees |>
    dplyr::mutate(
      legis_period = dplyr::coalesce(
        as.character(.data$legis_period),
        as.character(legis_period)
      ),
      committee = as.character(.data$committee),
      citation = as.character(.data$citation),
      id_number = as.integer(.data$id_number),
      url_committee = as.character(.data$url_committee)
    )

  if (!identical(details_type, "members")) {
    return(committees |>
      dplyr::select(dplyr::all_of(names(.parlat_empty_committees()))))
  }

  for (col in c("date_start", "date_end")) {
    if (!col %in% names(committees)) {
      committees[[col]] <- rep(as.POSIXct(NA, tz = "UTC"), nrow(committees))
    } else if (inherits(committees[[col]], "POSIXt")) {
      committees[[col]] <- as.POSIXct(committees[[col]], tz = "UTC")
      attr(committees[[col]], "tzone") <- "UTC"
    } else {
      committees[[col]] <- lubridate::ymd_hms(
        committees[[col]],
        tz = "UTC",
        quiet = TRUE
      )
    }
  }

  for (col in c("url_pdf", "url_html")) {
    if (!col %in% names(committees)) {
      committees[[col]] <- NA_character_
    } else {
      committees[[col]] <- as.character(committees[[col]])
    }
  }

  if (!"members" %in% names(committees)) {
    committees$members <- rep(
      list(.parlat_empty_committee_members()),
      nrow(committees)
    )
  } else {
    committees$members <- purrr::map(
      committees$members,
      .parlat_normalize_committee_members
    )
  }

  committees |>
    dplyr::select(
      dplyr::all_of(names(.parlat_empty_committees("members")))
    )
}

#' Retrieve Committee Data from the Austrian Parliament API
#'
#' `r lifecycle::badge("experimental")`
#'
#' Get data on the committees ('Ausschüsse') of the Austrian Parliament. Data includes meeting dates, agendas, meeting overviews, and member lists.
#' The function partly mirrors the search functionality of the Austrian Parliament's website for committees
#' <a href="https://www.parlament.gv.at/recherchieren/ausschuesse/index.html" target="_blank">here</a> and extends it by
#' e.g. incorporating the extraction of data from membership lists. Data available starting from the 20th legislative period.
#'
#' @param search_string A character string for free text search. Optional.
#' @param institution A character string specifying the institution. Either "NR" (Nationalrat, National Council) or "BR" (Bundesrat/Federal Council). Required.
#' @param legis_period A character or numeric vector of length 1 for a specific legislative period. Required. Data available starting from the 20th legislative period.
#' @param permanent A logical flag indicating whether only permanent committees should be queried. Default is NULL (both permanent and non-permanent).
#' @param citation A character vector for filtering results by committee citation code (e.g., "1/SA-BU"). This is applied as a post-processing filter after API results are retrieved. Default is NULL (no filtering).
#' @param include_subcommittees A logical flag to indicate whether subcommittees should be included
#'   in the search results. Search for subcommittees is only possible if `permanent` is not TRUE. Default is NULL.
#' @param details_type A character string specifying the type of details to retrieve. Currently supports "members" to extract committee membership information. Default is NULL (no additional details).
#' @param echo Logical. If TRUE, the function prints the URL to the pertaining search results on the website of the Austrian Parliament and the number of results. Default is NULL.
#'
#' @return A tibble (data frame) with different structures depending on `details_type`:
#'
#' **When `details_type = NULL` (default):**
#' - `legis_period`: Legislative period code (character)
#' - `committee`: Name of the committee
#' - `citation`: Citation information
#' - `id_number`: Committee ID number (integer)
#' - `url_committee`: URL to the committee page
#'
#' **When `details_type = "members"`:**
#' - `legis_period`: Legislative period code (character, relocated to first column)
#' - `committee`: Name of the committee
#' - `citation`: Citation information
#' - `id_number`: Committee ID number (integer)
#' - `url_committee`: URL to the committee page
#' - `date_start`: Committee start date (POSIXct)
#' - `date_end`: Committee end date (POSIXct)
#' - `url_pdf`: URL to PDF version of member list (character, may be NA)
#' - `url_html`: URL to HTML version of member list (character, may be NA)
#' - `members`: List-column containing tibbles with member information. Each tibble has:
#'   - `name`: Member name (character)
#'   - `member_type`: Type of membership - "member", "substitute", or leadership role (character)
#'   - `party`: Party affiliation (character, may be NA)
#'   - `member_url`: URL to member's profile page (character)
#'
#' If no results are found, the zero-row tibble has exactly the same columns,
#' order, and column types as a non-empty result for the requested
#' `details_type`.
#'
#' @examples
#' \donttest{
#' # Basic search for committees in National Council
#' result <- get_committees(
#'   institution = "NR",
#'   legis_period = 27
#' )
#' dplyr::glimpse(result)
#'
#' # Search with specific text and extract member details
#' result <- get_committees(
#'   search_string = "Ibiza",
#'   legis_period = 27,
#'   institution = "NR",
#'   details_type = "members"
#' )
#' dplyr::glimpse(result)
#'
#' # Search only permanent committees
#' result <- get_committees(
#'   institution = "NR",
#'   legis_period = 28,
#'   permanent = TRUE
#' )
#' dplyr::glimpse(result)
#'
#' # Include subcommittees (only works when permanent = FALSE or NULL)
#' result <- get_committees(
#'   institution = "NR",
#'   legis_period = 27,
#'   include_subcommittees = TRUE
#' )
#' dplyr::glimpse(result)
#'
#' # Federal Council committees
#' result <- get_committees(
#'   institution = "BR",
#'   legis_period = 27
#' )
#' dplyr::glimpse(result)
#' }
#'
#' @export
get_committees <- function(
  search_string = NULL,
  institution = NULL,
  legis_period,
  permanent = NULL,
  citation = NULL,
  include_subcommittees = NULL, #auch Unterausschuesse - UA
  details_type = NULL,
  echo = NULL
) {
  # PARAMETER VALIDATION
  checkmate::assert_character(search_string, len = 1, null.ok = TRUE)
  checkmate::assert_subset(
    x = institution,
    choices = c("NR", "BR"),
    empty.ok = FALSE
  )
  checkmate::assert_logical(echo, len = 1, null.ok = TRUE)

  # LEGIS PERIOD: required argument
  checkmate::assert(
    !missing(legis_period),
    .var.name = "legis_period is a required input"
  )

  # LEGIS PERIOD: must be length 1, accepts numeric or character
  # Check length first for more informative error message

  if (length(legis_period) > 1) {
    cli::cli_abort("Function allows only for one single legislative period")
  }

  if (
    is.na(legis_period) ||
      is.null(legis_period) ||
      !(any(is.character(legis_period), is.numeric(legis_period)))
  ) {
    cli::cli_abort("legis_period must be of class numeric or character")
  }

  legis_period <- aux_convert_legis_periods(
    legis_period,
    output = "roman"
  )

  if (as.numeric(as.roman(legis_period)) < 20) {
    cli::cli_warn("Data only available from legislative period 20 onwards.")
    return(.parlat_empty_committees(details_type))
  }

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
    cli::cli_abort(
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
  ) %>%
    purrr::compact() %>% #keep only non-empty elements
    jsonlite::toJSON()

  res <- get_committees_api_request(body_params)

  # Check if API request was successful
  if (httr2::resp_is_error(res)) {
    cli::cli_abort("API request failed with status: {httr2::resp_status(res)}")
  }

  vec_headings <- res %>%
    httr2::resp_body_json(simplifyVector = TRUE) %>%
    purrr::pluck("header", "label") %>%
    stringr::str_to_snake() %>%
    make.unique(sep = "_")

  # extract the actual substantive data
  df_res <- res %>%
    httr2::resp_body_json(simplifyVector = TRUE) %>%
    purrr::pluck("rows")

  # Handle empty results
  if (length(df_res) == 0) {
    cli::cli_inform("No results found for the provided search criteria.")
    return(.parlat_empty_committees(details_type))
  }

  colnames(df_res) <- vec_headings
  df_res <- tidyr::as_tibble(df_res)

  #SELECT RELEVANT COLUMNS
  df_res <- df_res %>%
    dplyr::mutate(
      id_number = stringr::str_extract(.data$link, stringr::regex("\\d+$")) %>%
        as.integer()
    ) %>%
    dplyr::mutate(
      citation = .data$link %>%
        stringr::str_remove(stringr::regex("^/ausschuss/[IVXLCDM]+/")) %>%
        stringr::str_remove(stringr::regex("/\\d+$"))
    ) %>%
    dplyr::select(any_of(
      c(
        "committee" = "ausschuss",
        "url_committee" = "link",
        "id_number",
        "citation"
      )
    )) %>%
    dplyr::mutate(
      url_committee = paste0(
        "https://www.parlament.gv.at",
        .data$url_committee
      )
    )

  # Pseudo filter
  if (!is.null(citation)) {
    df_res <- df_res %>%
      dplyr::filter(stringr::str_detect(
        .data$citation,
        stringr::regex({{ citation }}, ignore_case = TRUE)
      ))
  }

  if (nrow(df_res) == 0) {
    if (isTRUE(echo)) {
      .parlat_echo_request(
        body_params,
        url_base = "https://www.parlament.gv.at/recherchieren/ausschuesse/index.html",
        param_prefix = "WFP_009"
      )
    }

    return(.parlat_empty_committees(details_type))
  }

  #GET DETAILS
  if (!is.null(details_type)) {
    df_res <- df_res %>%
      dplyr::mutate(
        details = purrr::map2(
          .data$url_committee,
          {{ details_type }},
          \(x, y) {
            get_committee_details(url_committee = x, details_type = y)
          },
          .progress = TRUE
        )
      ) %>%
      tidyr::unnest("details", keep_empty = TRUE)

    if (!details_type %in% colnames(df_res)) {
      cli::cli_warn(
        "Column {.val {details_type}} not found in committee details. Available columns: {.val {colnames(df_res)}}."
      )
    }
  }

  df_res <- .parlat_normalize_committees(
    df_res,
    legis_period = legis_period,
    details_type = details_type
  )

  # ECHO
  if (isTRUE(echo)) {
    .parlat_echo_request(
      body_params,
      url_base = "https://www.parlament.gv.at/recherchieren/ausschuesse/index.html",
      param_prefix = "WFP_009"
    )
  }

  #RETURN RESULT
  return(df_res)
}


get_committees_api_request <- function(body_params) {
  res <- httr2::request("https://www.parlament.gv.at/Filter/api/json/post") %>%
    httr2::req_method("POST") %>%
    httr2::req_url_query(
      jsMode = "EVAL",
      FBEZ = "WFP_009",
      listeId = "undefined",
      # search = "Korruption",
      # pageNumber = "1",
      # pagesize = "10",
      showAll = TRUE,
      ascDesc = "ASC"
    ) %>%
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      origin = "https://www.parlament.gv.at"
    ) %>%
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") %>%
    httr2::req_retry(max_tries = 3) %>%
    httr2::req_body_raw(body_params, type = "application/json") %>%
    httr2::req_perform()

  return(res)
}


get_committee_details <- function(url_committee, details_type) {
  # url_committee <- "https://www.parlament.gv.at/ausschuss/XXVIII/A-AS/1/00917"

  # print(url_committee)
  # print(details_type)

  # url_committee <- "https://www.parlament.gv.at/ausschuss/XXII/SA-BU/1/00034"

  # fetched via httr2 so httptest2 can intercept and record the request
  li_details <- tryCatch(
    {
      json_text <- .parlat_fetch_detail_json_text(url_committee)
      .parlat_parse_detail_json(json_text)$data
    },
    error = function(e) {
      cli::cli_inform("Failed to fetch committee details for URL: {url_committee}")
      return(NULL)
    }
  )

  # If li_details is NULL, return empty tibble
  if (is.null(li_details)) {
    return(tibble::tibble())
  }

  # IF DETAILS_TYPE="members"

  if (details_type == "members" && !is.null(details_type)) {
    df_details <- tibble::tibble(
      # title = li_details %>%
      #   purrr::pluck("content", "title", .default = NA_character_),
      zitation = li_details %>%
        purrr::pluck("content", "zitation", .default = NA_character_),
      gp_code = li_details %>%
        purrr::pluck("content", "gp_code", .default = NA_character_),
      # aus_id = li_details %>%
      #   purrr::pluck("content", "aus_id", .default = NA_character_),
      aus_von = li_details %>%
        purrr::pluck("content", "aus_von", .default = NA_character_),
      aus_bis = li_details %>%
        purrr::pluck("content", "aus_bis", .default = NA_character_),
      # names = list(
      #   li_details %>% purrr::pluck("content", "names", .default = list())
      # ),
      documents = list(
        li_details %>% purrr::pluck("content", "documents", .default = list())
      ) #,
      # assignments = list(
      #   li_details %>% purrr::pluck("content", "assignments", .default = list())
      # ),
      # recentagenda = list(
      #   li_details %>% purrr::pluck("content", "recentagenda", .default = list())
      # ),
      # recentreports = list(
      #   li_details %>%
      #     purrr::pluck("content", "recentreports", .default = list())
      # ),
      # stages = list(
      #   li_details %>%
      #     purrr::pluck("content", "phase", "stages", .default = list())
      # )
    )

    cols_select <- c(
      "title",
      # "zitation",
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

    df_details <- df_details %>%
      dplyr::rename(
        # citation = zitation,
        legis_period = "gp_code",
        # committee_id = aus_id,
        date_start = "aus_von",
        date_end = "aus_bis"
      ) %>%
      dplyr::relocate(
        "legis_period",
        .before = 1
      ) %>%
      dplyr::mutate(
        across(dplyr::starts_with("date"), \(x) lubridate::ymd_hms(x))
      )

    # Check if documents column has any data
    has_documents <- !is.null(df_details$documents[[1]]) &&
      length(df_details$documents[[1]]) > 0
    if (has_documents) {
      df_details <- df_details %>%
        tidyr::unnest("documents") %>%
        tidyr::unnest("documents") %>%
        dplyr::rename(any_of(c(url = "link", url_type = "type"))) %>%
        dplyr::mutate(
          url_pdf = dplyr::if_else(
            .data$url_type == "PDF",
            .data$url,
            NA_character_
          ),
          url_html = dplyr::if_else(
            .data$url_type == "HTML",
            .data$url,
            NA_character_
          )
        ) %>%
        dplyr::select(-"url", -"url_type")
    } else {
      # If no documents, create placeholder columns
      df_details <- df_details %>%
        dplyr::select(-"documents") %>%
        dplyr::mutate(
          url_pdf = NA_character_,
          url_html = NA_character_
        )
    }

    #remove links to member list with fotos; would duplicate retrieval of members & features different page structure
    df_details <- df_details %>%
      dplyr::filter(
        is.na(.data$url_html) |
          !stringr::str_detect(
            .data$url_html,
            stringr::regex("FOTO", ignore_case = TRUE)
          )
      )

    # Only apply title filter if title column exists
    if ("title" %in% colnames(df_details)) {
      df_details <- df_details %>%
        dplyr::filter(
          !dplyr::coalesce(
            stringr::str_detect(
              .data$title,
              stringr::regex("Bebildertes", ignore_case = TRUE)
            ),
            FALSE
          )
        )
    }

    # print(df_details$url_html)

    df_details <- df_details %>%
      # dplyr::filter(!stringr::str_detect(url_pdf, stringr::regex("FOTO"))) %>% #remove url to 'bebildertes mitgliederverzeichnis to avoid duplicates"
      dplyr::mutate(
        members = purrr::map(.data$url_html, \(x) {
          if (all(is.na(x))) {
            .parlat_empty_committee_members()
          } else {
            safe_get_committee_members(x)
          }
        })
      )
  }

  # IF DETAILS_TYPE="agenda"

  # Ensure df_details is defined
  if (!exists("df_details")) {
    cli::cli_warn(
      "get_committee_details: details_type {.val {details_type}} not implemented"
    )
    return(tibble::tibble())
  }

  return(df_details)
}

safe_get_committee_members <- function(url) {
  result <- tryCatch(
    get_committee_members(url),
    error = function(e) {
      cli::cli_inform(
        "Failed to extract committee members for: https://www.parlament.gv.at{url}"
      )
      tibble::tibble(
        name = "Failed to extract members",
        member_type = NA_character_,
        party = NA_character_,
        member_url = NA_character_
      )
    }
  )
  return(result)
}

get_committee_members <- function(url) {
  # Normalize URL to full path
  url <- if (
    stringr::str_detect(url, stringr::regex("^https://www.parlament.gv.at"))
  ) {
    url
  } else {
    paste0("https://www.parlament.gv.at", url)
  }

  # Read HTML and check table structure
  html_doc <- url %>% rvest::read_html()
  tables <- html_doc %>% rvest::html_table()

  # No table at all
  if (length(tables) == 0 || nrow(tables[[1]]) == 0) {
    cli::cli_warn("No table found in URL: {url}")
    return(tibble::tibble(
      name = NA_character_,
      member_type = NA_character_,
      party = NA_character_,
      member_url = NA_character_
    ))
  }

  df_check <- tables[[1]]

  # PRIORITY 1: Check for base SA-P9/A-USA member list URLs (Type 3 structure)
  # Only the base member list URLs use Type 3 structure
  # Base pattern: /SA-P9/1/00152/MIT_00152.html (no version number after document ID)
  # NOT versioned: /A-USA/2/00944/MIT_00944.html (these are actually document versions, use type1/2)
  # The key difference: base member lists have pattern /committee/number/docid/MIT_docid.html
  # Versioned documents have different structure detected by table count
  is_base_special_committee <- stringr::str_detect(
    url,
    "/(SA-P9)/\\d+/\\d+/MIT_"
  )

  if (is_base_special_committee) {
    return(fn_extract_committees_type3(url))
  }

  # PRIORITY 2: Check table column count for Type 1
  is_type1 <- ncol(df_check) == 2

  # Type 1: 2-column tables
  if (is_type1) {
    return(fn_extract_hauptausschuss(url))
  }

  # Type 2 or Type 3: Both have 3 columns
  # Check if table matches Type 2 patterns before trying Type 2 extraction
  has_mitglieder_pattern <- any(stringr::str_detect(
    df_check[[2]],
    "^Mitglieder"
  ))
  has_vorsitzender_pattern <- any(stringr::str_detect(
    df_check[[2]],
    "^Vorsitzender|^Ob"
  ))

  # Type 3: 3-column table but doesn't match Type 2 patterns
  # if (!has_mitglieder_pattern && !has_vorsitzender_pattern) {
  #   return(fn_extract_committees_type3(url, html_doc))
  # }

  # Type 2: 3-column table with expected patterns
  # Wrap in tryCatch to handle unexpected failures
  result <- tryCatch(
    fn_extract_committees_other(url),
    error = function(e) {
      # If Type 2 extraction fails, try Type 3
      # message(paste0("Type 2 extraction failed for ", url, ", trying Type 3"))
      fn_extract_committees_type3(url)
    }
  )

  return(result)
}


#' Extract members of the "Hauptausschuss" from an HTML page
#'
#' Internal helper that reads an HTML page, iterates over all <table> nodes and
#' extracts person links and associated party/member_type information. The
#' function treats <b> (bold) nodes as party labels and <a> (anchor) nodes as
#' person links. It returns a tibble with one row per person found.
#'
#' Important behavior notes:
#' - Bold (<b>) elements update the current party label for subsequent links.
#' - Anchor (<a>) elements yield the person name and the href attribute.
#' - For the first table (table_index == 1) the extracted party names are put
#'   into a column named `party` and `member_type` is set to "committee member".
#' - For subsequent tables (table_index > 1) the extracted party names are
#'   placed in the `member_type` column.
#' - The returned tibble is formed by row-binding results from all tables;
#'   columns that are missing for particular tables will be NA after binding.
#'
#' @param url Character. A URL, file path, or other input acceptable to
#'   rvest::read_html() that points to the HTML page containing the
#'   Hauptausschuss tables.
#'
#' @return A tibble with one row per extracted person. Typical columns include:
#'   - url: character; the raw href attribute extracted from the person's <a> tag
#'     (may be relative).
#'   - name: character; visible link text for the person.
#'   - member_type: character; for tables after the first this will contain the
#'     party/member_type inferred from preceding <b> elements; for the first table
#'     this is set to "committee member".
#'   - party: character; for the first table this contains the party label(s).
#'   - table_index: integer; index of the source <table> node the row came from.
#'
#' @details
#' The function performs a full recursive traversal of each table node to find
#' nested <b> and <a> elements. It does not attempt to resolve relative hrefs
#' to absolute URLs. The function is intended for internal package use and
#' assumes the HTML structure places party labels in bold tags and person
#' entries in anchor tags within the same table.
#'
#' @examples
#' \donttest{
#' # Parse a live committee page (example URL)
#' fn_extract_hauptausschuss("https://example.org/parliament/committees/hauptausschuss")
#' }
#'
#' @keywords internal
#' @noRd
fn_extract_hauptausschuss <- function(url) {
  # Read HTML and extract tables
  tables <- url %>%
    rvest::read_html() %>%
    rvest::html_elements("table")

  # Initialize list to store results from all tables
  all_results <- list()

  # Process each table
  for (i in seq_along(tables)) {
    table_node <- tables[[i]]

    # Use a local environment as accumulator for recursive traversal
    acc <- new.env(parent = emptyenv())
    acc$persons <- character()
    acc$urls <- character()
    acc$parties <- character()
    acc$current_party <- NA_character_

    # Recursive function to traverse all nodes (including nested)
    traverse_nodes <- function(node, acc) {
      node_name <- rvest::html_name(node)

      if (node_name == "b") {
        # This is a party name - update current party
        acc$current_party <- rvest::html_text2(node)
      } else if (node_name == "a") {
        # This is a person link
        acc$persons <- c(acc$persons, rvest::html_text2(node))
        acc$urls <- c(acc$urls, rvest::html_attr(node, "href"))
        acc$parties <- c(acc$parties, acc$current_party)
      }

      # Recursively process child nodes
      children <- rvest::html_children(node)
      if (length(children) > 0) {
        for (child in children) {
          traverse_nodes(child, acc)
        }
      }
    }

    # Start traversal from the table node
    traverse_nodes(table_node, acc)

    all_persons <- acc$persons
    all_urls <- acc$urls
    all_parties <- acc$parties

    # Store results for this table
    if (length(all_persons) > 0) {
      if (i > 1) {
        all_results[[i]] <- tibble::tibble(
          member_url = all_urls,
          name = all_persons,
          member_type = all_parties,
          table_index = i
        )
      } else {
        all_results[[i]] <- tibble::tibble(
          member_url = all_urls,
          name = all_persons,
          party = all_parties,
          member_type = "member",
          table_index = i
        )
      }
    }
  }

  # Combine all table results
  df <- dplyr::bind_rows(all_results) %>%
    dplyr::select(-"table_index")

  # Ensure all expected columns exist
  if (!"party" %in% colnames(df)) {
    df$party <- NA_character_
  }

  df %>%
    dplyr::select("name", "member_type", "party", "member_url")
}


fn_extract_committees_other <- function(url) {
  url <- if (
    stringr::str_detect(url, stringr::regex("^https://www.parlament.gv.at"))
  ) {
    url
  } else {
    paste0("https://www.parlament.gv.at", url)
  }

  # Read HTML
  html_doc <- url %>% rvest::read_html()

  # Get table text content
  all_tables <- html_doc %>%
    rvest::html_table()
  df_members_raw <- all_tables[[1]]

  # Get table element for URL extraction
  all_table_elements <- html_doc %>%
    rvest::html_elements("table")
  table_element <- all_table_elements[[1]]

  # Extract URLs from table rows
  extract_urls_from_table <- function(table_elem) {
    rows <- table_elem %>% rvest::html_elements("tr")

    purrr::map(seq_along(rows), function(i) {
      cells <- rows[[i]] %>% rvest::html_elements("td")
      if (length(cells) == 0) {
        return(NULL)
      }

      # Extract URLs from each cell
      urls_list <- purrr::map(cells, function(cell) {
        links <- cell %>% rvest::html_elements("a") %>% rvest::html_attr("href")
        if (length(links) == 0) {
          return(NA_character_)
        }
        paste(links, collapse = " | ")
      })

      result <- tibble::as_tibble(setNames(
        urls_list,
        paste0("url_X", seq_along(urls_list))
      ))
      result$row_num_orig <- i
      result
    }) %>%
      purrr::list_rbind()
  }

  urls_table <- extract_urls_from_table(table_element)

  # Add row numbers to raw data for joining
  df_members_raw <- df_members_raw %>%
    tibble::as_tibble() %>%
    dplyr::mutate(row_num_orig = dplyr::row_number())

  # Join URLs with text data
  df_members_raw <- df_members_raw %>%
    dplyr::left_join(urls_table, by = "row_num_orig")

  df_members <- {
    idx_m <- which(stringr::str_detect(df_members_raw$X2, "^Mitglieder"))[1]
    idx_v <- which(stringr::str_detect(df_members_raw$X2, "^Vorsitzender|^Ob"))[
      1
    ]
    if (is.na(idx_m) || is.na(idx_v) || idx_v <= idx_m + 1) {
      tibble::tibble()
    } else {
      dplyr::slice(df_members_raw, (idx_m + 1):(idx_v - 1))
    }
  }

  df_members_first <- df_members %>%
    dplyr::select("X1", "X2", "url_X2", "row_num_orig") %>%
    dplyr::mutate(
      X2 = stringr::str_replace_all(.data$X2, stringr::regex("\n{2,}"), "--")
    ) %>%
    dplyr::mutate(X2 = stringr::str_split(.data$X2, stringr::regex("--"))) %>%
    dplyr::mutate(
      url_split = stringr::str_split(.data$url_X2, stringr::regex(" \\| "))
    ) %>%
    # Remove empty/NA elements from name list
    dplyr::mutate(X2 = purrr::map(.data$X2, ~ .x[!is.na(.x) & .x != ""])) %>%
    tidyr::unnest_longer("X2") %>%
    # Match URLs by position
    dplyr::group_by(.data$row_num_orig) %>%
    dplyr::mutate(member_idx = dplyr::row_number()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      member_url = purrr::map2_chr(
        .data$url_split,
        .data$member_idx,
        function(urls, idx) {
          if (length(urls) == 0) {
            return(NA_character_)
          }
          if (length(urls) == 1 && is.na(urls[[1]])) {
            return(NA_character_)
          }
          if (idx <= length(urls)) {
            return(urls[[idx]])
          }
          return(NA_character_)
        }
      )
    ) %>%
    dplyr::mutate(
      X1 = stringr::str_extract(.data$X1, stringr::regex("^[^:]*\\s"))
    ) %>%
    dplyr::rename("party" = "X1", "name" = "X2") %>%
    dplyr::mutate(member_type = "member", .before = 1) %>%
    dplyr::mutate(across(c("party", "name", "member_type"), function(x) {
      stringr::str_trim(x) %>% stringr::str_squish()
    })) %>%
    dplyr::filter(.data$name != "") %>%
    dplyr::select(-"url_X2", -"url_split", -"member_idx", -"row_num_orig")

  df_members_second <- df_members %>%
    dplyr::select("X1", "X3", "url_X3", "row_num_orig") %>%
    dplyr::mutate(
      X3 = stringr::str_replace_all(.data$X3, stringr::regex("\n{2,}"), "--")
    ) %>%
    dplyr::mutate(X3 = stringr::str_split(.data$X3, stringr::regex("--"))) %>%
    dplyr::mutate(
      url_split = stringr::str_split(.data$url_X3, stringr::regex(" \\| "))
    ) %>%
    # Remove empty/NA elements from name list
    dplyr::mutate(X3 = purrr::map(.data$X3, ~ .x[!is.na(.x) & .x != ""])) %>%
    tidyr::unnest_longer("X3") %>%
    # Match URLs by position
    dplyr::group_by(.data$row_num_orig) %>%
    dplyr::mutate(member_idx = dplyr::row_number()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      member_url = purrr::map2_chr(
        .data$url_split,
        .data$member_idx,
        function(urls, idx) {
          if (length(urls) == 0) {
            return(NA_character_)
          }
          if (length(urls) == 1 && is.na(urls[[1]])) {
            return(NA_character_)
          }
          if (idx <= length(urls)) {
            return(urls[[idx]])
          }
          return(NA_character_)
        }
      )
    ) %>%
    dplyr::mutate(
      X1 = stringr::str_extract(.data$X1, stringr::regex("^[^:]*\\s"))
    ) %>%
    dplyr::rename("party" = "X1", "name" = "X3") %>%
    dplyr::mutate(member_type = "substitute", .before = 1) %>%
    dplyr::mutate(across(c("party", "name", "member_type"), function(x) {
      stringr::str_trim(x) %>% stringr::str_squish()
    })) %>%
    dplyr::filter(.data$name != "") %>%
    dplyr::select(-"url_X3", -"url_split", -"member_idx", -"row_num_orig")

  df_members <- dplyr::bind_rows(df_members_first, df_members_second)

  # Find the starting row for office holders
  office_start_row <- {
    match_rows <- which(stringr::str_detect(
      df_members_raw$X2,
      stringr::regex("^(Vorsitzender|Ob)")
    ))
    if (length(match_rows) == 0) Inf else min(match_rows)
  }

  df_office <- df_members_raw %>%
    dplyr::mutate(row_num = dplyr::row_number()) %>%
    dplyr::filter(.data$row_num >= office_start_row) %>%
    dplyr::select(-"row_num", -"X1") %>%
    dplyr::filter(.data$X2 != "") %>%
    dplyr::select("X2", "X3", "url_X3", "row_num_orig") %>%
    dplyr::mutate(
      X3 = stringr::str_replace_all(.data$X3, stringr::regex("\n{2,}"), "--")
    ) %>%
    dplyr::mutate(X3 = stringr::str_split(.data$X3, stringr::regex("--"))) %>%
    dplyr::mutate(
      url_split = stringr::str_split(.data$url_X3, stringr::regex(" \\| "))
    ) %>%
    # Remove empty/NA elements from name list
    dplyr::mutate(X3 = purrr::map(.data$X3, ~ .x[!is.na(.x) & .x != ""])) %>%
    tidyr::unnest_longer("X3") %>%
    # Match URLs by position
    dplyr::group_by(.data$row_num_orig) %>%
    dplyr::mutate(member_idx = dplyr::row_number()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      member_url = purrr::map2_chr(
        .data$url_split,
        .data$member_idx,
        function(urls, idx) {
          if (length(urls) == 0) {
            return(NA_character_)
          }
          if (length(urls) == 1 && is.na(urls[[1]])) {
            return(NA_character_)
          }
          if (idx <= length(urls)) {
            return(urls[[idx]])
          }
          return(NA_character_)
        }
      )
    ) %>%
    dplyr::mutate(X2 = stringr::str_remove(.data$X2, ":$")) %>%
    dplyr::rename("name" = "X3", "member_type" = "X2") %>%
    dplyr::select(-"url_X3", -"url_split", -"member_idx", -"row_num_orig")

  dplyr::bind_rows(df_office, df_members_first, df_members_second) %>%
    dplyr::select("name", "member_type", "party", "member_url")
}


fn_extract_committees_type3 <- function(url) {
  #check url
  url <- if (
    stringr::str_detect(url, stringr::regex("^https://www.parlament.gv.at"))
  ) {
    url
  } else {
    paste0("https://www.parlament.gv.at", url)
  }

  tables_elements <- url %>%
    rvest::read_html() %>%
    rvest::html_elements("table")

  # NATIONAL COUNCIL members
  table_text <- tables_elements[[1]] %>%
    rvest::html_text() %>%
    unlist()
  checkNRTable1 <- any(stringr::str_detect(
    table_text,
    stringr::regex("Nationalrat entsendet")
  ))

  #get all names and url; create tibble
  individuals_names <- tables_elements[[2]] %>%
    rvest::html_elements("tr a") %>%
    rvest::html_text2()

  individuals_urls <- tables_elements[[2]] %>%
    rvest::html_elements("tr a") %>%
    rvest::html_attr("href")

  if (length(individuals_names) == length(individuals_urls)) {
    df_individuals <- tibble(
      name = individuals_names,
      url = individuals_urls
    )
  }

  #get table with members and party affiliation
  tables <- url %>%
    rvest::read_html() %>%
    rvest::html_table()

  members <- tables[[2]] %>%
    dplyr::filter(
      !dplyr::if_all(everything(), \(x) {
        is.na(x) |
          stringr::str_trim(x) == ""
      })
    ) %>%
    dplyr::select("X1", "X2") %>%
    dplyr::filter(.data$X1 != "")

  members <- members %>%
    dplyr::rename(party = "X1") %>%
    dplyr::mutate(
      party = stringr::str_extract(.data$party, stringr::regex("^[^:]+")) %>%
        stringr::str_trim()
    ) %>%
    dplyr::rename(name = "X2") %>%
    dplyr::mutate(
      name = stringr::str_split(.data$name, stringr::regex("\n{2,3}"))
    ) %>%
    tidyr::unnest("name")

  #add urls to members table
  members_full_nr <- members %>%
    dplyr::left_join(df_individuals, by = "name") %>%
    dplyr::mutate(position = "member") %>%
    dplyr::mutate(institution = "NR")

  #NR substitutes
  substitutes <- tables[[2]] %>%
    dplyr::filter(
      !dplyr::if_all(everything(), \(x) {
        is.na(x) |
          stringr::str_trim(x) == ""
      })
    ) %>%
    dplyr::select("X1", "X3") %>%
    dplyr::filter(.data$X1 != "")

  #table party and name of substitutes
  substitutes <- substitutes %>%
    dplyr::rename(party = "X1") %>%
    dplyr::mutate(
      party = stringr::str_extract(.data$party, stringr::regex("^[^:]+")) %>%
        stringr::str_trim()
    ) %>%
    dplyr::rename(name = "X3") %>%
    dplyr::mutate(
      name = stringr::str_split(.data$name, stringr::regex("\n{2,3}"))
    ) %>%
    tidyr::unnest("name")

  #add  url to tble substitutes
  substitutes_full_nr <- substitutes %>%
    dplyr::left_join(df_individuals, by = "name") %>%
    dplyr::mutate(position = "substitute") %>%
    dplyr::mutate(institution = "NR")

  # NR officers
  office_NR <- tables[[2]] %>%
    dplyr::filter(
      !dplyr::if_all(everything(), \(x) {
        is.na(x) |
          stringr::str_trim(x) == ""
      })
    ) %>%
    # dplyr::select("X1", "X2") %>%
    dplyr::filter(.data$X1 == "") %>%
    dplyr::slice(-1) %>%
    dplyr::select(position = "X2", name = "X3")

  office_NR_full <- office_NR %>%
    dplyr::left_join(df_individuals %>% dplyr::distinct(), by = "name") %>%
    dplyr::mutate(institution = "NR")

  # FEDERAL COUNCIL
  table_text_br <- tables_elements[[3]] %>%
    rvest::html_text() %>%
    unlist()
  checkNRTable3 <- any(stringr::str_detect(
    table_text_br,
    stringr::regex("Bundesrat entsendet")
  ))

  individuals_names <- tables_elements[[4]] %>%
    rvest::html_elements("tr a") %>%
    rvest::html_text2()

  individuals_urls <- tables_elements[[4]] %>%
    rvest::html_elements("tr a") %>%
    rvest::html_attr("href")

  if (length(individuals_names) == length(individuals_urls)) {
    df_individuals <- tibble(
      name = individuals_names,
      url = individuals_urls
    )
  }

  #get table with members and party affiliation
  tables <- url %>%
    rvest::read_html() %>%
    rvest::html_table()

  members <- tables[[4]] %>%
    dplyr::filter(
      !dplyr::if_all(everything(), \(x) {
        is.na(x) |
          stringr::str_trim(x) == ""
      })
    ) %>%
    dplyr::select("X1", "X2") %>%
    dplyr::filter(.data$X1 != "")

  members <- members %>%
    dplyr::rename(party = "X1") %>%
    dplyr::mutate(
      party = stringr::str_extract(.data$party, stringr::regex("^[^:]+")) %>%
        stringr::str_trim()
    ) %>%
    dplyr::rename(name = "X2") %>%
    dplyr::mutate(
      name = stringr::str_split(.data$name, stringr::regex("(?<=\\))\n{2,3}"))
    ) %>%
    tidyr::unnest("name") %>%
    dplyr::mutate(name = stringr::str_squish(.data$name)) %>%
    dplyr::mutate(
      state = stringr::str_extract(
        .data$name,
        stringr::regex("(?<=\\().*(?=\\))")
      )
    ) %>%
    dplyr::mutate(
      name = stringr::str_remove(.data$name, stringr::regex("\\s\\(.*$"))
    )

  #add urls to members table
  members_full_br <- members %>%
    dplyr::left_join(df_individuals, by = "name") %>%
    dplyr::mutate(position = "member") %>%
    dplyr::mutate(institution = "BR")

  #BR substitutes
  substitutes <- tables[[4]] %>%
    dplyr::filter(
      !dplyr::if_all(everything(), \(x) {
        is.na(x) |
          stringr::str_trim(x) == ""
      })
    ) %>%
    dplyr::select("X1", "X3") %>%
    dplyr::filter(.data$X1 != "")

  #table party and name of substitutes
  substitutes <- substitutes %>%
    dplyr::rename(party = "X1") %>%
    dplyr::mutate(
      party = stringr::str_extract(.data$party, stringr::regex("^[^:]+")) %>%
        stringr::str_trim()
    ) %>%
    dplyr::rename(name = "X3") %>%
    dplyr::mutate(
      name = stringr::str_split(.data$name, stringr::regex("(?<=\\))\n{2,3}"))
    ) %>%
    tidyr::unnest("name") %>%
    dplyr::mutate(name = stringr::str_squish(.data$name)) %>%
    dplyr::mutate(
      state = stringr::str_extract(
        .data$name,
        stringr::regex("(?<=\\().*(?=\\))")
      )
    ) %>%
    dplyr::mutate(
      name = stringr::str_remove(.data$name, stringr::regex("\\s\\(.*$"))
    )

  #add  url to tble substitutes
  substitutes_full_br <- substitutes %>%
    dplyr::left_join(df_individuals, by = "name") %>%
    dplyr::mutate(position = "substitute") %>%
    dplyr::mutate(institution = "BR")

  # BR officers
  office_BR <- tables[[4]] %>%
    dplyr::filter(
      !dplyr::if_all(everything(), \(x) {
        is.na(x) |
          stringr::str_trim(x) == ""
      })
    ) %>%
    dplyr::filter(.data$X1 == "") %>%
    dplyr::slice(-1) %>%
    dplyr::select(position = "X2", name = "X3") %>%
    dplyr::mutate(
      state = stringr::str_extract(
        .data$name,
        stringr::regex("(?<=\\().*(?=\\))")
      )
    ) %>%
    dplyr::mutate(
      name = stringr::str_remove(.data$name, stringr::regex("\\s\\(.*$")) %>%
        stringr::str_trim()
    )

  office_BR_full <- office_BR %>%
    dplyr::left_join(df_individuals %>% dplyr::distinct(), by = "name") %>%
    dplyr::mutate(position = "office") %>%
    dplyr::mutate(institution = "BR")

  result <- dplyr::bind_rows(
    members_full_nr,
    substitutes_full_nr,
    office_NR_full,
    members_full_br,
    substitutes_full_br,
    office_BR_full
  )

  # Standardize column names to match expected schema
  result <- result %>%
    dplyr::rename(
      member_type = "position",
      member_url = "url"
    )

  return(result)
}
