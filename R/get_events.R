#' Get Event Data from Austrian Parliament API
#'
#' This function retrieves event data based on search parameters from the Austrian Parliament API.
#' It mirrors the search functionality on the Austrian Parliament website at
#' <a href="https://www.parlament.gv.at/aktuelles/termine/index.html" target="_blank">this page</a>.
#'
#' @param search_string Optional character string used to filter events by searching in event titles and descriptions. Default is NULL.
#' @param institution Character vector specifying the institution(s) to query. Must be "NR" (Nationalrat/National Council), "BR" (Bundesrat/Federal Council), or "ParlDir/Klub" ("Parliamentary Directorate/Caucus"). Can be a single value or vector for multiple institutions. NULL covers all institutions.
#' @param event_type Optional character string indicating the event type. Must be one of the predefined event types (see Details). Default is NULL (all types).
#' @param location Optional character string to filter events by location. Must be one of the predefined locations (see Details). Default is NULL (all locations).
#' @param echo Logical indicating whether to print used search parameters, number of hits, and link to results on website of parliament. Default is TRUE.
#' @param legis_period Character or numeric value of length 1, or NULL. Specifies the legislative period to search in. Only available if `date_start` and `date_end` are NULL.
#' @param date_start Optional character string representing the start date. Default is NULL.
#' @param date_end Optional character string representing the end date. Default is NULL.
#' @details
#' ## Event type
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
#' ## Location
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
#'   # Get events with specific search term and date range
#'   events <- get_events(
#'     search_string = "budget",
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
    search_string = NULL,
    institution = NULL,
    event_type = NULL,
    location = NULL,
    legis_period = NULL,
    date_start = NULL,
    date_end = NULL,
    echo = TRUE
) {
    # PARAMETER VALIDATION
    checkmate::assert_character(search_string, len = 1, null.ok = TRUE)

    if (!is.null(institution) & length(institution) > 1) {
        li_res <- purrr::map(
            institution,
            \(x) {
                get_events(
                    institution = x,
                    search_string = {{ search_string }},
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
        "Führung",
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
        "Außer Haus",
        "Bertha von Suttner | Lokal 4",
        "Blauer Salon (Epstein E1)",
        "Bundesratssaal",
        "Bundesrats-Sitzungssaal (alt)",
        "Bundesversammlungssaal",
        "Burgraum (Hofburg)",
        "Camineum (ÖNB)",
        "Dachfoyer (Hofburg)",
        "Egon Schiele | Lokal 7",
        "Elise Richter | Lokal 2",
        "Empfangssalon",
        "Epstein Beletage",
        "Epstein Innenhof",
        "Erwin Schrödinger | Lokal 1",
        "Extern",
        "Festsaal (Epstein E3)",
        "Großer Prunksaal (1. OG Stubenring)",
        "Großer Redoutensaal",
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
        "Säulenhalle",
        "Säulenhalle (alt)",
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
    ) |>
        purrr::compact() |>
        jsonlite::toJSON()

    res <- get_events_api_request(body_params, search_string)

    df_res <- purrr::map(res, \(x) {
        vec_headings <- x |>
            httr2::resp_body_json(simplifyVector = T) |>
            purrr::pluck("header", "label") |>
            janitor::make_clean_names()

        # extract the actual substantive data
        df_res <- x |>
            httr2::resp_body_json(simplifyVector = T) |>
            purrr::pluck("rows") |>
            as.data.frame()

        if (length(df_res) == 0) {
            # message("No results found for the provided search criteria.")
            return(NULL)
        }

        colnames(df_res) <- vec_headings

        return(df_res)
    }) |>
        purrr::list_rbind()

    if (isTRUE(echo)) {
        print(body_params)

        # # print url to results / transparency reasons / add search string parameter
        body_params_li <- jsonlite::fromJSON(body_params) |>
            c("search" = search_string)

        query_string <- purrr::imap(
            body_params_li,
            \(x, y) glue::glue("TERMIN_01{URLencode(y)}={URLencode(x)}")
        ) |>
            unlist() |>
            unname() |>
            paste0(collapse = "&") |>
            URLencode()

        print(glue::glue(
            "https://www.parlament.gv.at/aktuelles/termine/index.html?{query_string}"
        ))

        print(nrow(df_res))
    }

    if (length(df_res) == 0) {
        message("No results found for the provided search criteria.")
        return(NULL)
    }

    if ("link2" %in% colnames(df_res)) {
        df_res <- df_res |>
            dplyr::mutate(
                link2 = purrr::map_chr(link2, \(x) {
                    if (is.na(x) | is.null(x)) {
                        return(NA)
                    } else {
                        x |>
                            rvest::read_html() |>
                            rvest::html_element("a") |>
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

    df_res <- df_res |>
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

    df_res <- df_res |>
        dplyr::select(any_of(cols_select)) %>%
        dplyr::mutate(date = lubridate::dmy(date)) %>%
        dplyr::mutate(date_time_start = lubridate::ymd_hms(date_time_start)) %>%
        dplyr::mutate(date_time_end = lubridate::ymd_hms(date_time_end)) %>%
        dplyr::arrange(desc(date))

    return(df_res)
}


#' Retrieve Event Data from the Parliamentary API
#'
#' Constructs and executes a POST API request to fetch event data from the
#' Austrian Parliament's filter endpoint. The function handles pagination by
#' iteratively fetching additional pages until a page is returned with fewer entries
#' than the specified pagesize.
#'
#' @param body_params A JSON formatted string containing the body parameters needed for the API call.
#' @param search_string A string used to filter the events based on the search term.
#'
#' @return A response object containing aggregated event data from multiple API calls.
#' @keywords internal
#' @details
#' The API request is constructed using a series of pipe operators to set the method,
#' query parameters, headers, and body. The request leverages the `httr2` package to perform
#' the call and manage verbose settings. Pagination is implemented via the function
#' `req_perform_iterative`, which continues to fetch data until a page returns less than
#' 1000 entries (as checked by the helper function `is_complete`).
#' @noMd
#' @examples
#' \dontrun{
#'   # Example body parameters and search string
#'   body <- '{"key1": "value1", "key2": "value2"}'
#'   search <- "Plenarsitzung"
#'
#'   # Retrieve event data
#'   response <- get_events_api_request(body, search)
#'
#'   # Process the response as needed
#'   print(response)
#' }
get_events_api_request <- function(body_params, search_string) {
    req <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/600"
    ) |>
        httr2::req_method("POST") |>
        httr2::req_url_query(
            js = "eval",
            page = "1",
            pagesize = "50",
            search = search_string,
            ascDesc = "ASC"
        ) |>
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
            dnt = "1",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            # referer = "https://www.parlament.gv.at/aktuelles/termine/index.html?TERMIN_01DATERANGE=2023-03-16T23%3A00%3A00.000Z&TERMIN_01DATERANGE=2025-03-17T23%3A59%3A59.999Z",
            `sec-ch-ua` = '"Chromium";v="134", "Not:A-Brand";v="24", "Google Chrome";v="134"',
            `sec-ch-ua-mobile` = "?0",
            `sec-ch-ua-platform` = '"Windows"',
            `sec-fetch-dest` = "empty",
            `sec-fetch-mode` = "cors",
            `sec-fetch-site` = "same-origin",
            `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36",
            # cookie = "JSESSIONID=cIGy7LD1aNKtp0tEQJfecl33xhjjA0K2wyRxrLDv.appsrv04e; JSESSIONID=cIGy7LD1aNKtp0tEQJfecl33xhjjA0K2wyRxrLDv.appsrv06e; JSESSIONID=cIGy7LD1aNKtp0tEQJfecl33xhjjA0K2wyRxrLDv.master:green1"
        ) |>
        httr2::req_body_raw(body_params, type = "application/json") |>
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

        # print(paste("Next page:", df_resp_current$pages))

        df_resp_current <- df_resp_current |>
            purrr::pluck("rows") |>
            as.data.frame()

        # print(nrow(df_resp_current))

        nrow(df_resp_current) < 50 #dependent on page size parameter
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
    date_cet <- lubridate::dmy(date_string)

    # Validate that date parsing was successful
    if (is.na(date_cet)) {
        stop(paste(param_name, "contains an invalid date:", date_string))
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
