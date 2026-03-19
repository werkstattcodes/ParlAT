#' Get name variants of a Member of Parliament
#'
#' Returns all name variants of an person or a specific name used on a given date.
#' This function is particularly relevant for MPs who changed their names (e.g., due to marriage or divorce).
#'
#' @param pad_intern The internal identifier for the MP; allows for input of length >= 1;
#' @param date Optional. A specific date to retrieve the name used at that time. When omitted, returns all name variants.
#' @param latest Logical. If TRUE, only the latest name is returned.
#'
#' @return A dataframe containing name variant(s) of the specified person with the following columns:
#' - `index`: Sequential index of name variants
#' - `pad_intern`: Person's unique identification number
#' - `name`: Full name with titles and formatting
#' - `date_start`: Start date when this name variant was valid (Date)
#' - `date_end`: End date when this name variant was valid (Date, NA if currently valid)
#' - `name_clean`: Cleaned version of the name without titles
#' - `name_family`: Family name/surname
#' - `name_given`: Given name/first name
#' - `note`: Raw value from the source data
#' @seealso [get_pad_intern()] to retrieve an MP's `pad_intern`
#' @export
#'
#' @examples \donttest{
#' get_names(44127) # Philippa Pia Beck, Philippa Pia Strache
#' get_names(44127, latest = TRUE) # Philippa Pia Beck, formerly Strache
#' get_names(44127, date = "01/01/2023") # Philippa Pia Strache
#' # Multiple pad_interns possible:
#' # e.g. Michael Pock/Bernhard; Freda Blau-Meissner/Meissner-Blau
#' get_names(c(1130, 83124))
#' }
get_names <- function(pad_intern, date = NULL, latest = NULL) {
  if (length(pad_intern) > 1) {
    return(
      purrr::map(
        pad_intern,
        \(x) get_names(x, date = date, latest = latest),
        .progress = TRUE
      ) %>%
        purrr::list_rbind()
    )
  }

  # check if pad_intern actually exists
  if (aux_check_pad_intern_exists(pad_intern = pad_intern) != TRUE) {
    message(paste0("No MP registered under this pad_intern: ", pad_intern))
    return(NULL)
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
    person_names_previous <- file_json$content$personInfo$frueherenamen %>%
      stringr::str_split_1(stringr::regex("\\<br\\>"))

    df_name_previous <- person_names_previous %>% tibble::enframe(name = NULL)

    df_name_previous <- df_name_previous %>%
      dplyr::mutate(
        date_name = stringr::str_extract(
          .data$value,
          stringr::regex("\\d+\\.\\d+\\.\\d+")
        )
      ) %>%
      dplyr::mutate(date_name = lubridate::dmy(.data$date_name)) %>%
      dplyr::mutate(
        name = stringr::str_extract(
          .data$value,
          stringr::regex("(?<=:\\s?).*?(?=\\))")
        ),
        .after = 2
      ) %>%
      dplyr::mutate(name = stringr::str_trim(.data$name)) %>%
      dplyr::mutate(
        date_type = dplyr::case_when(
          stringr::str_detect(.data$value, "bis") ~ "end",
          stringr::str_detect(.data$value, "seit") ~ "start",
          .default = NA
        )
      ) %>%
      dplyr::mutate(name_mp_latest = FALSE)

    #COMBINE CURRENT AND PREVIOUS NAMES
    df_names <- dplyr::bind_rows(df_name_current, df_name_previous) %>%
      dplyr::mutate(pad_intern = pad_intern, .before = 1)

    n_rows <- nrow(df_names)

    #SORT
    df_names <- df_names %>%
      dplyr::mutate(
        name_index = dplyr::case_when(
          stringr::str_detect(.data$value, stringr::regex("bis")) ~ n_rows,
          stringr::str_detect(.data$value, stringr::regex("seit")) ~ 1,
          .default = NA
        )
      )

    #1 on top; nrow last; NAs in between
    df_names <- dplyr::bind_rows(
      df_names %>% dplyr::filter(.data$name_index == 1),
      df_names %>% dplyr::filter(is.na(.data$name_index)),
      df_names %>% dplyr::filter(.data$name_index == n_rows),
    ) %>%
      dplyr::mutate(name_index_2 = dplyr::row_number())

    #add dates
    df_names <- df_names %>%
      dplyr::mutate(
        date_name = dplyr::case_when(
          # name_index_2 == 1 & is.na(date_name) ~ lubridate::today(),
          .data$name_index_2 == 1 & is.na(.data$date_name) ~ NA,
          is.na(.data$name_index) & is.na(.data$date_name) ~ dplyr::lag(.data$date_name) - 1,
          .default = .data$date_name
        )
      ) %>%
      dplyr::mutate(
        date_type = dplyr::case_when(
          is.na(.data$date_type) & is.na(.data$name_index) ~ "end",
          .default = .data$date_type
        )
      ) %>%
      dplyr::mutate(
        date_end = dplyr::case_when(
          !is.na(.data$date_name) & .data$date_type == "end" ~ .data$date_name,
          # !is.na(date_name) & date_type == "start" & name_index == 1 ~
          #   # date_name + (100 * 365),
          !is.na(.data$date_name) & .data$date_type == "start" & .data$name_index == 1 ~ NA,
          .default = NA
        )
      ) %>%
      dplyr::mutate(
        date_start = dplyr::case_when(
          !is.na(.data$date_name) & .data$date_type == "start" ~ .data$date_name,
          .default = NA
        )
      ) %>%
      dplyr::mutate(
        date_start = dplyr::case_when(
          is.na(.data$name_index) ~ dplyr::lead(.data$date_end) + 1,
          # name_index == n_rows ~ date_end - (100 * 365), #fictitious start date_name
          .data$name_index == n_rows ~ NA, #fictitious start date_name
          .default = .data$date_start
        )
      )
  } else {
    df_names <- df_name_current %>%
      dplyr::mutate(pad_intern = pad_intern, .before = 1)
  }

  #get family/given name
  ## clean name
  df_names <- df_names %>%
    #remove trailing acad titles after comma
    dplyr::mutate(
      name_clean = stringr::str_remove(.data$name, stringr::regex(",.*$"))
    ) %>%
    #remove leading title ending on a dot, including Abg. and acad titles
    dplyr::mutate(
      name_clean = stringr::str_remove_all(
        .data$name_clean,
        stringr::regex("\\S*\\.\\s")
      )
    ) %>%
    #remove academic titles comprising multiple capital letters
    dplyr::mutate(
      name_clean = stringr::str_remove(
        .data$name_clean,
        stringr::regex("\\p{Lu}+\\p{Ll}*\\p{Lu}+\\p{Ll}*\\b")
      )
    ) %>%
    #remove bracket elements
    dplyr::mutate(
      name_clean = stringr::str_remove_all(
        .data$name_clean,
        stringr::regex("\\([^\\(]*\\)")
      )
    ) %>%
    dplyr::mutate(
      name_clean = stringr::str_trim(.data$name_clean) %>% stringr::str_squish()
    )

  df_names <- df_names %>%
    dplyr::mutate(
      name_family = stringr::str_extract(.data$name_clean, stringr::regex("\\S+$"))
    ) %>%
    dplyr::mutate(
      name_given = stringr::str_remove(.data$name_clean, stringr::regex(.data$name_family))
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

  df_names <- df_names %>%
    dplyr::select(any_of(cols_select))

  # Only rename 'value' to 'note' if 'value' column exists
  if ("value" %in% names(df_names)) {
    df_names <- df_names %>%
      dplyr::rename(note = "value")
  }

  if (!is.null(date) && "date_start" %in% names(df_names)) {
    date_filter <- lubridate::dmy(date)
    df_names <- df_names %>%
      dplyr::mutate(
        date_end_filter = ifelse(is.na(.data$date_end), lubridate::today(), .data$date_end),
        date_start_filter = ifelse(
          is.na(.data$date_start),
          as.Date("1900/01/01"),
          .data$date_start
        )
      ) %>%
      dplyr::filter(
        date_filter >= .data$date_start_filter & date_filter <= .data$date_end_filter
      ) %>%
      dplyr::select(-contains("_filter"))
  }

  if (nrow(df_names) == 1) {
    df_names <- df_names %>%
      dplyr::mutate(index = 1)
  }

  if (!is.null(latest) && latest == TRUE) {
    df_names %>%
      dplyr::slice_head(n = 1)
  } else {
    df_names
  }
}
