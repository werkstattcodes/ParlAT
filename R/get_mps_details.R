get_mps_details <- function(
    pad_intern = NULL,
    detail_type = NULL,
    house = NULL,
    legis_period = NULL
) {
    # type
    checkmate::assert_subset(
        x = detail_type,
        choices = c("plenary"),
        empty.ok = TRUE
    )

    # house
    checkmate::assert_subset(
        x = type,
        choices = c("NR", "BR"), #PENDING PN KN as well?
        empty.ok = TRUE
    )

    res <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/251"
    ) |>
        httr2::req_method("POST") |>
        httr2::req_url_query(
            js = "eval",
            page = "1",
            pagesize = "20",
            sortrnr = "10",
            ascDesc = "DESC"
        ) |>
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            referer = "https://www.parlament.gv.at/person/145?selectedtab=PLENUM",
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
            # body_params,
            '{"PAD_INTERN":[145]}',
            type = "application/json"
        ) |>
        httr2::req_perform()

    li_res <- res %>%
        httr2::resp_body_json(simplifyVector = TRUE) #simplifyVector = TRUE !!

    df_res <- li_res %>% pluck("rows") %>% as.data.frame()
    # ncol(df_res)
    # class(df_res)

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
        "fromdate",
        "gp",
        "gremium",
        "sitzung",
        "rede",
        "transcript",
        "media"
    ) #TODO keep also pad_intern

    df_res <- df_res %>%
        dplyr::select(
            dplyr::all_of(cols_keep)
        )
    #TODO parse columns with html content
    return(df_res)
}
