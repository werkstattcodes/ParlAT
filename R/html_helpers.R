# Fetch an HTML page through httr2 so httptest2 can intercept and record it.
# Returns an xml_document parsed from the response body.
.parlat_fetch_html <- function(url) {
  req <- httr2::request(url) |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)")

  resp <- httr2::req_perform(req)
  html <- httr2::resp_body_string(resp)

  rvest::read_html(html)
}

.parlat_detail_json_url <- function(url) {
  url <- stringr::str_remove(url, "\\?.*$")
  stringr::str_c(url, "?json=TRUE")
}

.parlat_fetch_detail_json_text <- function(url) {
  req <- httr2::request(.parlat_detail_json_url(url)) |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)")

  resp <- httr2::req_perform(req)
  json_text <- httr2::resp_body_string(resp)

  if (is.na(json_text) || !nzchar(json_text)) {
    cli::cli_abort("Parliament detail JSON response was empty for {.url {url}}.")
  }

  json_text
}

.parlat_parse_detail_json <- function(json_text, simplifyVector = TRUE) {
  tryCatch(
    list(data = jsonlite::fromJSON(json_text, simplifyVector = simplifyVector)),
    error = function(e) {
      cli::cli_abort(
        c(
          "Could not parse Parliament detail JSON.",
          "x" = conditionMessage(e)
        )
      )
    }
  )
}

# Extract the embedded props JSON payload from a parlament.gv.at detail page.
.parlat_extract_props_json <- function(page) {
  json_text <- page |>
    rvest::html_elements("script") |>
    rvest::html_text2() |>
    (\(x) x[stringr::str_detect(x, "props:")])() |>
    stringr::str_extract("(?s)props:.*") |>
    stringr::str_remove("props:\\s*") |>
    stringr::str_remove("\\}\\);\\s*$")

  if (length(json_text) == 0 || is.na(json_text) || !nzchar(json_text)) {
    cli::cli_abort(
      "Could not find the legacy React {.code props:} payload in the detail page."
    )
  }

  json_text
}
