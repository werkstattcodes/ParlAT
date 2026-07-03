#' Retrieve Transcripts from the Austrian Parliament API
#'
#' `get_transcripts()` retrieves the transcripts of parliamentary meetings via Parliament's API (see <a href="https://www.parlament.gv.at/recherchieren/protokolle/index.html" target="_blank" rel="noopener">here</a>).
#'
#' @param search_string Optional character string to filter transcripts by keywords. Defaults to NULL.
#' @param legis_period Legislative period(s). Default NULL queries for all legislative periods. Accepts numeric (10), character ("10") or roman numerals in character format ("X") as well as "KN" (Konstituierende Nationalversammlung) and "PN" (Provisorische Nationalversammlung).
#' @param meeting_type Optional character string specifying the type(s) of meeting. Permissible values are "NRSITZ" (National Council - Plenary meetings) and "BRSITZ" (Federal Council - Plenary meetings). Defaults to NULL, which queries both NRSITZ and BRSITZ. See Details for more information.
#' @param date_start Optional start date for filtering transcripts. Defaults to NULL. Date has to be in dmy-format (e.g. "01.05.2020", "01/05/2020", "01-05-2020", "01052020").
#' @param date_end Optional end date for filtering transcripts. Defaults to NULL. Date has to be in dmy-format (e.g. "01.05.2020", "01/05/2020", "01-05-2020", "01052020").
#' @param echo Logical. If TRUE, the function prints the URL to the pertaining search results on the website of the Austrian Parliament and the number of results. Default is NULL.
#' @param export Optional character string to enable PDF downloads. Set to "pdf" to download transcript PDFs. Defaults to NULL (no export).
#' @param export_destination Character string specifying the directory path where PDFs will be saved. Defaults to "transcripts" (a folder in the current working directory). If the folder does not exist, the user will be prompted to create it in interactive meetings.
#' @return A tibble containing transcript data with the following columns:
#'   \describe{
#'     \item{date}{Date of the meeting}
#'     \item{meeting_url}{URL to the meeting page}
#'     \item{legis_period}{Legislative period}
#'     \item{meeting_type}{Type of meeting}
#'     \item{meeting_number}{Meeting number/citation}
#'     \item{meeting}{Meeting description}
#'     \item{meeting_transcript_html}{URL to HTML transcript (if available)}
#'     \item{meeting_transcript_pdf}{URL to PDF transcript (if available)}
#'   }
#' @details
#' ## Meeting Type ('Art der Sitzung')
#' Permissible values for `meeting_type`:
#' * NRSITZ: Nationalrat - Plenarsitzungen (National Council - Plenary meetings)
#' * BRSITZ: Bundesrat - Plenarsitzungen (Federal Council - Plenary meetings)
#'
#' Note: Querying for other meeting types (Untersuchungsausschüsse, Enqueten, Bundesversammlung,
#' Ausschüsse, EU-Ausschüsse, Gedenk-/Fest-/Trauersitzungen, Jugend- und Lehrlingsparlament, Veranstaltungen)
#' is currently only possible via the Parliament's website.
#'
#' ## Implementation Notes
#' Queries returning more than 10,000 results will raise
#' an error; in these cases it is recommended to cut your query into
#' multiple steps (e.g. by using the purrr package).
#'
#' ## PDF Export
#' When `export = "pdf"`, the function additionaly downloads the PDF files of the transcripts.
#' The default destination is the folder "transcripts", which will be created in the root of the
#' project. In interactive meetings, users are prompted to create the destination
#' folder if it doesn't exist, and if prefered, to provide an alternative destination name.
#' PDF filenames follow the pattern: `YYYY-MM-DD_LegislativePeriod_MeetingType_MeetingNumber.pdf`.
#' A summary of successful and failed downloads is printed at the conclusion of the download.
#' @export
#' @examples
#' \donttest{
#'   # Get transcripts using a search string and specifying a legislative period.
#'   result <- get_transcripts(search_string = "gesundheit",
#'                   legis_period = 28,
#'                   meeting_type = "NRSITZ",
#'                   echo = TRUE)
#'   dplyr::glimpse(result)
#'
#'  # Get transcript data for a specific period of time.
#'  result <- get_transcripts(meeting_type = "BRSITZ",
#'                  date_start = "01-01-2024",
#'                  date_end = "30-06-2024",
#'                  echo = TRUE)
#'  dplyr::glimpse(result)
#' }
#' \dontrun{
#'   # Retrieve all transcripts of National Council plenary meetings
#'   # and download PDFs to default "transcripts" folder.
#'   get_transcripts(
#'     meeting_type = "NRSITZ",
#'     legis_period = 26,
#'     export = "pdf"
#'   )
#' }
get_transcripts <- function(
    search_string = NULL,
    legis_period = NULL,
    meeting_type = NULL,
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

    # MEETING TYPES
    choices_meeting_type <- c(
        "NRSITZ",
        "BRSITZ"
    )

    checkmate::assert_subset(
        meeting_type,
        choices_meeting_type,
        empty.ok = TRUE
    )

    # Set default: if NULL, query both NRSITZ and BRSITZ
    if (is.null(meeting_type)) {
        meeting_type <- choices_meeting_type
    }

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
        date_start <- paste0(format(parsed_date_start, "%Y-%m-%d"), "T00:00:00.000Z")
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
        date_end <- paste0(format(parsed_date_end, "%Y-%m-%d"), "T00:00:00.000Z")
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
        NBVS = meeting_type,
        DATUM = c(date_start, date_end)
    ) %>%
        purrr::compact() %>% #keep only non-empty elements
        jsonlite::toJSON()

    # DEFINITION NESTED HELPER FUNCTION 1: Get total count from API
    get_total_count <- function() {
        resp <- httr2::request(
            "https://www.parlament.gv.at/Filter/api/filter/data/211"
        ) %>%
            httr2::req_method("POST") %>%
            httr2::req_url_query(
                js = "eval",
                page = "1",
                pagesize = "1",
                search = search_string,
                export = TRUE
            ) %>%
            httr2::req_headers(
                accept = "*/*",
                `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
                origin = "https://www.parlament.gv.at"
            ) %>%
            httr2::req_body_raw(
                body_params,
                type = "application/json"
            ) %>%
            httr2::req_user_agent(
                "ParlAT R package (http://werk.statt.codes)"
            ) %>%
            httr2::req_retry(max_tries = 3) %>%
            httr2::req_perform()

        resp_json <- httr2::resp_body_json(resp, simplifyVector = TRUE)
        total_count <- resp_json$count

        return(total_count)
    }

    # DEFINITION NESTED HELPER FUNCTION 2: Get all data with specified pagesize
    get_all_data <- function(total_count) {
        resp <- httr2::request(
            "https://www.parlament.gv.at/Filter/api/filter/data/211"
        ) %>%
            httr2::req_method("POST") %>%
            httr2::req_url_query(
                js = "eval",
                page = "1",
                pagesize = as.character(total_count),
                search = search_string,
                export = TRUE
            ) %>%
            httr2::req_headers(
                accept = "*/*",
                `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
                origin = "https://www.parlament.gv.at"
            ) %>%
            httr2::req_body_raw(
                body_params,
                type = "application/json"
            ) %>%
            httr2::req_user_agent(
                "ParlAT R package (http://werk.statt.codes)"
            ) %>%
            httr2::req_retry(max_tries = 3) %>%
            httr2::req_perform()

        resp_json <- httr2::resp_body_json(resp, simplifyVector = TRUE)
        return(resp_json)
    }

    # TWO-STEP API CALL PROCESS
    # Step 1: Get total count
    total_count <- get_total_count()

    # Check if no results (API returns HTTP 500 if we request pagesize = 0)
    if (total_count == 0) {
        cli::cli_inform("Query returned 0 results.")
        # Return empty tibble with correct column structure
        return(tibble::tibble(
            date = lubridate::Date(),
            meeting_url = character(),
            legis_period = character(),
            meeting_type = character(),
            meeting_number = character(),
            meeting = character(),
            meeting_transcript_html = character(),
            meeting_transcript_pdf = character()
        ))
    }

    # Check hard limit
    if (total_count > 100000) {
        cli::cli_abort(c(
            "Query returns {total_count} results, which exceeds the limit of 100,000.",
            "i" = "Please refine your query using more specific filters (e.g., narrower date range, specific legislative period, or meeting type)."
        ))
    }

    # Step 2: Get all data with the total count as pagesize
    resp_json <- get_all_data(total_count)

    vec_headings <- resp_json %>%
        purrr::pluck("header", "label") %>%
        stringr::str_to_snake() %>%
        make.unique(sep = "_")

    rows <- purrr::pluck(resp_json, "rows")

    if (length(rows) == 0) {
        df_res <- NULL
    } else {
        df_res <- rows %>%
            as.data.frame()

        #PATCH: API returns colums and header labels of different lenghts. Those
        #labels which exceed the number of cols appear to be irrelevant; not clear why
        #they were included

        if (ncol(df_res) != length(vec_headings)) {
            cli::cli_warn(
                "API returned {ncol(df_res)} column{?s} but {length(vec_headings)} header label{?s}; surplus labels are dropped."
            )

            vec_headings <- vec_headings[seq_len(ncol(df_res))]
        }

        colnames(df_res) <- vec_headings
    }

    # Convert inr to numeric
    df_res <- df_res %>%
        dplyr::mutate(inr = as.numeric(.data$inr))

    # ECHO - print request details if requested
    if (echo == TRUE) {
        .parlat_echo_request(
            body_params,
            url_base = "https://www.parlament.gv.at/recherchieren/protokolle/index.html",
            param_prefix = "STENO_211",
            n_results = nrow(df_res),
            search = search_string
        )
    }

    # SELECT AND RENAME COLUMNS
    renaming_map <- c(
        "datum" = "date",
        "uri" = "meeting_url",
        "gp_code" = "legis_period",
        "art" = "meeting_type",
        "zitation" = "meeting_number",
        "sitzung" = "meeting",
        "gesamtprotokoll" = "meeting_transcript"
    )

    df_res <- .parlat_apply_renaming(df_res, renaming_map)

    df_res <- df_res %>%
        dplyr::select(dplyr::any_of(unname(renaming_map))) %>%
        dplyr::mutate(date = lubridate::dmy(.data$date))

    aux_fn_get_hrefs <- function(html_string) {
        if (is.na(html_string) || html_string == "") {
            return(c(
                html = NA_character_,
                pdf = NA_character_
            ))
        }

        extract_all_hrefs <- purrr::possibly(
            \(html) {
                hrefs <- html %>%
                    rvest::read_html() %>%
                    rvest::html_elements("a") %>%
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

    df_res <- df_res %>%
        dplyr::mutate(
            meeting_transcript = purrr::map(.data$meeting_transcript, \(x) {
                aux_fn_get_hrefs(x)
            })
        ) %>%
        tidyr::unnest_wider("meeting_transcript", names_sep = "_") %>%
        dplyr::mutate(across(starts_with("meeting_transcript"), \(x) {
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
                    cli::cli_inform("Folder {.path {dest_path}} does not exist.")
                    response <- readline(prompt = "Create it? (y/n): ")
                    if (tolower(trimws(response)) == "y") {
                        dir.create(dest_path, recursive = TRUE)
                        cli::cli_inform("Created folder: {.path {dest_path}}")
                        return(dest_path)
                    } else {
                        cli::cli_abort(
                            "PDF export cancelled: destination folder not created."
                        )
                    }
                } else {
                    cli::cli_abort(c(
                        "Destination folder {.path {dest_path}} does not exist.",
                        "i" = "Please create it before running in non-interactive mode."
                    ))
                }
            }
            return(dest_path)
        }

        # HELPER FUNCTION: Generate filename
        generate_pdf_filename <- function(
            date,
            meeting_type,
            meeting_number,
            legis_period
        ) {
            # Clean meeting_number for filename (remove special characters)
            meeting_clean <- meeting_number %>%
                stringr::str_replace_all("[^A-Za-z0-9_-]", "_")

            filename <- sprintf(
                "%s_%s_%s_%s.pdf",
                legis_period,
                format(date, "%Y-%m-%d"),
                meeting_type,
                meeting_clean
            )

            return(filename)
        }

        # HELPER FUNCTION: Download single PDF
        download_pdf <- function(url, dest_file) {
            tryCatch(
                {
                    httr2::request(url) %>%
                        httr2::req_user_agent(
                            "ParlAT R package (http://werk.statt.codes)"
                        ) %>%
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
        df_to_download <- df_res %>%
            dplyr::filter(!is.na(.data$meeting_transcript_pdf))

        n_pdfs <- nrow(df_to_download)

        if (n_pdfs == 0) {
            cli::cli_inform("No PDF transcripts available for download.")
        } else {
            cli::cli_inform(
                "Downloading {n_pdfs} PDF{?s} to {.path {dest_path}}..."
            )

            # Initialize progress bar
            pb_id <- cli::cli_progress_bar(
                "Downloading transcripts",
                total = n_pdfs,
                format = "{cli::pb_spin} Downloading transcripts {cli::pb_current}/{cli::pb_total} | ETA: {cli::pb_eta}",
                format_done = "Downloaded {cli::pb_total} transcripts.",
                clear = FALSE
            )

            # Download PDFs
            results <- purrr::pmap_lgl(
                list(
                    df_to_download$meeting_transcript_pdf,
                    df_to_download$date,
                    df_to_download$meeting_type,
                    df_to_download$meeting_number,
                    df_to_download$legis_period
                ),
                function(
                    url,
                    date,
                    meeting_type,
                    meeting_number,
                    legis_period
                ) {
                    filename <- generate_pdf_filename(
                        date,
                        meeting_type,
                        meeting_number,
                        legis_period
                    )
                    dest_file <- file.path(dest_path, filename)

                    success <- download_pdf(url, dest_file)
                    cli::cli_progress_update(id = pb_id)
                    return(success)
                }
            )

            # Summary
            n_success <- sum(results)
            n_failed <- n_pdfs - n_success

            if (n_failed == 0) {
                cli::cli_inform("Successfully downloaded {n_success} PDF{?s}.")
            } else {
                cli::cli_warn(
                    "Downloaded {n_success} PDF{?s}. {n_failed} download{?s} failed."
                )
            }
        }
    }

    return(df_res %>% dplyr::arrange(.data$date))
}
