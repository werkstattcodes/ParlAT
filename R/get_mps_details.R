# pad_intern; one or more ids possible (plenary)
# legis_period => 20 (when plenary); more than 1 legis period possible (plenary)
# plenary details returns all speeches of the person, regardless of his or her
# mandate at the time of the speech; get_mps_details ("MPs") is  hence somewhat misleading

#' Get detailed information about Members of Parliament
#'
#' This function retrieves detailed information about Members of Parliament (MPs)
#' from the Austrian Parliament database based on various filter criteria.
#'
#' @param pad_intern Internal ID of the MP in the parliamentary database
#' @param detail_type Character string specifying the type of details to retrieve; "plenary" or "activities".
#' @param house Character string specifying the parliamentary house (optional).
#'   Defaults to NULL.
#' @param legis_period Numeric or character specifying the legislative period (optional).
#'   Defaults to NULL.
#' @param item Character string specifying a particular item, used only for activities (optional).
#'   Defaults to NULL.
#' @param search_string Character string for searching within activities (optional).
#'   Defaults to NULL.
#' @param echo Logical indicating whether to print the API request and response details.
#'
#' @return A data frame or list containing the requested MP details.
#' Note that detail_type plenary returns all speeches of the person in question (within in the house
#' requested), #' irrespective of its mandate at the time of the speech. E.g. querying all plenary
#' activities of Doris Bures in the National Council will return not only her speeches as an MP,
#' but also as a member in the presidency of the National Council, and Minister.
#'
#' @examples
#' \dontrun{
#' # Get basic details for an MP
#' get_mps_details(pad_intern = "12345", detail_type = "basic")
#'
#' # Get activities for an MP in a specific legislative period
#' get_mps_details(
#'   pad_intern = "12345",
#'   detail_type = "activities",
#'   legis_period = "XXVII"
#' )
#' }
#'
#' @export
get_mps_details <- function(
    pad_intern,
    detail_type,
    house = NULL,
    legis_period = NULL,
    item = NULL, #only for activities
    search_string = NULL, #search string for activities
    echo = TRUE
) {
    # detail_type must be supplied and valid
    if (missing(detail_type) || is.null(detail_type)) {
        stop(
            "`detail_type` is a required parameter (e.g. 'plenary').",
            call. = FALSE
        )
    }

    #check if pad_intern is valid
    if (any(aux_check_pad_intern_exists(pad_intern) == FALSE)) {
        stop(
            "One or more `pad_intern` values do not exist or are invalid.",
            call. = FALSE
        )
    }

    checkmate::assert_choice(detail_type, choices = c("plenary", "activities"))
    if (!is.null(detail_type) && detail_type == "plenary") {
        return(get_mps_details_plenary(
            pad_intern = pad_intern,
            # detail_type = detail_type,
            house = house,
            legis_period = legis_period,
            echo = echo
        ))
    }
    if (!is.null(detail_type) && detail_type == "activities") {
        return(get_mps_details_activities(
            pad_intern = pad_intern,
            # detail_type = detail_type,
            house = house,
            legis_period = legis_period,
            item = item,
            search_string = search_string
        ))
    }

    # Add other detail types here as needed
    stop("Unsupported detail type. Currently only 'plenary' is supported.")
}


get_mps_details_plenary <- function(
    pad_intern = NULL,
    # detail_type = NULL,
    house = NULL,
    legis_period = NULL, #string for activities
    echo = NULL
) {
    # house
    checkmate::assert_subset(
        x = house,
        choices = c("NR", "BR"), #PENDING PN KN as well?
        empty.ok = TRUE
    )

    if (!is.null(house)) {
        house <- switch(
            house,
            "NR" = "N",
            "BR" = "B",
            house
        )
    }

    # legis_period
    if (!is.null(legis_period)) {
        legis_period <- as.roman(legis_period)

        checkmate::assert_int(
            x = min(as.numeric(legis_period)), #min since length > 1 possible
            lower = 20,
            null.ok = TRUE
        )
    }

    # BODY PARAMS
    body_params <- list(
        PAD_INTERN = pad_intern,
        GREMIUM = house,
        GP_CODE = as.character(legis_period) #not roman
    ) |>
        purrr::compact() |>
        jsonlite::toJSON()

    #API CALL PLENARY
    res <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/251"
    ) |>
        httr2::req_method("POST") |>
        httr2::req_url_query(
            js = "eval",
            page = "1",
            # pagesize = "20",
            showAll = "true",
            sortrnr = "10",
            ascDesc = "DESC"
        ) |>
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            # referer = "https://www.parlament.gv.at/person/145?selectedtab=PLENUM",
            `sec-ch-ua` = '"Microsoft Edge";v="137", "Chromium";v="137", "Not/A)Brand";v="24"',
            `sec-ch-ua-mobile` = "?0",
            `sec-ch-ua-platform` = '"Windows"',
            `sec-fetch-dest` = "empty",
            `sec-fetch-mode` = "cors",
            `sec-fetch-site` = "same-origin",
            `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0",
            cookie = "pddsgvo=j; _pk_id.1.26ca=2b9c3ab31363e4f4.1742073577.; _pk_ref.1.26ca=%5B%22%22%2C%22%22%2C1749197886%2C%22https%3A%2F%2Fwww.bing.com%2F%22%5D; _pk_ses.1.26ca=1"
        ) |>
        httr2::req_body_raw(
            body_params,
            # '{"PAD_INTERN":[145]}',
            type = "application/json"
        ) |>
        httr2::req_perform()

    #PARSE RESPONSE
    li_res <- res %>%
        httr2::resp_body_json(simplifyVector = TRUE) #simplifyVector = TRUE !!

    df_res <- li_res %>% pluck("rows") %>% as.data.frame()
    # ncol(df_res)
    # class(df_res)

    # Exit if no match
    if (nrow(df_res) == 0 || is.null(df_res)) {
        message("No data found for the given parameters.")
        return(invisible(NULL))
    }

    vec_names <- li_res %>%
        purrr::pluck("header", "label") %>%
        stringr::str_to_lower()
    # length(vec_names)

    #assign column names; assumes stable column sorting in API response
    names(df_res) <- vec_names
    col_rede <- which(names(df_res) == "rede")
    names(df_res)[col_rede + 1] <- "transcript"
    names(df_res)[col_rede + 2] <- "media"
    cols_keep <- c(
        "pad_intern",
        "fromdate",
        "gp",
        "gremium",
        "sitzung",
        "rede",
        "transcript",
        "media"
    )
    # keep only relevant columns
    df_res <- df_res %>%
        dplyr::select(
            dplyr::any_of(cols_keep)
        )

    # parse html elements & format
    df_res <- df_res %>%
        dplyr::mutate(
            sitzung_url = map_chr(sitzung, \(x) {
                x |>
                    # rvest::read_html() |>
                    rvest::minimal_html(x) %>%
                    rvest::html_element("a") |>
                    rvest::html_attr("href")
            }) %>%
                stringr::str_c("https://www.parlament.gv.at", .)
        ) %>%
        dplyr::mutate(
            sitzung_name = map_chr(sitzung, \(x) {
                if (is.na(x)) {
                    return(NA_character_)
                }
                x |>
                    # rvest::read_html() |>
                    rvest::minimal_html(x) %>%
                    rvest::html_element("a") |>
                    rvest::html_text()
            })
        ) %>%
        dplyr::select(-sitzung) %>%
        dplyr::mutate(
            transcript_url = map_chr(transcript, \(x) {
                if (is.na(x)) {
                    return(NA_character_)
                }
                x |>
                    rvest::read_html() |>
                    rvest::html_element("a") |>
                    rvest::html_attr("href")
            }) %>%
                stringr::str_c("https://www.parlament.gv.at", .)
        ) %>%
        dplyr::select(-transcript) %>%
        dplyr::mutate(
            media_url = map_chr(media, \(x) {
                if (is.na(x)) {
                    return(NA_character_)
                }
                x |>
                    rvest::read_html() |>
                    rvest::html_element("a") |>
                    rvest::html_attr("href")
            }) %>%
                stringr::str_c("https://www.parlament.gv.at", .)
        ) %>%
        dplyr::select(-media) %>%
        dplyr::mutate(fromdate = lubridate::ymd_hms(fromdate) %>% as.Date())

    #rename columns; only when col available
    renaming_map <- c(
        "bez" = "position_text", #REMOVE tets if failure if non-existing column included
        "fromdate" = "date",
        "gp" = "legis_period",
        "gremium" = "house",
        "rede" = "speech_title",
        "transcript_url" = "speech_transcript_url",
        "sitzung_name" = "session_name",
        "media_url" = "speech_media_url",
        "sitzung_url" = "session_url"
    )

    df_res <- df_res %>%
        dplyr::rename_with(
            .fn = \(x) renaming_map[x], # For each selected old name, get its new name from the map
            .cols = any_of(names(renaming_map))
        )

    # standardize house names in output
    df_res <- df_res %>%
        dplyr::mutate(
            house = dplyr::case_when(
                house == "N" ~ "NR",
                house == "B" ~ "BR",
                TRUE ~ house
            )
        )

    # ADD MANDATE TYPE ATTIME OF SPEECH
    df_mandates <- get_mandates(pad_intern = pad_intern) %>%
        dplyr::select(
            name,
            pad_intern,
            position_name,
            position_date_start,
            position_date_end,
            position_active
        ) %>%
        dplyr::mutate(
            position_date_end = dplyr::case_when(
                is.na(position_date_end) & position_active == TRUE ~ Sys.Date(),
                TRUE ~ position_date_end
            )
        ) %>%
        dplyr::mutate(
            pad_intern = as.character(pad_intern)
        )

    df_res <- df_res %>%
        dplyr::left_join(
            df_mandates,
            by = dplyr::join_by(
                pad_intern,
                between(x$date, y$position_date_start, y$position_date_end)
            )
        ) %>%
        dplyr::select(
            -any_of(c(
                "position_date_start",
                "position_date_end",
                "position_active"
            ))
        )

    df_res <- df_res %>%
        dplyr::group_by(dplyr::across(-position_name)) %>%
        dplyr::summarise(
            position_name = list(unique(position_name[!is.na(position_name)])),
            .groups = "drop"
        )

    df_res <- df_res %>%
        dplyr::relocate(c("name", "position_name"), .after = pad_intern)

    #ECHO
    if (echo) {
        print(body_params)

        body_params_li <- jsonlite::fromJSON(body_params)

        query_string <- purrr::imap(
            body_params_li,
            \(x, y) {
                glue::glue(
                    "BIO_251{URLencode(y)}={URLencode(as.character(x))}"
                )
            }
        ) %>%
            unlist() %>%
            unname() %>%
            paste0(collapse = "&")

        print(glue::glue(
            "https://www.parlament.gv.at/person/{pad_intern}?{query_string}&selectedtab=PLENUM"
        ))
        print(nrow(df_res))
    }

    return(df_res)
}


get_mps_details_activities <- function(
    pad_intern = NULL,
    house = NULL,
    legis_period = NULL,
    item = NULL, #Art des Verhandlungsgegenstandes
    search_string = NULL #search string
) {
    # House check
    checkmate::assert_subset(
        x = house,
        choices = c("NR", "BR"), #PENDING PN KN as well?
        empty.ok = TRUE
    )

    if (!is.null(house)) {
        house <- switch(
            house,
            "NR" = "N",
            "BR" = "B",
            house
        )
    }

    # legis_period
    if (!is.null(legis_period)) {
        legis_period <- as.roman(legis_period)

        checkmate::assert_int(
            x = min(as.numeric(legis_period)), #min since length > 1 possible
            lower = 20,
            null.ok = TRUE
        )
    }

    # BODY PARAMS
    body_params <- list(
        PAD_INTERN = pad_intern,
        gremium = house,
        gp_text_full = as.character(legis_period),
        vhg4 = item
    ) |>
        purrr::compact() |>
        jsonlite::toJSON()

    res <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/25"
    ) |>
        req_method("POST") |>
        req_url_query(
            js = "eval",
            page = "1",
            # pagesize = "20",
            showAll = "true",
            sortrnr = "9",
            ascDesc = "DESC"
        ) |>
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            # referer = "https://www.parlament.gv.at/person/145?PERS_AKTIVIT_025PAD_INTERN=145&PERS_AKTIVIT_025gremium=N&PERS_AKTIVIT_025gremium=B&PERS_AKTIVIT_025gp_text_full=XXVII&PERS_AKTIVIT_025gp_text_full=XXVI&PERS_AKTIVIT_025vhg4=A&selectedtab=AKT",
            `sec-ch-ua` = '"Microsoft Edge";v="137", "Chromium";v="137", "Not/A)Brand";v="24"',
            `sec-ch-ua-mobile` = "?0",
            `sec-ch-ua-platform` = '"Windows"',
            `sec-fetch-dest` = "empty",
            `sec-fetch-mode` = "cors",
            `sec-fetch-site` = "same-origin",
            `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36 Edg/137.0.0.0",
            cookie = "pddsgvo=j; _pk_id.1.26ca=2b9c3ab31363e4f4.1742073577.; _pk_ref.1.26ca=%5B%22%22%2C%22%22%2C1749223177%2C%22https%3A%2F%2Fwww.bing.com%2F%22%5D"
        ) |>
        httr2::req_body_raw(
            body_params,
            type = "application/json"
        ) |>
        httr2::req_perform()

    li_res <- res %>%
        httr2::resp_body_json(simplifyVector = TRUE) #simplifyVector = TRUE !!

    df_res <- li_res %>% pluck("rows") %>% as.data.frame()
    # print(df_res)

    # Exit if no match
    if (nrow(df_res) == 0 || is.null(df_res)) {
        message("No data found for the given parameters.")
        return(invisible(NULL))
    }

    vec_names <- li_res %>%
        purrr::pluck("header", "label") %>%
        stringr::str_to_lower()

    #assign column names; assumes stable column sorting in API response
    names(df_res) <- vec_names
    col_rede <- which(names(df_res) == "status")
    names(df_res)[col_rede + 1] <- "details_html"
    cols_keep <- c(
        "pad_intern",
        "gp",
        "gremium",
        "frmdate",
        "art",
        "ityp_komm",
        "nr",
        "betreff",
        "aktualisierung",
        "link",
        "status",
        "details_html",
        "vhg4"
    )
    # keep only relevant columns
    df_res <- df_res %>%
        dplyr::select(
            dplyr::any_of(cols_keep)
        )

    # parse html elements & format
    df_res <- df_res %>%
        dplyr::mutate(
            details_html = stringr::str_squish(details_html) %>%
                stringr::str_remove_all(
                    .,
                    stringr::regex("<br />", literal = TRUE)
                )
        ) %>%
        dplyr::mutate(
            details_status = stringr::str_extract(
                details_html,
                stringr::regex("(?<=Status: ).*(?=Phase)")
            ) %>%
                stringr::str_squish()
        ) %>%
        dplyr::select(-details_html)

    # standardize house names in output
    df_res <- df_res %>%
        dplyr::mutate(
            house = dplyr::case_when(
                house == "N" ~ "NR",
                house == "B" ~ "BR",
                TRUE ~ house
            )
        )

    return(df_res)
}
