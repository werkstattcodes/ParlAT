# Fetch an HTML page through httr2 so httptest2 can intercept and record it.
# Returns an xml_document parsed from the response body.
.parlat_fetch_html <- function(url) {
  req <- httr2::request(url) |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)")

  resp <- httr2::req_perform(req)
  html <- httr2::resp_body_string(resp)

  rvest::read_html(html)
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
