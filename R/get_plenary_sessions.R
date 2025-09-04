#' @title Get Plenary Sessions from Austrian Parliament
#'
#' @description
#' Retrieves information about plenary sessions from the Austrian Parliament's API (see <a href="https://www.parlament.gv.at/recherchieren/plenarsessions" target="_blank" rel="noopener">here.</a>)
#' Basic data available from 1st legislative period onwards, detailed information from 20th legislative period onwards.
#'
#'
#' @param institution A character string specifying the institution. "BR" (Bundesrat/Federal Council), "NR" (Nationalrat/National Council), or "BV" (Bundesversammlung/Federal Assembly).
#' @param legis_period Numeric value or vector specifying the legislative period(s). Can also be NULL to retrieve all periods from 20th onwards. Basic data available from 1st legislative period onwards, detailed information from 20th legislative period onwards.
#' @param session_and_activities A character string. One of 'sessions', 'submitted' or 'held'. Not applicable for BV (Bundesversammlung) - must be NULL for BV institution.
#' @param submitted A character string.  Specifying the type of activities that were introduced. Possible values are: 'All', 'AA', 'G037', 'G080', 'J', 'AE', 'G015', 'G014', 'AB', 'G053', 'UEA', 'UEAM'. Only used when `session_and_activities = "submitted"`. Not applicable for BV institution. See details below.
#' @param held A character string. specifying the type of activities that took place. Possible values are: 'All', 'ASEU', 'AS', 'GO04', 'FS', 'RGER', 'RGEU', 'GO', 'GO35'. Only used when `session_and_activities = "held"`. Not applicable for BV institution. See details below.
#' @return A data frame containing plenary session details, or NULL if no results found. The structure depends on `session_and_activities` parameter:
#'
#' If *`session_and_activities = "sessions"`*:
#' - `institution`: The parliamentary institution (e.g., "NR", "BR")
#' - `legis_period`: The legislative period
#' - `date`: The date of the session
#' - `session_number`: The number of the session
#' - `session_day`: The day of the session
#' - `session_url`: The URL to the session page
#' - `session_type_abbrev`: The abbreviation for the session type
#' - `session_type_name`: The full name of the session type
#' - `agenda_url`: A list column with URLs to the agenda in HTML and PDF formats
#'
#' If *`session_and_activities = "submitted"` or `"held"`*:
#' - `legis_period`: The legislative period
#' - `date`: The date of the activity
#' - `url_session_item`: The URL to the session item
#' - `url_session`: The URL to the session
#' - `type_title`: The title of the activity type
#' - `type_txt`: The text of the activity type
#' - `topic`: The topic of the activity
#' - `session_id`: The ID of the session
#' - `session_number`: The number of the session
#' - `link`, `link_2`, `link_3`: Additional links related to the activity
#'
#' For *BV (Bundesversammlung) institution*:
#' - Returns basic session information without the activity-specific filtering options available for BR/NR
#'
#' @details
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
#' - GO04: Erklarungen des Prasidenten / der Prasidentin (President Declarations)
#' - FS: Fragestunden (Question Hours)
#' - RGER: Regierungserklärungen (Government Declarations)
#' - RGEU: Regierungserklärungen zu EU-Themen (Government Declarations on EU Topics)
#' - GO: Sonstige Geschäftsordnungsangelegenheiten (Other Procedural Matters)
#' - GO35: Unterrichtungen gemäß Art. 50 Abs. 5 B-VG (Notifications according to Art. 50 Para. 5 B-VG)
#'
#'
#' @examples
#' \dontrun{
#' # Basic usage: Get sessions for National Council, period 26
#' get_plenary_sessions(institution = "NR", legis_period = 26, session_and_activities = "sessions")
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
#' # Federal Assembly (BV) - no session_and_activities parameter
#' get_plenary_sessions(institution = "BV", legis_period = 27)
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
    held = NULL
) {
    # INSTITUTION
    checkmate::assert_subset(
        institution,
        choices = c("BR", "NR", "BV"),
        empty.ok = FALSE
    )
    ## encode
    institution_input <- institution

    # HANDLE MULTIPLE LEGIS PERIODS
    # NULL means every legis_period from 20 onwards
    if (is.null(legis_period)) {
        legis_period <- get_legis_periods() |>
            dplyr::filter(legis_period > 19) |>
            dplyr::pull(legis_period)
    }

    # if length(legis_period)>1 => apply function to each legis_period
    if (length(legis_period) > 1) {
        df_res <- purrr::map(
            legis_period,
            \(x) {
                get_plenary_sessions(
                    legis_period = x,
                    institution = institution,
                    session_and_activities = session_and_activities,
                    submitted = submitted,
                    held = held
                )
            },
            .progress = TRUE
        ) |>
            purrr::list_rbind()
        return(df_res)
    }

    # LEGISLATIVE PERIOD; requires roman input
    # Check that all legislative periods are >= 20 (API limitation)
    # checkmate::assert_numeric(
    #     legis_period,
    #     lower = 20,
    #     finite = TRUE,
    #     any.missing = FALSE
    # )

    if (!is.null(legis_period)) {
        legis_period_input <- as.character(as.roman(as.numeric(legis_period)))
        # print(legis_period_input)
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
        janitor::make_clean_names()

    # extract the actual substantive data
    df_res <- res |>
        httr2::resp_body_json(simplifyVector = T) |>
        purrr::pluck("rows")

    if (length(df_res) == 0) {
        message("No results found for the provided search criteria.")
        return(NULL)
    }

    colnames(df_res) <- vec_headings

    df_res <- as.data.frame(df_res)

    #COLS DEPEND ON SEARCH PARAMETERS => DIFFERENT RENAMINGS NEEDED
    if (
        institution != "BV" &&
            session_and_activities %in% c("held", "submitted")
    ) {
        df_res <- df_res |>
            dplyr::mutate(
                sitzung = stringr::str_extract(sitzung, stringr::regex("\\d+"))
            )

        #parse text from art
        df_res <- df_res |>
            dplyr::mutate(
                art_title = purrr::map_chr(art, \(x) aux_parse_html_title(x)),
                art_txt = purrr::map_chr(art, \(x) aux_parse_html_text(x))
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
            "nr" = "session_id",
            "sitzung" = "session_number"
        )

        df_res <- df_res |>
            dplyr::rename_with(
                .fn = \(x) renaming_map[x], # For each selected old name, get its new name from the map
                .cols = any_of(names(renaming_map))
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
            "session_id",
            "session_number",
            "link",
            "link_2",
            "link_3"
        )

        df_res <- df_res |>
            dplyr::select(dplyr::any_of(col_select)) |>
            dplyr::relocate(dplyr::any_of(col_select)) #ensures ordering of columns

        return(df_res)
    }

    if (institution != "BV" && session_and_activities == "sessions") {
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
        if (session_and_activities == "held") {
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
            "agenda_url"
        )

        df_res <- df_res |>
            dplyr::select(dplyr::any_of(col_select)) |>
            dplyr::relocate(dplyr::any_of(col_select))

        return(df_res)
    }
}
