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
#'
#' @return A zero-row tibble. Columns default to character.
#' @keywords internal
#' @noRd
.parlat_empty_tibble <- function(
  cols,
  date_cols = character(),
  list_cols = character()
) {
  proto <- purrr::map(cols, \(col) {
    if (col %in% date_cols) {
      as.Date(character())
    } else if (col %in% list_cols) {
      list()
    } else {
      character()
    }
  }) |>
    stats::setNames(cols)

  tibble::as_tibble(proto)
}
