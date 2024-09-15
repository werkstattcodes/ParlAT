#TODO
## if mandate is active, 'mandatBis' is "" (empty) => to be replaced with Sys.Date()?
## allow for multiple pad_interns as input

#' Title
#'
#' @param pad_intern_single
#'
#' @return
#' @export
#'
#' @examples
get_mandates_single <- function(pad_intern) {

  #pad_intern <- 35468

  link_file_json <- glue::glue("https://www.parlament.gv.at/person/{pad_intern}?json=TRUE")
  file_json <- jsonlite::read_json(link_file_json)

  content <- file_json$content

  biography <- file_json$content$biografie
  df_biography <- biography |> tibble::enframe()
  df_biography_wide <- df_biography |> tidyr::pivot_wider()
  df_biography_wide <- df_biography_wide |> tidyr::unnest_wider(mandatefunktionen)

  df_biography_wide |>
    dplyr::select(mandate) |>
    tidyr::unnest_longer(mandate) |>
    tidyr::unnest_wider(mandate) |>
    dplyr::mutate(pad_intern=pad_intern, .before=1)
}


#' Get mandates
#'
#' Returns a dataframe with all past and present mandates of a specific individual.
#'
#' @param pad_intern
#'
#' @return
#' @export
#'
#' @examples
get_mandates <- function(pad_intern) {

#remove duplicates
pad_intern_unique <- unique(pad_intern)
if (length(pad_intern_unique)!=length(pad_intern)) {
  print("Duplicate pad_interns removed")
}

li_res <- purrr::map(pad_intern_unique, \(x) get_mandates_single(pad_intern=x))
purrr::list_rbind(li_res)

}


