#' Retrieve Committee Data from the Austrian Parliament API
#'
#' Get data on the committees ('Ausschüsse') of the Austrian Parliament. Data includes session dates, agendas, meeting overviews, and member lists.
#' The function partly mirrors the search functionality of the Austrian Parliament's website for committees
#' <a href="https://www.parlament.gv.at/recherchieren/ausschuesse/index.html" target="_blank">here</a> and extends it by
#' e.g. incorporating the extraction of data from membership lists.
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
  citation = NULL,
  include_subcommittees = NULL, #auch Unterausschüsse - UA
  details = FALSE,
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
  # checkmate::assert_logical(details, len = 1, null.ok = FALSE)
  checkmate::assert_logical(echo, len = 1, null.ok = TRUE)

  # LEGIS PERIOD: required argument
  checkmate::assert(
    !missing(legis_period),
    .var.name = "legis_period is required"
  )

  # LEGIS PERIOD: must be length 1, accepts numeric or character
  checkmate::assert(
    checkmate::check_integerish(legis_period, len = 1) ||
      checkmate::check_character(legis_period, len = 1),
    .var.name = "legis_period"
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

  #SELECT RELEVANT COLUMNS
  df_res <- df_res |>
    dplyr::mutate(
      id_number = stringr::str_extract(link, stringr::regex("\\d+$")) %>%
        as.integer()
    ) %>%
    dplyr::mutate(
      citation = stringr::str_remove(
        link,
        stringr::regex("^/ausschuss/[IVXLCDM]+/")
      ) %>%
        stringr::str_remove(., stringr::regex("/\\d+$"))
    ) %>%
    dplyr::select(any_of(
      c(
        "committee" = "ausschuss",
        "url_committee" = "link",
        "id_number",
        "citation"
      )
    )) |>
    dplyr::mutate(
      url_committee = paste0(
        "https://www.parlament.gv.at",
        url_committee
      )
    )

  # Pseudo filter
  if (!is.null(citation)) {
    df_res <- df_res %>%
      dplyr::filter(citation %in% {{ citation }})
  }

  #GET DETAILS
  if (!is.null(details_type)) {
    df_res <- df_res |>
      dplyr::mutate(
        details = purrr::map2(
          url_committee,
          {{ details_type }},
          \(x, y) {
            get_committee_details(url_committee = x, details_type = y)
          },
          .progress = TRUE
        )
      ) |>
      tidyr::unnest_wider(details) %>%
      tidyr::unnest({{ details_type }})
  }

  if (is.null(details_type)) {
    df_res <- df_res %>%
      dplyr::mutate(legis_period = legis_period, .before = 1) %>%
      dplyr::select(legis_period, committee, citation, id_number, url_committee)
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

    # print(nrow(df_res))
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


get_committee_details <- function(url_committee, details_type) {
  # url_committee <- "https://www.parlament.gv.at/ausschuss/XXVIII/A-AS/1/00917"

  # print(url_committee)
  # print(details_type)

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
      # title = li_details |>
      #   purrr::pluck("content", "title", .default = NA_character_),
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
      # names = list(
      #   li_details |> purrr::pluck("content", "names", .default = list())
      # ),
      documents = list(
        li_details |> purrr::pluck("content", "documents", .default = list())
      ) #,
      # assignments = list(
      #   li_details |> purrr::pluck("content", "assignments", .default = list())
      # ),
      # recentagenda = list(
      #   li_details |> purrr::pluck("content", "recentagenda", .default = list())
      # ),
      # recentreports = list(
      #   li_details |>
      #     purrr::pluck("content", "recentreports", .default = list())
      # ),
      # stages = list(
      #   li_details |>
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

    df_details <- df_details |>
      dplyr::select(any_of(cols_select))

    df_details <- df_details %>%
      dplyr::rename(
        # citation = zitation,
        legis_period = gp_code,
        # committee_id = aus_id,
        date_start = aus_von,
        date_end = aus_bis
      ) %>%
      dplyr::relocate(
        legis_period,
        .before = 1
      ) %>%
      dplyr::mutate(
        across(dplyr::starts_with("date"), \(x) lubridate::ymd_hms(x))
      )

    df_details <- df_details |>
      tidyr::unnest(documents) |>
      tidyr::unnest(documents) %>%
      tidyr::pivot_wider(
        id_cols = c(
          legis_period,
          # citation,
          # committee_id,
          date_start,
          date_end,
          title
        ),
        names_from = type,
        values_from = link
      ) %>%
      dplyr::rename(
        any_of(c(
          url_pdf = "PDF",
          url_html = "HTML"
        ))
      )

    #remove links to member list with fotos; would duplicate retrieval of members & features different page structure
    df_details <- df_details %>%
      dplyr::filter(!stringr::str_detect(url_html, stringr::regex("FOTO")))

    # print(df_details$url_html)

    df_details <- df_details %>%
      # dplyr::filter(!stringr::str_detect(url_pdf, stringr::regex("FOTO"))) %>% #remove url to 'bebildertes mitgliederverzeichnis to avoid duplicates"
      dplyr::mutate(
        members = map(url_html, \(x) safe_get_committee_members(x))
      )
  }

  # IF DETAILS_TYPE="agenda"

  return(df_details)
}

safe_get_committee_members <- function(url) {
  result <- tryCatch(
    get_committee_members(url),
    error = function(e) {
      message(paste0("Failed to extract members for: ", url))
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

  # print(url)

  # Read table to determine structure type
  # Type 1: 2 columns (no substitute members)
  # Type 2: 3 columns (includes Ersatzmitglieder - substitute members)
  df_check <- url %>%
    rvest::read_html() %>%
    rvest::html_table() %>%
    .[[1]]

  # Determine type based on number of columns
  is_type1 <- ncol(df_check) == 2

  # print(paste("url", url))
  # print(paste("Number of columns:", ncol(df_check)))
  # print(paste("is_type1 (2 columns, no substitute members):", is_type1))

  if (is_type1) {
    fn_extract_hauptausschuss(url)
  } else {
    # Type 2: 3 columns with regular and substitute members
    fn_extract_committees_other(url)
  }
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
    dplyr::select(-table_index) %>%
    dplyr::select(name, member_type, party, member_url)
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
  df_members_raw <- html_doc %>%
    rvest::html_table() %>%
    .[[1]]

  # Get table element for URL extraction
  table_element <- html_doc %>%
    rvest::html_elements("table") %>%
    .[[1]]

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

  df_members <- df_members_raw %>%
    {
      idx_m <- which(stringr::str_detect(.$X2, "^Mitglieder"))[1]
      idx_v <- which(stringr::str_detect(.$X2, "^Vorsitzender|^Ob"))[1]
      if (is.na(idx_m) || is.na(idx_v) || idx_v <= idx_m + 1) {
        tibble::tibble()
      } else {
        dplyr::slice(., (idx_m + 1):(idx_v - 1))
      }
    }

  df_members_first <- df_members %>%
    dplyr::select(X1, X2, url_X2, row_num_orig) %>%
    dplyr::mutate(
      X2 = stringr::str_replace_all(X2, stringr::regex("\n{2,}"), "--")
    ) %>%
    dplyr::mutate(X2 = stringr::str_split(X2, stringr::regex("--"))) %>%
    dplyr::mutate(
      url_split = stringr::str_split(url_X2, stringr::regex(" \\| "))
    ) %>%
    # Remove empty/NA elements from name list
    dplyr::mutate(X2 = purrr::map(X2, ~ .x[!is.na(.x) & .x != ""])) %>%
    tidyr::unnest_longer(X2) %>%
    # Match URLs by position
    dplyr::group_by(row_num_orig) %>%
    dplyr::mutate(member_idx = dplyr::row_number()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      member_url = purrr::map2_chr(url_split, member_idx, function(urls, idx) {
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
      X1 = stringr::str_extract(X1, stringr::regex("^[^:]*\\s"))
    ) %>%
    dplyr::rename(party = X1, name = X2) %>%
    dplyr::mutate(member_type = "member", .before = 1) %>%
    dplyr::mutate(across(c(party, name, member_type), \(x) {
      stringr::str_trim(x) %>% stringr::str_squish(.)
    })) %>%
    dplyr::filter(name != "") %>%
    dplyr::select(-url_X2, -url_split, -member_idx, -row_num_orig)

  df_members_second <- df_members %>%
    dplyr::select(X1, X3, url_X3, row_num_orig) %>%
    dplyr::mutate(
      X3 = stringr::str_replace_all(X3, stringr::regex("\n{2,}"), "--")
    ) %>%
    dplyr::mutate(X3 = stringr::str_split(X3, stringr::regex("--"))) %>%
    dplyr::mutate(
      url_split = stringr::str_split(url_X3, stringr::regex(" \\| "))
    ) %>%
    # Remove empty/NA elements from name list
    dplyr::mutate(X3 = purrr::map(X3, ~ .x[!is.na(.x) & .x != ""])) %>%
    tidyr::unnest_longer(X3) %>%
    # Match URLs by position
    dplyr::group_by(row_num_orig) %>%
    dplyr::mutate(member_idx = dplyr::row_number()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      member_url = purrr::map2_chr(url_split, member_idx, function(urls, idx) {
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
      X1 = stringr::str_extract(X1, stringr::regex("^[^:]*\\s"))
    ) %>%
    dplyr::rename(party = X1, name = X3) %>%
    dplyr::mutate(member_type = "substitute", .before = 1) %>%
    dplyr::mutate(across(c(party, name, member_type), \(x) {
      stringr::str_trim(x) %>% stringr::str_squish(.)
    })) %>%
    dplyr::filter(name != "") %>%
    dplyr::select(-url_X3, -url_split, -member_idx, -row_num_orig)

  df_members <- dplyr::bind_rows(df_members_first, df_members_second)

  df_office <- df_members_raw %>%
    dplyr::mutate(row_num = dplyr::row_number()) %>%
    dplyr::filter(
      row_num >=
        {
          match_rows <- which(stringr::str_detect(
            X2,
            stringr::regex("^(Vorsitzender|Ob)")
          ))
          if (length(match_rows) == 0) Inf else min(match_rows)
        }
    ) %>%
    dplyr::select(-row_num, -X1) %>%
    dplyr::filter(X2 != "") %>%
    dplyr::select(X2, X3, url_X3, row_num_orig) %>%
    dplyr::mutate(
      X3 = stringr::str_replace_all(X3, stringr::regex("\n{2,}"), "--")
    ) %>%
    dplyr::mutate(X3 = stringr::str_split(X3, stringr::regex("--"))) %>%
    dplyr::mutate(
      url_split = stringr::str_split(url_X3, stringr::regex(" \\| "))
    ) %>%
    # Remove empty/NA elements from name list
    dplyr::mutate(X3 = purrr::map(X3, ~ .x[!is.na(.x) & .x != ""])) %>%
    tidyr::unnest_longer(X3) %>%
    # Match URLs by position
    dplyr::group_by(row_num_orig) %>%
    dplyr::mutate(member_idx = dplyr::row_number()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      member_url = purrr::map2_chr(url_split, member_idx, function(urls, idx) {
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
    dplyr::mutate(X2 = stringr::str_remove(X2, ":$")) %>%
    dplyr::rename(name = X3, member_type = X2) %>%
    dplyr::select(-url_X3, -url_split, -member_idx, -row_num_orig)

  dplyr::bind_rows(df_office, df_members_first, df_members_second) %>%
    dplyr::select(name, member_type, party, member_url)
}
