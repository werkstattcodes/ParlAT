#' Get Event Data from Austrian Parliament API
#'
#' This function retrieves event data based on search parameters from the Austrian Parliament API.
#' It mirrors the search functionality on the Austrian Parliament website at
#' <a href="https://www.parlament.gv.at/aktuelles/termine/index.html" target="_blank">this page</a>, and additionally
#' facilitates searches by legislative period.
#'
#' @param institution Character vector specifying the institution(s) to query. Must be "NR" (Nationalrat/National Council), "BR" (Bundesrat/Federal Council), or "ParlDir/Klub" ("Parliamentary Directorate/Caucus"). Can be a single value or vector for multiple institutions. NULL covers all institutions.
#' @param event_type Optional character string indicating the event type. Must be one of the predefined event types (see Details). Default is NULL (all types).
#' @param location Optional character string to filter events by location. Must be one of the predefined locations (see Details). Default is NULL (all locations).
#' @param echo Logical indicating whether to print used search parameters, number of hits, and link to results on website of parliament. Default is TRUE.
#' @param legis_period Character or numeric value of length 1, or NULL. Specifies the legislative period to search in. Only available if `date_start` and `date_end` are NULL.
#' @param date_start Optional character string representing the start date in day-month-year (DMY) format (e.g., "26-10-2025", "26.10.2025", or "26/10/2025"). Default is NULL.
#' @param date_end Optional character string representing the end date in day-month-year (DMY) format (e.g., "26-10-2025", "26.10.2025", or "26/10/2025"). Default is NULL.
#'
#' @note Free Text Search: Due to limitations of the underlying API, this function does not currently support a general free
#' text search across all fields. Search functionality is restricted to the specific parameters
#' provided.
#'
#' @details
#' ## event_type
#' Allowed event types are:
#'   - "Plenarsitzung" (Plenary Session)
#'   - "Ausschusssitzung oder Ausschuss" (Committee Meeting or Committee)
#'   - "Besuch einer Plenarsitzung" (Visit to a Plenary Session)
#'   - "Demokratiebildung" (Democracy Education)
#'   - "Fest-/Gedenksitzung" (Ceremonial/Commemorative Session)
#'   - "Führung" (Guided Tour)
#'   - "Internationales" (International)
#'   - "Klubveranstaltung" (Club Event)
#'   - "Konferenz" (Conference)
#'   - "Parlamentarische Enquete" (Parliamentary Inquiry)
#'   - "Pressekonferenz" (Press Conference)
#'   - "Sitzung der Bundesversammlung" (Federal Assembly Session)
#'   - "Sonstiger Termin" (Other Event)
#'   - "Veranstaltung" (Event)
#'
#' ## location
#' Allowed locations are:
#'   - "Abgeordneten-Sprechzimmer (alt)"
#'   - "Auditorium"
#'   - "Außer Haus"
#'   - "Bertha von Suttner | Lokal 4"
#'   - "Blauer Salon (Epstein E1)"
#'   - "Bundesratssaal"
#'   - "Bundesrats-Sitzungssaal (alt)"
#'   - "Bundesversammlungssaal"
#'   - "Burgraum (Hofburg)"
#'   - "Camineum (ÖNB)"
#'   - "Dachfoyer (Hofburg)"
#'   - "Egon Schiele | Lokal 7"
#'   - "Elise Richter | Lokal 2"
#'   - "Empfangssalon"
#'   - "Epstein Beletage"
#'   - "Epstein Innenhof"
#'   - "Erwin Schrödinger | Lokal 1"
#'   - "Extern"
#'   - "Festsaal (Epstein E3)"
#'   - "Großer Prunksaal (1. OG Stubenring)"
#'   - "Großer Redoutensaal"
#'   - "Heldenplatz"
#'   - "Historischer Sitzungssaal (alt)"
#'   - "Kunschak-Saal"
#'   - "Lise Meitner | Lokal 6"
#'   - "Lokal I (Ministerratszimmer, alt)"
#'   - "Lokal II (alt)"
#'   - "Lokal III (alt)"
#'   - "Lokal IV (alt)"
#'   - "Lokal V (alt)"
#'   - "Lokal VI (Budgetsaal, alt)"
#'   - "Lokal VII (alt)"
#'   - "Lokal VIII (alt)"
#'   - "Lokal 1 Medienraum (EG Bibliothekshof)"
#'   - "Lokal 2 (EG Bibliothekshof)"
#'   - "Lokal 3 (EG Bibliothekshof)"
#'   - "Lokal 4 (2. OG Bibliothekshof)"
#'   - "Lokal 5 (3. OG Bibliothekshof)"
#'   - "Lokal 6 (3. OG Bibliothekshof)"
#'   - "Lokal 7 (Hofburg Segmentbogen)"
#'   - "Ludwig Wittgenstein | Lokal 5"
#'   - "Nationalratssaal"
#'   - "Nationalrats-Sitzungssaal (alt)"
#'   - "Palais Epstein"
#'   - "Parlament"
#'   - "Parliament"
#'   - "Plenar-Lounge"
#'   - "Portikus"
#'   - "Pressezentrum"
#'   - "Roter Salon (Epstein E4)"
#'   - "Säulenhalle"
#'   - "Säulenhalle (alt)"
#'   - "Spielsalon (Epstein E5)"
#'   - "Teamentwicklung"
#'   - "Theophil Hansen | Lokal 3"
#'   - "virtuell"
#'
#' @return A data frame containing event details with the following columns, or NULL if no results are found:
#' - `date`: Event date (parsed as Date)
#' - `date_time_start`: Event start date and time (parsed as POSIXct)
#' - `date_time_end`: Event end date and time (parsed as POSIXct)
#' - `title`: Event title/name
#' - `event_type`: Type of event
#' - `location`: Event location/venue
#' - `topic`: Event topic/subject
#' - `institution`: Institution hosting the event
#' - `media_relevance`: Media relevance indicator
#' - `guidance_type`: Type of guidance (if applicable)
#' - `group`: Group information
#' - `view`: View/visibility settings
#' - `fully_booked`: Whether the event is fully booked
#' - `registration`: Registration information
#' - `livestream_url`: URL for livestream (if available)
#' - `available`: Availability status
#' - `language`: Event language
#' - `link`: Primary link to event details
#' - `link2`: Secondary link (if available)
#'
#' @examples
#' \dontrun{
#'   # Basic example: Get all National Council events
#'   events <- get_events(institution = "NR")
#'
#'   # Get events with specific date range
#'   events <- get_events(
#'     institution = "NR",
#'     date_start = "01-01-2024",
#'     date_end = "31-01-2024"
#'   )
#'
#'   # Get plenary sessions in the National Council chamber
#'   events <- get_events(
#'     institution = "NR",
#'     event_type = "Plenarsitzung",
#'     location = "Nationalratssaal"
#'   )
#'
#'   # Get Federal Council events
#'   events <- get_events(
#'     institution = "BR",
#'     event_type = "Plenarsitzung"
#'   )
#'
#'   # Get events for a specific legislative period
#'   events <- get_events(
#'     institution = "NR",
#'     legis_period = 28
#'   )
#'
#'   # Get events from multiple institutions
#'   events <- get_events(
#'     institution = c("NR", "BR"),
#'     event_type = "Plenarsitzung"
#'   )
#' }
#'
#' @export
get_events <- function(
    institution = NULL,
    event_type = NULL,
    location = NULL,
    legis_period = NULL,
    date_start = NULL,
    date_end = NULL,
    echo = TRUE
) {
    # PARAMETER VALIDATION

    if (!is.null(institution) & length(institution) > 1) {
        li_res <- purrr::map(
            institution,
            \(x) {
                get_events(
                    institution = x,
                    event_type = {{ event_type }},
                    location = {{ location }},
                    legis_period = {{ legis_period }},
                    date_start = {{ date_start }},
                    date_end = {{ date_end }},
                    echo = {{ echo }}
                )
            }
        )
        return(purrr::list_rbind(li_res))
    }

    checkmate::assert_subset(
        institution,
        choices = c("BR", "NR", "ParlDir/Klub"),
        empty.ok = TRUE
    )

    ##encode
    institution_input <- if (
        is.null(institution) || (length(institution) == 1 && is.na(institution))
    ) {
        NULL
    } else {
        dplyr::case_when(
            institution == "NR" ~ "Nationalrat",
            institution == "BR" ~ "Bundesrat",
            institution == "ParlDir/Klub" ~ "Parlamentsdirektion / Klubs",
            TRUE ~ as.character(institution)
        )
    }

    checkmate::assert_logical(echo, len = 1, null.ok = FALSE)

    #LEGIS PERIOD check
    if (!is.null(date_start) && !is.null(date_end) && !is.null(legis_period)) {
        stop(
            "Input for `legis_period` only permissible if `date_start` and `date_end` are NULL. Choose either
            `legis_period` or dates as input, not both."
        )
    }

    # Validate legis_period parameter (must be length 1)
    if (!is.null(legis_period)) {
        checkmate::assert(
            checkmate::check_character(legis_period, len = 1),
            checkmate::check_numeric(legis_period, len = 1),
            .var.name = "legis_period must be a single character or numeric value"
        )
    }

    if (is.null(date_start) && is.null(date_end) && !is.null(legis_period)) {
        df_legis <- get_legis_periods(legis_period = legis_period)
        date_start <- format(df_legis$date_start, "%d-%m-%Y")
        if (isTRUE(df_legis$legis_period_current)) {
            date_end <- format(lubridate::today(), "%d-%m-%Y")
        } else {
            date_end <- format(df_legis$date_end, "%d-%m-%Y")
        }
    }

    # DATE PROCESSING
    date_start <- aux_transform_event_date(
        date_start,
        "date_start",
        is_end_date = FALSE
    )
    date_end <- aux_transform_event_date(
        date_end,
        "date_end",
        is_end_date = TRUE
    )

    #event type
    choices_event_type <- c(
        "Plenarsitzung",
        "Ausschusssitzung oder Ausschuss",
        "Besuch einer Plenarsitzung",
        "Demokratiebildung",
        "Fest-/Gedenksitzung",
        "F\u00fchrung",
        "Internationales",
        "Klubveranstaltung",
        "Konferenz",
        "Parlamentarische Enquete",
        "Pressekonferenz",
        "Sitzung der Bundesversammlung",
        "Sonstiger Termin",
        "Veranstaltung"
    )

    checkmate::assert_subset(
        x = event_type,
        choices = choices_event_type,
        empty.ok = TRUE
    )

    # place
    choices_place <- c(
        "Abgeordneten-Sprechzimmer (alt)",
        "Auditorium",
        "Au\u00dfer Haus",
        "Bertha von Suttner | Lokal 4",
        "Blauer Salon (Epstein E1)",
        "Bundesratssaal",
        "Bundesrats-Sitzungssaal (alt)",
        "Bundesversammlungssaal",
        "Burgraum (Hofburg)",
        "Camineum (\u00d6NB)",
        "Dachfoyer (Hofburg)",
        "Egon Schiele | Lokal 7",
        "Elise Richter | Lokal 2",
        "Empfangssalon",
        "Epstein Beletage",
        "Epstein Innenhof",
        "Erwin Schr\u00f6dinger | Lokal 1",
        "Extern",
        "Festsaal (Epstein E3)",
        "Gro\u00dfer Prunksaal (1. OG Stubenring)",
        "Gro\u00dfer Redoutensaal",
        "Heldenplatz",
        "Historischer Sitzungssaal (alt)",
        "Kunschak-Saal",
        "Lise Meitner | Lokal 6",
        "Lokal I (Ministerratszimmer, alt)",
        "Lokal II (alt)",
        "Lokal III (alt)",
        "Lokal IV (alt)",
        "Lokal V (alt)",
        "Lokal VI (Budgetsaal, alt)",
        "Lokal VII (alt)",
        "Lokal VIII (alt)",
        "Lokal 1 Medienraum (EG Bibliothekshof)",
        "Lokal 2 (EG Bibliothekshof)",
        "Lokal 3 (EG Bibliothekshof)",
        "Lokal 4 (2. OG Bibliothekshof)",
        "Lokal 5 (3. OG Bibliothekshof)",
        "Lokal 6 (3. OG Bibliothekshof)",
        "Lokal 7 (Hofburg Segmentbogen)",
        "Ludwig Wittgenstein | Lokal 5",
        "Nationalratssaal",
        "Nationalrats-Sitzungssaal (alt)",
        "Palais Epstein",
        "Parlament",
        "Parliament",
        "Plenar-Lounge",
        "Portikus",
        "Pressezentrum",
        "Roter Salon (Epstein E4)",
        "S\u00e4ulenhalle",
        "S\u00e4ulenhalle (alt)",
        "Spielsalon (Epstein E5)",
        "Teamentwicklung",
        "Theophil Hansen | Lokal 3",
        "virtuell",
        "Keine Bezeichnung im Select."
    )

    checkmate::assert_subset(
        x = location,
        choices = choices_place,
        empty.ok = TRUE
    )

    # COLLECT PARAMETERS
    body_params <- list(
        DATERANGE = c(date_start, date_end),
        GREMIUM = institution_input,
        TERMINART = event_type,
        ORT = location
    ) %>%
        purrr::compact() %>%
        jsonlite::toJSON()

    req <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/600"
    ) %>%
        httr2::req_method("POST") %>%
        httr2::req_url_query(
            js = "eval",
            showAll = TRUE,
            ascDesc = "ASC"
        ) %>%
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
            dnt = "1",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            `sec-ch-ua` = '"Chromium";v="134", "Not:A-Brand";v="24", "Google Chrome";v="134"',
            `sec-ch-ua-mobile` = "?0",
            `sec-ch-ua-platform` = '"Windows"',
            `sec-fetch-dest` = "empty",
            `sec-fetch-mode` = "cors",
            `sec-fetch-site` = "same-origin",
            `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36"
        ) %>%
        httr2::req_body_raw(body_params, type = "application/json") %>%
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") %>%
        httr2::req_verbose(
            body_req = F,
            header_req = F,
            header_resp = F,
            body_resp = F,
            info = F
        )

    resp <- httr2::req_perform(req)

    resp_json <- httr2::resp_body_json(resp, simplifyVector = TRUE)

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

        colnames(df_res) <- vec_headings
    }

    if (isTRUE(echo)) {
        print(body_params)

        # # print url to results / transparency reasons
        body_params_li <- jsonlite::fromJSON(body_params)

        query_string <- purrr::imap(
            body_params_li,
            \(x, y) glue::glue("TERMIN_01{URLencode(y)}={URLencode(x)}")
        ) %>%
            unlist() %>%
            unname() %>%
            paste0(collapse = "&") %>%
            URLencode()

        print(glue::glue(
            "https://www.parlament.gv.at/aktuelles/termine/index.html?{query_string}"
        ))

        print(if (is.null(df_res)) 0 else nrow(df_res))
    }

    if (is.null(df_res) || nrow(df_res) == 0) {
        message("No results found for the provided search criteria.")
        return(NULL)
    }

    if ("link2" %in% colnames(df_res)) {
        df_res <- df_res %>%
            dplyr::mutate(
                link2 = purrr::map_chr(.data$link2, \(x) {
                    if (is.na(x) | is.null(x)) {
                        return(NA)
                    } else {
                        x %>%
                            rvest::read_html() %>%
                            rvest::html_element("a") %>%
                            rvest::html_attr("href")
                    }
                })
            )
    }

    #RENAME AND SELECT COLUMNS
    #rename
    renaming_map <- c(
        "datum" = "date",
        "datum_3" = "date_time_start",
        "datum_bis" = "date_time_end",
        "bezeichnung" = "title",
        "terminart" = "event_type",
        "ort" = "location",
        "themen" = "topic",
        "gremium" = "institution",
        "medienrelevant" = "media_relevance",
        "fuhrungsformat" = "guidance_type",
        "gruppe" = "group",
        "sicht" = "view",
        "ausgebucht" = "fully_booked",
        "anmeldung" = "registration",
        "livestreamlink" = "livestream_url",
        "verfugbar" = "available",
        "sprache" = "language"
    )

    df_res <- df_res %>%
        dplyr::rename_with(
            .fn = \(x) renaming_map[x], # For each selected old name, get its new name from the map
            .cols = any_of(names(renaming_map))
        )

    #select relevant columns
    cols_select <- c(
        "date",
        "date_time_start",
        "date_time_end",
        "title",
        "event_type",
        "location",
        "topic",
        "institution",
        "media_relevance",
        "guidance_type",
        "group",
        "view",
        "fully_booked",
        "registration",
        "livestream_url",
        "available",
        "language",
        "link",
        "link2"
    )

    df_res <- df_res %>%
        dplyr::select(dplyr::any_of(cols_select)) %>%
        dplyr::mutate(dplyr::across(dplyr::any_of("date"), lubridate::dmy)) %>%
        dplyr::mutate(dplyr::across(dplyr::any_of("date_time_start"), lubridate::ymd_hms)) %>%
        dplyr::mutate(dplyr::across(dplyr::any_of("date_time_end"), lubridate::ymd_hms)) %>%
        dplyr::arrange(dplyr::desc(date))

    return(df_res)
}


#' Transform Event Date for API Request
#'
#' Helper function to convert date from dd-mm-yyyy format to ISO 8601 UTC format
#' required by the Austrian Parliament API.
#'
#' @param date_string Character string in "dd-mm-yyyy" format or NULL
#' @param param_name Name of the parameter for error messages
#' @param is_end_date Logical indicating if this is an end date (adds 1 day minus 1 second)
#' @return Character string in ISO 8601 format or NULL
#' @keywords internal
aux_transform_event_date <- function(
    date_string,
    param_name,
    is_end_date = FALSE
) {
    if (is.null(date_string)) {
        return(NULL)
    }

    # Validate format
    checkmate::assert_character(date_string, len = 1)

    # Parse the date string (day-month-year format)
    date_cet <- lubridate::dmy(date_string, quiet = TRUE)

    # Validate that date parsing was successful
    if (is.na(date_cet)) {
        stop(paste0(
            param_name, " must be in day-month-year (DMY) format. ",
            "Expected formats: '26-10-2025', '26.10.2025', or '26/10/2025'. ",
            "Received: '", date_string, "'"
        ), call. = FALSE)
    }

    # Set the timezone to CET
    date_cet <- lubridate::force_tz(date_cet, tzone = "CET")

    # For end dates, add 1 day minus 1 second to include the full end day
    if (is_end_date) {
        date_cet <- date_cet + lubridate::days(1) - lubridate::seconds(1)
    }

    # Convert to UTC
    date_utc <- lubridate::with_tz(date_cet, tzone = "UTC")

    # Format the result in ISO 8601 format
    return(format(date_utc, "%Y-%m-%dT%H:%M:%S.000Z"))
}
