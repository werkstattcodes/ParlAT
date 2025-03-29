#' Get Current Members of Parliament
#'
#' @description
#' Fetches current members of parliament based on provided search criteria. Mirrors
#' the search functionality on the Austrian Parliament website at
#' <a href="https://www.parlament.gv.at/recherchieren/personen/nationalrat" target="_blank">this page</a>.
#'
#' @param institution Character. The parliamentary institution, accepted values are "Nationalrat" or "Bundesrat".
#' @param gender Character. Gender filter to apply; options are "all", "female", or "male". Default is "all".
#' @param position Character. Position filter with acceptable values:
#'   \itemize{
#'     \item "ALLE": Alle (all members of parliament)
#'     \item "1PNR": Präsident des Nationalrates (President of the National Council)
#'     \item "2PNR": Zweiter Präsident des Nationalrates (Second President of the National Council)
#'     \item "3PNR": Dritter Präsident des Nationalrates (Third President of the National Council)
#'     \item "PRAES": Präsidialkonferenz (Presidential Conference)
#'     \item "ZON":  Ordner des Nationalrates (Regulators of the National Council)
#'     \item "ZSN": Schriftführer des Nationalrates (Secretary of the National Council)
#'   }
#' @param parl_group Character. Parliamentary group filter. Acceptable values include "all", "LBd", "CSP", "GRÜNE", "SPÖ",
#'   "F-BZÖ", "GdP", "F", "FPÖ", "KuL", "VO", "WdU", "LB", "NEOS-LIF", "PILZ", "NEOS", "OK", "HB", "KPÖ",
#'   "ÖVP", "BZÖ", "JETZT", "L", "STRONACH", "NWB", "SdP".
#'
#' @param party Character. Political party filter with acceptable values such as "all", "BP", "BZÖ", "BAP", "CSP",
#'   "Grüne", "FPÖ", "GdP", "HB", "KuL", "KPÖ", "LBd", "L", "LB", "PILZ", "NWB", "NEOS", "ÖVP", "SdP",
#'   "SPÖ", "STRONACH", "VO", "WdU".
#' @param state Character. (Reserved) Currently not utilized.
#' @param electoral_district Character. Electoral district filter. Accepted values include region names such as "all", "Bundeswahlvorschlag",
#'   "Burgenland", "Kärnten", "Niederösterreich", "Oberösterreich", "Salzburg", "Steiermark", "Tirol", "Vorarlberg",
#'   "Wien", and various sub-regions (e.g., "Burgenland Nord", "Burgenland Süd", etc.).
#'
#' @return A data frame containing the list of current members of parliament that match the search criteria.
#'
#' @examples
#' \dontrun{
#'   df_members <- get_mps_current(
#'     institution = "Nationalrat",
#'     gender = "female",
#'     party = "SPÖ",
#'     electoral_district = "Wien"
#'   )
#'
#'   if (!is.null(df_members)) {
#'     print(df_members)
#'   }
#' }
#'
#' @import checkmate httr2 jsonlite purrr janitor
#' @export
get_mps_current <- function(
    institution = NULL,
    gender = "all",
    position = NULL,
    parl_group = NULL,
    party = NULL,
    state = NULL,
    electoral_district = NULL,
    postal_code = NULL,
    echo = TRUE
) {
    #GENDER
    choices_gender <- c("all", "female", "male")
    checkmate::assert_subset(
        gender,
        choices_gender,
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
        "ZSN" #SchriftführerIn des Nationalrates (Secretary of the National Council)
    )
    checkmate::assert_subset(
        position,
        choices = choices_position,
        empty.ok = TRUE
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
    checkmate::assert_subset(party, choices = choices_party, empty.ok = TRUE)

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
        empty.ok = TRUE
    )

    #encode
    # parl_group <- match.arg(parl_group, several.ok = FALSE)
    if (!is.null(parl_group) && parl_group == "all") {
        parl_group <- "NULL"
    }

    #STATE

    #POSTAL CODE
    R_PBW_input <- NULL
    if (!is.na(postal_code) && !is.null(postal_code)) {
        R_PBW_input <- "PLZ"
    } else {
        R_PBW_input <- R_PBW_input
    }

    #ELECTORAL DISTRICT
    # electoral_district <- match.arg(electoral_district, several.ok = FALSE)
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
        WP = party,
        FR = parl_group,
        PLZ = postal_code,
        R_PBW = R_PBW_input,
        WK = electoral_district
    ) |>
        purrr::compact() |>
        jsonlite::toJSON()

    # PERFORM REQUEST
    res <- get_mps_current_api_request(body_params)

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

    #ECHO
    if (echo == TRUE) {
        print(nrow(df_res))
        print(body_params)

        query_string <- body_params %>%
            fromJSON() %>%
            imap(
                .,
                \(x, y) glue::glue("WFW_002R{URLencode(y)}={URLencode(x)}")
            ) %>%
            unlist() %>%
            unname() %>%
            paste0(collapse = "&")

        print(glue::glue(
            "https://www.parlament.gv.at/recherchieren/personen/nationalrat/index.html?{query_string}"
        ))
    }

    # #PARSE HTML STRINGS
    df_res <- df_res |>
        dplyr::mutate(across(
            c("klub", "bundesland"),
            \(x) purrr::map_chr(x, aux_parse_html_text)
        ))

    return(df_res)
}


#' Fetch Current Members of Parliament Data
#'
#' This function sends a POST request to the Austrian Parliament's API endpoint to retrieve data related to current members of parliament.
#'
#' @param body_params A JSON-formatted string or raw vector containing the body parameters required by the API.
#'
#' @return An HTTP response object from the httr2 package containing the API's response.
#'
#' @noRd
get_mps_current_api_request <- function(body_params) {
    httr2::request("https://www.parlament.gv.at/Filter/api/json/post") |>
        req_method("POST") |>
        req_url_query(
            jsMode = "EVAL",
            FBEZ = "WFW_002",
            listeId = "undefined",
            pageNumber = "1",
            pagesize = "200",
            feldRnr = "1",
            ascDesc = "ASC"
        ) |>
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            # referer = "https://www.parlament.gv.at/recherchieren/personen/nationalrat",
            `sec-ch-ua` = '"Chromium";v="134", "Not:A-Brand";v="24", "Microsoft Edge";v="134"',
            `sec-ch-ua-mobile` = "?0",
            `sec-ch-ua-platform` = '"Windows"',
            `sec-fetch-dest` = "empty",
            `sec-fetch-mode` = "cors",
            `sec-fetch-site` = "same-origin",
            `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edg/134.0.0.0",
            # cookie = "JSESSIONID=8W7-0Ik_IGTvMWFmcUDtc42xP_c-TZhjBqdTemqY.appsrv05e; pddsgvo=j; _pk_id.1.26ca=2b9c3ab31363e4f4.1742073577.; _pk_ref.1.26ca=%5B%22%22%2C%22%22%2C1742568811%2C%22https%3A%2F%2Fwww.bing.com%2F%22%5D; _pk_ses.1.26ca=1"
        ) |>
        httr2::req_body_raw(body_params, type = "application/json") |>
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
        httr2::req_verbose(
            body_req = F,
            header_req = F,
            header_resp = F,
            body_resp = F,
            info = F
        ) %>%
        httr2::req_perform()
}
