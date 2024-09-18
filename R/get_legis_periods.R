#' #Get start and end dates of legislative periods
#'
#' @param legis_period
#'
#' @return
#' @export
#'
#' @examples
get_legis_period <- function(legis_period=NULL) {

  #legis_period <- 27

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
    httr2::req_body_raw('{"R_WF":["FR"],"R_BW":["BL"],"M":["M"],"W":["W"],"GP":["ALLE"]}', "application/json") |>
    httr2::req_perform()

  #retrieve legis period dates
  df_res <- res |>
    httr2::resp_body_json(simplifyVector = TRUE)  |>
    dplyr::pull(values) |> purrr::pluck(1)

  #extract/clean dates
  df_res <- df_res |>
    dplyr::filter(value!="ALLE") |>
    dplyr::mutate(current=dplyr::case_when(
      stringr::str_detect(label, "seit") ~ TRUE,
      .default=FALSE
    ))

  df_res <- df_res |>
    dplyr::mutate(dates_li=stringr::str_extract_all(label, stringr::regex("\\d{2}\\.\\d{2}\\.\\d{4}")))

  df_res <- df_res |>
    dplyr::mutate(date_start=purrr::map_chr(dates_li, purrr::pluck, 1)) |>
    dplyr::mutate(date_end=purrr::map_chr(dates_li, .f=\(x) purrr::pluck(x, 2, .default=NA)))|>
    dplyr::mutate(across(c("date_start", "date_end"), \(x) lubridate::dmy(x)))

  #select columns, rename
  df_res <- df_res |>
    dplyr::mutate(
      legis_period=as.roman(value) |> as.numeric()
    ) |>
    dplyr::select(
      legis_period_rom=value,
      legis_period,
      legis_period_current=current,
      date_start,
      date_end
    )

  if (!is.null(legis_period)) {
    df_res |>
      dplyr::filter(legis_period %in% {{legis_period}})
  } else {
    df_res
  }

}
