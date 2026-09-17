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
#' @param include_text Logical scalar. If `TRUE`, fetch each published
#'   submission's detail JSON and add inline text, HTML and document links.
#'   Defaults to `FALSE`, without additional detail requests.
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
#' With `include_text = TRUE`, three additional columns are returned:
#' * `submission_text`: Inline submission text with HTML markup removed,
#'   entities decoded and paragraph/line breaks preserved (character).
#' * `submission_html`: Original inline HTML from the API (character).
#' * `documents`: List-column of tibbles with character columns `doc_title`,
#'   `link` (absolute document URL), and `type` (e.g. PDF or HTML).
#'
#' Missing inline text is `NA_character_`; missing documents are zero-row
#' tibbles. Text and attachments can coexist. Attachment text is not extracted.
#'
#' No results produce a zero-row tibble with the same columns and types.
#'
#' @details
#' The function queries the parent-specific consultation filter and retrieves
#' all pages. By default it returns references and metadata only.
#' Results follow the API's date order
#' (newest first). Non-public submissions remain in the result, with unavailable
#' authors and links recorded as `NA`. A submission URL is returned only when
#' the API supplies a link; internal identifiers are not used to invent links.
#'
#' Setting `include_text = TRUE` adds one detail fetch per distinct published
#' submission URL, sequentially, and can substantially increase runtime.
#' Rows without a published URL are retained with missing text and empty
#' document tibbles. Documents themselves are not downloaded. Inline text is
#' a written consultation submission, not a speech in a parliamentary debate.
#' A failed or invalid detail response stops the call and identifies its URL.
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
#' # Retrieve inline text and links to attached documents.
#' detailed <- get_consultation_submissions(
#'   "/gegenstand/XXVIII/I/405", include_text = TRUE
#' )
#' detailed$submission_text
#' detailed$documents[[1]]$link
#'
#' # Combine submissions for several parent items in one flat table.
#' c("/gegenstand/XXVIII/ME/44", "/gegenstand/XXVIII/I/405") |>
#'   purrr::map(\(url) get_consultation_submissions(url, echo = FALSE)) |>
#'   purrr::list_rbind()
#' }
#' @export
get_consultation_submissions <- function(item_url, echo = TRUE, include_text = FALSE) {
  # Data flow through this file:
  # item_url -> parent identifiers -> reusable request -> page 1 JSON
  #   -> validate pagination -> parse page 1 into a tibble
  #   -> fetch/validate/parse each remaining page (if any)
  #   -> bind page tibbles -> check completeness and duplicates
  #   -> optionally retrieve submission content -> return.
  # Invalid inputs, failed requests or inconsistent responses stop the call.

  # Extract the parent draft/bill identifiers before making any HTTP request.
  # Example: /gegenstand/XXVIII/ME/44 -> period XXVIII, type ME, number 44.
  parent <- .parlat_parse_submission_parent_url(item_url)
  # echo must be one non-missing TRUE/FALSE value; it controls messages only.
  checkmate::assert_flag(echo)
  checkmate::assert_flag(include_text)

  # Build a request template; req_perform() in the fetch helper sends it later.
  # The base pipe (|>) passes each request object into the next function.
  request <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/142"
  ) |>
    # Request 100 rows per page, sorted by date (column 5), newest first.
    # js = "eval" is a server parameter, not a call to R's eval().
    httr2::req_url_query(
      js = "eval", page = 1, pagesize = 100, sortrnr = 5, ascDesc = "DESC"
    ) |>
    # BEZUG_* identifies the parent item, not an individual submission.
    # Inner lists become JSON arrays, e.g. BEZUG_ITYP: ["ME"].
    # Adding the JSON body makes this a POST request by default.
    httr2::req_body_json(list(
      BEZUG_GP_CODE = list(parent$legis_period),
      BEZUG_ITYP = list(parent$item_code),
      BEZUG_INR = list(parent$number)
    )) |>
    # Identify this client and allow up to three attempts for retryable errors.
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
    httr2::req_retry(max_tries = 3)

  if (echo) {
    cli::cli_inform("Consultation submissions on the Parliament website: {.url {parent$item_url}}")
  }

  # Fetch page 1 to learn the total result count and number of pages.
  # The decoded response contains count, pages, header and rows components.
  first <- .parlat_fetch_submission_page(request, 1)
  metadata <- .parlat_submission_pagination(first)
  # Keep a list of page tibbles for now; combine their rows after retrieval.
  results <- list(.parlat_parse_submissions(first, parent))

  # This guard also prevents seq.int(2, 1) from creating an unwanted sequence.
  if (metadata$pages > 1) {
    if (echo) {
      cli::cli_inform("Fetching {metadata$pages} pages...")
    }
    # map() visits pages sequentially and returns a list of parsed tibbles.
    remaining <- purrr::map(seq.int(2, metadata$pages), function(page) {
      response <- .parlat_fetch_submission_page(request, page)
      # Each page must report the same total count and page count as page 1.
      # This detects some changes during retrieval, not every content change.
      if (!identical(.parlat_submission_pagination(response), metadata)) {
        cli::cli_abort("Submission results changed during pagination. Please retry the call.")
      }
      .parlat_parse_submissions(response, parent)
    })
    # Concatenate lists of tibbles, without stacking their rows yet.
    results <- c(results, remaining)
  }

  # Stack pages in request order, retaining the API's ordering within pages.
  result <- purrr::list_rbind(results)
  # Detect missing rows or repeated pages. anyDuplicated() returns zero when
  # IDs are unique; a nonzero duplicate position acts as TRUE in this condition.
  if (nrow(result) != metadata$count || anyDuplicated(result$submission_id)) {
    cli::cli_abort(
      "The API returned an incomplete or duplicated submission list. Please retry the call."
    )
  }
  if (include_text) {
    # Enrich only after all search pages pass the completeness checks above.
    # The helper fetches published detail URLs and appends text, HTML and
    # document links, preserving the existing rows and metadata. The default
    # include_text = FALSE skips these requests and keeps the original schema.
    result <- .parlat_add_submission_text(result, echo)
  }
  if (echo) {
    cli::cli_inform("Returning {nrow(result)} consultation submission(s).")
  }
  # R implicitly returns the final expression in a function.
  result
}

# Normalize the parent URL and extract the three identifiers used as filters.
.parlat_parse_submission_parent_url <- function(item_url) {
  checkmate::assert_string(item_url, min.chars = 1)
  # Resolve relative URLs, then discard query/fragment text from ? or # onward.
  url <- .parlat_absolute_url(item_url) |>
    stringr::str_remove("[?#].*$")
  # Match the Parliament domain and item path, allowing a trailing slash.
  # str_match() returns a matrix: column 1 is the full match, and columns
  # 2, 3 and 4 capture the legislative period, object type and item number.
  parts <- stringr::str_match(
    url,
    "^https?://(?:www\\.)?parlament\\.gv\\.at/gegenstand/([A-Z]+)/([A-Z-]+)/([0-9]+)/?$"
  )
  # Accept Roman-numeral characters or KN/PN, and only parent types ME/I/A.
  # This checks the period's syntax, not whether that period actually exists.
  # Individual submission URLs (e.g. type SNME) are rejected here.
  if (is.na(parts[1, 1]) ||
      !stringr::str_detect(parts[1, 2], "^(?:[IVXLCDM]+|KN|PN)$") ||
      !parts[1, 3] %in% c("ME", "I", "A")) {
    cli::cli_abort(
      "{.arg item_url} must identify a Parliament ministerial draft or bill (ME, I or A), not an individual submission."
    )
  }
  # Convert "0044" to 44. Overflow becomes NA; use our own error below
  # instead of showing the conversion warning. Item numbers must be positive.
  number <- suppressWarnings(as.integer(parts[1, 4]))
  if (is.na(number) || number < 1L) {
    cli::cli_abort("{.arg item_url} must contain a positive item number.")
  }
  # Rebuild a canonical HTTPS URL without leading zeros or a trailing slash.
  list(
    legis_period = parts[1, 2], item_code = parts[1, 3], number = number,
    item_url = paste0(
      "https://www.parlament.gv.at/gegenstand/", parts[1, 2], "/",
      parts[1, 3], "/", number
    )
  )
}

.parlat_empty_submissions <- function() {
  # Preserve the output schema even with no results: Date for date, numeric
  # for support_n, and character for all other columns, each of length zero.
  .parlat_empty_tibble(
    c("legis_period", "date", "submission_id", "submission_code", "author",
      "submission_url", "support_n", "item_id", "item_code", "item_url"),
    date_cols = "date", num_cols = "support_n"
  )
}

.parlat_fetch_submission_page <- function(request, page) {
  request |>
    # Replace only the page parameter, retaining filters and other settings.
    httr2::req_url_query(page = page) |>
    # This is the network call; failures propagate if retries do not succeed.
    httr2::req_perform() |>
    # Decode JSON into R objects. Simplification can produce vectors, matrices
    # or data frames, so the parser below accepts several row representations.
    httr2::resp_body_json(simplifyVector = TRUE)
}

.parlat_submission_pagination <- function(response) {
  # Both count and pages must be finite, nonnegative, whole-number scalars.
  # && short-circuits: later checks run only if earlier checks passed.
  valid_count <- function(x) {
    is.numeric(x) && length(x) == 1L && !is.na(x) &&
      is.finite(x) && x >= 0 && x == floor(x)
  }
  # A positive number of submissions also requires at least one page.
  if (!valid_count(response$count) || !valid_count(response$pages) ||
      (response$count > 0 && response$pages < 1)) {
    cli::cli_abort("The submission API returned invalid pagination metadata.")
  }
  # Normalize integer/double differences before identical() compares pages.
  list(count = as.numeric(response$count), pages = as.numeric(response$pages))
}

.parlat_parse_submissions <- function(response, parent) {
  # Empty pages need no header parsing; return the same typed schema.
  if (length(response$rows) == 0) {
    return(.parlat_empty_submissions())
  }
  # header describes each column in rows: its field name, display label and
  # position (rnr). Require enough information to map values unambiguously.
  header <- response$header
  if (!is.data.frame(header) ||
      !all(c("feld_name", "label", "rnr") %in% names(header)) ||
      anyNA(header$rnr) || anyDuplicated(header$rnr)) {
    cli::cli_abort("The submission API returned an unrecognised header structure.")
  }
  # Header entries can arrive out of order; rnr gives their order in each row.
  header <- dplyr::arrange(header, .data$rnr)
  rows <- response$rows
  # Normalize all supported JSON simplifications to one rectangular matrix.
  if (is.data.frame(rows) || is.matrix(rows)) {
    rows <- as.matrix(rows)
  } else if (is.atomic(rows) && is.null(dim(rows))) {
    # A single row may have simplified to a vector without dimensions.
    rows <- matrix(rows, nrow = 1)
  } else if (is.list(rows)) {
    # Outer map: one row at a time. Inner map_chr: one character value per cell.
    rows <- purrr::map(rows, function(row) {
      purrr::map_chr(row, function(value) {
        # Keep a placeholder for JSON null rather than dropping a cell.
        if (is.null(value)) NA_character_ else as.character(value)
      })
    })
    # Check widths before rbind() could recycle values in short rows.
    if (any(lengths(rows) != nrow(header))) {
      cli::cli_abort("Submission rows do not match the API header.")
    }
    # Pass the list's row vectors as separate arguments to rbind().
    rows <- do.call(rbind, rows)
  }
  # Apply the same final shape check whichever conversion branch was used.
  if (!is.matrix(rows) || ncol(rows) != nrow(header)) {
    cli::cli_abort("Submission rows do not match the API header.")
  }

  # Some columns have no field name; their display labels are the only key.
  # This local helper captures header and rows from the enclosing function.
  column <- function(field = NULL, label = NULL, required = FALSE) {
    # Prefer the technical field name; fall back to the display label.
    index <- which(header$feld_name %in% field)
    if (!length(index)) index <- which(header$label %in% label)
    # Multiple matches are ambiguous; zero matches fail only if required.
    if (length(index) > 1L || (required && !length(index))) {
      key <- if (is.null(field)) label else field
      cli::cli_abort("Missing or ambiguous submission API column: {.val {key}}.")
    }
    # Missing optional columns still need one missing value per result row.
    if (!length(index)) return(rep(NA_character_, nrow(rows)))
    # Trim surrounding whitespace and normalize blank strings to missing data.
    values <- trimws(as.character(rows[, index]))
    values[is.na(values) | !nzchar(values)] <- NA_character_
    values
  }

  # Verify every returned row's parent, rather than trusting the filters alone.
  parent_period <- column("BEZUG_GP_CODE", required = TRUE)
  parent_code <- column("BEZUG_ITYP", required = TRUE)
  parent_number <- suppressWarnings(as.integer(column("BEZUG_INR", required = TRUE)))
  if (anyNA(parent_period) || anyNA(parent_code) || anyNA(parent_number) ||
      any(parent_period != parent$legis_period) ||
      any(parent_code != parent$item_code) || any(parent_number != parent$number)) {
    cli::cli_abort("The submission API returned results for a different parent item.")
  }

  # Nr is a citation such as "624/SN-44/ME"; ITYP is a type such as "SNME".
  # Requiring a column above does not guarantee its individual values exist.
  submission_id <- column(label = "Nr", required = TRUE)
  submission_code <- column("ITYP", required = TRUE)
  if (anyNA(submission_id) || anyNA(submission_code)) {
    cli::cli_abort("The submission API returned missing submission identifiers.")
  }
  # "Von" contains an HTML link for public submissions, or plain text for
  # non-public entries. Preserve those rows without inventing names or links.
  by <- column(label = "Von", required = TRUE)
  links <- purrr::map(by, function(value) {
    if (is.na(value) || !grepl("<", value, fixed = TRUE)) {
      return(list(author = NA_character_, url = NA_character_))
    }
    # Parse the supplied snippet and select its first link with an href.
    # This does not fetch the linked page: both text and URL come from the HTML.
    anchor <- rvest::read_html(value) |> rvest::html_element("a[href]")
    list(author = rvest::html_text2(anchor), url = rvest::html_attr(anchor, "href"))
  })
  # Extract each list entry's author into one character vector.
  author <- purrr::map_chr(links, "author")
  # Remove only the exact citation suffix, preserving parentheses in names.
  # "Example (Association) (624/SN-44/ME)" becomes "Example (Association)".
  suffix <- paste0(" (", submission_id, ")")
  has_suffix <- !is.na(author) & endsWith(author, suffix)
  author[has_suffix] <- substr(
    author[has_suffix], 1, nchar(author[has_suffix]) - nchar(suffix[has_suffix])
  )
  # Collapse repeated whitespace, then turn any empty names into NA.
  author <- stringr::str_squish(author)
  author[!is.na(author) & !nzchar(author)] <- NA_character_

  # Assemble one row per submission. Each column() call returns a vector.
  tibble::tibble(
    legis_period = column("GP_CODE", required = TRUE),
    # Parse day-month-year dates; unparseable/missing dates become NA quietly.
    date = lubridate::dmy(column("DATUM"), quiet = TRUE),
    submission_id = submission_id,
    submission_code = submission_code,
    author = author,
    # Resolve published relative links; missing links remain NA.
    submission_url = .parlat_absolute_url(purrr::map_chr(links, "url")),
    # The Unicode escape spells the umlaut in the German supports label.
    support_n = as.numeric(column(label = "Unterst\u00fctzungen")),
    # "Zu" is the displayed parent reference, e.g. "44/ME".
    item_id = column(label = "Zu"),
    item_code = parent_code,
    # Repeat the canonical parent URL for each row in this page.
    item_url = rep(parent$item_url, nrow(rows))
  )
}
