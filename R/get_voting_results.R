# Parse vote-result text blocks into structured fields.
#
# This helper is designed for strings such as `status_description` in
# `get_item_details()`, where plenary voting outcomes may appear as free text.
# It extracts decision, subject, and parliamentary groups listed as in favor /
# against / abstained.
#
# @param x Character vector. Typically `df_details$status_description` or
#   `df_details$stage_name` from [get_item_details()].
#
# @return A tibble with one row per input string and the columns:
#' \describe{
#'   \item{original_text}{Original input text.}
#'   \item{is_vote_result}{Logical flag indicating whether voting-related
#'     markers were detected.}
#'   \item{decision}{Parsed decision keyword (e.g. "angenommen",
#'     "abgelehnt") when present.}
#'   \item{vote_subject}{Text immediately following "Abstimmung:" before party
#'     blocks (if present).}
#'   \item{in_favor}{List-column of groups after "Dafür:".}
#'   \item{against}{List-column of groups after "Dagegen:" / "dagegen:".}
#'   \item{abstained}{List-column of groups after "Enthaltung:" /
#'     "Enthaltungen:".}
#' }
#'
#' @examples
#' txt <- "3. Sitzung des Nationalrates: Abstimmung: Antrag ...: angenommen Dafür: ÖVP, SPÖ, dagegen: FPÖ"
#' get_voting_results(txt)
#'
#' @export
get_voting_results <- function(x) {
  checkmate::assert_character(x, any.missing = TRUE, null.ok = FALSE)

  split_groups <- function(txt) {
    if (is.na(txt) || !nzchar(stringr::str_squish(txt))) {
      return(character(0))
    }
    txt |>
      stringr::str_replace_all("\\s+", " ") |>
      stringr::str_split(",") |>
      purrr::pluck(1) |>
      stringr::str_squish() |>
      (
        \(v) v[nzchar(v)]
      )()
  }

  normalize_text <- function(txt) {
    if (is.na(txt)) {
      return(NA_character_)
    }

    txt |>
      stringr::str_replace_all("<br\\s*/?>", " ") |>
      stringr::str_replace_all("([:;,])(?=\\S)", "\\1 ") |>
      stringr::str_replace_all("(angenommen|abgelehnt|vertagt|zugewiesen)(?=(Dafür:|Dagegen:|dagegen:|Enthaltung|Enthaltungen))", "\\1 ") |>
      stringr::str_squish()
  }

  parse_one <- function(txt) {
    txt_norm <- normalize_text(txt)

    is_vote <- !is.na(txt_norm) && stringr::str_detect(
      txt_norm,
      "(?i)(Abstimmung:|Dafür:|Dagegen:|Enthaltung|einstimmig|angenommen|abgelehnt)"
    )

    decision <- stringr::str_extract(
      txt_norm,
      "(?i)(einstimmig angenommen|angenommen|abgelehnt|vertagt|zugewiesen)"
    ) |>
      stringr::str_to_lower()

    vote_subject <- stringr::str_match(
      txt_norm,
      "(?i)Abstimmung:\\s*(.*?)(?=(?:Dafür:|Dagegen:|dagegen:|Enthaltung|Enthaltungen|$))"
    )[, 2] |>
      stringr::str_squish() |>
      stringr::str_remove("[:;,\\s]+$")

    in_favor_raw <- stringr::str_match(
      txt_norm,
      "(?i)Dafür:\\s*(.*?)(?=(?:Dagegen:|dagegen:|Enthaltung|Enthaltungen|$))"
    )[, 2]

    against_raw <- stringr::str_match(
      txt_norm,
      "(?i)Dagegen:\\s*(.*?)(?=(?:Enthaltung|Enthaltungen|$))"
    )[, 2]

    abstained_raw <- stringr::str_match(
      txt_norm,
      "(?i)Enthaltungen?:\\s*(.*)$"
    )[, 2]

    tibble::tibble(
      original_text = txt,
      is_vote_result = is_vote,
      decision = rlang::`%||%`(decision, NA_character_),
      vote_subject = rlang::`%||%`(vote_subject, NA_character_),
      in_favor = list(split_groups(rlang::`%||%`(in_favor_raw, NA_character_))),
      against = list(split_groups(rlang::`%||%`(against_raw, NA_character_))),
      abstained = list(split_groups(rlang::`%||%`(abstained_raw, NA_character_)))
    )
  }

  purrr::map(x, parse_one) |>
    purrr::list_rbind()
}
