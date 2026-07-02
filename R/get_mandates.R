#' Zero-row tibble matching the stable core columns of get_mandates()
#' @noRd
.empty_mandates_tibble <- function() {
  .parlat_empty_tibble(
    c(
      "pad_intern", "name", "position_text", "position_code",
      "position_name", "position_date_start", "position_date_end",
      "position_active", "parl_group", "electoral_district_region_code",
      "electoral_district_region", "legis_period", "url_biography"
    ),
    date_cols = c("position_date_start", "position_date_end"),
    lgl_cols = "position_active",
    list_cols = "legis_period"
  )
}

#' @title Get mandates single mandate
#' @description
#' Auxiliary function which retrieves mandates for a single person. Is used internally
#' in get_mandates which allows for multiple `pad_intern` to be passed.
#'
#' @param pad_intern  Personal identfication number of person
#' @noRd
#' @return A dataframe.
#'
get_mandates_single <- function(pad_intern) {
  link_person <- glue::glue(
    "https://www.parlament.gv.at/person/{pad_intern}"
  )

  # fetched via httr2 so httptest2 can intercept and record the request
  file_json <- tryCatch(
    {
      json_text <- .parlat_fetch_detail_json_text(link_person)
      .parlat_parse_detail_json(json_text, simplifyVector = FALSE)$data
    },
    error = function(e) NULL
  )

  if (is.null(file_json)) {
    cli::cli_inform("No data found for pad_intern {pad_intern}.")
    return(NULL)
  }

  content <- file_json$content

  person_name <- content$headingbox$title_plain

  biography <- file_json$content$biografie
  df_biography <- biography %>% tibble::enframe()
  df_biography_wide <- df_biography %>% tidyr::pivot_wider()
  df_biography_wide <- df_biography_wide %>%
    tidyr::unnest_wider("mandatefunktionen")

  df_biography_wide %>%
    dplyr::select("mandate") %>%
    tidyr::unnest_longer("mandate") %>%
    tidyr::unnest_wider("mandate") %>%
    dplyr::mutate(pad_intern = !!pad_intern, .before = 1) %>%
    dplyr::mutate(dplyr::across(
      dplyr::any_of(c("funktion_von", "funktion_bis")),
      \(x) lubridate::dmy(x)
    )) %>%
    dplyr::mutate(name = !!person_name, .before = 1) %>%
    dplyr::select(
      -any_of(c("mandatVon", "mandatBis", "zeitraum", "gremium", "mandat"))
    )
}

#' @title Get mandates
#'
#' @description
#' Takes one or multiple names or pad_interns as input and returns a dataframe
#' with all their past and present mandates. Mandates can be limited to a specific date
#' or institution. Mandates cover memberships in Parliament, but also in the executive (e.g. Bundeskanzler/Chancellor).
#'
#' Note that a single row in the returned dataframe can represent e.g. multiple mandates in e.g. the Nationalrat if they were consecutively held.
#'
#' The function partly mimics the behavior of the 'Personensuche' on the website
#' of the Parliament (<a href="https://www.parlament.gv.at/recherchieren/personen/" target="_blank">here</a>).
#' @param pad_intern Personal identfication number of person(s). Cannot be combined with `name`; one of the two must be provided.
#' @param name A character vector of name(s). First name followed by family name. Cannot be combined with `pad_intern`; one of the two must be provided.
#' @param date Date to filter mandates (dmy format).
#' @param institution Chamber of Parliament. "NR" (Nationalrat), "BR" (Bundesrat), "KN" (Konstituierende Nationalversammlung),
#' or "PN" (Provisorische Nationalversammlung). NULL covers all institutions. Note that e.g. "NR" does not only return MP's mandates,
#' but also presidents of the National Council, Secretaries ("Schriftführer"), and Regulators ("Ordner"). The equivalent applies to other
#' the chambers as well.
#' @details
#' ## Names: The API will always return the latest name of an MP, even if the MP had a different name at a previous point in time.
#' See examples.
#' @return A dataframe with the following columns:
#' - `pad_intern`: Person's unique identification number
#' - `name`: Name of the person
#' - `position_text`: Full description of the position
#' - `position_code`: Code for the position type
#' - `position_name`: Name of the position/function
#' - `position_date_start`: Start date of the position (Date)
#' - `position_date_end`: End date of the position (Date, NA if currently active)
#' - `position_active`: Logical indicating if the position is currently active
#' - `parl_group`: Parliamentary group affiliation
#' - `party`: Political party code
#' - `party_name`: Full name of the political party
#' - `substitute`: Information about substitute status
#' - `electoral_district_region_code`: Electoral district region code
#' - `electoral_district_region`: Electoral district region name
#' - `legis_period`: Legislative period(s) (list-column)
#' - `url_biography`: URL to the person's biography page
#' @export
#' @seealso [get_names()], [get_pad_intern()]
#' @examples
#' \donttest{
#'   result <- get_mandates(c("Elisabeth Götze", "Sebastian Kurz"))
#'   dplyr::glimpse(result)
#'
#'   # Returns results with latest name (Beck)
#'   result <- get_mandates(c("Pia Philippa Strache"))
#'   dplyr::glimpse(result)
#'
#'   # Michael Pöck changed name to Michael Bernhard.
#'   result <- get_names(pad_intern = "83124")
#'   dplyr::glimpse(result)
#'
#'   # Query for Micheal Pöck returns all results under the name
#'   # Michael Bernhard, even for periods where Michael Pöck was still valid.
#'   result <- get_mandates(name = "Michael Pöck")
#'   dplyr::glimpse(result)
#'
#'   # Query for Michael Bernhard returns all results,
#'   # including for those with the name Michael Pöck.
#'   result <- get_mandates(name = "Michael Bernhard")
#'   dplyr::glimpse(result)
#' }
#'
get_mandates <- function(
  name = NULL,
  pad_intern = NULL,
  institution = NULL,
  date = NULL
) {
  if (is.null(name) && is.null(pad_intern)) {
    cli::cli_abort("Exactly one of {.arg name} or {.arg pad_intern} must be provided.")
  }
  if (!is.null(name) && !is.null(pad_intern)) {
    cli::cli_abort("Only one of {.arg name} or {.arg pad_intern} can be provided, not both.")
  }

  #INSTITUTION
  checkmate::assert_subset(
    x = institution,
    choices = c(
      "NR",
      "BR",
      "KN",
      "PN"
    ),
    empty.ok = TRUE
  )

  if (is.null(pad_intern) && !is.null(name) && length(name) > 1) {
    pb_id <- cli::cli_progress_bar(
      "Fetching mandates",
      total = length(name),
      format = "{cli::pb_spin} Fetching mandates {cli::pb_current}/{cli::pb_total} | ETA: {cli::pb_eta}",
      format_done = "Fetched mandates for {cli::pb_total} names.",
      clear = FALSE
    )

    df_res <- purrr::map(name, \(x) {
      cli::cli_progress_update(id = pb_id)
      get_mandates(name = x)
    }) %>%
      purrr::list_rbind() %>%
      dplyr::as_tibble()

    return(df_res)
  }

  if (is.null(pad_intern) && !is.null(name)) {
    df_persons <- get_pad_intern(name)

    if (is.null(df_persons) || nrow(df_persons) == 0) {
      cli::cli_inform("No mandates found.")
      return(.empty_mandates_tibble())
    } else {
      pad_intern <- df_persons$pad_intern
    }
  }

  #remove duplicates
  pad_intern_unique <- unique(pad_intern)

  if (length(pad_intern_unique) != length(pad_intern)) {
    cli::cli_inform("Duplicate pad_interns removed.")
  }

  pb_id <- cli::cli_progress_bar(
    "Fetching mandates",
    total = length(pad_intern_unique),
    format = "{cli::pb_spin} Fetching mandates {cli::pb_current}/{cli::pb_total} | ETA: {cli::pb_eta}",
    format_done = "Fetched mandates for {cli::pb_total} persons.",
    clear = FALSE
  )

  li_res <- purrr::map(
    pad_intern_unique,
    \(x) {
      cli::cli_progress_update(id = pb_id)
      get_mandates_single(pad_intern = x)
    }
  )

  df_res <- purrr::list_rbind(li_res) %>%
    dplyr::as_tibble()

  if (is.null(df_res) || nrow(df_res) == 0) {
    cli::cli_inform("No mandates found.")
    return(.empty_mandates_tibble())
  }

  #filter by date
  if (!is.null(date)) {
    date_filter <- lubridate::parse_date_time(
      date, #parse_date_time recognizes different date formats
      orders = c("dmy", "ymd", "mdy")
    )

    df_res <- df_res %>%
      dplyr::mutate(
        funktion_bis = dplyr::case_when(
          .data$aktiv == TRUE & is.na(.data$funktion_bis) ~ lubridate::today(),
          .default = .data$funktion_bis
        )
      ) %>%
      dplyr::filter(
        date_filter >= .data$funktion_von & date_filter <= .data$funktion_bis
      ) %>%
      dplyr::mutate(
        funktion_bis = dplyr::case_when(
          .data$aktiv == TRUE ~ lubridate::NA_Date_,
          .default = .data$funktion_bis
        )
      )
  }

  # return(df_res)
  #sort columns
  df_res <- df_res %>%
    dplyr::select(
      "pad_intern",
      "name",
      "bez",
      "funktion",
      "funktion_text",
      "funktion_von",
      "funktion_bis",
      "aktiv",
      "klub",
      contains("wahl"),
      everything()
    )
  #rename columns
  df_res <- df_res %>%
    dplyr::mutate(
      electoral_district_region_code = stringr::str_extract(
        .data$wahlkreis,
        stringr::regex("^\\w+")
      ) %>%
        stringr::str_replace("Bundeswahlvorschlag", "FB"),
      electoral_district_region = stringr::str_remove(
        .data$wahlkreis,
        stringr::regex("^\\w+\\s-\\s")
      )
    ) %>%
    dplyr::mutate(
      legis_period = stringr::str_extract_all(
        .data$bez,
        stringr::regex("[XVI]+(?=\\.)", ignore_case = FALSE)
      )
    )

  renaming_map <- c(
    "bez" = "position_text",
    "funktion" = "position_code",
    "funktion_text" = "position_name",
    "funktion_von" = "position_date_start",
    "funktion_bis" = "position_date_end",
    "aktiv" = "position_active",
    "klub" = "parl_group",
    "wahlpartei" = "party",
    "wahlpartei_text" = "party_name",
    "eingetreten_txt" = "substitute"
  )

  df_res <- .parlat_apply_renaming(df_res, renaming_map)

  #add link to biography as means to check source
  df_res <- df_res %>%
    dplyr::mutate(
      url_biography = paste0(
        "https://www.parlament.gv.at/person/",
        .data$pad_intern
      )
    )

  # # only institution of interest
  if (!is.null(institution)) {
    if (institution == "NR") {
      df_res <- df_res %>%
        dplyr::filter(
          .data$position_code %in% c("NR", "1PNR", "2PNR", "3PNR", "ZON", "ZSN")
        )
    }
    if (institution == "BR") {
      df_res <- df_res %>%
        dplyr::filter(
          .data$position_code %in% c("BR", "PB", "SPB", "PRAES", "ZOB", "ZSB")
        )
    }
    if (institution == "KN") {
      df_res <- df_res %>%
        dplyr::filter(
          .data$position_code %in% c("PKNV", "2PKN", "3PKN", "KN")
        )
    }
    if (institution == "PN") {
      df_res <- df_res %>%
        dplyr::filter(
          .data$position_code %in% c("PN", "PPNV")
        )
    }

    if (nrow(df_res) == 0) {
      cli::cli_inform("No mandates found for institution {institution}.")
      return(.empty_mandates_tibble())
    }

    return(df_res)
  } else {
    df_res
  }
}


#' Get unique identificiaton number (pad_intern)
#'
#' @param name Character vector of length 1. Name of the person in the
#' format first name last name, or only family name.
#'
#' @return A dataframe with the unique identification number (pad_intern) and
#' person's current and previous names.
#'
#' @export
#'
#' @examples
#' \donttest{
#' result <- get_pad_intern("Strache")
#' dplyr::glimpse(result)
#'
#' result <- get_pad_intern("Heinz-Christian Strache")
#' dplyr::glimpse(result)
#' }
#'
#' @seealso
#' \code{\link{get_persons}}
get_pad_intern <- function(name) {
  checkmate::assert_character(name, len = 1)

  pad_intern_mps <- get_mps(search_string = name, echo = FALSE)

  if (is.null(pad_intern_mps) || nrow(pad_intern_mps) == 0) {
    cli::cli_inform("No person found for name {.val {name}}.")
    return(.parlat_empty_tibble(c("pad_intern", "names_variants")))
  }

  if (!is.null(pad_intern_mps) && nrow(pad_intern_mps) > 0) {
    pad_intern_mps <- pad_intern_mps %>%
      # dplyr::rename(name = name_nvg) %>%
      dplyr::distinct(.data$pad_intern, .data$name) %>%
      dplyr::mutate(pad_intern = as.character(.data$pad_intern)) %>%
      dplyr::mutate(names_previous = purrr::map(.data$pad_intern, \(x) get_names(x)))

    res <- pad_intern_mps %>%
      tidyr::unnest_longer("names_previous") %>%
      tidyr::unnest_wider("names_previous", names_sep = "_")

    pad_interns_scope <- res %>%
      dplyr::filter(stringr::str_detect(
        .data$names_previous_name_clean,
        stringr::regex(paste0("\\b", {{ name }}, "\\b"), ignore_case = FALSE)
      )) %>%
      dplyr::pull("pad_intern") %>%
      unique()

    res <- res %>%
      dplyr::filter(.data$pad_intern %in% pad_interns_scope) %>%
      dplyr::group_by(.data$pad_intern) %>%
      dplyr::summarise(
        names_variants = paste(.data$names_previous_name_clean, collapse = ", ")
      ) %>%
      dplyr::ungroup()

    return(res)
  }
}
