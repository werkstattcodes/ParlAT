get_mps_current <- function(
    institution = NULL,
    gender = "all",
    position = NULL,
    parl_group = NULL,
    party = NULL,
    state = NULL,
    electoral_district = NULL
) {
    #GENDER
    choices_gender <- c("all", "female", "male")
    checkmate::assert_subset(
        gender,
        choices_session_and_activities,
        empty.ok = T
    )
    ## encode
    gender <- match.arg(gender)
    if (gender == "all") {
        M_input <- "M"
        W_input <- "W"
    } else if (gender == "male") {
        M_input <- "M"
        W_input <- NULL
    } else if (gender == "female") {
        M_input <- NULL
        W_input <- "W"
    }

    #INSTITUTION
    choices_institution <- c("Nationalrat", "Bundesrat")
    checkmate::assert_subset(
        institution,
        choices = choices_institution,
        empty.ok = FALSE
    )
    ## encode
    institution <- switch(institution, Nationalrat = "NR", Bundesrat = "BR")

    #POSITION
    choices_position <- c(
        "ALLE", #Alle Abgeordnete (All Members of Parliament)
        "1PNR", #PräsidentIn des Nationalrates (President of the National Council)
        "2PNR", #2. PräsidentIn des Nationalrates (Second President of the National Council)
        "3PNR", #3. PräsidentIn des Nationalrates (Third President of the National Council)
        "PRAES", #Präsidialkonferenz (Presidential Conference)
        "ZON", #Ordner des Nationalrates (Regulators of the National Council)
        "ZSN", #SchriftführerIn des Nationalrates (Secretary of the National Council)
    )
    checkmate::assert_subset(
        position,
        choices = choices_position,
        empty.ok = FALSE
    )

    #PARTY
    choices_party <- c(
        "all",
        "BP",
        "BZÖ",
        "BAP",
        "CSP",
        "Grüne",
        "FPÖ",
        "GdP",
        "HB",
        "KuL",
        "KPÖ",
        "LBd",
        "L",
        "LB",
        "PILZ",
        "NWB",
        "NEOS",
        "ÖVP",
        "SdP",
        "SPÖ",
        "STRONACH",
        "VO",
        "WdU"
    )
    checkmate::assert_subset(party, choices = choices_party, empty.ok = FALSE)

    #PARLIAMENTARY GROUP
    ##TODO. parl_group only accepted if R_WF=="FR" (Fraktion)

    choices_parl_group <- c(
        "all",
        "LBd",
        "CSP",
        "GRÜNE",
        "SPÖ",
        "F-BZÖ",
        "GdP",
        "F",
        "FPÖ",
        "KuL",
        "VO",
        "WdU",
        "LB",
        "NEOS-LIF",
        "PILZ",
        "NEOS",
        "OK",
        "HB",
        "KPÖ",
        "ÖVP",
        "BZÖ",
        "JETZT",
        "L",
        "STRONACH",
        "NWB",
        "SdP"
    )
    checkmate::assert_subset(
        parl_group,
        choices = choices_parl_group,
        empty.ok = FALSE
    )

    #encode
    parl_group <- match.arg(parl_group, several.ok = FALSE)
    if (parl_group == "all") {
        parl_group <- "NULL"
    }

    electoral_district <- match.arg(electoral_district, several.ok = FALSE)
    electoral_district <- purrr::map_chr(
        electoral_district,
        \(x)
            switch(
                x,
                "all" = "ALLE",
                "Bundeswahlvorschlag" = "FB",
                "Burgenland" = "F1",
                "Kärnten" = "F2",
                "Niederösterreich" = "F3",
                "Oberösterreich" = "F4",
                "Salzburg" = "F5",
                "Steiermark" = "F6",
                "Tirol" = "F7",
                "Vorarlberg" = "F8",
                "Wien" = "F9",
                "Burgenland Nord" = "F1A",
                "Burgenland Süd" = "F1B",
                "Klagenfurt" = "F2A",
                "Villach" = "F2B",
                "Kärnten West" = "F2C",
                "Kärnten Ost" = "F2D",
                "Weinviertel" = "F3A",
                "Waldviertel" = "F3B",
                "Mostviertel" = "F3C",
                "Niederösterreich Mitte" = "F3D",
                "Niederösterreich Süd" = "F3E",
                "Thermenregion" = "F3F",
                "Niederösterreich Ost" = "F3G",
                "Linz und Umgebung" = "F4A",
                "Innviertel" = "F4B",
                "Hausruckviertel" = "F4C",
                "Traunviertel" = "F4D",
                "Mühlviertel" = "F4E",
                "Salzburg Stadt" = "F5A",
                "Flachgau/Tennengau" = "F5B",
                "Lungau/Pinzgau/Pongau" = "F5C",
                "Graz und Umgebung" = "F6A",
                "Oststeiermark" = "F6B",
                "Weststeiermark" = "F6C",
                "Obersteiermark" = "F6D",
                "Innsbruck" = "F7A",
                "Innsbruck-Land" = "F7B",
                "Unterland" = "F7C",
                "Oberland" = "F7D",
                "Osttirol" = "F7E",
                "Vorarlberg Nord" = "F8A",
                "Vorarlberg Süd" = "F8B",
                "Wien Innen-Süd" = "F9A",
                "Wien Innen-West" = "F9B",
                "Wien Innen-Ost" = "F9C",
                "Wien Süd" = "F9D",
                "Wien Süd-West" = "F9E",
                "Wien Nord-West" = "F9F",
                "Wien Nord" = "F9G"
            )
    )

    # BODY PARAMS
    body_params <- list(
        M = M_input,
        W = W_input,
        NRBR = institution,
        GP = legis_period,
        WP = party,
        FR = parl_group,
        PR = presidents_only,
        WK = electoral_district
    ) |>
        purrr::compact() |>
        jsonlite::toJSON()

    # PERFORM REQUEST
    res <- httr2::request("https://www.parlament.gv.at/Filter/api/json/post") |>
        req_url_query(
            jsMode = "FIELDS",
            FBEZ = "WFW_002",
        ) |>
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
            `content-type` = "application/json",
            cookie = "JSESSIONID=SrL57wtco2xe1q0nrAy05WS_7epciUmOJjL1Y4xr.appsrv04e; JSESSIONID=TMjVAqf5hP5ZYQFoBRd8_8vRxt8HCVbHUOEghgQV.appsrv05e",
            dnt = "1",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
        ) |>
        req_body_raw(
            '{"STEP":["1000"],"NRBR":["NR"],"GP":["AKT"],"R_WF":["WP"],"R_PBW":["WK"],"M":["M"],"W":["W"]}',
            "application/json"
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
    print(names(df_res))

    return(df_res)
}
