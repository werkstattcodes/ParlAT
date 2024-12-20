#' @param search_string A character string to search for specific names or keywords. Default is `NULL`.
#' @param institution A character vector specifying one or more institutions to search within. Possible values are `"Bundespräsident"`, `"Bundesrat"`, `"Bundesregierung"`, `"Europäisches Parlament"`, `"Konstituierende Nationalversammlung"`, `"Landeshauptleute"`, `"Nationalrat"`, `"Parlamentsdirektion"`, `"Politische Mandate"`, `"Provisorische Nationalversammlung"`, `"Rechnungshof"`, and `"Volksanwaltschaft"`. Defaults to all institutions.
#' @param gender A character string specifying the gender to filter by. Possible values are `"male"`, `"female"`, or `"all"`. Default is `"all"`.
#'
#' @return A data.frame with the search results. The data frame includes columns for the internal ID (`pad_intern`), name (`name`), gender (`gender`), position (`position`), and a link (`link`).
#' @noRd

get_person_single <- function(search_string = NULL,
                              search_strict=NULL,
                              institution = NULL,
                              gender = c("all", "female", "male")) {

  # INSTITUTION

  choices_institution= c("Bundespräsident","Bundesrat","Bundesregierung","Europäisches Parlament","Konstituierende Nationalversammlung",
    "Landeshauptleute","Nationalrat","Parlamentsdirektion","Politische Mandate","Provisorische Nationalversammlung","Rechnungshof",
    "Volksanwaltschaft")
  checkmate::check_subset(institution, choices=choices_institution, empty.ok = TRUE)

  institution <- purrr::map_chr(institution, \(x) switch(x,
    "Bundespräsident" = "BP",
    "Bundesrat" = "BR",
    "Konstituierende Nationalversammlung" = "KN",
    "Bundesregierung" = "BuREG",
    "Landeshauptleute" = "LH",
    "Europäisches Parlament" = "MEP",
    "Politische Mandate" = "MPO",
    "Nationalrat" = "NR",
    "Parlamentsdirektion" = "PD",
    "Provisorische Nationalversammlung" = "PN",
    "Rechnungshof" = "PRRH",
    "Volksanwaltschaft" = "VA"
  ))

  # gender <- NULL

  gender <- match.arg(gender)
  gender_code <- switch(gender,
    "male" = "M",
    "female" = "W",
    "all" = NULL
  )
  # gender_code <- NULL

  body_params <- list(
    PERSART = institution,
    GESCHL = gender_code
  ) |>
    purrr::compact() |> # keep only non-empty elements
    jsonlite::toJSON()

  res <- httr2::request("https://www.parlament.gv.at/Filter/api/filter/data/10400") |>
    httr2::req_url_query(
      js = "eval",
      # page = "1",
      pagesize = "10000",
      search = search_string,
      ascDesc = "ASC",
    ) |>
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      `content-type` = "application/json",
      dnt = "1",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i"
    ) |>
    httr2::req_body_raw(body_params, "application/json") |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
    httr2::req_verbose(body_req = T, header_req = F, header_resp = F) |>
    httr2::req_perform()

  # vec_headings
  vec_headings <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("header", "label") |>
    janitor::make_clean_names()

  df_res <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("rows") |>
    as.data.frame()

  if (nrow(df_res) == 0) {
    message("No results found for the given search criteria.")
    return(NULL)
  }

  colnames(df_res) <- vec_headings

  df_res <- df_res |>
    dplyr:::select(pad_intern,
      name,
      gender = geschl,
      position = funktion,
      link
    )

  df_res <- df_res |>
    dplyr::mutate(position = stringr::str_remove(position, pattern = stringr::regex("<.*$")))

  if(!is.null(search_strict) && search_strict==TRUE && !is.null(search_string)) {
    regex_search_string <- glue::glue("\\b{search_string}\\b") |> as.character()
    df_res <- df_res |>
      dplyr::filter(stringr::str_detect(name, stringr::regex(regex_search_string)))
    return(df_res)

  }

  return(df_res)


}


#' @title Search persons in Austrian political institutions
#'
#' @description 
#' The `get_persons` function searches for current and former individuals
#' active in the Austrian parliament as well as other related political
#' institutions of Austria. It allows filtering by specific institutions
#' and gender.
#' It mirrors the search functionality 'Personen' on the website of the
#'  Austrian Parliament (see [here](https://www.parlament.gv.at/recherchieren/personen/))
#'
#' @details Note that `get_person` only return matches for the latest 
#' name of an individual. MPs' pervious names, e.g. before marriage, do
#' not return a match.
#' 
#' @param names A character vector of name(s)
#' @param search_strict Logical. If `TRUE`, only exact matches are returned. Default is `TRUE`.
#' @param institution A character vector specifying one or more institutions to search within. Possible values are `"Bundespräsident"`, `"Bundesrat"`, `"Bundesregierung"`, `"Europäisches Parlament"`, `"Konstituierende Nationalversammlung"`, `"Landeshauptleute"`, `"Nationalrat"`, `"Parlamentsdirektion"`, `"Politische Mandate"`, `"Provisorische Nationalversammlung"`, `"Rechnungshof"`, and `"Volksanwaltschaft"`. Defaults to all institutions.
#' @param mandates Logical. If `TRUE`, mandates are retrieved for each person. Default is `FALSE`.
#' @param date A date to filter mandates. Default is `NULL`.
#' @param gender A character vector. Possible values are "all", "female", or "male". Default is "all".

#' @examples \dontrun{  
#' get_persons(c("Zadic", "Kurz"))}

get_persons <- function(
  names=NULL, 
  search_strict=TRUE, 
  institution=NULL, 
  mandates=FALSE, 
  date=NULL, 
  gender="all") {
  
# names <- NULL
# gender <- "female"
# date <- "2022-01-01"
# mandates <- TRUE
# institution <- NULL
# search_strict <- TRUE

  if (is.null(names) || length(names) == 0) {
    li_persons <- list(get_person_single(
      search_strict = search_strict, 
      institution = institution,
      gender = gender))
  } else {
    li_persons <- purrr::map(names, \(x) get_person_single(
      search_string = x, 
      search_strict = search_strict, 
      institution = institution,
      gender = gender))
  }
 
  df_persons <- li_persons |> purrr::list_rbind()
 
  if (nrow(df_persons)==0) {return(NULL)}

  if (!is.null(mandates) && mandates==TRUE) {

    df_persons <- df_persons |>
      dplyr::mutate(mandates=purrr::map(pad_intern, \(x) get_mandates(pad_intern=x, date=date))) |>
      tidyr::unnest_longer(mandates, keep_empty=TRUE) |>
      tidyr::unnest_wider(mandates, names_sep="_")

  }

    if (!is.null(date)) {
      df_persons <- df_persons |>
        dplyr::filter(!is.na(mandates_mandatVon))
    }

    return(df_persons)

}
