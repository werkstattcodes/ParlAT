#' @title Get Data on Plenary Sessions of the Austrian Parliament
#'
#' @description
#' Retrieves information about plenary sessions from the Austrian Parliament's API (see <a href="https://www.parlament.gv.at/recherchieren/plenarsitzungen/index.html" target="_blank" rel="noopener">here</a>).
#' Data available from 20th legislative period onwards.
#'
#' @param institution A character string specifying the institution. "BR" (Bundesrat/Federal Council), "NR" (Nationalrat/National Council), or "BV" (Bundesversammlung/Federal Assembly).
#' @param legis_period Numeric value or vector specifying the legislative period(s). Can also be NULL to retrieve all periods from 20th onwards. **Must be NULL when institution is "BV"** (Bundesversammlung does not use legislative periods).
#' @param session_and_activities A character string. One of 'sessions', 'submitted', or 'held'. Not applicable when institution is "BV" (Bundesversammlung); must be NULL for BV institution.
#' @param submitted A character string specifying the type of submissions that were introduced. Possible values are: 'All', 'AA', 'G037', 'G080', 'J', 'AE', 'G015', 'G014', 'AB', 'G053', 'UEA', 'UEAM'. Only used when `session_and_activities = "submitted"`. Not applicable for BV institution. See details below.
#' @param held A character string specifying the type of sessions that were held. Possible values are: 'All', 'ASEU', 'AS', 'GO04', 'FS', 'RGER', 'RGEU', 'GO', 'GO35'. Only used when `session_and_activities = "held"`. Not applicable for BV institution. See details below.
#' @param echo Logical. If `TRUE`, prints the API request body parameters and the number of results. Default is `FALSE`.
#' @return A data frame containing plenary session details, or NULL if no results found. The structure depends on `session_and_activities` parameter:
#'
#' If *`session_and_activities = "sessions"`*:
#' - `institution`: parliamentary institution (e.g., "NR", "BR")
#' - `legis_period`: legislative period (not returned if institution is 'BV')
#' - `date`: date of the session
#' - `session_number`: number of the session
#' - `session_day`: day of  session
#' - `session_url`: URL to the session page
#' - `agenda_url_html`: URL to the agenda in HTML format
#' - `agenda_url_pdf`: URL to the agenda in PDF format
#'
#' If *`session_and_activities = "submitted"` or `"held"`*:
#' - `legis_period`: legislative period
#' - `date`: date of the activity
#' - `url_session_item`: URL to the session item
#' - `url_session`: URL to the session
#' - `type_title`: title of the activity type
#' - `type_txt`: text of the activity type
#' - `topic`: topic of the activity
#' - `citation`:  item citation
#' - `session_number`: number of session
#' - `session_type_abbrev`: abbreviation for the session type
#' - `session_type_name`: full name of session type
#' - `link`, `link_2`, `link_3`: Additional links related to the activity
#'
#' For *BV (Bundesversammlung) institution*:
#' - Returns basic session information without the activity-specific filtering options available for BR/NR
#' - Does NOT include `legis_period` column (not applicable for Federal Assembly)
#' - Columns returned: `institution`, `date`, `session_number`, `session_day`, `session_url`, `agenda_url_html`, `agenda_url_pdf`
#'
#' @details
#' The function argument `session_and_activities` allows for three different inputs:
#' `sessions`: Returns details on the plenary sessions held.
#' `submitted`: Returns details on the submissions made during the plenary sessions.
#' `held`: Returns details on the type of sessions held during the plenary sessions.
#'
#' Possible values for `submitted` if `session_and_activities` is set to `submitted`:
#' - All
#' - AA: Abänderungsanträge (Amendment Motions)
#' - G037: Anträge auf Absetzung von der Tagesordnung (Motions to Remove from Agenda)
#' - G080: Anträge auf Durchführung einer Volksabstimmung (Motions for Referendum)
#' - J: Dringliche Anfragen (Urgent Inquiries)
#' - AE: Dringliche Anträge (Urgent Motions)
#' - G015: Fristerstreckungsanträge (Deadline Extension Motions)
#' - G014: Fristsetzungsanträge (Deadline Setting Motions)
#' - AB: Kurze Debatten über Anfragebeantwortungen (Brief Debates on Inquiry Responses)
#' - G053: Rückverweisungsanträge (Referral Back Motions)
#' - UEA: Unselbständige Entschließungsanträge (Dependent Resolution Motions)
#' - UEAM: Unselbständige Misstrauensanträge (Dependent No-Confidence Motions)
#'
#' Possible values for `held` if `session_and_activities` is set to `held`:
#' - All
#' - ASEU: Aktuelle Europastunden (Current Europe Hours)
#' - AS: Aktuelle Stunden (Current Hours)
#' - GO04: Erklärungen des Präsidenten / der Präsidentin (President Declarations)
#' - FS: Fragestunden (Question Hours)
#' - RGER: Regierungserklärungen (Government Declarations)
#' - RGEU: Regierungserklärungen zu EU-Themen (Government Declarations on EU Topics)
#' - GO: Sonstige Geschäftsordnungsangelegenheiten (Other Procedural Matters)
#' - GO35: Unterrichtungen gemäß Art. 50 Abs. 5 B-VG (Notifications according to Art. 50 Para. 5 B-VG)
#'
#'
#' @examples
#' \dontrun{
#' # Basic usage: Get sessions for National Council, legislative periods 20-27
#' sessions_20_27 <- get_plenary_sessions(institution = "NR", legis_period = seq(20, 27), session_and_activities = "sessions", echo = TRUE)
#'
#' # Get activities submitted during sessions
#' get_plenary_sessions(institution = "NR", legis_period = 27, session_and_activities = "submitted")
#'
#' # Get specific type of submitted activities (urgent inquiries)
#' get_plenary_sessions(institution = "NR", legis_period = 27, session_and_activities = "submitted", submitted = "J")
#'
#' # Get activities held during sessions
#' get_plenary_sessions(institution = "NR", legis_period = 27, session_and_activities = "held", held = "FS")
#'
#' # Federal Council sessions
#' get_plenary_sessions(institution = "BR", legis_period = 28, session_and_activities = "sessions")
#'
#' # Multiple legislative periods
#' get_plenary_sessions(institution = "NR", legis_period = c(26, 27), session_and_activities = "sessions")
#'
#' # All periods from 20th onwards (NULL legis_period)
#' get_plenary_sessions(institution = "NR", legis_period = NULL, session_and_activities = "sessions")
#' }
#'
#' @export

get_plenary_sessions <- function(
    institution = NULL,
    legis_period = NULL,
    session_and_activities = NULL,
    submitted = NULL,
    held = NULL,
    echo = FALSE
) {
    # INSTITUTION
    checkmate::assert_subset(
        institution,
        choices = c("BR", "NR", "BV"),
        empty.ok = FALSE
    )
    ## encode
    institution_input <- institution

    # Enforce BV constraint early to avoid overwriting a NULL later
    if (institution == "BV" && !is.null(legis_period)) {
        stop(
            "legis_period must be NULL for institution 'BV'. Filtering by legislative period is not supported for 'Bundesversammlung'."
        )
    }

    # HANDLE MULTIPLE LEGIS PERIODS
    # NULL means every legis_period from 20 onwards — but only for non-BV institutions
    if (is.null(legis_period) && institution != "BV") {
        legis_period <- get_legis_periods() |>
            dplyr::filter(legis_period > 19) |>
            dplyr::pull(legis_period)
    }

    # if length(legis_period)>1 => apply function to each legis_period
    # institution !=BV because API returns full results with only one legis period called
    if (length(legis_period) > 1 & institution != "BV") {
        df_res <- purrr::map(
            legis_period,
            \(x) {
                get_plenary_sessions(
                    legis_period = x,
                    institution = institution,
                    session_and_activities = session_and_activities,
                    submitted = submitted,
                    held = held,
                    echo = echo
                )
            },
            .progress = TRUE
        ) |>
            purrr::list_rbind()

        if (isTRUE(echo)) {
            print(paste("Hits total: ", nrow(df_res)))
        }

        return(df_res)
    }

    # LEGISLATIVE PERIOD; requires roman input
    # Check that all legislative periods are >= 20 (API limitation)

    if (institution != "BV") {
        # Store original input for error messages
        legis_period_original <- legis_period
        legis_period_char <- as.character(legis_period)

        # Validate input format before conversion (avoids warnings)
        # Valid formats: numeric, Roman numerals (I, V, X, L, C, D, M), or special codes
        is_valid_format <- purrr::map_lgl(legis_period_char, function(x) {
            is_numeric <- grepl("^\\d+$", x)
            is_roman <- grepl("^[IVXLCDM]+$", x)
            is_numeric || is_roman
        })

        if (!all(is_valid_format)) {
            invalid_values <- legis_period_original[!is_valid_format]
            stop(
                "Invalid legislative period(s) provided: ",
                paste(invalid_values, collapse = ", "), ". ",
                "Permissible inputs are numeric values (e.g., 27) or ",
                "Roman numerals (e.g., 'XXVII').",
                call. = FALSE
            )
        }

        # Now safe to convert without warnings
        legis_period <- aux_convert_legis_periods(
            legis_period,
            output = "character"
        ) %>%
            as.numeric()

        # Check minimum value constraint
        if (any(legis_period < 20)) {
            stop(
                "Only data from the 20th legislative period onwards can be queried. ",
                "You provided: ", paste(legis_period_original, collapse = ", "), ".",
                call. = FALSE
            )
        }
    }

    if (!is.null(legis_period)) {
        legis_period_input <- as.character(as.roman(as.numeric(legis_period)))
    } else {
        legis_period_input <- NULL
    }

    # SESSION AND ACTIVITIES

    if (institution != "BV") {
        choices_session_and_activities <- c(
            "sessions",
            "submitted",
            "held"
        )
        checkmate::assert_subset(
            session_and_activities,
            choices_session_and_activities,
            empty.ok = FALSE
        )
        ## encode
        session_and_activities_input <- switch(
            session_and_activities,
            "sessions" = "SI",
            "submitted" = "EI",
            "held" = "ST"
        )
    } else {
        checkmate::assert_null(session_and_activities)
        session_and_activities_input <- NULL
    }

    # CONDITION USE OF 'submitted' and 'held' on value in session_and_activities
    if (
        institution != "BV" &&
            !is.null(submitted) &&
            session_and_activities != "submitted"
    ) {
        stop(
            "'submitted' parameter can only be used when session_and_activities is 'submitted'"
        )
    }
    if (
        institution != "BV" &&
            !is.null(held) &&
            session_and_activities != "held"
    ) {
        stop(
            "'held' parameter can only be used when session_and_activities is 'held'"
        )
    }

    choices_submitted <- c(
        "All",
        "AA",
        "G037",
        "G080",
        "J",
        "AE",
        "G015",
        "G014",
        "AB",
        "G053",
        "UEA",
        "UEAM"
    )
    checkmate::assert_subset(submitted, choices_submitted, empty.ok = TRUE)

    submitted <- dplyr::case_when(
        submitted == "All" ~ "ALLE",
        .default = submitted
    )

    choices_held <- c(
        "All",
        "ASEU",
        "AS",
        "GO04",
        "FS",
        "RGER",
        "RGEU",
        "GO",
        "GO35"
    )
    checkmate::assert_subset(held, choices_held, empty.ok = TRUE)

    held <- dplyr::case_when(
        held == "All" ~ "ALLE",
        .default = held
    )

    # BODY PARAMS
    body_params <- list(
        MODUS = "PLENAR",
        NRBRBV = institution_input,
        GP = legis_period_input,
        R_SISTEI = session_and_activities_input,
        EING = submitted,
        STATT = held
    ) |>
        purrr::compact() |> # keep only non-empty elements
        jsonlite::toJSON()

    # API REQUEST
    res <- httr2::request("https://www.parlament.gv.at/Filter/api/json/post") |>
        httr2::req_url_query(
            jsMode = "EVAL",
            FBEZ = "WFP_007",
            listeId = "undefined",
            showAll = TRUE,
            ascDesc = "ASC"
        ) |>
        httr2::req_headers(
            accept = "*/*",
            `content-type` = "application/json",
            origin = "https://www.parlament.gv.at"
        ) |>
        httr2::req_body_raw(body_params, "application/json") |>
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
        httr2::req_verbose(
            body_req = FALSE,
            header_req = FALSE,
            header_resp = FALSE
        ) |>
        httr2::req_perform()

    vec_headings <- res |>
        httr2::resp_body_json(simplifyVector = T) |>
        purrr::pluck("header", "label") |>
        stringr::str_to_snake() |>
        make.unique(sep = "_")

    # extract the actual substantive data
    df_res <- res |>
        httr2::resp_body_json(simplifyVector = T) |>
        purrr::pluck("rows")
    #
    if (length(df_res) == 0) {
        message("No results found for the provided search criteria.")
        return(NULL)
    }

    colnames(df_res) <- vec_headings

    #session_and_activities = "submitted" - inconsistency in API response gp instead of gp_code

    df_res <- as.data.frame(df_res)

    if ("gp" %in% colnames(df_res)) {
        df_res <- df_res %>%
            dplyr::rename(gp_code = gp)
    }

    # browser()
    df_res <- df_res |>
        dplyr::mutate(
            gp_code = aux_convert_legis_periods(gp_code, output = "character")
        )

    #COLS DEPEND ON SEARCH PARAMETERS => DIFFERENT RENAMINGS NEEDED
    if (
        institution != "BV" &&
            session_and_activities %in% c("held", "submitted")
    ) {
        df_res <- df_res |>
            dplyr::mutate(
                sitzung = stringr::str_extract(sitzung, stringr::regex("\\d+"))
            )

        #parse text from art with error handling
        safe_parse_title <- purrr::possibly(
            aux_parse_html_title,
            otherwise = NA_character_
        )
        safe_parse_text <- purrr::possibly(
            aux_parse_html_text,
            otherwise = NA_character_
        )

        df_res <- df_res |>
            dplyr::mutate(
                art_title = purrr::map_chr(art, safe_parse_title),
                art_txt = purrr::map_chr(art, safe_parse_text)
            )

        #rename columns
        renaming_map <- c(
            "gp" = "legis_period",
            "pfad" = "url_session_item", #REVISE
            "pfad_sitzung" = "url_session",
            "datum" = "date",
            "art" = "type", #REVISE
            "art_title" = "type_title",
            "art_txt" = "type_txt",
            "betreff" = "topic", #REVISE
            "nr" = "citation",
            "sitzung" = "session_number"
        )

        df_res <- df_res |>
            dplyr::rename_with(
                .fn = \(x) renaming_map[x], # For each selected old name, get its new name from the map
                .cols = any_of(names(renaming_map))
            )

        # Convert date column to Date class
        df_res <- df_res |>
            dplyr::mutate(
                date = as.Date(date, format = "%d.%m.%Y")
            )

        # Add https://www.parlament.gv.at/ prefix to all URL columns
        df_res <- df_res |>
            dplyr::mutate(
                dplyr::across(
                    tidyselect::contains("url"),
                    \(x) {
                        dplyr::case_when(
                            is.na(x) | x == "" ~ NA_character_,
                            .default = paste0("https://www.parlament.gv.at", x)
                        )
                    }
                )
            )

        #select columns
        col_select <- c(
            "legis_period",
            "date",
            "url_session_item",
            "url_session",
            # "type",
            "type_title",
            "type_txt",
            "topic",
            "citation",
            "session_number",
            "link",
            "link_2",
            "link_3"
        )

        df_res <- df_res |>
            dplyr::select(dplyr::any_of(col_select)) |>
            dplyr::relocate(dplyr::any_of(col_select)) #ensures ordering of columns

        # PRINT ECHO
        if (echo == TRUE) {
            print(paste("Request parameters: ", body_params))
            # print url to results / transparency reasons
            body_params_li <- jsonlite::fromJSON(body_params)

            query_string <- purrr::imap(
                body_params_li,
                \(x, y) glue::glue("WFP_007{URLencode(y)}={URLencode(x)}")
            ) |>
                unlist() |>
                unname() |>
                paste0(collapse = "&")

            print(glue::glue(
                "URL Results: https://www.parlament.gv.at/recherchieren/plenarsitzungen/index.html?{query_string}"
            ))

            print(paste("Hits: ", nrow(df_res)))
        }

        return(df_res)
    }

    if (
        (institution != "BV" && session_and_activities == "sessions") ||
            institution == "BV"
    ) {
        # extract institution type
        df_res <- df_res |>
            dplyr::mutate(
                institution = stringr::str_extract(ityp, stringr::regex("^.."))
            )

        df_res <- df_res |>
            dplyr::mutate(
                sitzung = stringr::str_extract(sitzung, stringr::regex("^\\d+"))
            )

        # extract session type if "session_and_activities" == held
        if (
            !is.null(session_and_activities) && session_and_activities == "held"
        ) {
            df_res <- df_res |>
                dplyr::mutate(
                    session_type_abbrev = purrr::map_chr(art, \(x) {
                        aux_parse_html_title(x)
                    }),
                    session_type_name = purrr::map_chr(art, \(x) {
                        aux_parse_html_text(x)
                    })
                )
        }

        # parse html to extract HTML and pdf document links (if tagesordnung column exists)
        if ("tagesordnung" %in% colnames(df_res)) {
            df_res <- df_res |>
                dplyr::mutate(
                    tagesordnung = tagesordnung |>
                        purrr::map(\(html_string) {
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
                        })
                )
        }

        #rename columns
        renaming_map <- c(
            "datum" = "date",
            "sitzung" = "session_number",
            "tagesordnung" = "agenda_url",
            "gp_code" = "legis_period",
            "sitzungstag" = "session_day",
            "link" = "session_url"
        )

        df_res <- df_res |>
            dplyr::rename_with(
                .fn = \(x) renaming_map[x], # For each selected old name, get its new name from the map
                .cols = any_of(names(renaming_map))
            )

        # Convert date column to Date class
        df_res <- df_res |>
            dplyr::mutate(
                date = as.Date(date, format = "%d.%m.%Y")
            )

        # Unnest agenda_url with prefix
        if ("agenda_url" %in% colnames(df_res)) {
            df_res <- df_res |>
                tidyr::unnest_wider(agenda_url, names_sep = "_")
        }

        # Add https://www.parlament.gv.at/ prefix to all URL columns
        df_res <- df_res |>
            dplyr::mutate(
                dplyr::across(
                    tidyselect::contains("url"),
                    \(x) {
                        dplyr::case_when(
                            is.na(x) | x == "" ~ NA_character_,
                            .default = paste0("https://www.parlament.gv.at", x)
                        )
                    }
                )
            )

        #select columns
        col_select <- c(
            "institution",
            "legis_period",
            "date",
            "session_number",
            "session_day",
            "session_url",
            "session_type_abbrev",
            "session_type_name",
            "agenda_url_html",
            "agenda_url_pdf"
        )

        df_res <- df_res |>
            dplyr::select(dplyr::any_of(col_select)) |>
            dplyr::relocate(dplyr::any_of(col_select))

        # PRINT ECHO
        if (echo == TRUE) {
            print(paste("Request parameters: ", body_params))
            # print url to results / transparency reasons
            body_params_li <- jsonlite::fromJSON(body_params)

            query_string <- purrr::imap(
                body_params_li,
                \(x, y) glue::glue("WFP_007{URLencode(y)}={URLencode(x)}")
            ) |>
                unlist() |>
                unname() |>
                paste0(collapse = "&")

            print(glue::glue(
                "URL Results: https://www.parlament.gv.at/recherchieren/plenarsitzungen/index.html?{query_string}"
            ))

            print(paste("Hits: ", nrow(df_res)))
        }

        if (institution == "BV") {
            return(df_res %>% dplyr::select(-legis_period)) #when institution is "BV", API returns "BV" for legis_period; creates to var class conflicts
        } else {
            return(df_res)
        }
    }
}
