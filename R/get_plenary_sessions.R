#' @title Get Plenary Sessions from Austrian Parliament
#'
#' @description
#' Retrieves information about plenary sessions from the Austrian Parliament's API.
#'
#' @param institution A character string specifying the institution. "Bundesrat", "Nationalrat", or "Bundesversammlung"
#' @param legis_period Numeric value specifying the legislative period. Data available from 20th legislative period onwards.
#' @param session_and_activities A character string. 'Sitzungen', 'eingebracht wurden' or 'stattgefunden haben'.
#' @param eingebracht A character string.  Specifying the type of activities that were introduced. Possible values are: 'ALLE', 'AA', 'G037', 'G080', 'J', 'AE', 'G015', 'G014', 'AB', 'G053', 'UEA', 'UEAM'.
#' @param stattgefunden A character string. specifying the type of activities that took place. Possible values are: 'ALLE', 'ASEU', 'AS', 'GO04', 'FS', 'RGER', 'RGEU', 'GO', 'GO35'.
#' @return A data frame containing plenary session details.
#'
#' @details
#' Possible values for `eingebracht` if `session_and_activities` is set to `eingebracht wurden`:
#' *   ALLE: Alles (All)
#' *   AA: Abänderungsanträge (Amendment Motions)
#' *   G037: Anträge auf Absetzung von der Tagesordnung (Motions to Remove from Agenda)
#' *   G080: Anträge auf Durchführung einer Volksabstimmung (Motions for Referendum)
#' *   J: Dringliche Anfragen (Urgent Inquiries)
#' *   AE: Dringliche Anträge (Urgent Motions)
#' *   G015: Fristerstreckungsanträge (Deadline Extension Motions)
#' *   G014: Fristsetzungsanträge (Deadline Setting Motions)
#' *   AB: Kurze Debatten über Anfragebeantwortungen (Brief Debates on Inquiry Responses)
#' *   G053: Rückverweisungsanträge (Referral Back Motions)
#' *   UEA: Unselbständige Entschließungsanträge (Dependent Resolution Motions)
#' *   UEAM: Unselbständige Misstrauensanträge (Dependent No-Confidence Motions)
#'
#' Possible values for `stattgefunden` if `session_and_activities` is set to `stattgefunden haben`:
#' *   ALLE: Alles (All)
#' *   ASEU: Aktuelle Europastunden (Current Europe Hours)
#' *   AS: Aktuelle Stunden (Current Hours)
#' *   GO04: Erklärungen des Präsidenten / der Präsidentin (President's Declarations)
#' *   FS: Fragestunden (Question Hours)
#' *   RGER: Regierungserklärungen (Government Declarations)
#' *   RGEU: Regierungserklärungen zu EU-Themen (Government Declarations on EU Topics)
#' *   GO: Sonstige Geschäftsordnungsangelegenheiten (Other Procedural Matters)
#' *   GO35: Unterrichtungen gemäß Art. 50 Abs. 5 B-VG (Notifications according to Art. 50 Para. 5 B-VG)
#'
#'
#' @examples \dontrun{
#' get_plenary_session(instition = "Nationalrat", legis_period = 26)
#' }
#'
#' @export
# TODO augment documentation
# TODO rename attributes to english
get_plenary_sessions <- function(
    institution = NULL,
    legis_period = NULL,
    session_and_activities = "Sitzungen",
    eingebracht = NULL,
    stattgefunden = NULL
) {
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

    # SESSION AND ACTIVITIES
    choices_session_and_activities <- c(
        "Sitzungen",
        "eingebracht wurden",
        "stattgefunden haben"
    )
    checkmate::assert_subset(
        session_and_activities,
        choices_session_and_activities,
        empty.ok = T
    )
    ## encode
    session_and_activities_input <- switch(
        session_and_activities,
        "Sitzungen" = "SI",
        "eingebracht wurden" = "EI",
        "stattgefunden haben" = "ST"
    )

    # CONDITION USE OF 'eingebracht' and 'stattgefunden' on value in session_and_activities
    if (
        !is.null(eingebracht) && session_and_activities != "eingebracht wurden"
    ) {
        stop(
            "'eingebracht' parameter can only be used when session_and_activities is 'eingebracht wurden'"
        )
    }
    if (
        !is.null(stattgefunden) &&
            session_and_activities != "stattgefunden haben"
    ) {
        stop(
            "'stattgefunden' parameter can only be used when session_and_activities is 'stattgefunden haben'"
        )
    }

    choices_eingebracht <- c(
        "ALLE",
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
    checkmate::assert_subset(eingebracht, choices_eingebracht, empty.ok = T)

    choices_stattgefunden <- c(
        "ALLE",
        "ASEU",
        "AS",
        "GO04",
        "FS",
        "RGER",
        "RGEU",
        "GO",
        "GO35"
    )
    checkmate::assert_subset(stattgefunden, choices_stattgefunden, empty.ok = T)

    # BODY PARAMS
    body_params <- list(
        MODUS = "PLENAR",
        NRBRBV = institution_input,
        GP = legis_period_input,
        R_SISTEI = session_and_activities_input,
        EIN = eingebracht,
        STATT = stattgefunden
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

    # parse html to text
    # df_res <- df_res |>
    #     dplyr::mutate(across(any_of(c("art","tagesordnung")), \(x) aux_parse_html_title(x)))

    return(df_res)
}
