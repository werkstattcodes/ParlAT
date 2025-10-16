#' Retrieve Transcripts from the Austrian Parliament API
#'
#' `get_transcripts()` retrieves the transcripts of parlamentary sessions via Parliament's API (see <a href="https://www.parlament.gv.at/recherchieren/protokolle/index.html" target="_blank" rel="noopener">here.</a>)
#'
#' @param search_string Optional character string to filter transcripts by keywords. Defaults to NULL.
#' @param legis_period Legislative period(x). Default NULL queries for all legislative periods. Accepts numeric, character or roman numerals in character format as well as "KN" (Konstituierende Nationalversammlung) and "PN" (Provisorische Nationalversammlung).
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
#'   get_transcripts()?
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
    # legis_period_input <- as.character(utils::as.roman(legis_period)) #wrong if PN or KN
    legis_period_input <- aux_convert_legis_periods(
        legis_period,
        output = "roman"
    )

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

    # API REQUEST - using showAll=TRUE to get all data in a single call
    resp <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/211"
    ) |>
        httr2::req_method("POST") |>
        httr2::req_url_query(
            js = "eval",
            showAll = TRUE,
            search = search_string,
            ascDesc = "desc",
            export = TRUE
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
        ) |>
        httr2::req_perform()

    # EXTRACT DATA - single response with all data
    json_data <- httr2::resp_body_json(resp, simplifyVector = TRUE)

    # Extract rows
    df_res <- json_data |>
        purrr::pluck("rows") |>
        as.data.frame()

    # Extract and clean column names
    vec_headings <- json_data |>
        purrr::pluck("header", "label") |>
        janitor::make_clean_names()

    colnames(df_res) <- vec_headings

    # Convert inr to numeric
    df_res <- df_res |>
        dplyr::mutate(inr = as.numeric(inr))

    # ECHO - print request details if requested
    if (echo == TRUE) {
        print(body_params)
        # print url to results / transparency reasons / add search string parameter
        body_params_li <- jsonlite::fromJSON(body_params) |>
            c("search" = search_string)

        query_string <- purrr::imap(
            body_params_li,
            \(x, y) glue::glue("STENO_211{URLencode(y)}={URLencode(x)}")
        ) |>
            unlist() |>
            unname() |>
            paste0(collapse = "&")

        print(glue::glue(
            "https://www.parlament.gv.at/recherchieren/protokolle/index.html?{query_string}"
        ))

        print(nrow(df_res))
    }

    # SELECT AND RENAME COLUMNS
    renaming_map <- c(
        "datum" = "date",
        "uri" = "session_url",
        "gp_code" = "legis_period",
        "art" = "session_type",
        "zitation" = "session_number",
        "sitzung" = "session",
        "gesamtprotokoll" = "session_transcript"
    )

    df_res <- df_res |>
        dplyr::rename_with(
            .fn = \(x) renaming_map[x],
            .cols = any_of(names(renaming_map))
        )

    df_res <- df_res |>
        dplyr::select(dplyr::any_of(unname(renaming_map))) %>%
        dplyr::mutate(date = lubridate::dmy(date))

    aux_fn_get_hrefs <- function(html_string) {
        if (is.na(html_string) || html_string == "") {
            return(c(
                html = NA_character_,
                pdf = NA_character_
            ))
        }

        extract_all_hrefs <- purrr::possibly(
            \(html) {
                hrefs <- html |>
                    rvest::read_html() |>
                    rvest::html_elements("a") |>
                    rvest::html_attr("href")

                # Filter and separate HTML and PDF links
                html_href <- hrefs[stringr::str_ends(
                    hrefs,
                    "\\.html"
                )]
                pdf_href <- hrefs[stringr::str_ends(
                    hrefs,
                    "\\.pdf"
                )]

                # Create named vector: [html, pdf]
                html_url <- if (length(html_href) > 0) {
                    html_href[1]
                } else {
                    NA_character_
                }
                pdf_url <- if (length(pdf_href) > 0) {
                    pdf_href[1]
                } else {
                    NA_character_
                }

                return(c(html = html_url, pdf = pdf_url))
            },
            otherwise = c(
                html = NA_character_,
                pdf = NA_character_
            )
        )

        extract_all_hrefs(html_string)
    }

    df_res <- df_res |>
        dplyr::mutate(
            session_transcript = map(session_transcript, \(x) {
                aux_fn_get_hrefs(x)
            })
        ) |>
        tidyr::unnest_wider(session_transcript, names_sep = "_") |>
        dplyr::mutate(across(starts_with("session_transcript"), \(x) {
            dplyr::if_else(
                is.na(x) | stringr::str_starts(x, "http"),
                x,
                paste0("https://www.parlament.gv.at", x)
            )
        }))

    return(df_res %>% dplyr::arrange(date))
}
