# Fetch an HTML page through httr2 so httptest2 can intercept and record it.
# Returns an xml_document parsed from the response body.
.parlat_fetch_html <- function(url) {
  req <- httr2::request(url) |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
    httr2::req_retry(max_tries = 3)

  resp <- httr2::req_perform(req)
  html <- httr2::resp_body_string(resp)

  rvest::read_html(html)
}

.parlat_detail_json_url <- function(url) {
  url <- .parlat_absolute_url(url) |>
    stringr::str_remove("[?#].*$")
  stringr::str_c(url, "?json=TRUE")
}

.parlat_fetch_detail_json_text <- function(url) {
  req <- httr2::request(.parlat_detail_json_url(url)) |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
    httr2::req_retry(max_tries = 3)

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

# Complete API paths or resolve HTML hrefs against their source page. Already
# absolute URLs are left intact, including links outside Parliament's website.
.parlat_absolute_url <- function(x, base_url = "https://www.parlament.gv.at/") {
  x <- trimws(as.character(x))
  x[!is.na(x) & !nzchar(x)] <- NA_character_
  base_url <- rep_len(base_url, length(x))
  base_url[is.na(base_url) | !nzchar(base_url)] <- "https://www.parlament.gv.at/"
  vapply(seq_along(x), function(i) {
    value <- x[[i]]
    if (is.na(value) || grepl("^[A-Za-z][A-Za-z0-9+.-]*:", value)) {
      return(value)
    }
    if (startsWith(value, "//")) {
      return(paste0("https:", value))
    }
    base <- base_url[[i]]
    # Resolve only the path: URL builders can re-encode query/fragment text.
    if (startsWith(value, "#")) {
      return(paste0(sub("#.*$", "", base), value))
    }
    if (startsWith(value, "?")) {
      return(paste0(sub("[?#].*$", "", base), value))
    }
    path <- sub("[?#].*$", "", value)
    suffix <- substring(value, nchar(path) + 1L)
    # Search results often contain thousands of already encoded root paths.
    # These need only the origin; reserve URL parsing for relative navigation
    # and paths that need escaping.
    if (grepl("^/[A-Za-z0-9/._~%+-]*$", path) &&
        !grepl("(^|/)\\.{1,2}(/|$)", path)) {
      origin <- sub("^(https?://[^/?#]+).*$", "\\1", base)
      return(paste0(origin, value))
    }
    paste0(
      httr2::url_modify_relative(sub("[?#].*$", "", base), path),
      suffix
    )
  }, character(1), USE.NAMES = FALSE)
}

# URL-bearing search columns sometimes contain an anchor instead of a URL.
.parlat_href_url <- function(x, base_url = "https://www.parlament.gv.at/") {
  hrefs <- vapply(x, function(value) {
    if (is.na(value) || !grepl("<", value, fixed = TRUE)) {
      return(value)
    }
    rvest::read_html(value) |>
      rvest::html_element("a[href]") |>
      rvest::html_attr("href")
  }, character(1), USE.NAMES = FALSE)
  .parlat_absolute_url(hrefs, base_url)
}

.parlat_url_columns <- function(
  df,
  cols,
  base_url = "https://www.parlament.gv.at/"
) {
  for (col in intersect(cols, names(df))) {
    df[[col]] <- .parlat_absolute_url(df[[col]], base_url)
  }
  df
}
