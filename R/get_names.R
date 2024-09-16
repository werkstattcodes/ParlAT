#' Get all name variants of a person
#'
#'
#' `get_names` returns all name variants of an MP or a specific name on a specific date. Particularly relevant
#' for MPs who changed their name (marriage, divorce). Takes an MP's 'pad_intern' and an optional date as input.
#'
#' @param pad_intern
#'
#' @return a dataframe
#' @export
#'
#' @examples
get_names <- function(pad_intern, date=NULL) {

  # pad_intern <- 1174

  link_file_json <- glue::glue("https://www.parlament.gv.at/person/{pad_intern}?json=TRUE")
  file_json <- jsonlite::read_json(link_file_json)

  #CURRENT NAMES
  person_name_current <- file_json$content$headingbox$title
  df_name_current <- data.frame(
    name=person_name_current,
    name_mp_latest=TRUE
  )


  #PREVIOUS NAMES
  person_names_previous <- file_json$content$personInfo$frueherenamen  |>
    stringr::str_split_1(stringr::regex("\\<br\\>"))

  df_name_previous <- person_names_previous |> tibble::enframe(name=NULL)

  df_name_previous <- df_name_previous |>
    dplyr::mutate(date_name=stringr::str_extract(value, stringr::regex("\\d+\\.\\d+\\.\\d+"))) |>
    dplyr::mutate(date_name=lubridate::dmy(date_name)) |>
    dplyr::mutate(name=stringr::str_extract(value, stringr::regex("(?<=:\\s?).*?(?=\\))")), .after=2) |>
    dplyr::mutate(name=stringr::str_trim(name)) |>
    dplyr::mutate(date_type=dplyr::case_when(
      stringr::str_detect(value, "bis") ~ "end",
      stringr::str_detect(value, "seit") ~ "start",
      .default=NA
    )) |>
    dplyr::mutate(name_mp_latest=FALSE)


  #COMBINE CURRENT AND PREVIOUS NAMES
  df_names <- dplyr::bind_rows(df_name_current, df_name_previous) |>
    dplyr::mutate(pad_intern=pad_intern, .before=1)

  n_rows <- nrow(df_names)

  #SORT
  df_names <- df_names |>
    dplyr::mutate(name_index=dplyr::case_when(
      stringr::str_detect(value, stringr::regex("bis")) ~ n_rows,
      stringr::str_detect(value, stringr::regex("seit")) ~ 1,
      .default=NA
    ))

 #1 on top; nrow last; NAs in between
 df_names <- dplyr::bind_rows(
   df_names |> dplyr::filter(name_index==1),
   df_names |> dplyr::filter(is.na(name_index)),
   df_names |> dplyr::filter(name_index==n_rows),
 ) |>
   dplyr::mutate(name_index_2=dplyr::row_number())

 #add dates
 df_names <- df_names |>
   dplyr::mutate(date_name=dplyr::case_when(
     name_index_2==1 & is.na(date_name) ~ lubridate::today(),
     is.na(name_index) & is.na(date_name) ~ dplyr::lag(date_name)-1,
     .default=date_name
   )) |>
   dplyr::mutate(date_type=dplyr::case_when(
     is.na(date_type) & is.na(name_index) ~ "end",
     .default=date_type
   )) |>
   dplyr::mutate(date_end=dplyr::case_when(
     !is.na(date_name) & date_type=="end" ~ date_name,
     !is.na(date_name) & date_type=="start" & name_index==1 ~ date_name+(100*365),
     .default=NA
   )) |>
   dplyr::mutate(date_start=dplyr::case_when(
     !is.na(date_name) & date_type=="start" ~ date_name,
     .default=NA
   )) |>
   dplyr::mutate(date_start=dplyr::case_when(
     is.na(name_index) ~ dplyr::lead(date_end)+1,
     name_index==n_rows ~ date_end-(100*365),  #fictitious start date_name
     .default=date_start
   ))

 #get family/given name
 ## clean name
 df_names <- df_names |>
   #remove trailing acad titles after comma
   dplyr:::mutate(name_clean=stringr::str_remove(name, stringr::regex(",.*$"))) |>
   #remove leading title ending on a dot, including Abg. and acad titles
   dplyr::mutate(name_clean=stringr::str_remove_all(name_clean, stringr::regex("\\S*\\.\\s"))) |>
   #remove academic titles comprising multiple capital letters
   dplyr::mutate(name_clean=stringr::str_remove(name_clean, stringr::regex("\\p{Lu}+\\p{Ll}*\\p{Lu}+\\p{Ll}*\\b"))) |>
   #remove bracket elements
   dplyr::mutate(name_clean=stringr::str_remove_all(name_clean, stringr::regex("\\([^\\(]*\\)"))) |>
   dplyr::mutate(name_clean=stringr::str_trim(name_clean) |> stringr::str_squish())

 df_names <- df_names |>
    dplyr::mutate(name_family=stringr::str_extract(name_clean, stringr::regex("\\S+$"))) |>
    dplyr::mutate(name_given=stringr::str_remove(name_clean, stringr::regex(name_family)))

 df_names <- df_names |>
   dplyr::select(
     index=name_index_2,
     pad_intern,
     name,
     date_start,
     date_end,
     name_clean,
     name_family,
     name_given,
     value
   )

 if (!is.null(date)) {
   date_filter <- lubridate::dmy(date)
   df_names |>  dplyr::filter(date_filter >= date_start & date_filter <= date_end)
   } else {
   df_names
 }

}

