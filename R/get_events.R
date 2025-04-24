#' Get Event Data from Parlament API
#'
#' This function retrieves event data based on search parameters from the Parlament API.
#' It largely mirrors the search functionality on the Austrian Parliament website at
#' <a href="https://www.parlament.gv.at/aktuelles/termine/index.html" target="_blank">this page</a>.

#' @param search_string Optional character string used to further filter the search results.
#TODO make clear what search_string is actually doing; where does it search; title of events; or body?
#' @param institution Character specifying the institution to query. Must be one of "Bundesrat" or "Nationalrat".
#' @param event_type Optional character string indicating the event type. See Details.
#TODO add English translation
#' @param place Optional character string to filter events by location. See details.
#TODO add locations
#' @param echo Logical indicating; prints used search parameters, number of hits, and link to results on website of parliament.
#' @param date_start Optional character string representing the start date in "dd-mm-yyyy" format.
#' @param date_end Optional character string representing the end date in "dd-mm-yyyy" format.
#' @details
#' ## Event type
#' Allowed event types are:
#'   - "Plenarsitzung (Plenary Session)"
#'   - "Ausschusssitzung oder Ausschuss (Committee Meeting or Committee)"
#'   - "Besuch einer Plenarsitzung (Visit to a Plenary Session)"
#'   - "Demokratiebildung (Democracy Education)"
#'   - "Fest-/Gedenksitzung (Ceremonial/Commemorative Session)"
#'   - "Führung (Guided Tour)"
#'   - "Internationales (International)"
#'   - "Klubveranstaltung (Club Event)"
# TODO check translation
#'   - "Konferenz (Conference)"
#'   - "Parlamentarische Enquete (Parliamentary Inquiry)"
#'   - "Pressekonferenz (Press Conference)"
#'   - "Sitzung der Bundesversammlung (Federal Assembly Session)"
# TODO check translation
#'   - "Sonstiger Termin (Other Event)"
#'   - "Veranstaltung (Event)".
#'
#' ## Place
#' Must match one of the predefined choices.
#'
#'
#' @return A data frame containing event details if results are found. If no events match the criteria,
#'   the function prints a message and returns NULL.
#'
#' @examples
#' \dontrun{
#'   # Example: Retrieve events from the Nationalrat between "01-01-2022" and "31-01-2022"
#'   events <- get_events(
#'     search_string = "budget",
#'     institution = "Nationalrat",
#'     event_type = "Plenarsitzung",
#'     place = "Nationalratssaal",
#'     date_start = "01-01-2022",
#'     date_end = "31-12-2022",
#'     echo = TRUE
#'   )
#' }
#'
#' @export
get_events <- function(
    search_string = NULL,
    institution = "Nationalrat",
    event_type = NULL,
    place = NULL,
    date_start = NULL, #TODO add default
    date_end = NULL,
    echo = TRUE
) {
    #INSTITUTION
    checkmate::assert_subset(
        institution,
        choices = c("Bundesrat", "Nationalrat"),
        empty.ok = FALSE
    )
    ##encode
    # institution_input <- switch(
    #     institution,
    #     Nationalrat = "NR",
    #     Bundesrat = "BR"
    # )

    institution_input <- institution

    #DATE START; DATE END
    ## TODO allow for different date types such as "yyyy-mm-dd", "mm/dd/yyyy", and "dd-mm-yyyy"
    # Date validation
    if (!is.null(date_start)) {
        # checkmate::assert_character(date_start, len = 1, null.ok = TRUE)?
        checkmate::assert_true(
            stringr::str_detect(date_start, "^\\d{2}-\\d{2}-\\d{4}$"),
            .var.name = "date_start must be in format dd-mm-yyyy"
        )

        # date_start <- "17-03-2025"
        # Parse the date string (day-month-year format)
        date_cet <- lubridate::dmy(date_start)
        # Set the timezone to CET
        date_cet <- lubridate::force_tz(date_cet, tzone = "CET")
        # Convert to UTC
        date_utc <- lubridate::with_tz(date_cet, tzone = "UTC")
        # Format the result in ISO 8601 format
        date_start <- format(date_utc, "%Y-%m-%dT%H:%M:%S.000Z")
    }

    #date end
    if (!is.null(date_end)) {
        checkmate::assert_character(date_end, len = 1, null.ok = TRUE)
        checkmate::assert_true(
            stringr::str_detect(date_end, "^\\d{2}-\\d{2}-\\d{4}$"),
            .var.name = "date_end must be in format dd-mm-yyyy"
        )
        # date_end <- "19-03-2025"
        # Parse the date string (day-month-year format)
        date_cet <- lubridate::dmy(date_end)
        # Set the timezone to CET
        date_cet <- lubridate::force_tz(date_cet, tzone = "CET")
        # Convert to UTC
        date_utc <- lubridate::with_tz(
            date_cet + lubridate::days(1) - lubridate::seconds(1),
            tzone = "UTC"
        )
        # Format the result in ISO 8601 format
        date_end <- format(date_utc, "%Y-%m-%dT%H:%M:%S.000Z")
    }

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
        x = place,
        choices = choices_place,
        empty.ok = TRUE
    )

    # COLLECT PARAMETERS
    body_params <- list(
        DATERANGE = c(date_start, date_end),
        GREMIUM = institution_input,
        TERMINART = event_type,
        ORT = place
    ) %>%
        purrr::compact() %>%
        jsonlite::toJSON()

    # print(date_start)
    # print(date_end)
    # print(body_params)

    # body_params <- "{\"DATERANGE\":[\"2025-03-17T23:00:00.000Z\",\"2025-03-19T22:59:59.000Z\"],\"GREMIUM\":[\"Nationalrat\"]}"

    res <- get_events_api_request(body_params, search_string)

    #TODO alternative way to print search link
    # if (echo == TRUE) {
    #     print(class(res))
    #     print(length(res))
    #     res_request <- res[[1]] %>% httr2::resp_request()
    #     print(res_request)
    #     print(res_request$headers$referer)
    # }

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

        # # print url to results / transparency reasons / add search string parameter
        body_params_li <- jsonlite::fromJSON(body_params) %>%
            c(., "search" = search_string)

        query_string <- purrr::imap(
            body_params_li,
            \(x, y) glue::glue("TERMIN_01{URLencode(y)}={URLencode(x)}")
        ) %>%
            unlist() %>%
            unname() %>%
            paste0(collapse = "&") %>%
            # URLencode(., reserved = TRUE)
            URLencode()

        print(glue::glue(
            "https://www.parlament.gv.at/aktuelles/termine/index.html?{query_string}"
        ))

        print(nrow(df_res))
    }

    if ("link2" %in% colnames(df_res)) {
        df_res <- df_res %>%
            dplyr::mutate(
                link2 = map_chr(link2, \(x) {
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
#'
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
            cookie = "JSESSIONID=cIGy7LD1aNKtp0tEQJfecl33xhjjA0K2wyRxrLDv.appsrv04e; JSESSIONID=cIGy7LD1aNKtp0tEQJfecl33xhjjA0K2wyRxrLDv.appsrv06e; JSESSIONID=cIGy7LD1aNKtp0tEQJfecl33xhjjA0K2wyRxrLDv.master:green1"
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

        df_resp_current <- df_resp_current %>%
            purrr::pluck("rows") %>%
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
    # print(class(resp))
    return(resp)
}
