#' Retrieve Transcripts from the Austrian Parliament API
#'
#' `get_transcripts()` retrieves the transcripts of parliamentary sessions via Parliament's API (see <a href="https://www.parlament.gv.at/recherchieren/protokolle/index.html" target="_blank" rel="noopener">here</a>).
#'
#' @param search_string Optional character string to filter transcripts by keywords. Defaults to NULL.
#' @param legis_period Legislative period(s). Default NULL queries for all legislative periods. Accepts numeric (10), character ("10") or roman numerals in character format ("X") as well as "KN" (Konstituierende Nationalversammlung) and "PN" (Provisorische Nationalversammlung).
#' @param session_type Optional character string specifying the type(s) of session (e.g., "NRSITZ", "BRSITZ",
#'   "USA", etc.). Defaults to NULL. See Details for complete list of session types.
#' @param date_start Optional start date for filtering transcripts. Defaults to NULL. Date has to be in dmy-format (e.g. "01.05.2020", "01/05/2020", "01-05-2020", "01052020").
#' @param date_end Optional end date for filtering transcripts. Defaults to NULL. Date has to be in dmy-format (e.g. "01.05.2020", "01/05/2020", "01-05-2020", "01052020").
#' @param echo Logical. If TRUE, the function prints the used search parameters and the url to the pertaining search results on the website of the Austrian Parliament. Default is NULL.
#' @param export Optional character string to enable PDF downloads. Set to "pdf" to download transcript PDFs. Defaults to NULL (no export).
#' @param export_destination Character string specifying the directory path where PDFs will be saved. Defaults to "transcripts" (a folder in the current working directory). If the folder does not exist, the user will be prompted to create it in interactive sessions.
#' @return A tibble containing transcript data with the following columns:
#'   \describe{
#'     \item{date}{Date of the session}
#'     \item{session_url}{URL to the session page}
#'     \item{legis_period}{Legislative period}
#'     \item{session_type}{Type of session}
#'     \item{session_number}{Session number/citation}
#'     \item{session}{Session description}
#'     \item{session_transcript_html}{URL to HTML transcript (if available)}
#'     \item{session_transcript_pdf}{URL to PDF transcript (if available)}
#'   }
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
#' * VER: Veranstaltungen (Events)
#'
#' ## Implementation Notes
#' The function uses a two-step API approach: first fetching the total count of matching
#' records, then retrieving all results in a single request. This avoids duplicate records
#' that can occur with pagination. Queries returning more than 10,000 results will raise
#' an error; use more specific filters to refine your query in such cases.
#'
#' ## PDF Export
#' When `export = "pdf"`, the function downloads PDF transcripts after retrieving the data.
#' PDF filenames follow the pattern: `YYYY-MM-DD_LegislativePeriod_SessionType_SessionNumber.pdf`.
#' The function includes a progress bar during downloads and provides a summary of successful
#' and failed downloads. In interactive sessions, users are prompted to create the destination
#' folder if it doesn't exist. The function returns the same tibble regardless of export settings.
#'
#' @examples
#' \dontrun{
#'   # Retrieve all available transcripts with default filters.
#'   get_transcripts()
#'
#'   # Retrieve transcripts using a search string and specifying a legislative period.
#'   get_transcripts(search_string = "gesundheit", legis_period = 28, session_type = "NRSITZ",
#'                 date_start = NULL, date_end = NULL)
#'
#'   # Retrieve transcripts and download PDFs to default "transcripts" folder.
#'   get_transcripts(legis_period = 27, session_type = "NRSITZ",
#'                 date_start = "01-01-2020", date_end = "31-12-2020",
#'                 export = "pdf")
#'
#'   # Download PDFs to a custom folder.
#'   get_transcripts(legis_period = 27, session_type = "NRSITZ",
#'                 export = "pdf", export_destination = "my_pdfs")
#' }
get_transcripts <- function(
    search_string = NULL,
    legis_period = NULL,
    session_type = NULL,
    date_start = NULL,
    date_end = NULL,
    echo = TRUE,
    export = NULL,
    export_destination = "transcripts"
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

    # EXPORT PARAMETERS
    checkmate::assert_choice(
        export,
        choices = c("pdf"),
        null.ok = TRUE
    )

    checkmate::assert_character(
        export_destination,
        len = 1,
        null.ok = FALSE
    )

    # DATE START; DATE END
    # Date validation
    if (!is.null(date_start)) {
        # Expect a character string parseable by lubridate::dmy()
        checkmate::assert_character(date_start, len = 1, null.ok = FALSE)
        parsed_date_start <- lubridate::dmy(date_start, quiet = TRUE)
        checkmate::assert_true(
            !is.na(parsed_date_start),
            .var.name = "date_start must be a valid date (day-month-year order)"
        )
        date_start <- format(
            as.POSIXct(parsed_date_start),
            format = "%Y-%m-%dT%H:%M:%S.000Z",
            tz = "CET"
        )
    }

    # Date end
    if (!is.null(date_end)) {
        # Expect a character string parseable by lubridate::dmy()
        checkmate::assert_character(date_end, len = 1, null.ok = FALSE)
        parsed_date_end <- lubridate::dmy(date_end, quiet = TRUE)
        checkmate::assert_true(
            !is.na(parsed_date_end),
            .var.name = "date_end must be a valid date (day-month-year order)"
        )
        date_end <- format(
            as.POSIXct(parsed_date_end),
            format = "%Y-%m-%dT%H:%M:%S.000Z",
            tz = "CET"
        )
    }

    # if is.null(date_start) and !is.null(date_end) date_start has to be fed as character "null" into API call;
    # otherwise date_start is not part of url and date_end is interpreted as date_start; same for date_end.
    if (is.null(date_start) && !is.null(date_end)) {
        date_start <- "null"
    }
    if (!is.null(date_start) && is.null(date_end)) {
        date_end <- "null"
    }

    # COLLECT PARAMETERS
    body_params <- list(
        GP_CODE = legis_period_input,
        NBVS = session_type,
        DATUM = c(date_start, date_end)
    ) |>
        purrr::compact() |> #keep only non-empty elements
        jsonlite::toJSON()

    # DEFINITION NESTED HELPER FUNCTION 1: Get total count from API
    get_total_count <- function() {
        resp <- httr2::request(
            "https://www.parlament.gv.at/Filter/api/filter/data/211"
        ) |>
            httr2::req_method("POST") |>
            httr2::req_url_query(
                js = "eval",
                page = "1",
                pagesize = "1",
                search = search_string,
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
            httr2::req_user_agent(
                "ParlAT R package (http://werk.statt.codes)"
            ) |>
            httr2::req_perform()

        resp_json <- httr2::resp_body_json(resp, simplifyVector = TRUE)
        total_count <- resp_json$count

        return(total_count)
    }

    # DEFINITION NESTED HELPER FUNCTION 2: Get all data with specified pagesize
    get_all_data <- function(total_count) {
        resp <- httr2::request(
            "https://www.parlament.gv.at/Filter/api/filter/data/211"
        ) |>
            httr2::req_method("POST") |>
            httr2::req_url_query(
                js = "eval",
                page = "1",
                pagesize = as.character(total_count),
                search = search_string,
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
            httr2::req_user_agent(
                "ParlAT R package (http://werk.statt.codes)"
            ) |>
            httr2::req_perform()

        resp_json <- httr2::resp_body_json(resp, simplifyVector = TRUE)
        return(resp_json)
    }

    # TWO-STEP API CALL PROCESS
    # Step 1: Get total count
    total_count <- get_total_count()

    # Check if no results (API returns HTTP 500 if we request pagesize = 0)
    if (total_count == 0) {
        message("Query returned 0 results.")
        # Return empty tibble with correct column structure
        return(tibble::tibble(
            date = lubridate::Date(),
            session_url = character(),
            legis_period = character(),
            session_type = character(),
            session_number = character(),
            session = character(),
            session_transcript_html = character(),
            session_transcript_pdf = character()
        ))
    }

    # Check hard limit
    if (total_count > 100000) {
        stop(
            "Query returns ",
            total_count,
            " results, which exceeds the limit of 10,000. ",
            "Please refine your query using more specific filters (e.g., narrower date range, ",
            "specific legislative period, or session type)."
        )
    }

    # Step 2: Get all data with the total count as pagesize
    resp_json <- get_all_data(total_count)

    vec_headings <- resp_json |>
        purrr::pluck("header", "label") |>
        janitor::make_clean_names()

    rows <- purrr::pluck(resp_json, "rows")

    # browser()

    if (length(rows) == 0) {
        df_res <- NULL
    } else {
        df_res <- rows |>
            as.data.frame()

        #PATCH: API returns colums and header labels of different lenghts. Those
        #labels which exceed the number of cols appear to be irrelevant; not clear why
        #they were included

        if (ncol(df_res) != length(vec_headings)) {
            print("Warning: Columns and labels of different length!")

            vec_headings <- vec_headings[1:ncol(df_res)]
        }

        colnames(df_res) <- vec_headings
    }

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
        dplyr::select(dplyr::any_of(unname(renaming_map))) |>
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
            session_transcript = purrr::map(session_transcript, \(x) {
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

    # PDF EXPORT FUNCTIONALITY
    if (!is.null(export) && export == "pdf") {
        # HELPER FUNCTION: Check and create destination folder
        ensure_destination_folder <- function(dest_path) {
            # Convert to absolute path if relative
            dest_path <- normalizePath(
                dest_path,
                winslash = "/",
                mustWork = FALSE
            )

            if (!dir.exists(dest_path)) {
                if (interactive()) {
                    message(sprintf(
                        "Folder '%s' does not exist.",
                        dest_path
                    ))
                    response <- readline(prompt = "Create it? (y/n): ")
                    if (tolower(trimws(response)) == "y") {
                        dir.create(dest_path, recursive = TRUE)
                        message(sprintf("Created folder: %s", dest_path))
                        return(dest_path)
                    } else {
                        stop(
                            "PDF export cancelled: destination folder not created.",
                            call. = FALSE
                        )
                    }
                } else {
                    stop(
                        sprintf(
                            "Destination folder '%s' does not exist. ",
                            "Please create it before running in non-interactive mode."
                        ),
                        call. = FALSE
                    )
                }
            }
            return(dest_path)
        }

        # HELPER FUNCTION: Generate filename
        generate_pdf_filename <- function(
            date,
            session_type,
            session_number,
            legis_period
        ) {
            # Clean session_number for filename (remove special characters)
            session_clean <- session_number |>
                stringr::str_replace_all("[^A-Za-z0-9_-]", "_")

            filename <- sprintf(
                "%s_%s_%s_%s.pdf",
                legis_period,
                format(date, "%Y-%m-%d"),
                session_type,
                session_clean
            )

            return(filename)
        }

        # HELPER FUNCTION: Download single PDF
        download_pdf <- function(url, dest_file) {
            tryCatch(
                {
                    httr2::request(url) |>
                        httr2::req_user_agent(
                            "ParlAT R package (http://werk.statt.codes)"
                        ) |>
                        httr2::req_perform(path = dest_file)
                    return(TRUE)
                },
                error = function(e) {
                    return(FALSE)
                }
            )
        }

        # Ensure destination folder exists
        dest_path <- ensure_destination_folder(export_destination)

        # Filter rows with valid PDF URLs
        df_to_download <- df_res |>
            dplyr::filter(!is.na(session_transcript_pdf))

        n_pdfs <- nrow(df_to_download)

        if (n_pdfs == 0) {
            message("No PDF transcripts available for download.")
        } else {
            message(sprintf(
                "Downloading %d PDF(s) to '%s'...",
                n_pdfs,
                dest_path
            ))

            # Initialize progress bar
            pb <- progress::progress_bar$new(
                format = "  [:bar] :current/:total (:percent) eta: :eta",
                total = n_pdfs,
                clear = FALSE,
                width = 60
            )

            # Download PDFs
            results <- purrr::pmap_lgl(
                list(
                    df_to_download$session_transcript_pdf,
                    df_to_download$date,
                    df_to_download$session_type,
                    df_to_download$session_number,
                    df_to_download$legis_period
                ),
                function(
                    url,
                    date,
                    session_type,
                    session_number,
                    legis_period
                ) {
                    filename <- generate_pdf_filename(
                        date,
                        session_type,
                        session_number,
                        legis_period
                    )
                    dest_file <- file.path(dest_path, filename)

                    success <- download_pdf(url, dest_file)
                    pb$tick()
                    return(success)
                }
            )

            # Summary
            n_success <- sum(results)
            n_failed <- n_pdfs - n_success

            if (n_failed == 0) {
                message(sprintf(
                    "Successfully downloaded %d PDF(s).",
                    n_success
                ))
            } else {
                warning(sprintf(
                    "Downloaded %d PDF(s). %d download(s) failed.",
                    n_success,
                    n_failed
                ))
            }
        }
    }

    return(df_res |> dplyr::arrange(date))
}
