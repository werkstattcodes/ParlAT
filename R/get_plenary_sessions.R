#' @title Get Plenary Sessions from Austrian Parliament
#'
#' @description
#' Retrieves information about plenary sessions from the Austrian Parliament's API.
#'
#' @param institution A character string specifying the institution.
#' @param legis_period Numeric value specifying the legislative period. Data available from 20th legislative period onwards.
#' @param session_and_activities
#' @return A data frame containing plenary session details.
#'
#' @details
#'
#' @examples \dontrun{
#' get_plenary_session(instition = "Nationalrat", legis_period = 26)
#' }
#'
#' @export
get_plenary_sessions <- function(
    institution = NULL,
    legis_period = NULL,
    session_and_activities = NULL) {
    # INSTITUTION
    checkmate::assert_subset(institution, choices = c("Bundesrat", "Nationalrat", "Bundesversammlung"), empty.ok = FALSE)
    ## encode
    institution_input <- switch(institution,
        Nationalrat = "NR",
        Bundesrat = "BR",
        Bundesversammlung = "BV"
    )

    # LEGISLATIVE PERIOD
    legis_period_input <- as.character(utils::as.roman(legis_period))

    # SESSION AND ACTIVITIES
    choices_session_and_activities <- c("Sitzungen", "eingebracht wurden", "stattgefunden haben")
    checkmate::assert_subset(session_and_activities, choices_session_and_activities, empty.ok = T)
    ## encode
    session_and_activities_input <- switch(session_and_activities,
        Sitzungen = "SI",
        "eingebracht wurden" = "EI",
        "stattgefunden haben" = "ST"
    )
    # TODO 'eingebracht wurden' and 'stattgefunden haben' have nested options

    # BODY PARAMS
    body_params <- list(
        MODUS = "PLENAR",
        NRBRBV = institution_input,
        GP = legis_period_input,
        R_SISTEI = session_and_activities_input
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
            ascDesc = "ASC",
        ) |>
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
            `content-type` = "application/json",
            cookie = "JSESSIONID=2G9XjdAGlGAqPr2nTuHbdFadGVAlZBIZ-rpEs6VF.appsrv05e; JSESSIONID=TMjVAqf5hP5ZYQFoBRd8_8vRxt8HCVbHUOEghgQV.appsrv05e",
            dnt = "1",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
        ) |>
        httr2::req_body_raw(body_params, "application/json") |>
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
        httr2::req_verbose(
            body_req = T,
            header_req = F,
            header_resp = F
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

    # parse html to text
    df_res <- df_res |>
        dplyr::mutate(art = purrr::map_chr(art, \(x) aux_parse_html_title(x)))

    return(df_res)
}
