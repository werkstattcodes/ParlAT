#' Retrieve Transcripts from the Austrian Parliament API
#'
#' This function sends a POST request to the Austrian Parliament's API to retrieve transcript data
#' based on the provided filters such as search string, legislative period, session type, and date range.
#'
#' @param search_string Optional character string to filter transcripts by keywords. Defaults to NULL.
#' @param legis_period Optional numeric value representing the legislative period. This value is converted
#'   to its Roman numeral representation internally. Defaults to NULL.
#' @param session_type Optional character string specifying the type of session (e.g., "NRSITZ", "BRSITZ",
#'   "USA", etc.). Defaults to NULL.
#' @param date_start Optional start date (as character or Date) for filtering transcripts. Defaults to NULL.
#' @param date_end Optional end date (as character or Date) for filtering transcripts. Defaults to NULL.
#' @param echo Logical flag to indicate whether to print details of the request process. Defaults to TRUE.
#' @return An object containing the API response, which typically includes the transcript data in JSON format.
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
#'   # Retrieve all available transcripts with default filters.
#'   get_transcripts()
#'
#'   # Retrieve transcripts using a search string and specifying a legislative period.
#'   get_transcripts(search_string = "gesundheit", legis_period = 28, session_type = "NRSITZ",
#'                 date_start = "2024-01-01", date_end = NULL)
#' }
get_transcripts <- function(
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

    req <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/211"
    ) |>
        httr2::req_method("POST") |>
        httr2::req_url_query(
            js = "eval",
            showAll = TRUE,
            search = search_string,
            ascDesc = "DESC"
        ) |>
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            `sec-ch-ua` = '"Chromium";v="134", "Not:A-Brand";v="24", "Microsoft Edge";v="134"',
            `sec-ch-ua-mobile` = "?0",
            `sec-ch-ua-platform` = '"Windows"',
            `sec-fetch-dest` = "empty",
            `sec-fetch-mode` = "cors",
            `sec-fetch-site` = "same-origin",
            `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edg/134.0.0.0"
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

    resp <- httr2::req_perform(req)

    resp_json <- httr2::resp_body_json(resp, simplifyVector = TRUE)

    vec_headings <- resp_json |>
        purrr::pluck("header", "label") |>
        janitor::make_clean_names()

    rows <- purrr::pluck(resp_json, "rows")

    if (length(rows) == 0) {
        df_res <- NULL
    } else {
        df_res <- rows %>%
            as.data.frame()

        colnames(df_res) <- vec_headings
    }

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

        print(if (is.null(df_res)) 0 else nrow(df_res))
    }

    if (is.null(df_res) || nrow(df_res) == 0) {
        message("No results found for the provided search criteria.")
        return(NULL)
    }

    checkmate::assert_data_frame(df_res, min.rows = 1)

    return(df_res)
}
