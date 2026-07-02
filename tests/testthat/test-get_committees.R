test_that("get_committees returns valid data structure", {
  x <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 20
    )
  }, fixture_subdir = "get_committees")

  # Test basic structure
  expect_true(is.data.frame(x))

  if (!is.null(x) && nrow(x) > 0) {
    # Test expected columns exist
    expected_cols <- c("committee", "url_committee")
    expect_true(all(expected_cols %in% colnames(x)))

    # Test data types
    expect_true(is.character(x$committee))
    expect_true(is.character(x$url_committee))

    # Test URL format
    expect_true(all(grepl("^https://www.parlament.gv.at", x$url_committee)))
  }
})

test_that("get_committees validates parameters correctly", {
  # Missing institution
  expect_error(
    get_committees(legis_period = 27),
    "not empty"
  )

  # Invalid institution
  expect_error(
    get_committees(institution = "INVALID", legis_period = 27),
    "Must be a subset of"
  )

  # Missing legis_period
  expect_error(
    get_committees(institution = "NR")
  )

  # Multiple legis_period values
  expect_error(
    get_committees(institution = "NR", legis_period = c(26, 27)),
    "Function allows only for one single legislative period"
  )

  # Invalid legis_period type (not numeric or character)
  expect_error(
    get_committees(institution = "NR", legis_period = TRUE)
  )

  # Invalid search_string
  expect_error(
    get_committees(
      institution = "NR",
      legis_period = 27,
      search_string = c("a", "b")
    ),
    "Must have length 1"
  )

  # Invalid echo parameter
  expect_error(
    get_committees(institution = "NR", legis_period = 27, echo = "invalid"),
    "Must be of type 'logical'"
  )
})

test_that("get_committees parameter combination validation works", {
  # permanent = TRUE with include_subcommittees = TRUE should fail
  expect_error(
    get_committees(
      institution = "NR",
      legis_period = 27,
      permanent = TRUE,
      include_subcommittees = TRUE
    ),
    "Searching for subcommittees is only possible if `permanent` is not TRUE"
  )
})

test_that("get_committees warns for legislative periods before 20", {
  # Test period 19 triggers warning and returns a zero-row tibble
  expect_warning(
    result <- get_committees(
      institution = "NR",
      legis_period = 19
    ),
    "Data only available from legislative period 20 onwards"
  )

  # Should return a typed zero-row tibble for periods before 20
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_named(result, c("committee", "url_committee", "id_number", "citation"))

  # Test with period 1 as well
  expect_warning(
    result2 <- get_committees(
      institution = "NR",
      legis_period = 1
    ),
    "Data only available from legislative period 20 onwards"
  )
  expect_s3_class(result2, "tbl_df")
  expect_equal(nrow(result2), 0)

  # Test with Roman numeral input
  expect_warning(
    result3 <- get_committees(
      institution = "NR",
      legis_period = "XIX"
    ),
    "Data only available from legislative period 20 onwards"
  )
  expect_s3_class(result3, "tbl_df")
  expect_equal(nrow(result3), 0)
})

test_that("get_committees works with different institutions", {
  institutions <- c("NR", "BR")

  for (inst in institutions) {
    x <- run_api_call({
      get_committees(
        institution = inst,
        legis_period = 27
      )
    }, fixture_subdir = "get_committees")

    expect_true(
      is.data.frame(x) || is.null(x),
      info = paste("Failed for institution:", inst)
    )
  }
})

test_that("get_committees works with different parameter combinations", {
  # Test permanent = TRUE
  x1 <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27,
      permanent = TRUE
    )
  }, fixture_subdir = "get_committees")
  expect_true(is.data.frame(x1) || is.null(x1))

  # Test permanent = FALSE
  x2 <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27,
      permanent = FALSE
    )
  }, fixture_subdir = "get_committees")
  expect_true(is.data.frame(x2) || is.null(x2))

  # Test include_subcommittees = TRUE (only when permanent != TRUE)
  x3 <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27,
      include_subcommittees = TRUE
    )
  }, fixture_subdir = "get_committees")
  expect_true(is.data.frame(x3) || is.null(x3))
})

test_that("get_committees with search_string works", {
  x <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27,
      search_string = "Umwelt"
    )
  }, fixture_subdir = "get_committees")

  expect_true(is.data.frame(x) || is.null(x))
})

test_that("get_committees handles empty results gracefully", {
  # Try a search that's likely to return no results
  x <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27,
      search_string = "ThisShouldNotExistAnywhere12345"
    )
  }, fixture_subdir = "get_committees")

  # Should return a typed zero-row tibble for no results
  expect_s3_class(x, "tbl_df")
  expect_equal(nrow(x), 0)
  expect_named(x, c("committee", "url_committee", "id_number", "citation"))
})

test_that("get_committees works with different legis_period types", {
  # Test numeric
  x1 <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27
    )
  }, fixture_subdir = "get_committees")
  expect_true(is.data.frame(x1))

  # Test character
  x2 <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = "27"
    )
  }, fixture_subdir = "get_committees")
  expect_true(is.data.frame(x2))
})

test_that("get_committees returns identical results for different legis_period formats", {
  # Get results with numeric input
  result_numeric <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27
    )
  }, fixture_subdir = "get_committees")

  # Get results with character numeric input
  result_character <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = "27"
    )
  }, fixture_subdir = "get_committees")

  # Get results with Roman numeral input
  result_roman <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = "XXVII"
    )
  }, fixture_subdir = "get_committees")

  # All three should produce data frames
  expect_true(is.data.frame(result_numeric))
  expect_true(is.data.frame(result_character))
  expect_true(is.data.frame(result_roman))

  # All should have the same number of rows
  expect_equal(nrow(result_numeric), nrow(result_character))
  expect_equal(nrow(result_numeric), nrow(result_roman))

  # All should have the same columns
  expect_equal(colnames(result_numeric), colnames(result_character))
  expect_equal(colnames(result_numeric), colnames(result_roman))

  # The actual data should be identical (ignoring row order)
  # Sort by committee name to ensure consistent ordering
  result_numeric_sorted <- result_numeric[order(result_numeric$committee), ]
  result_character_sorted <- result_character[
    order(result_character$committee),
  ]
  result_roman_sorted <- result_roman[order(result_roman$committee), ]

  # Reset row names for comparison
  rownames(result_numeric_sorted) <- NULL
  rownames(result_character_sorted) <- NULL
  rownames(result_roman_sorted) <- NULL

  # Compare the sorted data frames
  expect_equal(result_numeric_sorted, result_character_sorted)
  expect_equal(result_numeric_sorted, result_roman_sorted)
})

test_that("get_committees handles committees with empty documents", {
  skip_on_cran()

  # Test the specific case from legis_period 22 that had empty documents
  x <- run_api_call({
    get_committees(
      legis_period = 22,
      institution = "NR",
      details_type = "members",
      citation = "1/SA-BU"
    )
  }, fixture_subdir = "get_committees")

  expect_true(is.data.frame(x))

  if (!is.null(x) && nrow(x) > 0) {
    # Should have url_pdf and url_html columns even if they're NA
    expect_true("url_pdf" %in% colnames(x))
    expect_true("url_html" %in% colnames(x))
    expect_true("members" %in% colnames(x))
  }
})

test_that("get_committees with details_type='members' has no unexpected list-columns", {
  skip_on_cran()
  # This is a comprehensive integration test - run only in live mode
  skip_if_mocked("Complex integration test across multiple periods")

  # Fetch committee membership data across multiple legislative periods
  all_members <- seq(20, 28, 1) |>
    purrr::map(\(x) {
      get_committees(
        legis_period = x,
        institution = "NR",
        details_type = "members",
        echo = FALSE
      )
    })

  # Check each result
  all_members |>
    purrr::iwalk(\(result, idx) {
      if (!is.null(result) && nrow(result) > 0) {
        # Get column types using map
        col_types <- result |>
          purrr::map(class)

        # Find list-columns (columns where class contains "list" or "data.frame")
        list_cols <- col_types |>
          purrr::keep(\(x) "list" %in% x | "data.frame" %in% x) |>
          names()

        # Only "members" should be a list-column
        expect_true(
          all(list_cols == "members") || length(list_cols) == 0,
          info = paste(
            "Unexpected list-columns found in legis_period",
            19 + idx,
            ":",
            paste(setdiff(list_cols, "members"), collapse = ", ")
          )
        )

        # If members column exists, it should be a list
        if ("members" %in% colnames(result)) {
          expect_true(
            "list" %in% class(result$members),
            info = paste(
              "members column should be a list in legis_period",
              19 + idx
            )
          )
        }
      }
    })
})
