#' Get start and end dates of legislative periods.
#'
#' @param legis_period Number or identifier of legislative period(s) for which dates should be returned.
#'   Accepts numeric values (e.g., 27), Roman numerals (e.g., "XXVII"), or historical period
#'   abbreviations: "PV" (Provisorische Nationalversammlung), "KN" (Konstituierende Nationalversammlung),
#'   "Bundesrat1Rep" (Bundesrat der 1. Republik). Can be a vector for multiple periods.
#' @param date Date within a legislative period. Format should be "dd.mm.yyyy".
#'
#' @return A dataframe
#' @export
#'
#' @examples
#' \dontrun{
#' # Numeric periods
#' get_legis_periods(legis_period = 27)
#' get_legis_periods(legis_period = c(26, 27))
#'
#' # Roman numerals
#' get_legis_periods(legis_period = "XXVII")
#' get_legis_periods(legis_period = c("XXVI", "XXVII"))
#'
#' # Historical periods
#' get_legis_periods(legis_period = "PV")
#' get_legis_periods(legis_period = c("PV", "KN"))
#'
#' # Mixed input types
#' get_legis_periods(legis_period = c(26, "XXVII", "PV"))
#'
#' # Filter by date
#' get_legis_periods(date = "01.01.2020")
#' get_legis_periods(date = c("01.01.2020", "05.05.1954"))
#' }
get_legis_periods <- function(legis_period = NULL, date = NULL) {
  if (!is.null(legis_period) && !is.null(date)) {
    stop("Please provide either legis_period or date, not both.")
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

  res <- httr2::request("https://www.parlament.gv.at/Filter/api/json/post") |>
    httr2::req_url_query(
      jsMode = "FIELDS",
      FBEZ = "WFW_004",
    ) |>
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      `content-type` = "application/json",
      dnt = "1",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i",
      `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36",
    ) |>
    httr2::req_body_raw(
      '{"R_WF":["FR"],"R_BW":["BL"],"M":["M"],"W":["W"],"GP":["ALLE"]}',
      "application/json"
    ) |>
    httr2::req_perform()

  #retrieve legis period dates
  df_res <- res |>
    httr2::resp_body_json(simplifyVector = TRUE) |>
    dplyr::pull(values) |>
    purrr::pluck(1)

  #extract/clean dates
  df_res <- df_res |>
    dplyr::filter(value != "ALLE") #|>
  # dplyr::mutate(current=dplyr::case_when(
  #   stringr::str_detect(label, "seit") ~ TRUE,
  #   .default=FALSE
  # ))

  df_res <- df_res |>
    dplyr::mutate(
      dates_li = stringr::str_extract_all(
        label,
        stringr::regex("\\d{2}\\.\\d{2}\\.\\d{4}")
      )
    )

  df_res <- df_res |>
    dplyr::mutate(date_start = purrr::map_chr(dates_li, purrr::pluck, 1)) |>
    dplyr::mutate(
      date_end = purrr::map_chr(
        dates_li,
        .f = \(x) purrr::pluck(x, 2, .default = NA)
      )
    ) |>
    dplyr::mutate(across(
      c("date_start", "date_end"),
      \(x) lubridate::dmy(x)
    )) |>
    dplyr::mutate(
      legis_period_current = dplyr::case_when(
        is.na(date_end) ~ TRUE,
        .default = FALSE
      )
    )

  #select columns, rename
  df_res <- df_res |>
    dplyr::mutate(
      legis_period = as.roman(value) |> as.numeric()
    ) |>
    dplyr::select(
      legis_period_rom = value,
      legis_period,
      legis_period_current,
      date_start,
      date_end
    )

  #add names to periods
  df_res <- df_res %>%
    dplyr::mutate(
      legis_period_name = dplyr::case_when(
        legis_period_current == TRUE ~
          glue::glue(
            "ab {format(date_start, '%d.%m.%Y')}: {legis_period_rom}. Gesetzgebungsperiode"
          ),
        .default = glue::glue(
          "{format(date_start, '%d.%m.%Y')} - {format(date_end, '%d.%m.%Y')}: {legis_period_rom}. GP"
        )
      )
    ) %>%
    dplyr::mutate(legis_period_abbrev = legis_period_rom) %>%
    dplyr::mutate(legis_period_abbrev_num = legis_period %>% as.character())

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
    legis_period_abbrev = c("PV", "KN", "Bundesrat1Rep")
  ) %>%
    dplyr::mutate(legis_period_abbrev_num = legis_period_abbrev) %>%
    dplyr::mutate(
      legis_period_name = glue::glue(
        "{format(date_start, '%d.%m.%Y')} - {format(date_end, '%d.%m.%Y')}: {legis_period_name}"
      )
    )

  df_res <- df_res |>
    dplyr::bind_rows(df_periods_missing) |>
    dplyr::arrange(date_start)

  #filter full result by requested period
  if (!is.null(legis_period)) {
    df_res <- df_res |>
      dplyr::filter(
        legis_period_abbrev_num %in% as.character({{ legis_period }})
      )
    return(df_res)
  } else if (!is.null(date)) {
    df_date <- data.frame(date = lubridate::dmy(date))

    #if legis_period is not yet over, use today's date as end date
    df_res <- df_res %>%
      dplyr::mutate(
        date_end_open = dplyr::case_when(
          is.na(date_end) ~ lubridate::today(),
          .default = date_end
        )
      )

    #semi-join to filter dates; allows to filter for multiple dates
    df_res <- df_res %>%
      dplyr::semi_join(
        .,
        df_date,
        by = dplyr::join_by(between(y$date, x$date_start, x$date_end_open))
      ) %>%
      dplyr::select(-date_end_open)

    return(df_res %>% dplyr::select(-legis_period_rom))
  } else {
    df_res %>% dplyr::select(-legis_period_rom)
  }
}
