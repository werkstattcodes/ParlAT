# Tests for get_item_details() -----------------------------------------------

test_that("get_item_details returns expected structure for an absolute URL", {
  result <- run_api_call(
    get_item_details("https://www.parlament.gv.at/gegenstand/XXVII/GAST/2"),
    fixture_subdir = "get_item_details"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(c("item_url", "type", "title", "stage_name") %in% names(result)))
})

test_that("get_item_details normalizes relative URLs consistently", {
  absolute_url <- "https://www.parlament.gv.at/gegenstand/XXVIII/BI/24"

  result_absolute <- run_api_call(
    get_item_details(absolute_url),
    fixture_subdir = "get_item_details"
  )
  result_relative <- run_api_call(
    get_item_details("/gegenstand/XXVIII/BI/24"),
    fixture_subdir = "get_item_details"
  )
  result_no_slash <- run_api_call(
    get_item_details("gegenstand/XXVIII/BI/24"),
    fixture_subdir = "get_item_details"
  )

  expect_equal(result_absolute, result_relative)
  expect_equal(result_absolute, result_no_slash)
})

test_that("get_item_details includes stable item-level metadata fields", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVII/UEA/283"),
    fixture_subdir = "get_item_details"
  )

  expect_true(all(c(
    "date_introduced",
    "gp_code",
    "status_number",
    "status_description",
    "item_documents",
    "introducers",
    "references",
    "topics",
    "headwords",
    "eurovoc"
  ) %in% names(result)))
  expect_s3_class(result$date_introduced, "Date")
  expect_type(result$item_documents, "list")
  expect_type(result$introducers, "list")
  expect_type(result$references, "list")
  expect_type(result$topics, "list")
  expect_type(result$headwords, "list")
  expect_type(result$eurovoc, "list")
  expect_equal(length(unique(result$gp_code)), 1)
  expect_equal(length(unique(result$date_introduced)), 1)
})

test_that("get_item_details nested item metadata keeps expected columns", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVII/UEA/283"),
    fixture_subdir = "get_item_details"
  )

  intro <- result$introducers[[1]]
  refs <- result$references[[1]]

  expect_s3_class(intro, "data.frame")
  expect_s3_class(refs, "data.frame")
  expect_true(all(c("role", "name", "frak_code", "url") %in% names(intro)))
  expect_true(all(c("text", "subject", "zitation", "url", "art") %in% names(refs)))
})

test_that("get_item_details speech extraction preserves list-column structure", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/A/5"),
    fixture_subdir = "get_item_details"
  )

  expect_true("speeches" %in% names(result))
  expect_type(result$speeches, "list")
  expect_equal(length(result$speeches), nrow(result))
  expect_true(all(vapply(result$speeches, \(x) is.null(x) || is.data.frame(x), logical(1))))
  expect_true(any(vapply(result$speeches, is.null, logical(1))))
})

test_that("get_item_details nested speech tibbles keep expected columns and types", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/A/5"),
    fixture_subdir = "get_item_details"
  )

  speeches_tbl <- result$speeches[!vapply(result$speeches, is.null, logical(1))][[1]]

  expect_s3_class(speeches_tbl, "data.frame")
  expect_true(all(c(
    "speaker",
    "speaker_url",
    "position",
    "protocol_page",
    "protocol_url",
    "video_url"
  ) %in% names(speeches_tbl)))
  expect_type(speeches_tbl$protocol_url, "list")
  expect_type(speeches_tbl$speaker_url, "character")
  expect_type(speeches_tbl$video_url, "character")
})

test_that("get_item_details keeps split protocol links together for a single speech", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/A/5"),
    fixture_subdir = "get_item_details"
  )

  all_speeches <- dplyr::bind_rows(result$speeches[!vapply(result$speeches, is.null, logical(1))])
  hafenecker <- all_speeches[grepl("Hafenecker", all_speeches$speaker), ]
  split_row <- hafenecker[vapply(hafenecker$protocol_url, length, integer(1)) == 2L, ]

  expect_true(nrow(hafenecker) > 0)
  expect_equal(nrow(split_row), 1)
  expect_match(split_row$protocol_page, "RN/70", fixed = TRUE)
  expect_match(split_row$protocol_page, "RN/72", fixed = TRUE)
  expect_true(all(grepl("^https://www.parlament.gv.at", split_row$protocol_url[[1]])))
})

test_that("get_item_details uses NA_character_ instead of empty protocol_url vectors", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/A/5"),
    fixture_subdir = "get_item_details"
  )

  all_speeches <- dplyr::bind_rows(result$speeches[!vapply(result$speeches, is.null, logical(1))])
  url_lengths <- vapply(all_speeches$protocol_url, length, integer(1))

  expect_true(all(url_lengths >= 1L))
})

test_that("get_item_details handles items with missing optional debate fields", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/BI/24"),
    fixture_subdir = "get_item_details"
  )

  expect_s3_class(result, "data.frame")
  expect_true(all(c("date_introduced", "gp_code") %in% names(result)))
  expect_false("speeches" %in% names(result))
})
