# pad_intern; one or more ids possible (plenary)
# legis_period => 20 (when plenary); more than 1 legis period possible (plenary)
# plenary details returns all speeches of the person, regardless of his or her
# mandate at the time of the speech; get_mps_details ("MPs") is  hence somewhat misleading

#' Get detailed information about Members of Parliament
#'
#' The function retrieves details on Members of Parliament (MPs) in three categories:
#' \itemize{
#'   \item speeches held in plenary meetings ("plenary"),
#'   \item other relevant activities ("activities"), and
#'   \item their participation in committees ("committees").
#' }
#' Depending on the requested details category, different function parameters are available.
#' For an example of the data source on the website of the Austrian Parliament, see
#' the different tabs e.g., <a href="https://www.parlament.gv.at/person/145?selectedtab=PLENUM" target="_blank">here.</a>
#'
#' @param pad_intern  ID of MP. Vector of length 1. See `get_pad_intern()` for more details.
#' @param detail_type Character string specifying the type of details to retrieve: "plenary", "activities", or "committees". For examples see here:  <a href="https://www.parlament.gv.at/person/145?selectedtab=PLENUM" target="_blank">plenary </a>; <a href="https://www.parlament.gv.at/person/145?selectedtab=AKT" target="_blank">activities</a>; <a href="https://www.parlament.gv.at/person/145?selectedtab=AUS" target="_blank">committees</a>.
#' @param institution Character string specifying the parliamentary house. Permissible inputs are "NR" (Nationalrat/National Council),
#' "BR" (Bundesrat/Federal Council ) or NULL (which returns results for both houses). Defaults to NULL.
#' @param legis_period Numeric or character vector specifying one or more legislative periods (optional).
#'   Accepts numeric values (e.g., 27 or c(26, 27)), Roman numerals (e.g., "XXVII"), or historical abbreviations.
#'   Must be >= 20 for valid periods. Defaults to NULL.
#' @param item Character string specifying the item type (Art des Verhandlungsgegenstandes) (optional).
#'   Defaults to NULL. Used only for details category "activities". See Details below.
#' @param committee Character string specifying the committee name (optional). Only if `detail_type == "committees"`.
#'   See Details section for valid committee names.
#' @param committee_position Character string specifying the committee position (optional). Only if `detail_type == "committees"`.
#'   Common values include "Mitglied", "Vorsitzende/r", "Stellvertretende/r Vorsitzende/r".
#' @param search_string Character string for searching within activities (optional).
#'   Defaults to NULL. Currently only implemented for details category "activities".
#' @param echo Logical indicating whether to print the API request and response details. Defaults to TRUE.
#' @details
#' ## Item type (Art des Verhandlungsgegenstandes)
#IMPROVE #PARLSIMON
#' Possible values for `item` are:
#' - "A" (Gesetzesanträge, Legislative proposals)
#' - "AA" (Abänderungsanträge, Amendment Motion)
#' - "ABMIN" (Anfragebeantwortung durch die Bundesregierung, Responses by the Federal Government)
#' - "ABMIN-BR" (Anfragebeantwortung durch die Bundesregierung im Bundesrat, Responses by the Federal Government in the Federal Council)
#' - "ABPRPR" (Anfragebeantwortung durch den Präsidenten des Nationalrates, Responses by the President of the National Council)
#' - "AE" (Selbständige Entschließungen, Independent Resolutions)
#' - "ARH1" (Anträge gemäß $ 99 Abs. 1, Motions according to § 99 Abs. 1)
#' - "JMIN" (Schriftliche Anfrage an die Bundesregierung, Written Questions to the Federal Government)
#' - "JPRPR" (Schriftliche Anfrage an den Präsidenten des Nationalrates, Written Questions to the President of the National Council)
#' - "M" (Mündliche Anfrage an die Bundesregierung, Oral Questions to the Federal Government)
#' - "UEA" (Unselbständige Entschließungen, Dependent Resolution Motion)
#' - "AVB" (Anträge auf Volksbefragung)
#' - "JHR" (Schriftliche Anfrage an den RechnungshofpräsidentInnen, Written Questions to the President of the Court of Auditors)
#' - "PET" (Petitionen, Petitions)
#'
#' ## Committees
#' Possible values for `committee` are:
#'
#' - Ausschuss für Arbeit und Soziales
#' - Ausschuss für Bauten und Wohnen
#' - Ausschuss für Familie und Jugend
#' - Ausschuss für Forschung, Innovation und Digitalisierung
#' - Ausschuss für innere Angelegenheiten
#' - Ausschuss für Konsumentenschutz
#' - Ausschuss für Land- und Forstwirtschaft
#' - Ausschuss für Menschenrechte
#' - Ausschuss für Petitionen und Bürgerinitiativen
#' - Ausschuss für Wirtschaft, Industrie und Energie
#' - Außenpolitischer Ausschuss
#' - Budgetausschuss
#' - COFAG-Untersuchungsausschuss eingesetzt am 15.12.2023 - beendet am 03.07.2024
#' - Finanzausschuss
#' - Geschäftsordnungsausschuss
#' - Gesundheitsausschuss
#' - Gleichbehandlungsausschuss
#' - Hauptausschuss
#' - Untersuchungsauschuss: Ibiza-Untersuchungsausschuss
#' - Immunitätsausschuss
#' - Justizausschuss
#' - Kulturausschuss
#' - Landesverteidigungsausschuss
#' - ÖVP-Korruptions-Untersuchungsausschuss eingesetzt am 09.12.2021 - beendet am 27.04.2023
#' - Rechnungshofausschuss
#' - "ROT-BLAUER Machtmissbrauch-Untersuchungsausschuss" eingesetzt am 15.12.2023 - beendet am 03.07.2024
#' - Sportausschuss
#' - Ständiger gemeinsamer Ausschuss im Sinne des § 9 des Finanz-Verfassungsgesetzes 1948
#' - Ständiger Unterausschuss des Ausschusses für innere Angelegenheiten
#' - Ständiger Unterausschuss des Budgetausschusses
#' - Ständiger Unterausschuss des Hauptausschusses
#' - Ständiger Unterausschuss des Landesverteidigungsausschusses
#' - Ständiger Unterausschuss des Rechnungshofausschusses
#' - Ständiger Unterausschuss in Angelegenheiten der Europäischen Union
#' - Ständiger Unterausschuss in ESM-Angelegenheiten
#' - Tourismusausschuss
#' - Umweltausschuss
#' - Unterrichtsausschuss
#' - Unvereinbarkeitsausschuss
#' - Verfassungsausschuss
#' - Verkehrsausschuss
#' - Volksanwaltschaftsausschuss
#' - Wissenschaftsausschuss
#'
#' @return A data frame containing the requested MP details. The structure depends on the
#'   \code{detail_type} parameter:
#'
#'   For \code{detail_type = "plenary"}: Returns all speeches of the person in the specified
#'   house, regardless of their mandate at the time of the speech. For example, querying
#'   all plenary activities of Doris Bures in the National Council will return not only
#'   her speeches as an MP, but also as President of the National Council and as Minister.
#'   Columns returned:
#'   - `pad_intern`: Unique identifier for the MP
#'   - `name`: Full name of the MP
#'   - `position_name`: List of mandates/positions held at the time of speech
#'   - `date`: Date of the speech
#'   - `legis_period`: Legislative period (Roman numeral)
#'   - `institution`: Chamber of Parliament: "NR" (National Council) or "BR" (Federal Council)
#'   - `speech_title`: Title of the speech
#'   - `meeting_url`: URL to the meeting details page
#'   - `meeting_name`: Name of the parliamentary meeting
#'   - `speech_transcript_url`: URL to the speech transcript
#'   - `speech_media_url`: URL to speech recordings, if available
#'
#'   For \code{detail_type = "activities"}: Returns parliamentary activities and legislative
#'   items associated with the MP. Columns returned:
#'   - `pad_intern`: Unique identifier for the MP
#'   - `legis_period`: Legislative period
#'   - `institution`: Chamber of Parliament: "NR" (National Council) or "BR" (Federal Council)
#'   - `frmdate`: Date field
#'   - `ityp_komm`: Item type comment
#'   - `item_number`: Number of the parliamentary item
#'   - `item_type`: Type of parliamentary item (e.g., "A", "JMIN")
#'   - `title`: Title/subject of the item
#'   - `date_updated`: Last update date of the item
#'   - `item_url`: URL to the item details
#'   - `status_text`: Current status description
#'   - `status_numeric`: Numeric status code
#'
#'   For \code{detail_type = "committees"}: Returns committee memberships and participation.
#'   Columns returned:
#'   - `pad_intern`: Unique identifier for the MP
#'   - `name`: Full name of the MP
#'   - `legis_period`: Legislative period
#'   - `committee_name`: Name of the committee
#'   - `committee_position`: Position in the committee (e.g., "Mitglied", "Vorsitzende/r")
#'   - `institution`: Chamber of Parliament: "NR" (National Council) or "BR" (Federal Council)
#'   - `committee_position_start`: Start date of committee membership
#'   - `committee_position_end`: End date of committee membership (NA if still active)
#'   - `committee_active`: Logical indicating if membership is currently active
#'   - `committee_url`: URL to committee details
#'
#'   Returns \code{NULL} invisibly if no data is found for the given parameters.
#'
#' @examples
#' \donttest{
#' # Get Stephanie Krisper's plenary speeches in National Council only for the 27th legislative period
#' plenary_nr <- get_mps_details(
#'   pad_intern = 2344,
#'   detail_type = "plenary",
#'   institution = "NR",
#'   legis_period = 27
#' )
#' dplyr::glimpse(plenary_nr)
#'
#' # Get plenary speeches for multiple legislative periods
#' plenary_multiple <- get_mps_details(
#'   pad_intern = 2344,
#'   detail_type = "plenary",
#'   legis_period = c(26, 27)
#' )
#' dplyr::glimpse(plenary_multiple)
#'
#' # Get only legislative proposals (item type "A")
#' proposals <- get_mps_details(
#'   pad_intern = 2344,
#'   detail_type = "activities",
#'   item = "A",
#'   legis_period = 27
#' )
#' dplyr::glimpse(proposals)
#'
#' # Get committee memberships for Stephanie Krisper
#' committees <- get_mps_details(
#'   pad_intern = 2344,
#'   detail_type = "committees",
#'   legis_period = 27
#' )
#' dplyr::glimpse(committees)
#'}
#' @export
get_mps_details <- function(
    pad_intern,
    detail_type,
    institution = NULL,
    legis_period = NULL,
    item = NULL, #only for activities
    search_string = NULL, #search string for activities
    committee = NULL, #only for committees
    committee_position = NULL, #only for committees
    echo = TRUE
) {
    # detail_type must be supplied and valid
    if (missing(detail_type) || is.null(detail_type)) {
        cli::cli_abort(
            "`detail_type` is a required parameter: Add 'activities', 'committees', or 'plenary'."
        )
    }

    if (detail_type == "plenary" && !is.null(search_string)) {
        cli::cli_abort(
            "search_string is only supported for details type 'activities' and 'committees', but not for plenary details."
        )
    }

    #check if pad_intern is valid and of length 1
    checkmate::assert_scalar(
        pad_intern,
        .var.name = "`pad_intern` must be a vector of length 1. Only one single value accepted."
    )

    if (aux_check_pad_intern_exists(pad_intern) == FALSE) {
        cli::cli_abort(
            "`pad_intern` value is invalid. No entry found under this id."
        )
    }

    checkmate::assert_choice(
        detail_type,
        choices = c("plenary", "activities", "committees")
    )

    if (!is.null(item) && detail_type != "activities") {
        cli::cli_abort(
            "`item` is only supported for details type 'activities'."
        )
    }

    if (detail_type == "activities") {
        # check if item is valid
        checkmate::assert_choice(
            item,
            choices = c(
                "A",
                "AA",
                "ABMIN",
                "ABMIN-BR",
                "ABPRPR",
                "AE",
                "ARH1",
                "JMIN",
                "JPRPR",
                "M",
                "UEA",
                "AVB",
                "JHR",
                "PET"
            ),
            null.ok = TRUE
        )
    }

    if (!is.null(detail_type) && detail_type == "plenary") {
        return(get_mps_details_plenary(
            pad_intern = pad_intern,
            # detail_type = detail_type,
            institution = institution,
            legis_period = legis_period,
            echo = echo
        ))
    }
    if (!is.null(detail_type) && detail_type == "activities") {
        return(get_mps_details_activities(
            pad_intern = pad_intern,
            # detail_type = detail_type,
            institution = institution,
            legis_period = legis_period,
            item = item,
            search_string = search_string,
            echo = echo
        ))
    }
    if (!is.null(detail_type) && detail_type == "committees") {
        return(get_mps_details_committees(
            pad_intern = pad_intern,
            # detail_type = detail_type,
            institution = institution,
            legis_period = legis_period,
            committee = committee,
            committee_position = committee_position,
            search_string = search_string,
            echo = echo
        ))
    }
}

#' Internal function for plenary details
#'
#' @noRd
#' @keywords internal
get_mps_details_plenary <- function(
    pad_intern = NULL,
    # detail_type = NULL,
    institution = NULL,
    legis_period = NULL, #string for activities
    echo = NULL
) {
    # institution
    checkmate::assert_subset(
        x = institution,
        choices = c("NR", "BR"), #PENDING PN KN as well?
        empty.ok = TRUE
    )

    if (!is.null(institution)) {
        institution <- switch(
            institution,
            "NR" = "N",
            "BR" = "B",
            institution
        )
    }

    # legis_period
    if (!is.null(legis_period)) {
        legis_period <- as.roman(legis_period)

        if (min(as.numeric(legis_period)) < 20) {
            cli::cli_abort(
                "Only data from the 20th legislative period onwards can be queried. You provided legis_period = {min(as.numeric(legis_period))}."
            )
        }
    }

    # BODY PARAMS
    body_params <- list(
        PAD_INTERN = pad_intern,
        GREMIUM = institution,
        GP_CODE = as.character(legis_period) #not roman
    ) %>%
        purrr::compact() %>%
        jsonlite::toJSON()

    #API CALL PLENARY
    res <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/251"
    ) %>%
        httr2::req_method("POST") %>%
        httr2::req_url_query(
            js = "eval",
            page = "1",
            # pagesize = "20",
            showAll = "true",
            sortrnr = "10",
            ascDesc = "DESC"
        ) %>%
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
            origin = "https://www.parlament.gv.at"
        ) %>%
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") %>%
        httr2::req_body_raw(
            body_params,
            # '{"PAD_INTERN":[145]}',
            type = "application/json"
        ) %>%
        httr2::req_perform()

    #PARSE RESPONSE
    li_res <- res %>%
        httr2::resp_body_json(simplifyVector = TRUE) #simplifyVector = TRUE !!

    df_res <- li_res %>% pluck("rows") %>% as.data.frame()

    # Exit if no match
    if (is.null(df_res) || nrow(df_res) == 0) {
        cli::cli_inform("No data found for the given parameters.")
        return(.parlat_empty_tibble(
            c(
                "pad_intern", "name", "position_name", "date", "legis_period",
                "institution", "speech_title", "meeting_url", "meeting_name",
                "speech_transcript_url", "speech_media_url"
            ),
            date_cols = "date",
            list_cols = "position_name"
        ))
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
            sitzung_url = purrr::map_chr(.data$sitzung, \(x) {
                x %>%
                    # rvest::read_html() %>%
                    rvest::minimal_html(x) %>%
                    rvest::html_element("a") %>%
                    rvest::html_attr("href")
            }) %>%
                stringr::str_c("https://www.parlament.gv.at", .)
        ) %>%
        dplyr::mutate(
            sitzung_name = purrr::map_chr(.data$sitzung, \(x) {
                if (is.na(x)) {
                    return(NA_character_)
                }
                x %>%
                    # rvest::read_html() %>%
                    rvest::minimal_html(x) %>%
                    rvest::html_element("a") %>%
                    rvest::html_text()
            })
        ) %>%
        dplyr::select(-"sitzung") %>%
        dplyr::mutate(
            transcript_url = purrr::map_chr(.data$transcript, \(x) {
                if (is.na(x)) {
                    return(NA_character_)
                }
                x %>%
                    rvest::read_html() %>%
                    rvest::html_element("a") %>%
                    rvest::html_attr("href")
            }) %>%
                stringr::str_c("https://www.parlament.gv.at", .)
        ) %>%
        dplyr::select(-"transcript") %>%
        dplyr::mutate(
            media_url = purrr::map_chr(.data$media, \(x) {
                if (is.na(x)) {
                    return(NA_character_)
                }
                x %>%
                    rvest::read_html() %>%
                    rvest::html_element("a") %>%
                    rvest::html_attr("href")
            }) %>%
                stringr::str_c("https://www.parlament.gv.at", .)
        ) %>%
        dplyr::select(-"media") %>%
        dplyr::mutate(fromdate = lubridate::ymd_hms(.data$fromdate) %>% as.Date())

    #rename columns; only when col available
    renaming_map <- c(
        "bez" = "position_text", #REMOVE tets if failure if non-existing column included
        "fromdate" = "date",
        "gp" = "legis_period",
        "gremium" = "institution",
        "rede" = "speech_title",
        "transcript_url" = "speech_transcript_url",
        "sitzung_name" = "meeting_name",
        "media_url" = "speech_media_url",
        "sitzung_url" = "meeting_url"
    )

    df_res <- .parlat_apply_renaming(df_res, renaming_map)

    # standardize institution names in output
    df_res <- df_res %>%
        dplyr::mutate(
            institution = dplyr::case_when(
                .data$institution == "N" ~ "NR",
                .data$institution == "B" ~ "BR",
                TRUE ~ .data$institution
            )
        )

    # ADD MANDATE TYPE ATTIME OF SPEECH
    df_mandates <- get_mandates(pad_intern = pad_intern) %>%
        dplyr::select(
            "name",
            "pad_intern",
            "position_name",
            "position_date_start",
            "position_date_end",
            "position_active"
        ) %>%
        dplyr::mutate(
            position_date_end = dplyr::case_when(
                is.na(.data$position_date_end) & .data$position_active == TRUE ~ Sys.Date(),
                TRUE ~ .data$position_date_end
            )
        ) %>%
        dplyr::mutate(
            pad_intern = as.character(.data$pad_intern)
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
        dplyr::group_by(dplyr::across(-"position_name")) %>%
        dplyr::summarise(
            position_name = list(unique(.data$position_name[!is.na(.data$position_name)])),
            .groups = "drop"
        )

    df_res <- df_res %>%
        dplyr::relocate(c("name", "position_name"), .after = pad_intern)

    #ECHO
    if (echo) {
        .parlat_echo_request(
            body_params,
            url_base = glue::glue("https://www.parlament.gv.at/person/{pad_intern}"),
            param_prefix = "BIO_250",
            n_results = nrow(df_res),
            url_suffix = "&selectedtab=PLENUM"
        )
    }

    return(df_res)
}


#' Internal function for activities details
#'
#' @noRd
#' @keywords internal
get_mps_details_activities <- function(
    pad_intern = NULL,
    institution = NULL,
    legis_period = NULL,
    item = NULL, #Art des Verhandlungsgegenstandes
    search_string = NULL, #search string
    echo = NULL
) {
    # institution check
    checkmate::assert_subset(
        x = institution,
        choices = c("NR", "BR"), #PENDING PN KN as well?
        empty.ok = TRUE
    )

    if (!is.null(institution)) {
        institution <- switch(
            institution,
            "NR" = "N",
            "BR" = "B",
            institution
        )
    }

    # legis_period
    if (!is.null(legis_period)) {
        legis_period <- as.roman(legis_period)

        if (min(as.numeric(legis_period)) < 20) {
            cli::cli_abort(
                "Only data from the 20th legislative period onwards can be queried. You provided legis_period = {min(as.numeric(legis_period))}."
            )
        }
    }

    # BODY PARAMS
    body_params <- list(
        PAD_INTERN = pad_intern,
        gremium = institution,
        gp_text_full = as.character(legis_period),
        vhg4 = item
    ) %>%
        purrr::compact() %>%
        jsonlite::toJSON()

    res <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/25"
    ) %>%
        httr2::req_method("POST") %>%
        httr2::req_url_query(
            js = "eval",
            page = "1",
            # pagesize = "20",
            showAll = "true",
            sortrnr = "9",
            ascDesc = "DESC"
        ) %>%
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
            origin = "https://www.parlament.gv.at"
        ) %>%
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") %>%
        httr2::req_body_raw(
            body_params,
            type = "application/json"
        ) %>%
        httr2::req_perform()

    li_res <- res %>%
        httr2::resp_body_json(simplifyVector = TRUE) #simplifyVector = TRUE !!

    df_res <- li_res %>% pluck("rows") %>% as.data.frame()

    # Exit if no match
    if (is.null(df_res) || nrow(df_res) == 0) {
        cli::cli_inform("No data found for the given parameters.")
        return(.parlat_empty_tibble(
            c(
                "pad_intern", "legis_period", "institution", "frmdate",
                "ityp_komm", "item_number", "item_type", "title",
                "date_updated", "item_url", "status_numeric", "status_text"
            )
        ))
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
            details_html = stringr::str_squish(.data$details_html) %>%
                stringr::str_remove_all(
                    stringr::regex("<br />", literal = TRUE)
                )
        ) %>%
        dplyr::mutate(
            details_status = stringr::str_extract(
                .data$details_html,
                stringr::regex("(?<=Status: ).*(?=Phase)")
            ) %>%
                stringr::str_squish()
        ) %>%
        dplyr::select(-"details_html")

    #rename columns; only when col available
    renaming_map <- c(
        # "bez" = "position_text", #REMOVE tets if failure if non-existing column included
        # "fromdate" = "date",
        "gp" = "legis_period",
        "gremium" = "institution",
        # "art"= "item_type",
        "vhg4" = "item_type",
        "nr" = "item_number",
        "betreff" = "title",
        "aktualisierung" = "date_updated",
        "link" = "item_url",
        "details_status" = "status_text",
        "status" = "status_numeric"

        # "rede" = "speech_title",
        # "transcript_url" = "speech_transcript_url",
        # "sitzung_name" = "meeting_name",
        # "media_url" = "speech_media_url",
        # "sitzung_url" = "meeting_url"
    )

    df_res <- .parlat_apply_renaming(df_res, renaming_map)

    # standardize institution names in output
    df_res <- df_res %>%
        dplyr::mutate(
            institution = dplyr::case_when(
                .data$institution == "N" ~ "NR",
                .data$institution == "B" ~ "BR",
                TRUE ~ .data$institution
            )
        )

    df_res <- df_res %>%
        dplyr::select(
            -"art"
        ) %>%
        dplyr::relocate("item_type", .after = "item_number")

    # ADD MANDATE TYPE ATTIME OF SPEECH
    #PENDING #PARLSIMON
    # there is no date of the activity returned; only an updated date which
    # is the latest date in the procedures related to the activity;
    # e.g. Antrag: date_updated is e.g. when Antrag was accepted, but not when
    # Antrag was actually submitted/tabled;
    # df_mandates <- get_mandates(pad_intern = pad_intern) %>%
    #     dplyr::select(
    #         name,
    #         pad_intern,
    #         position_name,
    #         position_date_start,
    #         position_date_end,
    #         position_active
    #     ) %>%
    #     dplyr::mutate(
    #         position_date_end = dplyr::case_when(
    #             is.na(position_date_end) & position_active == TRUE ~ Sys.Date(),
    #             TRUE ~ position_date_end
    #         )
    #     ) %>%
    #     dplyr::mutate(
    #         pad_intern = as.character(pad_intern)
    #     )

    # df_res <- df_res %>%
    #     dplyr::left_join(
    #         df_mandates,
    #         by = dplyr::join_by(
    #             pad_intern,
    #             between(x$date, y$position_date_start, y$position_date_end)
    #         )
    #     ) %>%
    #     dplyr::select(
    #         -any_of(c(
    #             "position_date_start",
    #             "position_date_end",
    #             "position_active"
    #         ))
    #     )

    # df_res <- df_res %>%
    #     dplyr::group_by(dplyr::across(-position_name)) %>%
    #     dplyr::summarise(
    #         position_name = list(unique(position_name[!is.na(position_name)])),
    #         .groups = "drop"
    #     )

    # df_res <- df_res %>%
    #     dplyr::relocate(c("name", "position_name"), .after = pad_intern)

    #ECHO
    if (echo) {
        .parlat_echo_request(
            body_params,
            url_base = glue::glue("https://www.parlament.gv.at/person/{pad_intern}"),
            param_prefix = "PERS_AKTIVIT_025",
            n_results = nrow(df_res),
            url_suffix = "&selectedtab=AKT"
        )
    }

    return(df_res)
}


#' Internal function for committees details
#'
#' @noRd
#' @keywords internal
get_mps_details_committees <- function(
    pad_intern = NULL,
    institution = NULL,
    legis_period = NULL,
    item = NULL, #Art des Verhandlungsgegenstandes
    search_string = NULL, #search string
    committee_position = NULL, #only for committees
    committee = NULL, #only for committees
    echo = NULL
) {
    # parameter validation
    checkmate::assert_subset(
        x = institution,
        choices = c("NR", "BR"), #PENDING PN KN as well?
        empty.ok = TRUE
    )

    checkmate::assert_character(committee, null.ok = TRUE)
    checkmate::assert_character(committee_position, null.ok = TRUE)
    checkmate::assert_logical(echo, null.ok = TRUE)

    if (!is.null(institution)) {
        institution <- switch(
            institution,
            "NR" = "Nationalrat",
            "BR" = "Bundesrat",
            institution
        )
    }

    # legis_period
    legis_period_input <- NULL
    if (!is.null(legis_period)) {
        legis_period_roman <- as.roman(legis_period)

        if (min(as.numeric(legis_period_roman)) < 20) {
            cli::cli_abort(
                "Only data from the 20th legislative period onwards can be queried. You provided legis_period = {min(as.numeric(legis_period_roman))}."
            )
        }

        df_legis_period_input <- get_legis_periods(
            legis_period
        )

        legis_period_input <- df_legis_period_input %>%
            dplyr::pull("legis_period_name") %>%
            stringr::str_replace(
                stringr::regex("\\bGP$"),
                "Gesetzgebungsperiode des NR"
            )
    }
    # BODY PARAMS
    body_params <- list(
        PAD_INTERN = pad_intern,
        GREMIUM = institution,
        GP_TEXT_FULL = legis_period_input,
        FUNKTION = committee_position,
        AUSSCHUSS = committee
    ) %>%
        purrr::compact() %>%
        jsonlite::toJSON()

    # print(body_params)

    #API CALL COMMITTEE
    res <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/250"
    ) %>%
        httr2::req_method("POST") %>%
        httr2::req_url_query(
            `1` = "1",
            page = "1",
            # pagesize = "20",
            showAll = "true",
            sortrnr = "2",
            ascDesc = "ASC"
        ) %>%
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
            origin = "https://www.parlament.gv.at"
        ) %>%
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") %>%
        httr2::req_body_raw(
            body_params,
            type = "application/json"
        ) %>%
        httr2::req_perform()

    # return(res)

    #PARSE RESPONSE
    li_res <- res %>%
        httr2::resp_body_json(simplifyVector = TRUE) #simplifyVector = TRUE !!

    # return(li_res)

    df_res <- li_res %>% pluck("rows") %>% as.data.frame()

    # Exit if no match
    if (is.null(df_res) || nrow(df_res) == 0) {
        cli::cli_inform("No committee data found for the given parameters.")
        return(.parlat_empty_tibble(
            c(
                "pad_intern", "name", "legis_period", "committee_name",
                "committee_position", "institution",
                "committee_position_start", "committee_position_end",
                "committee_active", "committee_url"
            ),
            lgl_cols = "committee_active"
        ))
    }

    #RENAME AND SELECT VARIALBES

    renaming_map <- c(
        "V1" = "legis_period",
        "V9" = "committee_name",
        "V3" = "committee_position",
        "V4" = "committee_name_dates",
        "V5" = "institution",
        "V6" = "committee_url"
        # "V8" = "committee_meeting_date_start",
        # "V11" = "committee_duration"
    )

    df_res <- .parlat_apply_renaming(df_res, renaming_map)

    df_res <- df_res %>%
        dplyr::select(dplyr::any_of(unname(renaming_map))) %>%
        dplyr::relocate(dplyr::any_of(unname(renaming_map))) %>%
        dplyr::mutate(
            committee_position_start = stringr::str_extract(
                .data$committee_name_dates,
                stringr::regex("(?<=\\()\\d+\\.\\d+\\.\\d+")
            ),
            committee_position_end = stringr::str_extract(
                .data$committee_name_dates,
                stringr::regex("(?<=-\\s)[\\d.]+(?=\\)$)")
            )
        ) %>%
        dplyr::select(-"committee_name_dates") %>%
        dplyr::mutate(
            committee_active = ifelse(
                is.na(.data$committee_position_end),
                TRUE,
                FALSE
            )
        ) %>%
        dplyr::mutate(across(starts_with("committee_date"), \(x) {
            lubridate::dmy(x)
        })) %>%
        dplyr::relocate("committee_url", .after = dplyr::last_col()) %>%
        dplyr::mutate(
            committee_url = paste0(
                "https://www.parlament.gv.at/",
                .data$committee_url
            )
        )

    #ADD MPinfo

    mp_name <- get_names(pad_intern = pad_intern, latest = TRUE)$name

    df_res <- df_res %>%
        dplyr::mutate(pad_intern = !!pad_intern, .before = 1) %>%
        dplyr::mutate(name = !!mp_name, .after = "pad_intern")

    #ECHO
    if (echo) {
        .parlat_echo_request(
            body_params,
            url_base = glue::glue("https://www.parlament.gv.at/person/{pad_intern}"),
            param_prefix = "AUSSCHUSS_BIO_250",
            n_results = nrow(df_res),
            url_suffix = "&selectedtab=AUS"
        )
    }

    return(df_res)
}
