# Shared internal utilities used across the get_*() functions.

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
