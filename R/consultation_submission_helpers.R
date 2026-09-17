# Add content only after the complete search result has been validated.
# Called by get_consultation_submissions() when include_text = TRUE.
# Data flow:
#   search rows -> distinct published URLs -> one content list per URL
#   -> content lists aligned with the original rows -> three extra columns.
# The search metadata and row order are retained throughout this process.
.parlat_add_submission_text <- function(result, echo) {
  # Non-public submissions have no published URL. Do not request those pages
  # or construct URLs from internal identifiers. Deduplicate the remaining
  # URLs so repeated references share one fetch within this function call.
  urls <- unique(result$submission_url[!is.na(result$submission_url)])
  # map() runs sequentially and keeps its results in the same order as urls.
  # Each result is a named list of text, original HTML and a document tibble.
  details <- purrr::map(seq_along(urls), function(i) {
    # Report the first, every 25th and the final fetch without emitting a
    # message for every submission. echo = FALSE suppresses these messages.
    if (echo && (i == 1L || i %% 25L == 0L || i == length(urls))) {
      cli::cli_inform("Fetching submission content {i}/{length(urls)}...")
    }
    .parlat_submission_content(urls[[i]])
  })
  # Use the same typed placeholders for an unpublished submission as for a
  # published submission whose detail response contains no text or documents.
  empty <- .parlat_empty_submission_content()
  # match() maps each original row back to its entry in the unique URL list.
  # Repeated URLs reuse a result; missing URLs produce NA and use placeholders.
  # This restores row alignment without joining, sorting or expanding rows.
  rows <- purrr::map(match(result$submission_url, urls), function(i) {
    if (is.na(i)) empty else details[[i]]
  })
  # map_chr() produces ordinary character columns for the two text versions.
  # map() keeps document tibbles in a list-column: one submission may have
  # zero, one or several attachments, but still occupies exactly one row.
  # With no search results, these maps return character(0) and list(), so the
  # enriched zero-row result still has the documented column types.
  result$submission_text <- purrr::map_chr(rows, "submission_text")
  result$submission_html <- purrr::map_chr(rows, "submission_html")
  result$documents <- purrr::map(rows, "documents")
  result
}

# A shared empty value keeps missing content consistent across code paths.
# NA means no inline text was supplied; it does not mean the request failed.
# An empty document tibble retains column names/types for later row binding.
.parlat_empty_submission_content <- function() {
  list(
    submission_text = NA_character_,
    submission_html = NA_character_,
    documents = tibble::tibble(
      doc_title = character(), link = character(), type = character()
    )
  )
}

# Retrieve the content of one published submission, not its parent draft/bill.
# The API can provide inline text, attachments, both, or neither. Attachment
# links are returned as metadata; this helper never downloads their contents.
# Returns the same named-list structure as .parlat_empty_submission_content().
.parlat_submission_content <- function(url) {
  # Add the affected URL to any fetch, validation or parsing error. A failure
  # propagates to the caller rather than looking like a successful empty row.
  tryCatch(
    {
      # The shared fetcher requests ?json=TRUE, normalizes the supplied URL,
      # applies the package's user agent and retries retryable HTTP failures.
      # Fetch separately from parsing so HTTP failures retain their own cause.
      json_text <- .parlat_fetch_detail_json_text(url)
      # Keep JSON arrays as lists instead of simplifying them to matrices or
      # data frames. The shared document parser already supports list input.
      # The parsing helper wraps the response in `data`; `content` is the
      # item-specific portion of that decoded response.
      content <- json_text |>
        .parlat_parse_detail_json(simplifyVector = FALSE) |>
        (\(x) x$data$content)()
      # Extract period, object type and number from the requested page URL.
      # str_match() returns a matrix: column 1 is the entire match and columns
      # 2-4 are the three parenthesized captures. Ignore query/fragment text.
      parts <- stringr::str_match(
        sub("[?#].*$", "", url),
        "^https?://(?:www\\.)?parlament\\.gv\\.at/gegenstand/([A-Z]+)/([A-Z-]+)/([0-9]+)/?$"
      )
      # A successful HTTP response alone is insufficient: redirects or an
      # unexpected API response must not attach another item's text to a row.
      # Compare the response identifiers with those in the requested URL.
      # Convert the API number to character to match the URL capture's type.
      if (is.na(parts[1, 1]) || !is.list(content) ||
          !identical(content$gp_code, parts[1, 2]) ||
          !identical(content$ityp, parts[1, 3]) ||
          !identical(as.character(content$inr), parts[1, 4])) {
        cli::cli_abort("The detail response does not identify the requested submission.")
      }

      # Start with missing values; fill each content source independently.
      # In particular, a PDF-only submission legitimately has no inline text.
      result <- .parlat_empty_submission_content()
      # Exact lookup avoids matching the unrelated `statementsstate` field.
      # R's $ operator partially matches list names: content$statement could
      # otherwise return the participation status when `statement` is absent.
      html <- content[["statement"]]
      if (!is.null(html)) {
        # Missing/null is allowed, but an array or object here would indicate
        # a changed API shape. Fail explicitly instead of coercing it to text.
        checkmate::assert_string(html, na.ok = TRUE)
        # Blank or missing values retain the placeholders. Trim only to test
        # for emptiness; the original nonblank HTML is preserved unchanged.
        if (!is.na(html) && nzchar(trimws(html))) {
          result$submission_html <- html
          # Wrap plain text as HTML too, so read_html never treats it as a URL.
          # html_text2() removes markup, decodes entities such as &amp;, and
          # retains paragraph and <br> breaks in the readable text version.
          result$submission_text <- rvest::read_html(paste0("<div>", html, "</div>")) |>
            rvest::html_element("body") |>
            rvest::html_text2()
        }
      }
      # Parse attachments even when inline text exists: they are independent
      # sources of content. The shared parser keeps titles, links and formats.
      documents <- .parse_item_documents(content$documents)
      if (!is.null(documents) && nrow(documents) > 0L) {
        # Resolve relative links against the submission page. Already absolute
        # links remain unchanged, and all attachments stay in their API order.
        documents$link <- .parlat_absolute_url(documents$link, url)
        result$documents <- documents
      }
      result
    },
    error = function(e) {
      # Keep the original condition as the parent so callers can see both
      # which submission failed and the underlying HTTP or parsing problem.
      cli::cli_abort(
        "Could not retrieve submission content for {.url {url}}.",
        parent = e
      )
    }
  )
}
