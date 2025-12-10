get_inquiries_and_responses <- function(
    institution = NULL,
    legis_period = NULL,
    search_term = NULL,
    inquiry_or_response = NULL,
    type = "ALLE"
) {
    # PENDING

    # INSTITUTION
    checkmate::assert_subset(
        institution,
        choices = c("Bundesrat", "Nationalrat", "Bundesversammlung"),
        empty.ok = FALSE
    )
    ## encode
    institution_input <- switch(
        institution,
        Nationalrat = "NR",
        Bundesrat = "BR",
        Bundesversammlung = "BV"
    )

    # LEGISLATIVE PERIOD
    legis_period_input <- as.character(utils::as.roman(legis_period))

    # INQUIRY OR RESPONSE
    checkmate::assert_subset(
        inquiry_or_response,
        choices = c("inquiry", "response"),
        empty.ok = FALSE
    )
    ## encode
    inquiry_or_response_input <- switch(
        inquiry_or_response,
        inquiry = "J_JPR_M",
        response = "AB_ABPR_ABM"
    )

    # SEARCH TERM
    search_term_input <- search_term

    # TYPE OF INQUIRY OR RESPONSE
    type_input <- type

    # BODY PARAMS
    body_params <- list(
        NRBR = institution_input,
        GP = legis_period_input,
        SUCH = search_term_input,
        JMAB = inquiry_or_response_input,
        VHG2 = type_input
    ) %>%
        purrr::compact() %>% # keep only non-empty elements
        jsonlite::toJSON()

    # PERFORM REQUEST
    res <- httr2::request("https://www.parlament.gv.at/Filter/api/json/post") %>%
        httr2::req_url_query(
            jsMode = "EVAL",
            FBEZ = "WFP_005",
            listeId = "undefined",
            showAll = TRUE,
            feldRnr = "1",
            ascDesc = "DESC",
        ) %>%
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
            `content-type` = "application/json",
            cookie = "JSESSIONID=iKXM7OFa8k08t-YvjlkpMqniLt2vciq1o-7ihZer.appsrv04e; JSESSIONID=TMjVAqf5hP5ZYQFoBRd8_8vRxt8HCVbHUOEghgQV.appsrv05e",
            dnt = "1",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
        ) %>%
        httr2::req_body_raw(body_params, "application/json") %>%
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") %>%
        httr2::req_verbose(
            body_req = T,
            header_req = F,
            header_resp = F
        ) %>%
        httr2::req_perform()

    vec_headings <- res %>%
        httr2::resp_body_json(simplifyVector = T) %>%
        purrr::pluck("header", "label") %>%
        stringr::str_to_snake() %>%
        make.unique(sep = "_")

    # extract the actual substantive data
    df_res <- res %>%
        httr2::resp_body_json(simplifyVector = T) %>%
        purrr::pluck("rows")

    if (length(df_res) == 0) {
        message("No results found for the provided search criteria.")
        return(NULL)
    }

    colnames(df_res) <- vec_headings

    df_res <- as.data.frame(df_res)
    print(names(df_res))

    return(df_res)
}
