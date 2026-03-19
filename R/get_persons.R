#' @param search_string A character string to search for specific names or keywords. Default is `NULL`.
#' @param institution A character vector specifying one or more institutions to search within. Possible values are `"Bundespräsident"`, `"Bundesrat"`, `"Bundesregierung"`, `"Europäisches Parlament"`, `"Konstituierende Nationalversammlung"`, `"Landeshauptleute"`, `"Nationalrat"`, `"Politische Mandate"`, `"Provisorische Nationalversammlung"`, `"Rechnungshof"`, and `"Volksanwaltschaft"`. Defaults to all institutions.
#' @param gender A character string specifying the gender to filter by. Possible values are `"male"`, `"female"`, or `"all"`. Default is `"all"`.
#' @param echo Logical. If `TRUE`, prints the API request body parameters, the constructed URL, and the number of results. Default is `FALSE`.
#'
#' @return A data.frame with the search results. The data frame includes columns for the internal ID (`pad_intern`), name (`name`), gender (`gender`), position (`position`), and a link (`link`). Returns `NULL` if no results are found.
#' @noRd

get_persons_single <- function(
  search_string = NULL,
  institution = NULL,
  gender = c("all", "female", "male"),
  echo = FALSE
) {
  # INSTITUTION

  choices_institution <- c(
    "Bundespr\u00e4sident",
    "Bundesrat",
    "Bundesregierung",
    "Europ\u00e4isches Parlament",
    "Konstituierende Nationalversammlung",
    "Landeshauptleute",
    "Nationalrat",
    "Politische Mandate",
    "Provisorische Nationalversammlung",
    "Rechnungshof",
    "Volksanwaltschaft"
  )
  checkmate::assert_subset(
    institution,
    choices = choices_institution,
    empty.ok = TRUE
  )

  institution <- purrr::map_chr(
    institution,
    \(x) {
      switch(
        x,
        "Bundespr\u00e4sident" = "BP",
        "Bundesrat" = "BR",
        "Konstituierende Nationalversammlung" = "KN",
        "Bundesregierung" = "BuREG",
        "Landeshauptleute" = "LH",
        "Europ\u00e4isches Parlament" = "MEP",
        "Politische Mandate" = "MPO",
        "Nationalrat" = "NR",
        "Provisorische Nationalversammlung" = "PN",
        "Rechnungshof" = "PRRH",
        "Volksanwaltschaft" = "VA"
      )
    }
  )

  gender <- match.arg(gender)
  gender_code <- switch(gender, "male" = "M", "female" = "W", "all" = NULL)

  body_params <- list(
    PERSART = institution,
    GESCHL = gender_code
  ) %>%
    purrr::compact() %>% # keep only non-empty elements
    jsonlite::toJSON()

  res <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/10400"
  ) %>%
    httr2::req_url_query(
      js = "eval",
      pagesize = "10000",
      search = search_string,
      ascDesc = "ASC",
    ) %>%
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      `content-type` = "application/json",
      dnt = "1",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i"
    ) %>%
    httr2::req_body_raw(body_params, "application/json") %>%
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") %>%
    httr2::req_verbose(
      body_req = FALSE,
      header_req = FALSE,
      header_resp = FALSE
    ) %>%
    httr2::req_perform()

  df_res <- res %>%
    httr2::resp_body_json(simplifyVector = TRUE) %>%
    purrr::pluck("rows") %>%
    as.data.frame()

  if (nrow(df_res) == 0) {
    return(NULL)
  }

  vec_headings <- res %>%
    httr2::resp_body_json(simplifyVector = TRUE) %>%
    purrr::pluck("header", "label") %>%
    stringr::str_to_snake() %>%
    make.unique(sep = "_")

  colnames(df_res) <- vec_headings

  df_res <- df_res %>%
    dplyr::select(
      "pad_intern",
      "name",
      gender = "geschl",
      position = "funktion",
      "link"
    ) %>%
    dplyr::mutate(
      position = stringr::str_remove(.data$position, pattern = stringr::regex("<.*$"))
    )

  # PRINT ECHO
  if (isTRUE(echo)) {
    print(body_params)
    body_params_li <- jsonlite::fromJSON(body_params) %>%
      c("search" = search_string)

    query_string <- purrr::imap(
      body_params_li,
      \(x, y) glue::glue("PERSON_10400{URLencode(y)}={URLencode(x)}")
    ) %>%
      unlist() %>%
      unname() %>%
      paste0(collapse = "&")

    print(glue::glue(
      "https://www.parlament.gv.at/recherchieren/personen?{query_string}"
    ))

    print(nrow(df_res))
  }

  return(df_res)
}


#' @title Search persons in Austrian political institutions
#'
#' @description
#' The `get_persons` function searches for current and former individuals
#' active in the Austrian parliament as well as other related political
#' institutions of Austria. It allows filtering by specific institutions
#' and gender and mirrors the "Personen" search on the website of the
#' Austrian Parliament (see [here](https://www.parlament.gv.at/recherchieren/personen/)).
#'
#' @details
#' Note that `get_persons` only returns matches for the latest
#' name of an individual. MPs' previous names (e.g., before marriage) do
#' not return a match. When `names` is `NULL`, the function returns all
#' available persons for the supplied filters.
#'
#' @param names A character vector of name(s) in the format "Surname Givenname". Defaults to `NULL`.
#' @param institution A character vector specifying one or more institutions to search within. Possible values are `"Bundespräsident"`, `"Bundesrat"`, `"Bundesregierung"`, `"Europäisches Parlament"`, `"Konstituierende Nationalversammlung"`, `"Landeshauptleute"`, `"Nationalrat"`, `"Politische Mandate"`, `"Provisorische Nationalversammlung"`, `"Rechnungshof"`, and `"Volksanwaltschaft"`. Defaults to all institutions.
#' @param mandates Logical. If `TRUE`, mandates are retrieved for each person. Default is `FALSE`.
#' @param gender A character string. Possible values are `"all"`, `"female"`, or `"male"`. Default is `"all"`.
#' @param echo Logical. If `TRUE`, prints the API request body parameters, the constructed URL, and the number of results. Default is `FALSE`.
#'
#' @return A data frame with one row per matching person and the columns `pad_intern`,
#'   `name`, `gender`, `position`, and `link`. When `mandates = TRUE`, the
#'   returned data frame additionally contains mandate details for each person.
#'   Returns `NULL` with a message if no persons are found.
#'
#' @export
#'
#' @examples \donttest{
#' get_persons(c("Kogler Werner", "Kurz Sebastian"))}

get_persons <- function(
  names = NULL,
  institution = NULL,
  mandates = FALSE,
  gender = "all",
  echo = FALSE
) {
  if (is.null(names) || length(names) == 0) {
    li_persons <- list(get_persons_single(
      institution = institution,
      gender = gender,
      echo = echo
    ))
  } else {
    li_persons <- purrr::map(
      names,
      \(x) {
        get_persons_single(
          search_string = x,
          institution = institution,
          gender = gender,
          echo = echo
        )
      }
    )
  }

  df_persons <- li_persons %>% purrr::list_rbind()

  if (nrow(df_persons) == 0) {
    message("No person found for the given search criteria.")
    return(NULL)
  }

  if (isTRUE(mandates)) {
    df_persons <- df_persons %>%
      dplyr::mutate(
        mandates = purrr::map(
          .data$pad_intern,
          \(x) get_mandates(pad_intern = x)
        )
      ) %>%
      tidyr::unnest_longer(mandates, keep_empty = TRUE) %>%
      tidyr::unnest_wider(mandates, names_sep = "_")
  }

  return(df_persons)
}
