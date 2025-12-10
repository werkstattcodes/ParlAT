#' Retrieve Committee Data from the Austrian Parliament API
#'
#' Get data on the committees ('Ausschüsse') of the Austrian Parliament. Data includes session dates, agendas, meeting overviews, and member lists.
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
#' @param echo Logical. If TRUE, the function prints the used search parameters and the url to the pertaining search results on the website of the Austrian Parliament. Default is NULL.
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
#' Returns NULL if no results are found for the provided search criteria.
#'
#' @examples
#' \dontrun{
#' # Basic search for committees in National Council
#' get_committees(
#'   institution = "NR",
#'   legis_period = 27
#' )
#'
#' # Search with specific text and extract member details
#' get_committees(
#'   search_string = "Ibiza",
#'   legis_period = 27,
#'   institution = "NR",
#'   details_type = "members"
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
  citation = NULL,
  include_subcommittees = NULL, #auch Unterausschüsse - UA
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
    stop("Function allows only for one single legislative period")
  }

  if (
    is.na(legis_period) ||
      is.null(legis_period) ||
      !(any(is.character(legis_period), is.numeric(legis_period)))
  ) {
    stop("legis_period must be of class numeric or character")
  }

  legis_period <- aux_convert_legis_periods(
    legis_period,
    output = "roman"
  )

  if (as.numeric(as.roman(legis_period)) < 20) {
    warning(
      "Data only available from legislative period 20 onwards.",
      call. = F
    )
    return(NULL)
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
  ) %>%
    purrr::compact() %>% #keep only non-empty elements
    jsonlite::toJSON()

  res <- get_committees_api_request(body_params)

  # Check if API request was successful
  if (httr2::resp_is_error(res)) {
    stop("API request failed with status: ", httr2::resp_status(res))
  }

  vec_headings <- res %>%
    httr2::resp_body_json(simplifyVector = T) %>%
    purrr::pluck("header", "label") %>%
    stringr::str_to_snake() %>%
    make.unique(sep = "_")

  # extract the actual substantive data
  df_res <- res %>%
    httr2::resp_body_json(simplifyVector = T) %>%
    purrr::pluck("rows")

  # Handle empty results
  if (length(df_res) == 0) {
    message("No results found for the provided search criteria.")
    return(NULL)
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
      tidyr::unnest_wider("details")

    # Check if the details_type column exists before unnesting
    if (details_type %in% colnames(df_res)) {
      df_res <- df_res %>%
        tidyr::unnest({{ details_type }})
    } else {
      warning(
        paste0(
          "Column '",
          details_type,
          "' not found in committee details. ",
          "Available columns: ",
          paste(colnames(df_res), collapse = ", ")
        )
      )
    }
  }

  if (is.null(details_type)) {
    df_res <- df_res %>%
      dplyr::mutate(legis_period = legis_period, .before = 1) %>%
      dplyr::select("legis_period", "committee", "citation", "id_number", "url_committee")
  }

  # ECHO
  if (isTRUE(echo)) {
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

    # print(nrow(df_res))
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
    ) %>%
    httr2::req_body_raw(body_params, type = "application/json") %>%
    httr2::req_perform()

  return(res)
}


get_committee_details <- function(url_committee, details_type) {
  # url_committee <- "https://www.parlament.gv.at/ausschuss/XXVIII/A-AS/1/00917"

  # print(url_committee)
  # print(details_type)

  # url_committee <- "https://www.parlament.gv.at/ausschuss/XXII/SA-BU/1/00034"

  url_committee_json <- paste0(
    url_committee,
    "?json=TRUE"
  )

  li_details <- tryCatch(
    {
      fromJSON(url_committee_json)
    },
    error = function(e) {
      message("Failed to fetch committee details for URL: ", url_committee)
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
        tidyr::pivot_wider(
          id_cols = any_of(c(
            "legis_period",
            # "citation",
            # "committee_id",
            "date_start",
            "date_end",
            "title"
          )),
          names_from = "type",
          values_from = "link"
        ) %>%
        dplyr::rename(
          any_of(c(
            url_pdf = "PDF",
            url_html = "HTML"
          ))
        )
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
      dplyr::filter(!is.na(.data$url_html)) %>%
      dplyr::filter(
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
          if (is.na(x)) {
            tibble::tibble(
              name = NA_character_,
              member_type = NA_character_,
              party = NA_character_,
              member_url = NA_character_
            )
          } else {
            safe_get_committee_members(x)
          }
        })
      )
  }

  # IF DETAILS_TYPE="agenda"

  # Ensure df_details is defined
  if (!exists("df_details")) {
    warning(paste0(
      "get_committee_details: details_type '",
      details_type,
      "' not implemented"
    ))
    return(tibble::tibble())
  }

  return(df_details)
}

safe_get_committee_members <- function(url) {
  result <- tryCatch(
    get_committee_members(url),
    error = function(e) {
      message(paste0(
        "Failed to extract committee members for: ",
        paste0("https://www.parlament.gv.at", url)
      ))
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
    warning(paste0("No table found in URL: ", url))
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
#' \dontrun{
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

    # Initialize vectors for this table
    all_persons <- c()
    all_urls <- c()
    all_parties <- c()
    current_party <- NA_character_

    # Recursive function to traverse all nodes (including nested)
    traverse_nodes <- function(node) {
      node_name <- rvest::html_name(node)

      if (node_name == "b") {
        # This is a party name - update current party
        current_party <<- rvest::html_text2(node)
      } else if (node_name == "a") {
        # This is a person link
        all_persons <<- c(all_persons, rvest::html_text2(node))
        all_urls <<- c(all_urls, rvest::html_attr(node, "href"))
        all_parties <<- c(all_parties, current_party)
      }

      # Recursively process child nodes
      children <- rvest::html_children(node)
      if (length(children) > 0) {
        for (child in children) {
          traverse_nodes(child)
        }
      }
    }

    # Start traversal from the table node
    traverse_nodes(table_node)

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
  dplyr::bind_rows(all_results) %>%
    dplyr::select(-"table_index") %>%
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

    purrr::map_dfr(seq_along(rows), function(i) {
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
    })
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
    idx_v <- which(stringr::str_detect(df_members_raw$X2, "^Vorsitzender|^Ob"))[1]
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
      member_url = purrr::map2_chr(.data$url_split, .data$member_idx, function(urls, idx) {
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
      })
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
      member_url = purrr::map2_chr(.data$url_split, .data$member_idx, function(urls, idx) {
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
      })
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
      member_url = purrr::map2_chr(.data$url_split, .data$member_idx, function(urls, idx) {
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
      })
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
      state = stringr::str_extract(.data$name, stringr::regex("(?<=\\().*(?=\\))"))
    ) %>%
    dplyr::mutate(name = stringr::str_remove(.data$name, stringr::regex("\\s\\(.*$")))

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
      state = stringr::str_extract(.data$name, stringr::regex("(?<=\\().*(?=\\))"))
    ) %>%
    dplyr::mutate(name = stringr::str_remove(.data$name, stringr::regex("\\s\\(.*$")))

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
      state = stringr::str_extract(.data$name, stringr::regex("(?<=\\().*(?=\\))"))
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


#' Extract members from Type 3 committee pages (SA-P9 and A-USA)
#'
#' Internal helper for extracting committee membership from pages with
#' non-standard 3-column table structures (SA-P9 joint committees and A-USA
#' investigation committees). These pages have tables that use different column
#' naming and member URL patterns than standard committee pages.
#'
#' @param url Character. URL to the committee membership page
#' @param html_doc Optional. Pre-parsed HTML document from rvest::read_html().
#'   If NULL, the function will read the URL.
#'
#' @return A tibble with columns:
#'   - name: character; member name
#'   - member_type: character; "member", "substitute", or leadership role
#'   - party: character; party affiliation
#'   - member_url: character; URL to member's profile page
#'
#' @details
#' Type 3 pages differ from Type 2 in several ways:
#' - Use /person/ID URLs instead of /WWER/PAD_ID
#' - Tables may have different column names (not always X1, X2, X3)
#' - SA-P9 pages have separate Nationalrat and Bundesrat sections
#' - Member links must be extracted from HTML separately from table text
#'
#' @keywords internal
#' @noRd
fn_extract_committees_type3_old <- function(url, html_doc = NULL) {
  # Read HTML if not provided
  if (is.null(html_doc)) {
    url <- if (
      stringr::str_detect(url, stringr::regex("^https://www.parlament.gv.at"))
    ) {
      url
    } else {
      paste0("https://www.parlament.gv.at", url)
    }
    html_doc <- url %>% rvest::read_html()
  }

  # Extract all member links from the page
  all_links <- html_doc %>% rvest::html_elements("a")
  member_links <- list()
  member_names <- character()
  member_urls <- character()

  for (link in all_links) {
    href <- rvest::html_attr(link, "href")
    if (!is.na(href) && stringr::str_detect(href, "/WWER/PAD_|/person/")) {
      name <- rvest::html_text2(link)
      # Make URL absolute
      if (!stringr::str_detect(href, "^https://")) {
        href <- paste0("https://www.parlament.gv.at", href)
      }
      member_names <- c(member_names, name)
      member_urls <- c(member_urls, href)
    }
  }

  # If no member links found, return empty result
  if (length(member_names) == 0) {
    warning(paste0("No member links found in URL: ", url))
    return(tibble::tibble(
      name = NA_character_,
      member_type = NA_character_,
      party = NA_character_,
      member_url = NA_character_
    ))
  }

  # Get all tables
  tables <- html_doc %>% rvest::html_table()

  # Find tables with "Mitglieder:" pattern (member tables)
  member_tables <- list()
  for (i in seq_along(tables)) {
    df <- tables[[i]]
    # Check if any cell contains "Mitglieder:"
    has_mitglieder <- any(sapply(df, function(col) {
      any(stringr::str_detect(col, "Mitglieder:"), na.rm = TRUE)
    }))

    if (has_mitglieder && ncol(df) >= 2) {
      member_tables[[length(member_tables) + 1]] <- df
    }
  }

  # If no member tables found, return members without detailed structure
  if (length(member_tables) == 0) {
    return(tibble::tibble(
      name = member_names,
      member_type = "member",
      party = NA_character_,
      member_url = member_urls
    ))
  }

  # Process each member table to extract structured information
  all_members <- list()
  member_idx <- 1

  for (tbl in member_tables) {
    # Use positional indexing - don't assume column names
    col1 <- tbl[[1]] # Party column
    col2 <- tbl[[2]] # Regular members column
    col3 <- if (ncol(tbl) >= 3) tbl[[3]] else rep(NA_character_, nrow(tbl)) # Substitute members column

    for (row_idx in seq_len(nrow(tbl))) {
      # Extract party from column 1
      party_text <- col1[row_idx]
      party <- if (!is.na(party_text) && party_text != "") {
        # Extract party name before colon and parentheses
        stringr::str_extract(party_text, "^[^:\\(]+") %>%
          stringr::str_trim()
      } else {
        NA_character_
      }

      # Process regular members (column 2)
      members_text <- col2[row_idx]
      if (
        !is.na(members_text) &&
          members_text != "" &&
          !stringr::str_detect(
            members_text,
            "^Mitglieder:|^Vorsitzend|^Obmann|^Schriftführer"
          )
      ) {
        # Split by newlines to get individual names
        names_in_cell <- stringr::str_split(members_text, "\\n+")[[1]] %>%
          stringr::str_trim()
        names_in_cell <- names_in_cell[names_in_cell != ""]

        for (name in names_in_cell) {
          # Skip if this is just a state code like "(St)" or "(W)"
          if (stringr::str_detect(name, "^\\([A-Z]+\\)$")) {
            next
          }

          # Find matching member link by partial name match
          if (member_idx <= length(member_names)) {
            all_members[[length(all_members) + 1]] <- list(
              name = member_names[member_idx],
              member_type = "member",
              party = party,
              member_url = member_urls[member_idx]
            )
            member_idx <- member_idx + 1
          }
        }
      }

      # Process substitute members (column 3)
      if (
        !is.na(col3[row_idx]) &&
          col3[row_idx] != "" &&
          !stringr::str_detect(
            col3[row_idx],
            "^Ersatzmitglieder:|^Vorsitzend|^Obmann|^Schriftführer"
          )
      ) {
        names_in_cell <- stringr::str_split(col3[row_idx], "\\n+")[[1]] %>%
          stringr::str_trim()
        names_in_cell <- names_in_cell[names_in_cell != ""]

        for (name in names_in_cell) {
          if (stringr::str_detect(name, "^\\([A-Z]+\\)$")) {
            next
          }

          if (member_idx <= length(member_names)) {
            all_members[[length(all_members) + 1]] <- list(
              name = member_names[member_idx],
              member_type = "substitute",
              party = party,
              member_url = member_urls[member_idx]
            )
            member_idx <- member_idx + 1
          }
        }
      }
    }
  }

  # Convert to tibble
  if (length(all_members) == 0) {
    # Fallback: return all members without structure
    return(tibble::tibble(
      name = member_names,
      member_type = "member",
      party = NA_character_,
      member_url = member_urls
    ))
  }

  result <- dplyr::bind_rows(all_members)

  # Clean up text fields
  result <- result %>%
    dplyr::mutate(
      across(c("name", "party", "member_type"), \(x) {
        stringr::str_trim(x) %>% stringr::str_squish()
      })
    ) %>%
    dplyr::filter(!is.na(.data$name), .data$name != "")

  return(result)
}
