#' Get name variants of a Member of Parliament
#'
#' Returns all name variants of an person or a specific name used on a given date.
#' This function is particularly relevant for MPs who changed their names (e.g., due to marriage or divorce).
#'
#' @param pad_intern The internal identifier for the MP; allows for input of length >= 1;
#' @param date Optional. A specific date to retrieve the name used at that time. When omitted, returns all name variants.
#' @param latest Logical. If TRUE, only the latest name is returned.
#'
#' @return A dataframe containing name variant(s) of the specified person, including metadata such as dates and name types.
#' @export
#'
#' @examples \dontrun{
#' get_names(44127) #Philippa Pia Beck, Philippa Pia Strache
#' get_names(44127, latest=T) #Philippa Pia Beck, formerly Strache
#' get_names(44127, date="01/01/2023") #Philippa Pia Strache
#' get_names(c(1130,83124)) #multiple pad_interns possible; e.g. Michael Pock/Bernhard; Freda Blau-Meissner/Meissner-Blau
#' }
get_names <- function(pad_intern, date = NULL, latest = NULL) {
  if (length(pad_intern) > 1) {
    return(
      purrr::map(pad_intern, \(x) get_names(x, date = date, latest = latest)) |>
        purrr::list_rbind()
    )
  }

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
    return(NA)
  }

  #CURRENT NAMES
  person_name_current <- file_json$content$headingbox$title
  df_name_current <- data.frame(
    name = person_name_current,
    name_mp_latest = TRUE
  )

  #PREVIOUS NAMES
  if (!is.null(file_json$content$personInfo$frueherenamen)) {
    person_names_previous <- file_json$content$personInfo$frueherenamen |>
      stringr::str_split_1(stringr::regex("\\<br\\>"))

    df_name_previous <- person_names_previous |> tibble::enframe(name = NULL)

    df_name_previous <- df_name_previous |>
      dplyr::mutate(
        date_name = stringr::str_extract(
          value,
          stringr::regex("\\d+\\.\\d+\\.\\d+")
        )
      ) |>
      dplyr::mutate(date_name = lubridate::dmy(date_name)) |>
      dplyr::mutate(
        name = stringr::str_extract(
          value,
          stringr::regex("(?<=:\\s?).*?(?=\\))")
        ),
        .after = 2
      ) |>
      dplyr::mutate(name = stringr::str_trim(name)) |>
      dplyr::mutate(
        date_type = dplyr::case_when(
          stringr::str_detect(value, "bis") ~ "end",
          stringr::str_detect(value, "seit") ~ "start",
          .default = NA
        )
      ) |>
      dplyr::mutate(name_mp_latest = FALSE)

    #COMBINE CURRENT AND PREVIOUS NAMES
    df_names <- dplyr::bind_rows(df_name_current, df_name_previous) |>
      dplyr::mutate(pad_intern = pad_intern, .before = 1)

    n_rows <- nrow(df_names)

    #SORT
    df_names <- df_names |>
      dplyr::mutate(
        name_index = dplyr::case_when(
          stringr::str_detect(value, stringr::regex("bis")) ~ n_rows,
          stringr::str_detect(value, stringr::regex("seit")) ~ 1,
          .default = NA
        )
      )

    #1 on top; nrow last; NAs in between
    df_names <- dplyr::bind_rows(
      df_names |> dplyr::filter(name_index == 1),
      df_names |> dplyr::filter(is.na(name_index)),
      df_names |> dplyr::filter(name_index == n_rows),
    ) |>
      dplyr::mutate(name_index_2 = dplyr::row_number())

    #add dates
    df_names <- df_names |>
      dplyr::mutate(
        date_name = dplyr::case_when(
          # name_index_2 == 1 & is.na(date_name) ~ lubridate::today(),
          name_index_2 == 1 & is.na(date_name) ~ NA,
          is.na(name_index) & is.na(date_name) ~ dplyr::lag(date_name) - 1,
          .default = date_name
        )
      ) |>
      dplyr::mutate(
        date_type = dplyr::case_when(
          is.na(date_type) & is.na(name_index) ~ "end",
          .default = date_type
        )
      ) |>
      dplyr::mutate(
        date_end = dplyr::case_when(
          !is.na(date_name) & date_type == "end" ~ date_name,
          # !is.na(date_name) & date_type == "start" & name_index == 1 ~
          #   # date_name + (100 * 365),
          !is.na(date_name) & date_type == "start" & name_index == 1 ~ NA,
          .default = NA
        )
      ) |>
      dplyr::mutate(
        date_start = dplyr::case_when(
          !is.na(date_name) & date_type == "start" ~ date_name,
          .default = NA
        )
      ) |>
      dplyr::mutate(
        date_start = dplyr::case_when(
          is.na(name_index) ~ dplyr::lead(date_end) + 1,
          # name_index == n_rows ~ date_end - (100 * 365), #fictitious start date_name
          name_index == n_rows ~ NA, #fictitious start date_name
          .default = date_start
        )
      )
  } else {
    df_names <- df_name_current |>
      dplyr::mutate(pad_intern = pad_intern, .before = 1)
  }

  #get family/given name
  ## clean name
  df_names <- df_names |>
    #remove trailing acad titles after comma
    dplyr::mutate(
      name_clean = stringr::str_remove(name, stringr::regex(",.*$"))
    ) |>
    #remove leading title ending on a dot, including Abg. and acad titles
    dplyr::mutate(
      name_clean = stringr::str_remove_all(
        name_clean,
        stringr::regex("\\S*\\.\\s")
      )
    ) |>
    #remove academic titles comprising multiple capital letters
    dplyr::mutate(
      name_clean = stringr::str_remove(
        name_clean,
        stringr::regex("\\p{Lu}+\\p{Ll}*\\p{Lu}+\\p{Ll}*\\b")
      )
    ) |>
    #remove bracket elements
    dplyr::mutate(
      name_clean = stringr::str_remove_all(
        name_clean,
        stringr::regex("\\([^\\(]*\\)")
      )
    ) |>
    dplyr::mutate(
      name_clean = stringr::str_trim(name_clean) |> stringr::str_squish()
    )

  df_names <- df_names |>
    dplyr::mutate(
      name_family = stringr::str_extract(name_clean, stringr::regex("\\S+$"))
    ) |>
    dplyr::mutate(
      name_given = stringr::str_remove(name_clean, stringr::regex(name_family))
    )

  cols_select <- c(
    index = "name_index_2",
    "pad_intern",
    "name",
    "date_start",
    "date_end",
    "name_clean",
    "name_family",
    "name_given",
    "value"
  )

  df_names <- df_names |>
    dplyr::select(any_of(cols_select))

  if (!is.null(date)) {
    date_filter <- lubridate::dmy(date)
    df_names <- df_names |>
      dplyr::mutate(
        date_end_filter = ifelse(is.na(date_end), lubridate::today(), date_end),
        date_start_filter = ifelse(
          is.na(date_start),
          as.Date("1900/01/01"),
          date_start
        )
      ) %>%
      dplyr::filter(
        date_filter >= date_start_filter & date_filter <= date_end_filter
      ) %>%
      dplyr::select(-contains("_filter"))
  }

  if (nrow(df_names) == 1) {
    df_names <- df_names %>%
      dplyr::mutate(index = 1)
  }

  if (!is.null(latest) && latest == TRUE) {
    df_names |>
      dplyr::slice_head(n = 1)
  } else {
    df_names
  }
}
