library(rvest)
library(jsonlite)
library(stringr)

check_url <- function(url) {
  cat("\n========================================\n")
  cat("URL:", url, "\n")
  cat("========================================\n")

  page <- read_html(url)
  json_text <- page |>
    html_elements("script") |>
    html_text2() |>
    (\(x) x[str_detect(x, "props:")])() |>
    str_extract("(?s)props:.*") |>
    str_remove("props:\\s*") |>
    str_remove("\\}\\);\\s*$")

  s <- fromJSON(json_text)$data$content
  u <- parse_json(json_text)$data$content

  cat("\n--- fromJSON ---\n")
  cat("has phase:", !is.null(s$phase), "\n")
  cat("has phase$stages:", !is.null(s$phase$stages), "\n")
  cat("has stages:", !is.null(s$stages), "\n")
  if (!is.null(s$phase)) {
    cat("class(phase):", class(s$phase), "\n")
    if (is.data.frame(s$phase)) {
      cat("nrow(phase):", nrow(s$phase), "\n")
    }
  }
  if (!is.null(s$stages)) {
    cat("class(stages):", class(s$stages), "\n")
    if (is.data.frame(s$stages)) {
      cat("nrow(stages):", nrow(s$stages), "\n")
      cat("names(stages):", paste(names(s$stages), collapse = ", "), "\n")
    }
  }

  cat("\n--- parse_json ---\n")
  cat("has phase:", !is.null(u$phase), "\n")
  if (!is.null(u$phase)) {
    cat("phase is unnamed list:", is.list(u$phase) && is.null(names(u$phase)), "\n")
    cat("length(phase):", length(u$phase), "\n")
    if (length(u$phase) > 0) {
      cat("phase[[1]] has stages:", !is.null(u$phase[[1]]$stages), "\n")
      if (!is.null(u$phase[[1]]$name)) cat("phase[[1]]$name:", u$phase[[1]]$name, "\n")
    }
  }
  cat("has stages:", !is.null(u$stages), "\n")
  if (!is.null(u$stages)) {
    cat("stages is unnamed list:", is.list(u$stages) && is.null(names(u$stages)), "\n")
    cat("length(stages):", length(u$stages), "\n")
  }
}

check_url("https://www.parlament.gv.at/gegenstand/XXVIII/A/5")
check_url("https://www.parlament.gv.at/gegenstand/XXVIII/BI/24")
# Also check a known flat-stages type
check_url("https://www.parlament.gv.at/gegenstand/XXVII/UEA/283")
