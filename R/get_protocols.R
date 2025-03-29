#' Retrieve Protocols from the Austrian Parliament API
#'
#' This function sends a POST request to the Austrian Parliament's API to retrieve protocol data
#' based on the provided filters such as search string, legislative period, session type, and date range.
#'
#' @param search_string Optional character string to filter protocols by keywords. Defaults to NULL.
#' @param legis_period Optional numeric value representing the legislative period. This value is converted
#'   to its Roman numeral representation internally. Defaults to NULL.
#' @param session_type Optional character string specifying the type of session (e.g., "NRSITZ", "BRSITZ",
#'   "USA", etc.). Defaults to NULL.
#' @param date_start Optional start date (as character or Date) for filtering protocols. Defaults to NULL.
#' @param date_end Optional end date (as character or Date) for filtering protocols. Defaults to NULL.
#' @param echo Logical flag to indicate whether to print details of the request process. Defaults to TRUE.
#' @return An object containing the API response, which typically includes the protocol data in JSON format.
#' @details
#' ## Session Type ('Art der Sitzung')
#' * NRSITZ: Nationalrat - Plenarsitzungen (National Council - Plenary sessions)
#' * BRSITZ: Bundesrat - Plenarsitzungen (Federal Council - Plenary sessions)
#' * USA: Untersuchungsausschüsse (Inquiry Committees)
#' * ENQ: Enqueten und Enquete-Kommissionen (Inquiries and Inquiry Commissions)
#' * BVSITZ: Bundesversammlung (Federal Assembly)
#' * AUS: Ausschüsse (Committees)
#' * EU: EU-Ausschüsse (EU Committees)
#' * GFT: Gedenk-, Fest- und Trauersitzungen (Memorial, Celebratory, and Condolence Sessions)
#' * PARL: Jugend- und Lehrlingsparlament (Youth and Apprentice Parliament)

#' @examples
#' \dontrun{
#'   # Retrieve all available protocols with default filters.
#'   get_protocols()
#'
#'   # Retrieve protocols using a search string and specifying a legislative period.
#'   get_protocols(search_string = "gesundheit", legis_period = 28, session_type = "NRSITZ",
#'                 date_start = "2024-01-01", date_end = NULL)
#' }
get_protocols <- function(
    search_string = NULL,
    legis_period = NULL,
    session_type = NULL,
    date_start = NULL,
    date_end = NULL,
    echo = TRUE
) {
    # LEGISLATIVE PERIOD
    legis_period_input <- as.character(utils::as.roman(legis_period))

    # SESSION TYPES
    choices_session_type <- c(
        "NRSITZ",
        "BRSITZ",
        "USA",
        "ENQ",
        "BVSITZ",
        "AUS",
        "EU",
        "GFT",
        "PARL",
        "VER"
    )

    checkmate::assert_subset(
        session_type,
        choices_session_type,
        empty.ok = TRUE
    )

    #DATE START; DATE END
    ## TODO allow for different date types such as "yyyy-mm-dd", "mm/dd/yyyy", and "dd-mm-yyyy"
    # Date validation
    if (!is.null(date_start)) {
        # checkmate::assert_character(date_start, len = 1, null.ok = TRUE)?
        checkmate::assert_true(
            stringr::str_detect(date_start, "^\\d{2}-\\d{2}-\\d{4}$"),
            .var.name = "date_start must be in format dd-mm-yyyy"
        )
        date_start = as.Date(date_start, format = "%d-%m-%Y")
        date_start <- format(
            as.POSIXct(date_start),
            format = "%Y-%m-%dT%H:%M:%S.000Z",
            tz = "CET"
        )
    }

    #date end
    if (!is.null(date_end)) {
        checkmate::assert_character(date_end, len = 1, null.ok = TRUE)
        checkmate::assert_true(
            stringr::str_detect(date_end, "^\\d{2}-\\d{2}-\\d{4}$"),
            .var.name = "date_end must be in format dd-mm-yyyy"
        )
        date_end = as.Date(date_end, format = "%d-%m-%Y")
        date_end <- format(
            as.POSIXct(date_end),
            format = "%Y-%m-%dT%H:%M:%S.000Z",
            tz = "CET"
        )
    }

    # COLLECT PARAMETERS
    body_params <- list(
        GP_CODE = legis_period_input,
        NBVS = session_type,
        DATUM = c(date_start, date_end)
    ) |>
        purrr::compact() |> #keep only non-empty elements
        jsonlite::toJSON()

    res <- get_protocols_api_request(body_params, search_string)

    df_res <- purrr::map(res, \(x) {
        vec_headings <- x |>
            httr2::resp_body_json(simplifyVector = T) |>
            purrr::pluck("header", "label") |>
            janitor::make_clean_names()

        # extract the actual substantive data
        df_res <- x |>
            httr2::resp_body_json(simplifyVector = T) |>
            purrr::pluck("rows") %>%
            as.data.frame()

        if (length(df_res) == 0) {
            message("No results found for the provided search criteria.")
            return(NULL)
        }

        colnames(df_res) <- vec_headings

        return(df_res)
    }) %>%
        purrr::list_rbind()

    checkmate::check_data_frame(df_res, min.rows = 1)

    if (echo == TRUE) {
        print(body_params)
        # print url to results / transparency reasons / add search string parameter
        body_params_li <- jsonlite::fromJSON(body_params) %>%
            c(., "search" = search_string)

        query_string <- purrr::imap(
            body_params_li,
            \(x, y) glue::glue("STENO_211{URLencode(y)}={URLencode(x)}")
        ) %>%
            unlist() |>
            unname() |>
            paste0(collapse = "&")

        print(glue::glue(
            "https://www.parlament.gv.at/recherchieren/protokolle/index.html?{query_string}"
        ))

        print(nrow(df_res))
    }

    return(df_res)
}


#' Retrieve Protocols via API Request
#'
#' This function constructs and sends a POST request to the ParlAT API endpoint
#' for retrieving protocol data. It uses the httr2 package to build the request,
#' including setting specific query parameters (such as page, pagesize, search term, and sort order)
#' and necessary headers (like Accept, User-Agent, and others) to emulate a browser request.
#'
#' The function supports iterative fetching by automatically handling pagination.
#' It continues making requests until the number of rows returned is less than the specified page size,
#' indicating that the final page has been reached.
#'
#' @param body_params A JSON string representing the body parameters for the POST request.
#' @param search_string A string used as a search parameter in the query to filter protocols.
#'
#' @return A list containing the concatenated responses from all successful paginated API requests.
#'
#' @details
#' Internally, the function defines a helper 'is_complete' to determine if the current response
#' indicates that there is no further data to fetch. The pagination is managed by incrementing the
#' 'page' parameter until fewer items than the page size are returned.
#'
#' @examples
#' \dontrun{
#'   # Define JSON body parameters and a search string
#'   json_body <- '{"key": "value"}'
#'   search_query <- "health"
#'
#'   # Retrieve protocols from the API
#'   protocols <- get_protocols_api_request(json_body, search_query)
#'
#'   # View the structure of the result
#'   print(str(protocols))
#' }
get_protocols_api_request <- function(body_params, search_string) {
    req <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/211"
    ) |>
        httr2::req_method("POST") |>
        req_url_query(
            js = "eval",
            page = "1",
            pagesize = "10",
            search = search_string,
            ascDesc = "DESC"
        ) |>
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            # referer = "https://www.parlament.gv.at/recherchieren/protokolle/index.html?STENO_211GP_CODE=XXVIII&STENO_211NBVS=NRSITZ&STENO_211DATUM=2024-01-01T00%3A00%3A00.000Z&STENO_211DATUM=null&STENO_211search=gesundheit",
            `sec-ch-ua` = '"Chromium";v="134", "Not:A-Brand";v="24", "Microsoft Edge";v="134"',
            `sec-ch-ua-mobile` = "?0",
            `sec-ch-ua-platform` = '"Windows"',
            `sec-fetch-dest` = "empty",
            `sec-fetch-mode` = "cors",
            `sec-fetch-site` = "same-origin",
            `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edg/134.0.0.0" #,
            # cookie = "pddsgvo=j; _pk_id.1.26ca=2b9c3ab31363e4f4.1742073577.; _pk_ref.1.26ca=%5B%22%22%2C%22%22%2C1742538939%2C%22https%3A%2F%2Fwww.bing.com%2F%22%5D; _pk_ses.1.26ca=1"
        ) |>
        httr2::req_body_raw(
            body_params,
            type = "application/json"
        ) |>
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
        httr2::req_verbose(
            body_req = F,
            header_req = F,
            header_resp = F,
            body_resp = F,
            info = F
        )

    is_complete <- function(resp) {
        df_resp_current <- resp |>
            httr2::resp_body_json(simplifyVector = T)

        df_resp_current <- df_resp_current %>%
            purrr::pluck("rows") %>%
            as.data.frame()

        # print(nrow(df_resp_current))

        nrow(df_resp_current) < 10 #dependent on page size parameter
    }

    resp <- httr2::req_perform_iterative(
        req,
        next_req = httr2::iterate_with_offset(
            param_name = "page",
            start = 1,
            offset = 1,
            resp_complete = \(resp) is_complete(resp)
        ),
        max_reqs = Inf
    )

    # return result
    return(resp)
}
