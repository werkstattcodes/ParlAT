#' Convert nested JSON parliamentary item to tibble with list-columns
#'
#' @param json_data A nested list object (parsed from JSON) representing a parliamentary item
#' @return A tibble with one row where nested elements become list-columns
#'
#' @importFrom tibble tibble
#' @importFrom purrr map_if map_lgl
#' @noRd
#' @keywords internal
aux_json_to_tibble <- function(json_data) {
  # Function to identify complex nested structures that should become list-columns
  is_complex <- function(x) {
    is.list(x) && (length(x) > 1 || purrr::map_lgl(x, is.list) %>% any())
  }

  # Convert the JSON data to a flat structure for tibble creation
  flattened <- purrr::map_if(json_data, is_complex, list)

  # Create tibble with list-columns for nested elements
  tibble::tibble(!!!flattened)
}
