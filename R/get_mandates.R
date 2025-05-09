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
  link_file_json <- glue::glue(
    "https://www.parlament.gv.at/person/{pad_intern}?json=TRUE"
  )

  file_json <- tryCatch(
    {
      jsonlite::read_json(link_file_json)
    },
    error = function(e) {
      #warning(paste("Error reading JSON from URL:", e$message))
      return(NULL)
    }
  )

  if (is.null(file_json)) {
    print(glue::glue("No data found for pad_intern {pad_intern}."))
    return(NULL)
  }

  content <- file_json$content

  person_name <- content$headingbox$title_plain

  biography <- file_json$content$biografie
  df_biography <- biography |> tibble::enframe()
  df_biography_wide <- df_biography |> tidyr::pivot_wider()
  df_biography_wide <- df_biography_wide |>
    tidyr::unnest_wider(mandatefunktionen)

  df_biography_wide |>
    dplyr::select(mandate) |>
    tidyr::unnest_longer(mandate) |>
    tidyr::unnest_wider(mandate) |>
    dplyr::mutate(pad_intern = pad_intern, .before = 1) |>
    dplyr::mutate(dplyr::across(
      dplyr::any_of(c("funktion_von", "funktion_bis")),
      \(x) lubridate::dmy(x)
    )) |>
    dplyr::mutate(name = person_name, .before = 1) %>%
    dplyr::select(
      -any_of(c("mandatVon", "mandatBis", "zeitraum", "gremium", "mandat"))
    )
}

#' @title Get mandates
#'
#' @description
#' Takes one or multiple names as input and returns a dataframe
#' with all their past and present mandates. Mandates can be limited to a specific date
#' or institution. Mandates cover memberships in Parliament, but also in the executive (e.g. Bundeskanzler/Chancellor).
#'
#' Note that a single row in the returned dataframe can represent e.g. multiple mandates in e.g. the Nationalrat if they were consecutively held.
#'
#' The function partly mimics the behavior of the 'Personensuche' on the website
#' of the Parliament (<a href="https://www.parlament.gv.at/recherchieren/personen/" target="_blank">here</a>).
#' @param names A character vector of name(s). Surname first. See details.
#' @param pad_intern Personal identfication number of person
#' @param date Date to filter mandates
#' @param institution Institution for which mandates should be returned. Possible values are "Nationalrat" (National Council),
#' "Bundesrat" (Federal Council) or "all" (returns also memberships in the executive).
#' @details
#' ## Names
#' Surname first. If a person changed his or her name, the latest name
#' has to be used to obtain all mandates. A search with a previous name will
#' return no results. This is a design decision by the API creators.
#'
#' @return A dataframe.
#' @export
#'
#' @examples
#' \dontrun{
#'   result <- get_mandates(c("Götze Elisabeth", "Kurz Sebastian"), institution="Nationalrat")
#'   print(result)
#'
#'  get_mandates(c("Strache Pia Philipp")) #returns no result since previous name
#'  get_mandates(c("Beck Pia Philipp")) #returns result since latest name
#' }
#'
get_mandates <- function(names, date = NULL, institution = "Nationalrat") {
  #INSTITUTION
  checkmate::assert_subset(
    institution,
    choices = c("Bundesrat", "Nationalrat", "all"),
    empty.ok = FALSE
  )

  df_persons <- get_persons(names)

  if (is.null(df_persons) || nrow(df_persons) == 0) {
    message("No mandates found.")
    return(NULL)
  } else {
    pad_intern <- df_persons$pad_intern
  }

  #remove duplicates
  pad_intern_unique <- unique(pad_intern)

  if (length(pad_intern_unique) != length(pad_intern)) {
    print("Duplicate pad_interns removed")
  }

  li_res <- purrr::map(
    pad_intern_unique,
    \(x) get_mandates_single(pad_intern = x)
  )
  df_res <- purrr::list_rbind(li_res)

  if (is.null(df_res) | nrow(df_res) == 0) {
    return(NULL)
  }

  if (!is.null(date)) {
    date_filter <- lubridate::parse_date_time(
      date, #parse_date_time recognizes different date formats
      orders = c("dmy", "ymd", "mdy")
    )

    df_res <- df_res |>
      dplyr::mutate(
        funktion_bis = dplyr::case_when(
          aktiv == TRUE & is.na(funktion_bis) ~ lubridate::today(),
          .default = funktion_bis
        )
      ) |>
      dplyr::filter(
        date_filter >= funktion_von & date_filter <= funktion_bis
      ) |>
      dplyr::mutate(
        funktion_bis = dplyr::case_when(
          aktiv == TRUE ~ lubridate::NA_Date_,
          .default = funktion_bis
        )
      )
  }

  #sort columns
  df_res <- df_res |>
    dplyr::select(
      pad_intern,
      name,
      bez,
      funktion,
      funktion_text,
      funktion_von,
      funktion_bis,
      aktiv,
      klub,
      contains("wahl"),
      everything()
    )

  if (!is.null(institution)) {
    institution <- switch(
      institution,
      all = "ALLE",
      Nationalrat = "NR",
      Bundesrat = "BR"
    )
    if (institution == "ALLE") {
      return(df_res)
    } else {
      df_res <- df_res |>
        dplyr::filter(funktion %in% institution)

      if (nrow(df_res) == 0) {
        print(glue::glue("No mandates found for institution {institution}."))
        return(NULL)
      }

      return(df_res)
    }
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
#' \dontrun{
#' get_pad_intern("Strache")
#' get_pad_intern("Heinz-Christian Strache")
#' }
#'
#' @seealso
#' \code{\link{get_persons}}
get_pad_intern <- function(name) {
  checkmate::assert_character(name, len = 1)

  pad_intern_mps <- get_mps(search_string = name, echo = FALSE)

  if (!is.null(pad_intern_mps) && nrow(pad_intern_mps) > 0) {
    pad_intern_mps <- pad_intern_mps %>%
      # dplyr::rename(name = name_nvg) %>%
      dplyr::distinct(pad_intern, name) %>%
      dplyr::mutate(pad_intern = as.character(pad_intern)) %>%
      dplyr::mutate(names_previous = map(pad_intern, \(x) get_names(x)))

    res <- pad_intern_mps %>%
      tidyr::unnest_longer(names_previous) %>%
      tidyr::unnest_wider(names_previous, names_sep = "_")

    pad_interns_scope <- res %>%
      dplyr::filter(stringr::str_detect(
        names_previous_name_clean,
        stringr::regex(paste0("\\b", {{ name }}, "\\b"), ignore_case = FALSE)
      )) %>%
      dplyr::pull(pad_intern) %>%
      unique()

    res <- res %>%
      dplyr::filter(pad_intern %in% pad_interns_scope) %>%
      dplyr::group_by(pad_intern) %>%
      dplyr::summarise(
        names_variants = paste(names_previous_name_clean, collapse = ", ")
      ) %>%
      dplyr::ungroup()

    return(res)
  }
}
