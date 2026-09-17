# Small synthetic responses exercise API shape changes independently of fixtures.
submission_test_response <- function() {
  list(
    count = 2L, pages = 1L,
    header = data.frame(
      feld_name = c("GP_CODE", "ITYP", "DATUM", "BEZUG_GP_CODE",
                    "BEZUG_INR", "BEZUG_ITYP", rep(NA_character_, 5)),
      label = c("?", "?", "Datum", "GP", "INR", "ITYP", "Von",
                "Unterst\u00fctzungen", "Nr", "Zu", "Bezug_Link"),
      rnr = 1:11
    ),
    rows = rbind(
      c("XXVIII", "SNME", "25.10.2025", "XXVIII", "44", "ME",
        '<a href="/gegenstand/XXVIII/SNME/2458/?x=a%2Fb&amp;y=2#details">Example (Association) (624/SN-44/ME)</a>',
        "12", "624/SN-44/ME", "44/ME", "/gegenstand/XXVIII/ME/44"),
      c("XXVIII", "SNME", "24.10.2025", "XXVIII", "44", "ME",
        "Nicht-\u00f6ffentliche Stellungnahme (623/SN-44/ME)",
        "", "623/SN-44/ME", "44/ME", "/gegenstand/XXVIII/ME/44")
    )
  )
}

test_that("parent URLs normalize to the same API identifiers", {
  expected <- .parlat_parse_submission_parent_url("/gegenstand/XXVIII/ME/44")
  for (url in c(
    "gegenstand/XXVIII/ME/44", " /gegenstand/XXVIII/ME/0044/ ",
    "https://www.parlament.gv.at/gegenstand/XXVIII/ME/44?tab=2#details",
    "http://parlament.gv.at/gegenstand/XXVIII/ME/44/"
  )) {
    expect_identical(.parlat_parse_submission_parent_url(url), expected)
  }
  expect_identical(.parlat_parse_submission_parent_url("/gegenstand/XXVIII/I/405")$item_code, "I")
  expect_identical(.parlat_parse_submission_parent_url("/gegenstand/XXVIII/A/5")$item_code, "A")
})

test_that("invalid inputs fail before any request is made", {
  local_mocked_bindings(.parlat_fetch_submission_page = function(...) {
    stop("Unexpected network call")
  })
  for (url in list(NULL, NA_character_, "", " ", character(), c("a", "b"), 44,
                   "https://example.org/gegenstand/XXVIII/ME/44",
                   "/gegenstand/XXVIII/SNME/2458", "/person/145",
                   "/gegenstand/invalid/ME/44", "/gegenstand/XXVIII/ME/0",
                   "/gegenstand/XXVIII/ME/999999999999")) {
    expect_error(get_consultation_submissions(url), "item_url")
  }
  for (echo in list(NA, NULL, 1, c(TRUE, FALSE))) {
    expect_error(get_consultation_submissions("/gegenstand/XXVIII/ME/44", echo), "echo")
  }
})

test_that("submission metadata preserves names and only uses published links", {
  result <- .parlat_parse_submissions(
    submission_test_response(), .parlat_parse_submission_parent_url("/gegenstand/XXVIII/ME/44")
  )
  expect_s3_class(result, "tbl_df")
  expect_false(dplyr::is_grouped_df(result))
  expect_identical(names(result), names(.parlat_empty_submissions()))
  expect_false(any(vapply(result, is.list, logical(1))))
  expect_identical(result$author, c("Example (Association)", NA_character_))
  expect_identical(result$submission_url, c(
    "https://www.parlament.gv.at/gegenstand/XXVIII/SNME/2458/?x=a%2Fb&y=2#details",
    NA_character_
  ))
  expect_identical(result$support_n, c(12, NA_real_))
  expect_identical(result$date, as.Date(c("2025-10-25", "2025-10-24")))
  expect_true(all(result$item_url == "https://www.parlament.gv.at/gegenstand/XXVIII/ME/44"))
})

test_that("parsing handles reordered fields and missing optional values", {
  parent <- .parlat_parse_submission_parent_url("/gegenstand/XXVIII/ME/44")
  original <- submission_test_response()
  expected <- .parlat_parse_submissions(original, parent)
  response <- original
  order <- rev(seq_len(nrow(response$header)))
  response$header <- response$header[order, ]
  expect_identical(.parlat_parse_submissions(response, parent), expected)
  response$header$rnr <- seq_along(order)
  response$rows <- response$rows[, order]
  expect_identical(.parlat_parse_submissions(response, parent), expected)

  response <- original
  keep <- !response$header$label %in% c("Datum", "Unterst\u00fctzungen", "Zu")
  response$header <- response$header[keep, ]
  response$rows <- response$rows[, keep]
  parsed <- .parlat_parse_submissions(response, parent)
  expect_identical(parsed$date, as.Date(c(NA, NA)))
  expect_identical(parsed$support_n, c(NA_real_, NA_real_))
  expect_identical(parsed$item_id, c(NA_character_, NA_character_))
})

test_that("single rows and list-shaped rows retain the same schema", {
  response <- submission_test_response()
  parent <- .parlat_parse_submission_parent_url("/gegenstand/XXVIII/ME/44")
  expected <- .parlat_parse_submissions(response, parent)
  response$rows <- response$rows[1, ]
  expect_identical(.parlat_parse_submissions(response, parent), expected[1, ])
  response <- submission_test_response()
  response$rows <- lapply(seq_len(nrow(response$rows)), function(i) {
    as.list(response$rows[i, ])
  })
  response$rows[[2]][8] <- list(NULL)
  expect_identical(.parlat_parse_submissions(response, parent), expected)
})

test_that("malformed responses and unrelated parent rows are not silently accepted", {
  parent <- .parlat_parse_submission_parent_url("/gegenstand/XXVIII/ME/44")
  response <- submission_test_response()
  response$rows[1, 5] <- "45"
  expect_error(.parlat_parse_submissions(response, parent), "different parent")
  response <- submission_test_response()
  response$header$label[9] <- "unknown"
  expect_error(.parlat_parse_submissions(response, parent), "Missing or ambiguous")
  response <- submission_test_response()
  response$rows <- response$rows[, -1]
  expect_error(.parlat_parse_submissions(response, parent), "do not match")
  response <- submission_test_response()
  response$rows[1, 9] <- NA_character_
  expect_error(.parlat_parse_submissions(response, parent), "missing submission identifiers")
})

test_that("empty results retain the documented types and echo can be silenced", {
  local_mocked_bindings(.parlat_fetch_submission_page = function(...) {
    list(count = 0L, pages = 0L, rows = list())
  })
  expect_silent(result <- get_consultation_submissions("/gegenstand/XXVIII/ME/44", echo = FALSE))
  expect_identical(result, .parlat_empty_submissions())
  expect_message(get_consultation_submissions("/gegenstand/XXVIII/ME/44"), "Parliament website")
})

test_that("pagination retrieves each page once and combines a complete result", {
  requested <- integer()
  local_mocked_bindings(.parlat_fetch_submission_page = function(request, page) {
    requested <<- c(requested, page)
    response <- submission_test_response()
    response$pages <- 2L
    response$rows <- response$rows[page, , drop = FALSE]
    response
  })
  result <- get_consultation_submissions("/gegenstand/XXVIII/ME/44", echo = FALSE)
  expect_equal(requested, c(1, 2))
  expect_identical(result$submission_id, c("624/SN-44/ME", "623/SN-44/ME"))
})

test_that("failed, repeated, truncated or changing pages cannot look complete", {
  for (problem in c("failure", "repeated", "truncated", "changed", "metadata")) {
    local_mocked_bindings(.parlat_fetch_submission_page = function(request, page) {
      response <- submission_test_response()
      response$pages <- 2L
      response$rows <- response$rows[1, , drop = FALSE]
      if (problem == "metadata") response$count <- NULL
      if (page == 2) {
        if (problem == "failure") stop("HTTP page failure")
        if (problem == "truncated") response$rows <- list()
        if (problem == "changed") response$count <- 3L
      }
      response
    })
    expect_error(get_consultation_submissions("/gegenstand/XXVIII/ME/44", echo = FALSE))
  }
})

test_that("recorded ministerial draft submissions include every page", {
  result <- run_api_call(
    get_consultation_submissions("/gegenstand/XXVIII/ME/44", echo = FALSE),
    "get_consultation_submissions"
  )
  expect_gt(nrow(result), 100)
  expect_identical(anyDuplicated(result$submission_id), 0L)
  expect_true(all(result$item_code == "ME"))
  expect_true(all(result$submission_code == "SNME"))
  expect_true(all(result$item_id == "44/ME"))
  expect_type(result$support_n, "double")
  expect_s3_class(result$date, "Date")
  expect_match(stats::na.omit(result$submission_url), "^https://www\\.parlament\\.gv\\.at/", all = TRUE)
})

test_that("government bills use their I object code and retain non-public submissions", {
  result <- run_api_call(
    get_consultation_submissions("https://www.parlament.gv.at/gegenstand/XXVIII/I/405/?tab=2#details", echo = FALSE),
    "get_consultation_submissions"
  )
  expect_gt(nrow(result), 0)
  expect_true(all(result$item_code == "I"))
  expect_true(all(result$submission_code == "SN"))
  expect_true(any(is.na(result$submission_url)))
  expect_true(all(is.na(result$author[is.na(result$submission_url)])))
})

test_that("motions without submissions return a typed empty tibble", {
  result <- run_api_call(
    get_consultation_submissions("/gegenstand/XXVIII/A/5", echo = FALSE),
    "get_consultation_submissions"
  )
  if (!.parlat_live_api()) expect_identical(result, .parlat_empty_submissions())
  expect_identical(names(result), names(.parlat_empty_submissions()))
})

test_that("motions with submissions use the A parent code", {
  result <- run_api_call(
    get_consultation_submissions("/gegenstand/XXVIII/A/865", echo = FALSE),
    "get_consultation_submissions"
  )
  expect_gt(nrow(result), 0)
  expect_true(all(result$item_code == "A"))
  expect_true(all(result$submission_code == "SN"))
  expect_true(all(result$item_id == "865/A"))
})

test_that("include_text is opt-in and retains unpublished rows", {
  fetched <- character()
  local_mocked_bindings(
    .parlat_fetch_submission_page = function(...) submission_test_response(),
    .parlat_submission_content = function(url) {
      fetched <<- c(fetched, url)
      result <- .parlat_empty_submission_content()
      result$submission_text <- "Submission text"
      result
    }
  )
  plain <- get_consultation_submissions("/gegenstand/XXVIII/ME/44", FALSE)
  expect_identical(fetched, character())
  expect_silent(enriched <- get_consultation_submissions(
    "/gegenstand/XXVIII/ME/44", echo = FALSE, include_text = TRUE
  ))
  expect_identical(enriched[names(plain)], plain)
  expect_identical(fetched, plain$submission_url[1])
  expect_identical(enriched$submission_text, c("Submission text", NA_character_))
})

test_that("include_text validates inputs and extends empty results", {
  local_mocked_bindings(.parlat_fetch_submission_page = function(...) {
    list(count = 0L, pages = 0L, rows = list())
  })
  expect_snapshot(error = TRUE, get_consultation_submissions(
    "/gegenstand/XXVIII/ME/44", include_text = NA
  ))
  result <- get_consultation_submissions(
    "/gegenstand/XXVIII/ME/44", echo = FALSE, include_text = TRUE
  )
  expect_identical(result$submission_text, character())
  expect_identical(result$submission_html, character())
  expect_identical(result$documents, list())
})
