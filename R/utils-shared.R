# Shared internal utilities used across the get_*() functions.

#' Rename columns according to a renaming map
#'
#' Applies `renaming_map` (a named character vector of `old_name = new_name`
#' pairs) to the columns of `df` that are present in the map.
#'
#' @param df A data frame.
#' @param renaming_map Named character vector; names are the current column
#'   names, values the new ones.
#' @return `df` with renamed columns.
#' @keywords internal
#' @noRd
.parlat_apply_renaming <- function(df, renaming_map) {
  df |>
    dplyr::rename_with(
      .fn = \(x) renaming_map[x],
      .cols = dplyr::any_of(names(renaming_map))
    )
}

#' Echo request parameters and the equivalent website URL
#'
#' Prints (via cli) the JSON body sent to the Filter API, the URL to the
#' matching search results on the Parliament website, and the number of
#' results. Used by the `echo` argument of the `get_*()` functions.
#'
#' @param body_params JSON string of the request body.
#' @param url_base Base URL of the corresponding search page on the
#'   Parliament website (without query string).
#' @param param_prefix Query-parameter prefix used by the website's search
#'   form (e.g. `"PERSON_409"`).
#' @param n_results Number of rows in the result, or `NULL` to omit.
#' @param search Optional free-text search string appended as the `search`
#'   query parameter.
#' @param url_suffix Optional string appended after the query string
#'   (e.g. `"&selectedtab=PLENUM"`).
#' @return `invisible(NULL)`, called for its side effect.
#' @keywords internal
#' @noRd
.parlat_echo_request <- function(
  body_params,
  url_base,
  param_prefix,
  n_results = NULL,
  search = NULL,
  url_suffix = ""
) {
  params_li <- jsonlite::fromJSON(body_params)
  if (!is.null(search)) {
    params_li <- c(params_li, search = search)
  }

  query_string <- purrr::imap(
    params_li,
    \(x, y) {
      glue::glue(
        "{param_prefix}{URLencode(y)}={URLencode(as.character(x))}"
      )
    }
  ) |>
    unlist() |>
    unname() |>
    paste0(collapse = "&")

  cli::cli_inform(c(
    "i" = "Request parameters: {body_params}",
    "i" = "Results on the Parliament website: {url_base}?{query_string}{url_suffix}"
  ))
  if (!is.null(n_results)) {
    cli::cli_inform("Hits: {n_results}")
  }
  invisible(NULL)
}

#' Create a zero-row tibble with the given column names
#'
#' Used by the `get_*()` functions to return type-stable empty results when
#' the API finds nothing: the caller always receives a tibble with the
#' documented columns, even when there are no rows.
#'
#' @param cols Character vector of column names.
#' @param date_cols Character vector of columns typed as `Date`.
#' @param list_cols Character vector of columns typed as list-columns.
#' @param int_cols Character vector of columns typed as integer.
#' @param num_cols Character vector of columns typed as numeric.
#' @param datetime_cols Character vector of columns typed as `POSIXct` (UTC).
#' @param lgl_cols Character vector of columns typed as logical.
#'
#' @return A zero-row tibble. Columns default to character.
#' @keywords internal
#' @noRd
.parlat_empty_tibble <- function(
  cols,
  date_cols = character(),
  list_cols = character(),
  int_cols = character(),
  num_cols = character(),
  datetime_cols = character(),
  lgl_cols = character()
) {
  proto <- purrr::map(cols, \(col) {
    if (col %in% date_cols) {
      as.Date(character())
    } else if (col %in% list_cols) {
      list()
    } else if (col %in% int_cols) {
      integer()
    } else if (col %in% num_cols) {
      numeric()
    } else if (col %in% datetime_cols) {
      as.POSIXct(character(), tz = "UTC")
    } else if (col %in% lgl_cols) {
      logical()
    } else {
      character()
    }
  }) |>
    stats::setNames(cols)

  tibble::as_tibble(proto)
}
