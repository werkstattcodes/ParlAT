#' @title Get Details of a Plenary Meeting
#'
#' @description
#' Retrieves detailed information about a specific plenary meeting from the
#' Austrian Parliament website. The function scrapes the embedded JavaScript
#' data from the meeting's detail page.
#'
#' Supply either `url` **or** the combination of `institution`,
#' `legis_period`, and `meeting_number` — not both.
#'
#' @param url Character or NULL. URL of the plenary meeting page on
#'   `parlament.gv.at`. Can be an absolute URL (with or without a
#'   `?selectedStage=` query parameter) or a relative path. The
#'   `selectedStage` parameter is ignored when fetching data — both
#'   `selectedStage=100` and `selectedStage=110` return the same embedded
#'   dataset. Mutually exclusive with `institution`, `legis_period`, and
#'   `meeting_number`.
#' @param institution Character or NULL. Parliamentary chamber: `"NR"`
#'   (Nationalrat) or `"BR"` (Bundesrat). Mutually exclusive with `url`.
#' @param legis_period Character, numeric, or NULL. Legislative period.
#'   Accepts numeric (`28`), Arabic character (`"28"`), or Roman numeral
#'   (`"XXVIII"`) formats. Mutually exclusive with `url`.
#' @param meeting_number Character, numeric, or NULL. Meeting number within
#'   the legislative period (e.g. `50` or `"50"`). Mutually exclusive with
#'   `url`.
#' @param details_on Character or NULL. Specifies which part of the meeting
#'   data to return. If `NULL` (default), returns a 1-row tibble with meeting
#'   metadata. Use `"speakers"` to return a multi-row tibble with one row per
#'   speech, including timing information. Use `"decisions"` to return a
#'   multi-row tibble with one row per agenda item (TOP). Use `"timeline"` to
#'   return a multi-row tibble with one row per Sitzungsverlauf event.
#' @param echo Logical. If `TRUE`, prints the URL being fetched and the number
#'   of rows returned. Default is `FALSE`.
#'
#' @return A tibble. The structure depends on `details_on`:
#'
#' If `details_on = NULL` (default):
#' - `meeting_url` (character): The URL used to fetch the data.
#' - `meeting_title` (character): Full title of the meeting.
#' - `meeting_citation` (character): Citation reference (e.g. `"50/NRSITZ"`).
#' - `legis_period` (character): Legislative period code (e.g. `"XXVIII"`).
#' - `meeting_type` (character): Meeting type label (e.g. `"Plenarsitzung"`).
#' - `meeting_type_short` (character): Short type code (e.g. `"NRSITZ"`).
#' - `meeting_nr` (integer): Meeting number within the legislative period.
#' - `date` (Date): Date of the meeting.
#' - `state` (character): Completion state (e.g. `"fertig"`).
#' - `start_time` (POSIXct): Start time of the meeting.
#' - `end_time` (POSIXct): End time of the meeting.
#'
#' If `details_on = "speakers"`:
#' - `meeting_url` (character): The URL used to fetch the data.
#' - `meeting_title` (character): Full title of the meeting.
#' - `meeting_citation` (character): Citation reference (e.g. `"50/NRSITZ"`).
#' - `legis_period` (character): Legislative period code (e.g. `"XXVIII"`).
#' - `meeting_type` (character): Meeting type label (e.g. `"Plenarsitzung"`).
#' - `debate_id` (integer): Internal debate identifier.
#' - `debate_type` (character): Debate type code (`"AS"`, `"ND"`, `"DA"`, `"SU"`).
#' - `debate_typetext` (character): Human-readable debate type label.
#' - `debate_text` (character): Full debate heading text.
#' - `debate_starttime` (character): Debate start time (ISO 8601 or time string).
#' - `debate_endtime` (character): Debate end time (time string).
#' - `debate_limit` (integer): Default per-speech time limit in minutes.
#' - `debate_state` (character): Debate completion state.
#' - `speech_nr` (integer): Sequential speech number within the debate.
#' - `speech_state` (character): Speech completion state.
#' - `speaker_name` (character): Speaker name with party abbreviation.
#' - `pad_intern` (integer): Internal person identifier.
#' - `wm_type` (character): Speech type abbreviation (`"wm"`, `"un"`, `"sr"`, etc.).
#' - `start_time` (character): Speech start time (HH:MM).
#' - `duration` (character): Actual speech duration (MM:SS).
#' - `speech_limit` (integer): Individual speech time limit in minutes.
#'
#' If `details_on = "decisions"`:
#' - `meeting_url` (character): The URL used to fetch the data.
#' - `meeting_title` (character): Full title of the meeting.
#' - `meeting_citation` (character): Citation reference (e.g. `"59/NRSITZ"`).
#' - `legis_period` (character): Legislative period code (e.g. `"XXVIII"`).
#' - `meeting_type` (character): Meeting type label (e.g. `"Plenarsitzung"`).
#' - `resolution_top` (character): Agenda item label (e.g. `"TOP 1"`).
#' - `resolution_title` (character): Agenda item title.
#' - `resolution_url` (character): Relative URL to the main document.
#' - `resolution_citation` (character): Citation of the main document (e.g. `"319 d.B."`).
#'
#' If `details_on = "timeline"`:
#' - `meeting_url` (character): The URL used to fetch the data.
#' - `meeting_title` (character): Full title of the meeting.
#' - `meeting_citation` (character): Citation reference (e.g. `"59/NRSITZ"`).
#' - `legis_period` (character): Legislative period code (e.g. `"XXVIII"`).
#' - `meeting_type` (character): Meeting type label (e.g. `"Plenarsitzung"`).
#' - `stage_date` (character): Date of the event (`"DD.MM.YYYY"`), or `NA` for
#'   agenda-item rows. The Schriftführer row (no text) is excluded.
#' - `agenda_item` (character): Agenda item label (e.g. `"TOP 1"`) for TOP rows,
#'   or `NA` for dated rows.
#' - `stage_text` (character): Plain-text description of the event (HTML stripped).
#' - `statements` (list): For "Wortmeldungen in der Debatte" rows, a nested tibble
#'   with one row per speaker: `speaker_name` (character), `speaker_url` (character),
#'   `wm_type` (character, e.g. `"Pro"`, `"Contra"`), `protocol_ref` (character,
#'   e.g. `"RN/4"`), `protocol_url` (character). `NULL` for all other rows.
#' - `stage_fsth_url` (character): URL to the stenographic protocol reference, or `NA`.
#' - `stage_fsth_title` (character): Title of the stenographic protocol reference, or `NA`.
#'
#' @seealso
#' * [get_plenary_meetings()] for retrieving meeting URLs.
#'
#' @examples
#' \dontrun{
#' # Via URL — meeting metadata (default)
#' get_plenary_meeting_details(
#'   url = "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50?selectedStage=100"
#' )
#'
#' # Via structured arguments — numeric legis_period
#' get_plenary_meeting_details(institution = "NR", legis_period = 28, meeting_number = 50)
#'
#' # Via structured arguments — Roman numeral legis_period, speakers mode
#' get_plenary_meeting_details(
#'   institution = "NR", legis_period = "XXVIII", meeting_number = 50,
#'   details_on = "speakers", echo = TRUE
#' )
#'
#' # Via URL — speaker list with timing information
#' get_plenary_meeting_details(
#'   url = "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50",
#'   details_on = "speakers"
#' )
#' }
#'
#' @export
get_plenary_meeting_details <- function(
    url            = NULL,
    institution    = NULL,
    legis_period   = NULL,
    meeting_number = NULL,
    details_on     = NULL,
    echo           = FALSE
) {
    # VALIDATE INPUTS
    url_provided   <- !is.null(url)
    parts_provided <- !is.null(institution) || !is.null(legis_period) || !is.null(meeting_number)

    if (url_provided && parts_provided) {
        cli::cli_abort(
            "Provide either {.arg url} OR the combination of {.arg institution}, \\
             {.arg legis_period}, and {.arg meeting_number} -- not both."
        )
    }
    if (!url_provided && !parts_provided) {
        cli::cli_abort(
            "Supply either {.arg url} or all three of {.arg institution}, \\
             {.arg legis_period}, and {.arg meeting_number}."
        )
    }
    if (!url_provided && parts_provided) {
        if (is.null(institution) || is.null(legis_period) || is.null(meeting_number)) {
            cli::cli_abort(
                "{.arg institution}, {.arg legis_period}, and {.arg meeting_number} \\
                 must all be supplied together."
            )
        }
    }

    checkmate::assert_choice(details_on, choices = c("speakers", "decisions", "timeline"), null.ok = TRUE)
    checkmate::assert_flag(echo)

    # BUILD URL FROM PARTS or NORMALISE PROVIDED URL
    prefix <- "https://www.parlament.gv.at/"

    if (!url_provided) {
        checkmate::assert_choice(institution, choices = c("NR", "BR"))
        institution_code <- switch(institution, NR = "NRSITZ", BR = "BRSITZ")

        checkmate::assert_scalar(meeting_number)
        meeting_number_str <- as.character(meeting_number)
        path_prefix <- if (identical(institution, "BR")) {
            "BR"
        } else {
            aux_convert_legis_periods(as.character(legis_period), output = "roman")
        }

        url <- stringr::str_c(
            prefix, "gegenstand/",
            path_prefix, "/", institution_code, "/", meeting_number_str
        )
    } else {
        checkmate::assert_string(url)
        if (!stringr::str_starts(url, prefix)) {
            url <- url |>
                stringr::str_replace("^/+", "") |>
                (\(x) stringr::str_c(prefix, x))()
        }
    }

    if (isTRUE(echo)) {
        details_label <- if (is.null(details_on)) "NULL (meeting metadata)" else details_on
        cli::cli_inform("Fetching URL: {url}")
        cli::cli_inform("details_on: {details_label}")
    }

    # FETCH PAGE AND EXTRACT EMBEDDED JAVASCRIPT DATA
    page <- .parlat_fetch_html(url)

    # jsonlite simplifies the heterogeneous content array into a single
    # data frame with all keys merged across the 3 content items.
    # Row 1 = meeting metadata, row 2 = session info + debates, row 3 = progress.
    content <- .parlat_extract_props_json(page) |>
        jsonlite::fromJSON() |>
        (\(x) x$data$content)()

    # RETURN DATA
    if (is.null(details_on)) {
        # MEETING METADATA — 1-row tibble
        # Scalar columns come from row 1; session info is a nested df (row 2).
        df_res <- tibble::tibble(
            meeting_url      = url,
            meeting_title    = content$title[1],
            meeting_citation = content$zitation[1],
            legis_period     = content$gp_code[1],
            meeting_type       = content$type[1],
            meeting_type_short = content$ityp[1],
            meeting_nr         = content$inr[1],
            date               = as.Date(
                stringr::str_extract(content$einlangen[1], "^[0-9-]+")
            ),
            state      = content$info$state[2],
            start_time = lubridate::ymd_hms(content$info$starttime[2]),
            end_time   = lubridate::ymd_hms(content$info$endtime[2])
        )
    } else if (details_on == "speakers") {
        # SPEAKERS — one row per speech across all debates.
        # past_debates is a list-column; element [[2]] is the data frame.
        past_debates <- content$past_debates[[2]]

        df_res <- purrr::map(
            seq_len(nrow(past_debates)),
            function(i) {
                # speeches is a list-column of character matrices (Nx10)
                speeches <- past_debates$speeches[[i]]

                if (!is.matrix(speeches) || nrow(speeches) == 0) {
                    return(NULL)
                }

                purrr::map(
                    seq_len(nrow(speeches)),
                    function(j) {
                        row <- speeches[j, ]
                        tibble::tibble(
                            debate_id        = past_debates$id[i],
                            debate_type      = past_debates$type[i],
                            debate_typetext  = stringr::str_trim(past_debates$typetext[i]),
                            debate_text      = past_debates$text[i],
                            debate_starttime = past_debates$starttime[i],
                            debate_endtime   = past_debates$endtime[i],
                            debate_limit     = past_debates$limit[i],
                            debate_state     = past_debates$state[i],
                            speech_nr    = as.integer(row[1]),
                            speech_state = row[2],
                            speaker_name = row[3],
                            pad_intern   = as.integer(row[4]),
                            wm_type      = row[6],
                            start_time   = row[7],
                            duration     = row[8],
                            speech_limit = as.integer(row[9])
                        )
                    }
                ) |>
                    purrr::list_rbind()
            }
        ) |>
            purrr::compact() |>
            purrr::list_rbind() |>
            dplyr::mutate(
                meeting_url      = url,
                meeting_title    = content$title[1],
                meeting_citation = content$zitation[1],
                legis_period     = content$gp_code[1],
                meeting_type     = content$type[1],
                .before          = 1
            )
    } else if (details_on == "decisions") {
        # DECISIONS — one row per agenda item (TOP).
        # resolutions is a list-column in row 1 of the merged content data frame.
        resolutions <- content$resolutions[[1]]

        df_res <- tibble::tibble(
            resolution_top      = resolutions$top,
            resolution_title    = resolutions$text,
            resolution_url      = resolutions$url,
            resolution_citation = resolutions$zitation
        ) |>
            dplyr::mutate(
                meeting_url      = url,
                meeting_title    = content$title[1],
                meeting_citation = content$zitation[1],
                legis_period     = content$gp_code[1],
                meeting_type     = content$type[1],
                .before          = 1
            )
    } else if (details_on == "timeline") {
        # TIMELINE — one row per Sitzungsverlauf event.
        # stages is a list-column in row 1 of the merged content data frame.
        # Items without a text field (e.g. the Schriftführer names row) are
        # dropped via filter; fsth is a list-column that is NA for most rows.
        stages <- content$stages[[1]]

        df_res <- tibble::tibble(
            stage_date       = stages$date,
            stage_text       = stringr::str_remove_all(stages$text, "<[^>]+>"),
            statements       = purrr::map(seq_len(nrow(stages)), function(i) {
                # stages$reden is a nested data frame (jsonlite simplification):
                # 3 cols (rendertype, data, mapped) × 40 rows.
                # Rows without reden have NA in rendertype.
                reden_col <- stages[["reden"]]
                if (!is.data.frame(reden_col) ||
                    is.na(reden_col[["rendertype"]][[i]])) return(NULL)
                rows <- reden_col[["data"]][["rows"]][[i]]
                if (is.null(rows) || length(rows) == 0) return(NULL)
                if (is.matrix(rows)) {
                    purrr::map(seq_len(nrow(rows)), function(j) {
                        s3 <- rows[j, 3]
                        tibble::tibble(
                            speaker_name = stringr::str_remove_all(rows[j, 1], "<[^>]+>"),
                            speaker_url  = stringr::str_extract(rows[j, 1], "href=\"([^\"]+)\"", group = 1),
                            wm_type      = rows[j, 2],
                            protocol_ref = stringr::str_remove_all(s3, "<[^>]+>"),
                            protocol_url = stringr::str_extract(s3, "href=\"([^\"]+)\"", group = 1)
                        )
                    }) |> purrr::list_rbind()
                } else {
                    purrr::map(rows, function(row) {
                        s3 <- if (!is.null(row[[3]])) as.character(row[[3]]) else NA_character_
                        tibble::tibble(
                            speaker_name = stringr::str_remove_all(as.character(row[[1]]), "<[^>]+>"),
                            speaker_url  = stringr::str_extract(as.character(row[[1]]), "href=\"([^\"]+)\"", group = 1),
                            wm_type      = as.character(row[[2]]),
                            protocol_ref = stringr::str_remove_all(s3, "<[^>]+>"),
                            protocol_url = stringr::str_extract(s3, "href=\"([^\"]+)\"", group = 1)
                        )
                    }) |> purrr::list_rbind()
                }
            }),
            stage_fsth_url   = purrr::map_chr(stages$fsth, function(f) {
                if (is.data.frame(f) && nrow(f) > 0) f$url[1] else NA_character_
            }),
            stage_fsth_title = purrr::map_chr(stages$fsth, function(f) {
                if (is.data.frame(f) && nrow(f) > 0) f$title[1] else NA_character_
            })
        ) |>
            dplyr::filter(!is.na(.data$stage_text)) |>
            dplyr::mutate(
                agenda_item = dplyr::if_else(
                    stringr::str_starts(.data$stage_date, "TOP"),
                    .data$stage_date,
                    NA_character_
                ),
                stage_date  = dplyr::if_else(
                    stringr::str_starts(.data$stage_date, "TOP"),
                    NA_character_,
                    .data$stage_date
                ),
                .after = "stage_date"
            ) |>
            dplyr::mutate(
                meeting_url      = url,
                meeting_title    = content$title[1],
                meeting_citation = content$zitation[1],
                legis_period     = content$gp_code[1],
                meeting_type     = content$type[1],
                .before          = 1
            )
    }

    if (isTRUE(echo)) {
        cli::cli_inform("Returning {nrow(df_res)} row(s).")
    }

    df_res
}
