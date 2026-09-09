#' @noRd
.plenary_meetings_website_url <- function(
    institution,
    meeting_and_activities_input,
    legis_period_input,
    tagungsart_input,
    sitzungsart_input
) {
    website_periods <- if (length(legis_period_input) > 0L) {
        legis_period_input
    } else {
        .parlat_all_legis_period_codes()
    }

    query_params <- c(
        paste0("PLENAR_701GREMIUM=", institution),
        if (!is.null(meeting_and_activities_input)) {
            paste0("PLENAR_701SIAKT=", meeting_and_activities_input)
        },
        paste0("PLENAR_701GP_CODE=", website_periods),
        if (!is.null(tagungsart_input)) {
            paste0("PLENAR_701TAGUNGSART=", tagungsart_input)
        },
        if (!is.null(sitzungsart_input)) {
            paste0("PLENAR_701SITZUNGSART=", sitzungsart_input)
        }
    )

    paste0(
        "https://www.parlament.gv.at/recherchieren/plenarsitzungen?",
        paste(query_params, collapse = "&")
    )
}

#' @title Get Data on Plenary Meetings of the Austrian Parliament
#'
#' @description
#' Retrieves information about plenary meetings from the Austrian Parliament's API (see <a href="https://www.parlament.gv.at/recherchieren/plenarsitzungen/index.html" target="_blank" rel="noopener">here</a>).
#' Explicit period filters are available from the 20th legislative period
#' onwards. With `legis_period = NULL`, the API returns all available periods.
#'
#' @param institution A character string specifying the institution. "BR" (Bundesrat/Federal Council), "NR" (Nationalrat/National Council), or "BV" (Bundesversammlung/Federal Assembly).
#' @param legis_period Numeric value or vector specifying the legislative
#'   period(s). Explicit filters are supported from the 20th period onwards.
#'   `NULL` retrieves all available periods, including periods before the 20th
#'   and the historical codes `"KN"` and `"PN"`. It must be `NULL` when
#'   `institution = "BV"` because the Bundesversammlung does not use
#'   legislative periods.
#' @param meeting_and_activities A character string. One of 'meetings' or 'activities'. 'meetings' returns plenary meeting entries; 'activities' returns parliamentary items submitted or acted upon in meetings. Not applicable when institution is "BV" (Bundesversammlung); must be NULL for BV institution.
#' @param session_type A character string or vector. Filter by meeting period type. Permissible values: `"N"` (Ordentliche Tagung / Ordinary session), `"A"` (Ausserordentliche Tagung / Extraordinary session). Can be NULL to retrieve all meeting period types. Not applicable when institution is "BV".
#' @param meeting_type A character string or vector. Filter by sitting type. Permissible values: `"S"` (Sitzung / Regular sitting), `"SO"` (Sondersitzung / Special sitting), `"ZU"` (Zuweisungssitzung / Assignment sitting), `"N"` (Nachtrag / Addendum). Can be NULL to retrieve all sitting types. Only applicable when `meeting_and_activities = "meetings"`.
#' @param echo Logical. If `TRUE`, prints the URL to the corresponding search on the Parliament website, pagination progress, and the number of results. Default is `FALSE`.
#' @return A tibble containing plenary meeting details (zero rows if no results are found). The structure depends on the `meeting_and_activities` parameter:
#'
#' If *`meeting_and_activities = "meetings"`*:
#' - `institution`: parliamentary institution (e.g., "NR", "BR")
#' - `legis_period`: legislative period (not returned if institution is 'BV')
#' - `date`: date of the meeting
#' - `meeting_number`: number of the meeting
#' - `meeting_url`: URL to the meeting page
#' - `meeting_type`: sitting type abbreviation (`"S"`, `"SO"`, `"ZU"`, or `"N"`)
#' - `meeting_title`: full title of the meeting
#' - `session_type`: meeting period type (e.g., "N" for Ordentliche Tagung)
#' - `agenda_url_html`: URL to the agenda in HTML format (NA if not yet published)
#' - `agenda_url_pdf`: URL to the agenda in PDF format (NA if not yet published)
#'
#' If *`meeting_and_activities = "activities"`*:
#' - `institution`: parliamentary institution
#' - `legis_period`: legislative period
#' - `date`: date of the activity
#' - `title`: title of the parliamentary item
#' - `url_item`: URL to the parliamentary item
#' - `meeting_number`: number of the meeting in which the item appeared
#' - `url_meeting`: URL to the meeting
#' - `session_type`: meeting period type of the meeting
#' - `activity_type`: type of activity (e.g., "Sonstiges")
#' - `doc_type`: document type description
#' - `citation`: item citation string
#'
#' For *BV (Bundesversammlung) institution*:
#' - Returns basic meeting information without activity filtering
#' - Does NOT include `legis_period` column (not applicable for Federal Assembly)
#' - Columns returned: `institution`, `date`, `meeting_number`, `meeting_url`, `meeting_type`, `meeting_title`, `session_type`, `agenda_url_html`, `agenda_url_pdf`
#'
#' @examples
#' \donttest{
#' # Basic usage: meetings of the National Council for legislative period 28
#' result <- get_plenary_meetings(
#'   institution = "NR",
#'   legis_period = 28,
#'   meeting_and_activities = "meetings"
#' )
#' dplyr::glimpse(result)
#'
#' # Parliamentary activities during meetings
#' result <- get_plenary_meetings(
#'   institution = "NR",
#'   legis_period = 27,
#'   meeting_and_activities = "activities"
#' )
#' dplyr::glimpse(result)
#'
#' # Federal Council meetings
#' result <- get_plenary_meetings(
#'   institution = "BR",
#'   legis_period = 28,
#'   meeting_and_activities = "meetings"
#' )
#' dplyr::glimpse(result)
#'
#' # Multiple legislative periods
#' result <- get_plenary_meetings(
#'   institution = "NR",
#'   legis_period = c(26, 27),
#'   meeting_and_activities = "meetings"
#' )
#' dplyr::glimpse(result)
#'
#' # Federal Assembly (no legis_period, no meeting_and_activities)
#' result <- get_plenary_meetings(institution = "BV", legis_period = NULL)
#' dplyr::glimpse(result)
#' }
#'
#' @export

get_plenary_meetings <- function(
    institution = NULL,
    legis_period = NULL,
    meeting_and_activities = NULL,
    session_type = NULL,
    meeting_type = NULL,
    echo = FALSE
) {
    # INSTITUTION
    checkmate::assert_subset(
        institution,
        choices = c("BR", "NR", "BV"),
        empty.ok = FALSE
    )

    # BV constraint: legis_period must be NULL
    if (institution == "BV" && !is.null(legis_period)) {
        cli::cli_abort(
            "legis_period must be NULL for institution 'BV'. Filtering by legislative period is not supported for 'Bundesversammlung'."
        )
    }

    # LEGISLATIVE PERIOD
    if (institution != "BV") {
        if (!is.null(legis_period)) {
            legis_period_char <- as.character(legis_period)

            # Validate input format
            is_valid_format <- purrr::map_lgl(legis_period_char, function(x) {
                grepl("^\\d+$", x) || grepl("^[IVXLCDM]+$", x)
            })
            if (!all(is_valid_format)) {
                invalid_values <- legis_period[!is_valid_format]
                cli::cli_abort(c(
                    "Invalid legislative period{?s} provided: {.val {invalid_values}}.",
                    "i" = "Permissible inputs are numeric values (e.g., 27) or Roman numerals (e.g., 'XXVII')."
                ))
            }

            legis_period_numeric <- aux_convert_legis_periods(
                legis_period,
                output = "character"
            ) |>
                as.numeric()

            if (any(legis_period_numeric < 20)) {
                cli::cli_abort(
                    "Only data from the 20th legislative period onwards can be queried. You provided: {.val {legis_period}}."
                )
            }

            legis_period_input <- as.character(as.roman(legis_period_numeric))
        } else {
            legis_period_input <- NULL
        }
    } else {
        legis_period_input <- NULL
    }

    # MEETING AND ACTIVITIES
    if (institution != "BV") {
        checkmate::assert_subset(
            meeting_and_activities,
            choices = c("meetings", "activities"),
            empty.ok = FALSE
        )
        meeting_and_activities_input <- switch(
            meeting_and_activities,
            "meetings" = "SI",
            "activities" = "AKT"
        )
    } else {
        checkmate::assert_null(meeting_and_activities)
        meeting_and_activities_input <- NULL
    }

    # SESSION TYPE (tagungsart)
    if (!is.null(session_type)) {
        checkmate::assert_subset(session_type, choices = c("N", "A"))
        tagungsart_input <- session_type
    } else {
        tagungsart_input <- NULL
    }

    # MEETING TYPE / sitzungsart (only meaningful for meetings mode)
    if (!is.null(meeting_type)) {
        checkmate::assert_subset(meeting_type, choices = c("S", "SO", "ZU", "N"))
        sitzungsart_input <- meeting_type
    } else {
        sitzungsart_input <- NULL
    }

    # BODY PARAMS
    # All filter values must be JSON arrays for the API to apply them as
    # server-side filters. I() prevents jsonlite auto_unbox from collapsing
    # a length-1 vector to a scalar string.
    body_list <- list(
        GREMIUM = I(institution),
        GP_CODE = if (!is.null(legis_period_input)) {
            I(legis_period_input)
        } else {
            NULL
        },
        SIAKT = if (!is.null(meeting_and_activities_input)) {
            I(meeting_and_activities_input)
        } else {
            NULL
        },
        TAGUNGSART = if (!is.null(tagungsart_input)) {
            I(tagungsart_input)
        } else {
            NULL
        },
        SITZUNGSART = if (!is.null(sitzungsart_input)) {
            I(sitzungsart_input)
        } else {
            NULL
        }
    ) |>
        purrr::compact()

    body_params <- jsonlite::toJSON(body_list, auto_unbox = TRUE)

    # BUILD REFERER URL — explicit all-period values prevent the website from
    # restoring its current-period default when legis_period is NULL.
    referer_url <- .plenary_meetings_website_url(
        institution = institution,
        meeting_and_activities_input = meeting_and_activities_input,
        legis_period_input = legis_period_input,
        tagungsart_input = tagungsart_input,
        sitzungsart_input = sitzungsart_input
    )

    if (isTRUE(echo)) {
        cli::cli_inform("Results on the Parliament website: {referer_url}")
    }

    # BUILD BASE REQUEST
    base_req <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/701"
    ) |>
        httr2::req_method("POST") |>
        httr2::req_url_query(
            `1` = 1,
            page = 1,
            pagesize = 50,
            sortrnr = 22,
            ascDesc = "ASC"
        ) |>
        httr2::req_headers(
            accept = "*/*",
            `content-type` = "application/json",
            Referer = referer_url,
            origin = "https://www.parlament.gv.at"
        ) |>
        httr2::req_body_raw(body_params, "application/json") |>
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
        httr2::req_retry(max_tries = 3)
    # FETCH FIRST PAGE
    res <- base_req |> httr2::req_perform()
    res_body <- res |> httr2::resp_body_json(simplifyVector = TRUE)

    # PARSE HEADER
    header_tbl <- res_body$header
    vec_headings <- header_tbl |>
        dplyr::arrange(.data$rnr) |>
        dplyr::pull(.data$feld_name) |>
        tolower()
    vec_headings <- make.unique(vec_headings, sep = "_")

    # PARSE ROWS HELPER
    .parse_rows <- function(rows_raw) {
        if (length(rows_raw) == 0) {
            return(NULL)
        }
        df <- as.data.frame(rows_raw, stringsAsFactors = FALSE)
        if (ncol(df) != length(vec_headings)) {
            cli::cli_abort(
                "Column mismatch between response rows ({ncol(df)}) and header definitions ({length(vec_headings)})."
            )
        }
        colnames(df) <- vec_headings
        df
    }

    # EMPTY RESULT HELPER (schema depends on the requested mode)
    .empty_result <- function() {
        is_meetings_mode <- (institution == "BV") ||
            (!is.null(meeting_and_activities) &&
                meeting_and_activities == "meetings")
        if (is_meetings_mode) {
            cols <- c(
                "institution", "legis_period", "date", "meeting_number",
                "meeting_url", "meeting_type", "meeting_title",
                "session_type", "agenda_url_html", "agenda_url_pdf"
            )
            if (institution == "BV") {
                cols <- setdiff(cols, "legis_period")
            }
        } else {
            cols <- c(
                "institution", "legis_period", "date", "title", "url_item",
                "meeting_number", "url_meeting", "session_type",
                "activity_type", "doc_type", "citation"
            )
        }
        .parlat_empty_tibble(cols, date_cols = "date")
    }

    df_page1 <- .parse_rows(res_body$rows)

    if (is.null(df_page1)) {
        cli::cli_inform("No results found for the provided search criteria.")
        return(.empty_result())
    }

    # PAGINATE REMAINING PAGES
    n_pages <- res_body$pages
    if (!is.null(n_pages) && n_pages > 1) {
        if (isTRUE(echo)) {
            cli::cli_inform("Fetching {n_pages} pages...")
        }

        remaining <- purrr::map(
            seq(2, n_pages),
            \(pg) {
                resp_pg <- base_req |>
                    httr2::req_url_query(page = pg) |>
                    httr2::req_perform()
                body_pg <- resp_pg |>
                    httr2::resp_body_json(simplifyVector = TRUE)
                .parse_rows(body_pg$rows)
            }
        )

        df_res <- purrr::list_rbind(c(list(df_page1), remaining))
    } else {
        df_res <- df_page1
    }

    df_res <- tibble::as_tibble(df_res)

    if (nrow(df_res) == 0) {
        cli::cli_inform("No results found for the provided search criteria.")
        return(.empty_result())
    }

    # CLIENT-SIDE SIAKT FILTER (belt-and-suspenders; server filters by array body
    # params but a redundant local filter keeps the result set clean)
    if (!is.null(meeting_and_activities_input)) {
        df_res <- df_res |>
            dplyr::filter(.data$siakt == meeting_and_activities_input)
    }

    if (nrow(df_res) == 0) {
        cli::cli_inform("No results found for the provided search criteria.")
        return(.empty_result())
    }

    # AGENDA HTML PARSER (extracts PDF and HTML URLs from AGENDA HTML snippet)
    .parse_agenda_html <- function(html_string) {
        if (is.null(html_string) || is.na(html_string) || html_string == "") {
            return(list(html = NA_character_, pdf = NA_character_))
        }
        tryCatch(
            {
                hrefs <- html_string |>
                    rvest::read_html() |>
                    rvest::html_elements("a") |>
                    rvest::html_attr("href")
                list(
                    html = hrefs[stringr::str_ends(hrefs, "\\.html")][1],
                    pdf = hrefs[stringr::str_ends(hrefs, "\\.pdf")][1]
                )
            },
            error = function(e) {
                list(html = NA_character_, pdf = NA_character_)
            }
        )
    }

    # CONVERT LEGIS PERIOD
    if ("gp_code" %in% colnames(df_res)) {
        df_res <- df_res |>
            dplyr::mutate(
                gp_code = aux_convert_legis_periods(
                    .data$gp_code,
                    output = "character"
                )
            )
    }

    # MEETINGS MODE (SI) — also used for BV
    is_meetings_mode <- (institution == "BV") ||
        (!is.null(meeting_and_activities) &&
            meeting_and_activities == "meetings")

    if (is_meetings_mode) {
        # Parse agenda HTML
        df_res <- df_res |>
            dplyr::mutate(
                .agenda_parsed = purrr::map(.data$agenda, .parse_agenda_html),
                agenda_url_html = purrr::map_chr(
                    .data$.agenda_parsed,
                    \(x) x$html %||% NA_character_
                ),
                agenda_url_pdf = purrr::map_chr(
                    .data$.agenda_parsed,
                    \(x) x$pdf %||% NA_character_
                )
            )

        df_res <- df_res |>
            dplyr::mutate(
                institution = .data$gremium,
                legis_period = .data$gp_code,
                date = as.Date(.data$datum, format = "%d.%m.%Y"),
                meeting_number = stringr::str_extract(.data$sitzung, "^\\d+"),
                meeting_url = dplyr::if_else(
                    !is.na(.data$sitzung_url) & .data$sitzung_url != "",
                    paste0("https://www.parlament.gv.at", .data$sitzung_url),
                    NA_character_
                ),
                meeting_type = .data$sitzungsart,
                meeting_title = .data$title,
                session_type = .data$tagungsart,
                agenda_url_html = dplyr::if_else(
                    !is.na(.data$agenda_url_html),
                    paste0(
                        "https://www.parlament.gv.at",
                        .data$agenda_url_html
                    ),
                    NA_character_
                ),
                agenda_url_pdf = dplyr::if_else(
                    !is.na(.data$agenda_url_pdf),
                    paste0("https://www.parlament.gv.at", .data$agenda_url_pdf),
                    NA_character_
                )
            )

        col_select <- c(
            "institution",
            "legis_period",
            "date",
            "meeting_number",
            "meeting_url",
            "meeting_type",
            "meeting_title",
            "session_type",
            "agenda_url_html",
            "agenda_url_pdf"
        )

        df_res <- df_res |>
            dplyr::select(dplyr::any_of(col_select)) |>
            dplyr::relocate(dplyr::any_of(col_select))

        if (isTRUE(echo)) {
            cli::cli_inform("Hits: {nrow(df_res)}")
        }

        if (institution == "BV") {
            return(df_res |> dplyr::select(-"legis_period"))
        }
        return(df_res)
    }

    # ACTIVITIES MODE (AKT)
    df_res <- df_res |>
        dplyr::mutate(
            institution = .data$gremium,
            legis_period = .data$gp_code,
            date = as.Date(.data$datum, format = "%d.%m.%Y"),
            title = .data$title,
            url_item = dplyr::if_else(
                !is.na(.data$url) & .data$url != "",
                paste0("https://www.parlament.gv.at", .data$url),
                NA_character_
            ),
            meeting_number = stringr::str_extract(.data$sitzung, "^\\d+"),
            url_meeting = dplyr::if_else(
                !is.na(.data$sitzung_url) & .data$sitzung_url != "",
                paste0("https://www.parlament.gv.at", .data$sitzung_url),
                NA_character_
            ),
            session_type = .data$tagungsart,
            activity_type = .data$akt_text,
            doc_type = .data$doktyp_text,
            citation = .data$zitation
        )

    col_select <- c(
        "institution",
        "legis_period",
        "date",
        "title",
        "url_item",
        "meeting_number",
        "url_meeting",
        "session_type",
        "activity_type",
        "doc_type",
        "citation"
    )

    df_res <- df_res |>
        dplyr::select(dplyr::any_of(col_select)) |>
        dplyr::relocate(dplyr::any_of(col_select))

    if (isTRUE(echo)) {
        cli::cli_inform("Hits: {nrow(df_res)}")
    }

    df_res
}
