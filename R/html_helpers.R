# Fetch an HTML page through httr2 so httptest2 can intercept and record it.
# Returns an xml_document parsed from the response body.
.parlat_fetch_html <- function(url) {
  req <- httr2::request(url) |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)")

  resp <- httr2::req_perform(req)
  html <- httr2::resp_body_string(resp)

  rvest::read_html(html)
}

#' Extract the full text of a parliamentary correspondence item
#' @encoding UTF-8
#' @description
#' `get_press_releases_text` fetches the detail page of a parliamentary
#' correspondence item and returns its full body text. It is designed to be
#' used with the `url` column returned by [get_press_releases()].
#'
#' @param url Character string. A URL from the `url` column of a
#'   [get_press_releases()] result, pointing to a detail page on
#'   parlament.gv.at.
#'
#' @return A character string containing the full article text, with paragraphs
#'   separated by `"\n\n"`. Returns `NA_character_` if no text could be
#'   extracted and emits a warning.
#'
#' @seealso [get_press_releases()]
#'
#' @export
#'
#' @examples \donttest{
#' result <- get_press_releases(category = "Bundesrat", year = 2024)
#' text <- get_press_releases_text(result$url[[1]])
#' cat(text)
#' }
get_press_releases_text <- function(url) {
  checkmate::assert_string(url)

  page <- .parlat_fetch_html(url)

  paragraphs <- page |>
    rvest::html_elements(".htmlBox .pk p") |>
    rvest::html_text2()

  if (length(paragraphs) == 0) {
    warning("No text content found at: ", url, call. = FALSE)
    return(NA_character_)
  }

  paste(paragraphs, collapse = "\n\n")
}

# Extract the embedded props JSON payload from a parlament.gv.at detail page.
.parlat_extract_props_json <- function(page) {
  page |>
    rvest::html_elements("script") |>
    rvest::html_text2() |>
    (\(x) x[stringr::str_detect(x, "props:")])() |>
    stringr::str_extract("(?s)props:.*") |>
    stringr::str_remove("props:\\s*") |>
    stringr::str_remove("\\}\\);\\s*$")
}
