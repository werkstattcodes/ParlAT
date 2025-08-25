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
#' Takes one or multiple names or pad_interns as input and returns a dataframe
#' with all their past and present mandates. Mandates can be limited to a specific date
#' or institution. Mandates cover memberships in Parliament, but also in the executive (e.g. Bundeskanzler/Chancellor).
#'
#' Note that a single row in the returned dataframe can represent e.g. multiple mandates in e.g. the Nationalrat if they were consecutively held.
#'
#' The function partly mimics the behavior of the 'Personensuche' on the website
#' of the Parliament (<a href="https://www.parlament.gv.at/recherchieren/personen/" target="_blank">here</a>).
#' @param pad_intern Personal identfication number of person(s). Has to be NULL if names are provided
#' @param names A character vector of name(s). Only considered if no pad_intern(s) provided.
#' @param date Date to filter mandates
#' @param institution Chamber of Parliament. "NR" (Nationalrat), "BR" (Bundesrat), "KN" (Konstituierende Nationalversammlung),
#' or "PN" (Provisorische Nationalversammlung). NULL covers all institutions. Note that e.g. "NR" does not only return MP's mandates,
#' but also presidents of the National Council, Secretaries ("Schriftführer"), and Regulators ("Ordner"). The equivalent applies to other
#' the chambers as well.
#' @details
#' ## Names
#' If a person changed his or her name, the latest name
#' has to be used to obtain data on the mandates. The API does not return a
#' match if a search with a previous name is made.
#TODO dataframe details to be added
#' @return A dataframe.?g
#'
#' @export
#' @seealso [get_names(), get_pad_intern()]
#' @examples
#' \dontrun{
#'   get_mandates(c("Götze Elisabeth", "Kurz Sebastian"))
#'   get_mandates(c("Strache Pia Philipp")) #returns no result since previous name
#'   get_mandates(c("Beck Pia Philipp")) #returns result since latest name
#'   get_mandates(c("Beck Pia Philipp")) #returns result since latest name
#'   get_mandates(pad_intern="44127")
#' }
#'
get_mandates <- function(
  name = NULL,
  pad_intern = NULL,
  institution = NULL,
  date = NULL
) {
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
    pb <- progress::progress_bar$new(
      format = "[:bar] :percent :current/:total ETA: :eta",
      total = length(name),
      clear = FALSE
    )

    df_res <- purrr::map(name, \(x) {
      pb$tick()
      get_mandates(name = x)
    }) |>
      purrr::list_rbind() %>%
      dplyr::as_tibble()

    return(df_res)
  }

  if (is.null(pad_intern) && !is.na(name)) {
    df_persons <- get_pad_intern(name)

    if (is.null(df_persons) || nrow(df_persons) == 0) {
      message("No mandates found.")
      return(NULL)
    } else {
      pad_intern <- df_persons$pad_intern
    }
  }

  #remove duplicates
  pad_intern_unique <- unique(pad_intern)

  if (length(pad_intern_unique) != length(pad_intern)) {
    print("Duplicate pad_interns removed")
  }

  pb <- progress::progress_bar$new(
    format = "[:bar] :percent :current/:total ETA: :eta",
    total = length(pad_intern_unique),
    clear = FALSE
  )

  li_res <- purrr::map(
    pad_intern_unique,
    \(x) {
      pb$tick()
      get_mandates_single(pad_intern = x)
    }
  )

  df_res <- purrr::list_rbind(li_res) %>%
    dplyr::as_tibble()

  if (is.null(df_res) | nrow(df_res) == 0) {
    return(NULL)
  }

  #filter by date
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

  # return(df_res)
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
  #rename columns
  df_res <- df_res %>%
    dplyr::mutate(
      electoral_district_region_code = stringr::str_extract(
        wahlkreis,
        stringr::regex("^\\w+")
      ) %>%
        stringr::str_replace("Bundeswahlvorschlag", "FB"),
      electoral_district_region = stringr::str_remove(
        wahlkreis,
        stringr::regex("^\\w+\\s-\\s")
      )
    ) %>%
    dplyr::mutate(
      legis_period = stringr::str_extract_all(
        bez,
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

  df_res <- df_res %>%
    dplyr::rename_with(
      .fn = \(x) renaming_map[x], # For each selected old name, get its new name from the map
      .cols = any_of(names(renaming_map))
    )

  #add link to biography as means to check source
  df_res <- df_res |>
    dplyr::mutate(
      url_biography = paste0(
        "https://www.parlament.gv.at/person/",
        pad_intern
      )
    )

  # # only institution of interest
  if (!is.null(institution)) {
    if (institution == "NR") {
      df_res <- df_res |>
        dplyr::filter(
          position_code %in% c("NR", "1PNR", "2PNR", "3PNR", "ZON", "ZSN")
        )
    }
    if (institution == "BR") {
      df_res <- df_res |>
        dplyr::filter(
          position_code %in% c("BR", "PB", "SPB", "PRAES", "ZOB", "ZSB")
        )
    }
    if (institution == "KN") {
      df_res <- df_res |>
        dplyr::filter(
          position_code %in% c("PKNV", "2PKN", "3PKN", "KN")
        )
    }
    if (institution == "PN") {
      df_res <- df_res |>
        dplyr::filter(
          position_code %in% c("PN", "PPNV")
        )
    }

    if (nrow(df_res) == 0) {
      print(glue::glue("No mandates found for institution {institution}."))
      return(NULL)
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
