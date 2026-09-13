#' Get Consultation Submissions for a Draft or Bill
#'
#' Retrieve references to consultation submissions (Stellungnahmen im
#' Begutachtungsverfahren), called "opinions" on Parliament's English website.
#' These are written contributions by individuals or organisations concerning
#' one ministerial draft or parliamentary bill.
#'
#' @param item_url Character scalar. Full Parliament URL or relative path of
#'   the parent item. Supported object types are ministerial drafts (`ME`),
#'   parliamentary papers such as government bills (`I`), and motions (`A`).
#'   Query strings, fragments and a trailing slash are ignored.
#' @param echo Logical scalar. If `TRUE`, display the parent item's website URL,
#'   pagination progress and the number of submissions returned.
#'
#' @return An ungrouped tibble with one row per submission and these columns:
#' * `legis_period`: Legislative period (character).
#' * `date`: Submission date (`Date`).
#' * `submission_id`: Citation, e.g. `624/SN-44/ME` (character).
#' * `submission_code`: Submission type, e.g. `SNME` or `SN` (character).
#' * `author`: Published person or organisation name (character).
#' * `submission_url`: Full URL of the submission's detail page (character).
#' * `support_n`: Number of supports (numeric).
#' * `item_id`: Parent reference as returned by the API (character).
#' * `item_code`: Parent object type, e.g. `ME` or `I` (character).
#' * `item_url`: Full URL of the parent item (character).
#'
#' No results produce a zero-row tibble with the same columns and types.
#'
#' @details
#' The function queries the parent-specific consultation filter and retrieves
#' all pages. It returns references and metadata, without downloading submission
#' texts, PDFs or individual detail pages. Results follow the API's date order
#' (newest first). Non-public submissions remain in the result, with unavailable
#' authors and links recorded as `NA`. A submission URL is returned only when
#' the API supplies a link; internal identifiers are not used to invent links.
#'
#' The object type is taken from the parent URL. For example, a government
#' bill may use `I` in its URL even though its document type is `RV`.
#' If an HTTP request fails, pagination changes during retrieval, or the API
#' returns an inconsistent result, the function errors rather than returning
#' an incomplete table. Retry the call if the underlying results have changed.
#'
#' @seealso [get_participation()] for searching participation items and their
#'   submission counts; [get_item_details()] for a public submission's details.
#' @examples
#' \donttest{
#' submissions <- get_consultation_submissions("/gegenstand/XXVIII/ME/44")
#' submissions |>
#'   dplyr::select(submission_id, author, submission_url)
#'
#' get_consultation_submissions("/gegenstand/XXVIII/I/405", echo = FALSE)
#'
#' # Combine submissions for several parent items in one flat table.
#' c("/gegenstand/XXVIII/ME/44", "/gegenstand/XXVIII/I/405") |>
#'   purrr::map(\(url) get_consultation_submissions(url, echo = FALSE)) |>
#'   purrr::list_rbind()
#' }
#' @export
get_consultation_submissions <- function(item_url, echo = TRUE) {
  parent <- .parlat_submission_parent(item_url)
  checkmate::assert_flag(echo)

  request <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/142"
  ) |>
    httr2::req_url_query(
      js = "eval", page = 1, pagesize = 100, sortrnr = 5, ascDesc = "DESC"
    ) |>
    httr2::req_body_json(list(
      BEZUG_GP_CODE = list(parent$legis_period),
      BEZUG_ITYP = list(parent$item_code),
      BEZUG_INR = list(parent$number)
    )) |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
    httr2::req_retry(max_tries = 3)

  if (echo) {
    cli::cli_inform("Consultation submissions on the Parliament website: {.url {parent$item_url}}")
  }

  first <- .parlat_fetch_submission_page(request, 1)
  metadata <- .parlat_submission_pagination(first)
  results <- list(.parlat_parse_submissions(first, parent))

  if (metadata$pages > 1) {
    if (echo) {
      cli::cli_inform("Fetching {metadata$pages} pages...")
    }
    remaining <- purrr::map(seq.int(2, metadata$pages), function(page) {
      response <- .parlat_fetch_submission_page(request, page)
      if (!identical(.parlat_submission_pagination(response), metadata)) {
        cli::cli_abort("Submission results changed during pagination. Please retry the call.")
      }
      .parlat_parse_submissions(response, parent)
    })
    results <- c(results, remaining)
  }

  result <- purrr::list_rbind(results)
  if (nrow(result) != metadata$count || anyDuplicated(result$submission_id)) {
    cli::cli_abort(
      "The API returned an incomplete or duplicated submission list. Please retry the call."
    )
  }
  if (echo) {
    cli::cli_inform("Returning {nrow(result)} consultation submission(s).")
  }
  result
}

.parlat_submission_parent <- function(item_url) {
  checkmate::assert_string(item_url, min.chars = 1)
  url <- .parlat_absolute_url(item_url) |>
    stringr::str_remove("[?#].*$")
  parts <- stringr::str_match(
    url,
    "^https?://(?:www\\.)?parlament\\.gv\\.at/gegenstand/([A-Z]+)/([A-Z-]+)/([0-9]+)/?$"
  )
  if (is.na(parts[1, 1]) ||
      !grepl("^(?:[IVXLCDM]+|KN|PN)$", parts[1, 2]) ||
      !parts[1, 3] %in% c("ME", "I", "A")) {
    cli::cli_abort(
      "{.arg item_url} must identify a Parliament ministerial draft or bill (ME, I or A), not an individual submission."
    )
  }
  number <- suppressWarnings(as.integer(parts[1, 4]))
  if (is.na(number) || number < 1L) {
    cli::cli_abort("{.arg item_url} must contain a positive item number.")
  }
  list(
    legis_period = parts[1, 2], item_code = parts[1, 3], number = number,
    item_url = paste0(
      "https://www.parlament.gv.at/gegenstand/", parts[1, 2], "/",
      parts[1, 3], "/", number
    )
  )
}

.parlat_empty_submissions <- function() {
  .parlat_empty_tibble(
    c("legis_period", "date", "submission_id", "submission_code", "author",
      "submission_url", "support_n", "item_id", "item_code", "item_url"),
    date_cols = "date", num_cols = "support_n"
  )
}

.parlat_fetch_submission_page <- function(request, page) {
  request |>
    httr2::req_url_query(page = page) |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE)
}

.parlat_submission_pagination <- function(response) {
  valid_count <- function(x) {
    is.numeric(x) && length(x) == 1L && !is.na(x) &&
      is.finite(x) && x >= 0 && x == floor(x)
  }
  if (!valid_count(response$count) || !valid_count(response$pages) ||
      (response$count > 0 && response$pages < 1)) {
    cli::cli_abort("The submission API returned invalid pagination metadata.")
  }
  list(count = as.numeric(response$count), pages = as.numeric(response$pages))
}

.parlat_parse_submissions <- function(response, parent) {
  if (length(response$rows) == 0) {
    return(.parlat_empty_submissions())
  }
  header <- response$header
  if (!is.data.frame(header) ||
      !all(c("feld_name", "label", "rnr") %in% names(header)) ||
      anyNA(header$rnr) || anyDuplicated(header$rnr)) {
    cli::cli_abort("The submission API returned an unrecognised header structure.")
  }
  header <- dplyr::arrange(header, .data$rnr)
  rows <- response$rows
  if (is.data.frame(rows) || is.matrix(rows)) {
    rows <- as.matrix(rows)
  } else if (is.atomic(rows) && is.null(dim(rows))) {
    rows <- matrix(rows, nrow = 1)
  } else if (is.list(rows)) {
    rows <- purrr::map(rows, function(row) {
      purrr::map_chr(row, function(value) {
        if (is.null(value)) NA_character_ else as.character(value)
      })
    })
    if (any(lengths(rows) != nrow(header))) {
      cli::cli_abort("Submission rows do not match the API header.")
    }
    rows <- do.call(rbind, rows)
  }
  if (!is.matrix(rows) || ncol(rows) != nrow(header)) {
    cli::cli_abort("Submission rows do not match the API header.")
  }

  # Some columns have no field name; their display labels are the only key.
  column <- function(field = NULL, label = NULL, required = FALSE) {
    index <- which(header$feld_name %in% field)
    if (!length(index)) index <- which(header$label %in% label)
    if (length(index) > 1L || (required && !length(index))) {
      key <- if (is.null(field)) label else field
      cli::cli_abort("Missing or ambiguous submission API column: {.val {key}}.")
    }
    if (!length(index)) return(rep(NA_character_, nrow(rows)))
    values <- trimws(as.character(rows[, index]))
    values[is.na(values) | !nzchar(values)] <- NA_character_
    values
  }

  parent_period <- column("BEZUG_GP_CODE", required = TRUE)
  parent_code <- column("BEZUG_ITYP", required = TRUE)
  parent_number <- suppressWarnings(as.integer(column("BEZUG_INR", required = TRUE)))
  if (anyNA(parent_period) || anyNA(parent_code) || anyNA(parent_number) ||
      any(parent_period != parent$legis_period) ||
      any(parent_code != parent$item_code) || any(parent_number != parent$number)) {
    cli::cli_abort("The submission API returned results for a different parent item.")
  }

  submission_id <- column(label = "Nr", required = TRUE)
  submission_code <- column("ITYP", required = TRUE)
  if (anyNA(submission_id) || anyNA(submission_code)) {
    cli::cli_abort("The submission API returned missing submission identifiers.")
  }
  by <- column(label = "Von", required = TRUE)
  links <- purrr::map(by, function(value) {
    if (is.na(value) || !grepl("<", value, fixed = TRUE)) {
      return(list(author = NA_character_, url = NA_character_))
    }
    anchor <- rvest::read_html(value) |> rvest::html_element("a[href]")
    list(author = rvest::html_text2(anchor), url = rvest::html_attr(anchor, "href"))
  })
  author <- purrr::map_chr(links, "author")
  # Remove only the exact citation suffix, preserving parentheses in names.
  suffix <- paste0(" (", submission_id, ")")
  has_suffix <- !is.na(author) & endsWith(author, suffix)
  author[has_suffix] <- substr(
    author[has_suffix], 1, nchar(author[has_suffix]) - nchar(suffix[has_suffix])
  )
  author <- stringr::str_squish(author)
  author[!is.na(author) & !nzchar(author)] <- NA_character_

  tibble::tibble(
    legis_period = column("GP_CODE", required = TRUE),
    date = lubridate::dmy(column("DATUM"), quiet = TRUE),
    submission_id = submission_id,
    submission_code = submission_code,
    author = author,
    submission_url = .parlat_absolute_url(purrr::map_chr(links, "url")),
    support_n = as.numeric(column(label = "Unterst\u00fctzungen")),
    item_id = column(label = "Zu"),
    item_code = parent_code,
    item_url = rep(parent$item_url, nrow(rows))
  )
}
