# Tests for get_item_details() -----------------------------------------------

test_that("get_item_details returns correct structure with absolute URL", {
  # Use a known item URL
  item_url <- "https://www.parlament.gv.at/gegenstand/XXVII/GAST/2"
  result <- run_api_call(
    {
      get_item_details(item_url)
    },
    fixture_subdir = "get_item_details"
  )

  expect_s3_class(result, "data.frame")
  expect_true(ncol(result) > 0)
  expect_true(nrow(result) > 0)
})

test_that("get_item_details works with relative URL", {
  # Test relative path normalization
  result <- run_api_call(
    {
      get_item_details("/gegenstand/XXVIII/BI/24")
    },
    fixture_subdir = "get_item_details"
  )

  expect_s3_class(result, "data.frame")
  expect_true(ncol(result) > 0)
})


test_that("get_item_details handles URL normalization correctly", {
  # Test that absolute and relative URLs return the same data
  absolute_url <- "https://www.parlament.gv.at/gegenstand/XXVIII/BI/24"
  relative_url <- "/gegenstand/XXVIII/BI/24"
  relative_no_slash <- "gegenstand/XXVIII/BI/24"

  result_absolute <- run_api_call(
    {
      get_item_details(absolute_url)
    },
    fixture_subdir = "get_item_details"
  )
  result_relative <- run_api_call(
    {
      get_item_details(relative_url)
    },
    fixture_subdir = "get_item_details"
  )
  result_no_slash <- run_api_call(
    {
      get_item_details(relative_no_slash)
    },
    fixture_subdir = "get_item_details"
  )

  # All should return same number of rows
  expect_equal(nrow(result_absolute), nrow(result_relative))
  expect_equal(nrow(result_absolute), nrow(result_no_slash))
})

# Tests for speech extraction in get_item_details() --------------------------
# NOTE: get_item_details() uses rvest::read_html() (libcurl), which httptest2
# does NOT intercept. All tests below hit the live API and are skipped in
# offline/mocked CI runs.

test_that("get_item_details speeches column is a list", {
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVIII/A/5")

  expect_s3_class(result, "data.frame")
  expect_true("speeches" %in% names(result))
  expect_type(result$speeches, "list")
})

test_that("get_item_details stages without debate have NULL speeches", {
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVIII/A/5")

  # At least some stages should have no speeches
  expect_true(any(sapply(result$speeches, is.null)))
})

test_that("get_item_details speeches tibble has correct columns", {
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVIII/A/5")

  non_null_speeches <- result$speeches[!sapply(result$speeches, is.null)]
  expect_true(length(non_null_speeches) > 0)

  speeches_tbl <- non_null_speeches[[1]]
  expect_s3_class(speeches_tbl, "data.frame")
  expect_true(all(
    c("speaker", "speaker_url", "position", "protocol_page", "protocol_url", "video_url") %in%
      names(speeches_tbl)
  ))
})

test_that("get_item_details protocol_url inside speeches is a list column", {
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVIII/A/5")

  non_null_speeches <- result$speeches[!sapply(result$speeches, is.null)]
  speeches_tbl <- non_null_speeches[[1]]

  expect_type(speeches_tbl$protocol_url, "list")
})

test_that("get_item_details captures both URLs for a split speech (Hafenecker, XXVIII/A/5)", {
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVIII/A/5")

  # Collect all speeches rows across all stages
  all_speeches <- dplyr::bind_rows(
    result$speeches[!sapply(result$speeches, is.null)]
  )

  hafenecker <- all_speeches[grepl("Hafenecker", all_speeches$speaker, fixed = FALSE), ]
  expect_true(nrow(hafenecker) > 0, label = "Hafenecker row found")

  # The split-speech row must carry exactly 2 protocol URLs
  split_row <- hafenecker[sapply(hafenecker$protocol_url, length) == 2, ]
  expect_true(nrow(split_row) == 1, label = "Exactly one split-speech row for Hafenecker")

  # The text field should mention both protocol pages
  expect_true(grepl("RN/70", split_row$protocol_page, fixed = TRUE))
  expect_true(grepl("RN/72", split_row$protocol_page, fixed = TRUE))

  # Both URLs should be absolute parlament.gv.at links
  urls <- split_row$protocol_url[[1]]
  expect_true(all(grepl("^https://www.parlament.gv.at", urls)))
})

test_that("get_item_details protocol_url entries are never length-0 (NA_character_ fallback)", {
  # extract_hrefs() must return NA_character_ (length 1), not character(0),
  # when a cell contains no <a> tag, so that is.na() works uniformly downstream.
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVIII/A/5")

  all_speeches <- dplyr::bind_rows(
    result$speeches[!sapply(result$speeches, is.null)]
  )

  url_lengths <- sapply(all_speeches$protocol_url, length)
  expect_true(
    all(url_lengths >= 1L),
    label = "every protocol_url element has length >= 1 (NA_character_ not character(0))"
  )
})

test_that("get_item_details speaker_url and video_url are scalar character columns", {
  # These columns use map_chr (not map), so they must remain character vectors,
  # not list columns — documents the intentional type asymmetry with protocol_url.
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVIII/A/5")

  all_speeches <- dplyr::bind_rows(
    result$speeches[!sapply(result$speeches, is.null)]
  )

  expect_type(all_speeches$speaker_url, "character")
  expect_type(all_speeches$video_url,   "character")
})

test_that("get_item_details speeches list has one entry per stage row", {
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVIII/A/5")

  expect_equal(length(result$speeches), nrow(result))
  # Every element is either NULL or a data.frame
  expect_true(all(sapply(result$speeches, function(x) is.null(x) || is.data.frame(x))))
})

test_that("get_item_details has no speeches column for item with no floor debate (BI)", {
  # BI (Bürgerinitiative) items are submitted to committee but not floor-debated.
  # The API returns no reden field, so get_item_details() produces no speeches column.
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVIII/BI/24")

  expect_s3_class(result, "data.frame")
  expect_false("speeches" %in% names(result))
})

# Tests for get_item_details() new metadata fields ----------------------------

test_that("get_item_details includes new item-level metadata fields", {
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVII/UEA/283")

  # Scalar fields
  expect_true("date_introduced" %in% names(result))
  expect_s3_class(result$date_introduced, "Date")
  expect_true("gp_code" %in% names(result))
  expect_equal(result$gp_code[1], "XXVII")
  expect_true("status_number" %in% names(result))
  expect_true("status_description" %in% names(result))

  # List-column fields
  expect_type(result$item_documents, "list")
  expect_type(result$introducers, "list")
  expect_type(result$references, "list")
  expect_type(result$topics, "list")
  expect_type(result$headwords, "list")
  expect_type(result$eurovoc, "list")

  # All rows replicate the same item-level metadata
  expect_true(length(unique(result$gp_code)) == 1)
  expect_true(length(unique(result$date_introduced)) == 1)
})

test_that("get_item_details introducers tibble has expected columns", {
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVII/UEA/283")
  intro <- result$introducers[[1]]

  expect_s3_class(intro, "data.frame")
  expect_true(all(c("role", "name", "frak_code", "url") %in% names(intro)))
})

test_that("get_item_details references tibble has expected columns", {
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVII/UEA/283")
  refs <- result$references[[1]]

  expect_s3_class(refs, "data.frame")
  expect_true(all(c("text", "subject", "zitation", "url", "art") %in% names(refs)))
})

test_that("get_item_details handles items with missing optional fields", {
  skip_if_mocked("get_item_details uses rvest, not intercepted by httptest2")
  skip_on_cran()

  result <- get_item_details("/gegenstand/XXVIII/BI/24")
  expect_s3_class(result, "data.frame")
  expect_true("date_introduced" %in% names(result))
  expect_true("gp_code" %in% names(result))
})
