#' Get start and end dates of legislative periods.
#'
#' @param legis_period Number or identifier of legislative period(s) for which dates should be returned.
#'   Accepts numeric values (e.g., 27), Roman numerals (e.g., "XXVII"), or historical period
#'   abbreviations: "PN" (Provisorische Nationalversammlung), "KN" (Konstituierende Nationalversammlung),
#'   "Bundesrat1Rep" (Bundesrat der 1. Republik). Can be a vector for multiple periods.
#' @param date Date within a legislative period. Format should be "dd.mm.yyyy".
#'
#' @return A dataframe with the following columns:
#' - `legis_period_rom`: Legislative period in Roman numerals
#' - `legis_period`: Legislative period as numeric value
#' - `legis_period_current`: Logical indicating if this is the current period
#' - `date_start`: Start date of the legislative period (Date)
#' - `date_end`: End date of the legislative period (Date, NA if current)
#' - `legis_period_name`: Name/description of the legislative period
#' @export
#'
#' @examples
#' \donttest{
#' # Numeric periods
#' result <- get_legis_periods(legis_period = 27)
#' dplyr::glimpse(result)
#'
#' result <- get_legis_periods(legis_period = c(26, 27))
#' dplyr::glimpse(result)
#'
#' # Roman numerals
#' result <- get_legis_periods(legis_period = "XXVII")
#' dplyr::glimpse(result)
#'
#' # Historical periods
#' result <- get_legis_periods(legis_period = "PN")
#' dplyr::glimpse(result)
#'
#' # Mixed input types
#' result <- get_legis_periods(legis_period = c(26, "XXVII", "PN"))
#' dplyr::glimpse(result)
#'
#' # Filter by date
#' result <- get_legis_periods(date = "01.01.2020")
#' dplyr::glimpse(result)
#' }
get_legis_periods <- function(legis_period = NULL, date = NULL) {
  if (!is.null(legis_period) && !is.null(date)) {
    cli::cli_abort("Please provide either legis_period or date, not both.")
  }

  #convert roman numerals in character format to numeric, ensure all inputs are character
  if (!is.null(legis_period)) {
    if (is.character(legis_period)) {
      # Convert each element individually if it's a Roman numeral
      legis_period <- purrr::map_chr(legis_period, function(x) {
        if (stringr::str_detect(x, "^[IVXLCDM]+$")) {
          # Convert Roman numeral to numeric, then to character
          as.character(as.numeric(as.roman(x)))
        } else {
          # Keep as is (could be numeric string or historical abbreviation)
          x
        }
      })
    } else {
      # Convert numeric input to character
      legis_period <- as.character(legis_period)
    }
  }

  res <- httr2::request("https://www.parlament.gv.at/Filter/api/json/post") %>%
    httr2::req_url_query(
      jsMode = "FIELDS",
      FBEZ = "WFW_004",
    ) %>%
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      origin = "https://www.parlament.gv.at"
    ) %>%
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") %>%
    httr2::req_retry(max_tries = 3) %>%
    httr2::req_body_raw(
      '{"R_WF":["FR"],"R_BW":["BL"],"M":["M"],"W":["W"],"GP":["ALLE"]}',
      "application/json"
    ) %>%
    httr2::req_perform()

  #retrieve legis period dates
  df_res <- res %>%
    httr2::resp_body_json(simplifyVector = TRUE) %>%
    dplyr::pull("values") %>%
    purrr::pluck(1)

  #extract/clean dates
  df_res <- df_res %>%
    dplyr::filter(.data$value != "ALLE")

  df_res <- df_res %>%
    dplyr::mutate(
      dates_li = stringr::str_extract_all(
        .data$label,
        stringr::regex("\\d{2}\\.\\d{2}\\.\\d{4}")
      )
    )

  df_res <- df_res %>%
    dplyr::mutate(
      date_start = purrr::map_chr(.data$dates_li, purrr::pluck, 1)
    ) %>%
    dplyr::mutate(
      date_end = purrr::map_chr(
        .data$dates_li,
        .f = function(x) purrr::pluck(x, 2, .default = NA)
      )
    ) %>%
    dplyr::mutate(across(
      c("date_start", "date_end"),
      function(x) lubridate::dmy(x)
    )) %>%
    dplyr::mutate(
      legis_period_current = dplyr::case_when(
        is.na(.data$date_end) ~ TRUE,
        .default = FALSE
      )
    )

  #select columns, rename
  df_res <- df_res %>%
    dplyr::mutate(
      legis_period = as.roman(.data$value) %>% as.numeric()
    ) %>%
    dplyr::select(
      legis_period_rom = "value",
      "legis_period",
      "legis_period_current",
      "date_start",
      "date_end"
    )

  #add names to periods
  df_res <- df_res %>%
    dplyr::mutate(
      legis_period_name = dplyr::case_when(
        .data$legis_period_current == TRUE ~
          glue::glue(
            "ab {format(.data$date_start, '%d.%m.%Y')}: {.data$legis_period_rom}. Gesetzgebungsperiode"
          ),
        .default = glue::glue(
          "{format(.data$date_start, '%d.%m.%Y')} - {format(.data$date_end, '%d.%m.%Y')}: {.data$legis_period_rom}. GP"
        )
      )
    ) %>%
    dplyr::mutate(legis_period_abbrev = .data$legis_period_rom) %>%
    dplyr::mutate(
      legis_period_abbrev_num = .data$legis_period %>% as.character()
    )

  # add missing periods:

  df_periods_missing <- data.frame(
    legis_period_name = c(
      "Provisorische Nationalversammlung",
      "Konstituierende Nationalversammlung",
      "Bundesrat der 1. Republik"
    ),
    date_start = as.Date(
      c("21.10.1918", "04.03.1919", "01.12.1920"),
      format = "%d.%m.%Y"
    ),
    date_end = as.Date(
      c("16.02.1919", "09.11.1920", "02.05.1934"),
      format = "%d.%m.%Y"
    ),
    legis_period_current = c(FALSE, FALSE, FALSE),
    legis_period_abbrev = c("PN", "KN", "Bundesrat1Rep")
  ) %>%
    dplyr::mutate(legis_period_abbrev_num = .data$legis_period_abbrev) %>%
    dplyr::mutate(
      legis_period_name = glue::glue(
        "{format(date_start, '%d.%m.%Y')} - {format(date_end, '%d.%m.%Y')}: {legis_period_name}"
      )
    )

  df_res <- df_res %>%
    dplyr::bind_rows(df_periods_missing) %>%
    dplyr::arrange(.data$date_start)

  #filter full result by requested period
  if (!is.null(legis_period)) {
    df_res <- df_res %>%
      dplyr::filter(
        .data$legis_period_abbrev_num %in% as.character({{ legis_period }})
      )
    return(df_res)
  } else if (!is.null(date)) {
    df_date <- data.frame(date = lubridate::dmy(date))

    #if legis_period is not yet over, use today's date as end date
    df_res <- df_res %>%
      dplyr::mutate(
        date_end_open = dplyr::case_when(
          is.na(.data$date_end) ~ lubridate::today(),
          .default = .data$date_end
        )
      )

    #semi-join to filter dates; allows to filter for multiple dates
    df_res <- df_res %>%
      dplyr::semi_join(
        df_date,
        by = dplyr::join_by(between(y$date, x$date_start, x$date_end_open))
      ) %>%
      dplyr::select(-"date_end_open")

    return(df_res %>% dplyr::select(-"legis_period_rom"))
  } else {
    df_res %>% dplyr::select(-"legis_period_rom")
  }
}
