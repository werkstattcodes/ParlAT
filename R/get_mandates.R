#' @title Get mandates single mandate
#' @description 
#' Auxiliary function which retrieves mandates for a single mandate. Is used internally
#' in get_mandates which allows for multiple `pad_intern` to be passed.
#'
#' @param pad_intern  Personal identfication number of person 
#' @noRd
#' @return A dataframe.
#'
get_mandates_single <- function(pad_intern) {

  link_file_json <- glue::glue("https://www.parlament.gv.at/person/{pad_intern}?json=TRUE")

  file_json <-   tryCatch(
    {
      jsonlite::read_json(link_file_json)
    },
    error = function(e) {
      #warning(paste("Error reading JSON from URL:", e$message))
      return(NULL)
    }
  )

  if (is.null(file_json)) {
    return(NULL)    }

  content <- file_json$content

  biography <- file_json$content$biografie
  df_biography <- biography |> tibble::enframe()
  df_biography_wide <- df_biography |> tidyr::pivot_wider()
  df_biography_wide <- df_biography_wide |> tidyr::unnest_wider(mandatefunktionen)

  df_biography_wide |>
    dplyr::select(mandate) |>
    tidyr::unnest_longer(mandate) |>
    tidyr::unnest_wider(mandate) |>
    dplyr::mutate(pad_intern=pad_intern, .before=1) |>
    dplyr::mutate(dplyr::across(c("mandatVon", "mandatBis"), \(x) lubridate::dmy(x))) |>
    dplyr::select(-zeitraum)

}

#' @title Get mandates
#'
#' @description 
#' Takes the `pad_intern` of one or several MPs as input and returns a dataframe
#' with all past and present mandates. Mandates can be limited to a specific date
#' or institution. 
#' 
#' The function partly mimics the behavior of the 'Personensuche' on the website 
#' of the Parliament ([here]("https://www.parlament.gv.at/recherchieren/personen/")), 
#' but requires the 'pad_intern' instead of the name of the MP. To get the 'pad_intern' of an MP,
#' see the function `get_pad_intern`. 
#'
#' @param pad_intern Personal identfication number of person
#' @param date Date to filter mandates
#' @param institution Institution for which mandates should be returned. Possible values are "Nationalrat", "Bundesrat" or "all"
#'
#' @return A dataframe.
#' @export
#'
#' @examples 
#' \dontrun{
#'   pad_intern <- c(1174, 1234)
#'   result <- get_mandates(pad_intern, date="2023-01-01", institution="Nationalrat")
#'   print(result)
#' }
#'
get_mandates <- function(pad_intern, date=NULL, institution="Nationalrat") {

#remove duplicates
pad_intern_unique <- unique(pad_intern)

if (length(pad_intern_unique)!=length(pad_intern)) {
  print("Duplicate pad_interns removed")
}

li_res <- purrr::map(pad_intern_unique, \(x) get_mandates_single(pad_intern=x))
df_res <- purrr::list_rbind(li_res)

if (is.null(df_res)| nrow(df_res)==0) {return(NULL)}

if (!is.null(date)) {

  date_filter <- lubridate::parse_date_time(date, #parse_date_time recognizes different date formats
                                            orders=c("dmy","ymd", "mdy"))

  df_res <- df_res |>
    dplyr::mutate(mandatBis=dplyr::case_when(
      aktiv==TRUE & is.na(mandatBis) ~ lubridate::today(),
      .default=mandatBis
    )) |>
    dplyr::filter(date_filter >= mandatVon & date_filter<=mandatBis) |>
    dplyr::mutate(mandatBis=dplyr::case_when(
      aktiv==TRUE ~ lubridate::NA_Date_,
      .default=mandatBis
    ))
}

if (!is.null(institution)) {

  institution <- switch(
    institution,
    all = "ALLE",
    Nationalrat = "NR",
    Bundesrat = "BR"
  )

  df_res |>
    dplyr::filter(gremium %in% institution)
} else {
  df_res
}


}





