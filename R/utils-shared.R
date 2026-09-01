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

#' Echo the equivalent website URL for a request
#'
#' Prints (via cli) the URL to the matching search results on the Parliament
#' website and the number of results. Used by the `echo` argument of the
#' `get_*()` functions.
#'
#' @param body_params JSON string of the request body; used to reconstruct
#'   the website query string (not printed itself).
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

  cli::cli_inform(
    "Results on the Parliament website: {url_base}?{query_string}{url_suffix}"
  )
  if (!is.null(n_results)) {
    cli::cli_inform("Hits: {n_results}")
  }
  invisible(NULL)
}

#' Return all legislative-period codes used by Parliament search pages
#'
#' The website requires explicit period parameters to override its current-
#' period default. `last_period` must be updated when a new legislative period
#' starts.
#'
#' @param first_period First numbered legislative period to include.
#' @param last_period Last numbered legislative period to include.
#' @return Character vector of Roman numerals followed by `"KN"` and `"PN"`.
#' @keywords internal
#' @noRd
.parlat_all_legis_period_codes <- function(
  first_period = 1L,
  last_period = 28L
) {
  c(
    as.character(as.roman(seq.int(first_period, last_period))),
    "KN",
    "PN"
  )
}

#' Add explicit all-period values to an echo-only request body
#'
#' API requests interpret an omitted period as unrestricted, but some website
#' search pages restore the current legislative period when their URL omits the
#' same parameter. This helper changes only the body used to construct the
#' website URL.
#'
#' @param body_params JSON request body.
#' @param legis_period Normalized period input; an empty value means all.
#' @param first_period First numbered period supported by the search page.
#' @param period_param Period parameter name in the request body.
#' @return JSON request body suitable for `.parlat_echo_request()`.
#' @keywords internal
#' @noRd
.parlat_echo_body_all_periods <- function(
  body_params,
  legis_period,
  first_period = 1L,
  period_param = "GP_CODE"
) {
  if (length(legis_period) > 0L) {
    return(body_params)
  }

  echo_params <- jsonlite::fromJSON(body_params)
  echo_params[[period_param]] <- .parlat_all_legis_period_codes(first_period)
  jsonlite::toJSON(echo_params)
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

#' Match a data frame to a typed zero-row prototype
#'
#' Adds absent columns, casts present columns to the prototype types, removes
#' extra columns, and orders the result to match `prototype`.
#'
#' @param df A data frame.
#' @param prototype A typed zero-row data frame.
#' @return A tibble matching `prototype`.
#' @keywords internal
#' @noRd
.parlat_match_tibble_prototype <- function(df, prototype) {
  n <- nrow(df)

  for (col in names(prototype)) {
    column_prototype <- prototype[[col]]

    if (!col %in% names(df)) {
      df[[col]] <- column_prototype[rep(NA_integer_, n)]
    } else if (inherits(column_prototype, "Date")) {
      df[[col]] <- as.Date(df[[col]])
    } else if (inherits(column_prototype, "POSIXct")) {
      timezone <- attr(column_prototype, "tzone")
      if (is.null(timezone) || length(timezone) == 0L) {
        timezone <- "UTC"
      }

      if (is.numeric(df[[col]]) && !inherits(df[[col]], "POSIXct")) {
        df[[col]] <- as.POSIXct(
          df[[col]],
          origin = "1970-01-01",
          tz = timezone
        )
      } else {
        df[[col]] <- as.POSIXct(df[[col]], tz = timezone)
      }
    } else if (is.list(column_prototype)) {
      df[[col]] <- as.list(df[[col]])
    } else if (is.logical(column_prototype)) {
      df[[col]] <- as.logical(df[[col]])
    } else if (is.integer(column_prototype)) {
      df[[col]] <- as.integer(df[[col]])
    } else if (is.numeric(column_prototype)) {
      df[[col]] <- as.numeric(df[[col]])
    } else {
      df[[col]] <- as.character(df[[col]])
    }
  }

  df |>
    tibble::as_tibble() |>
    dplyr::select(dplyr::all_of(names(prototype)))
}
