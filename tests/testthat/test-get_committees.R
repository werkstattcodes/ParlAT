test_that("get_committees returns valid data structure", {
  skip_on_cran()
  skip_if_offline()

  x <- get_committees(
    institution = "NR",
    legis_period = 27
  )

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
    get_committees(institution = "NR"),
    'argument "legis_period" is missing'
  )

  # Multiple legis_period values
  expect_error(
    get_committees(institution = "NR", legis_period = c(26, 27)),
    "legis_period must be of length 1"
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

  # Invalid details parameter
  expect_error(
    get_committees(institution = "NR", legis_period = 27, details = "invalid"),
    "Must be of type 'logical'"
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

test_that("get_committees works with different institutions", {
  skip_on_cran()
  skip_if_offline()

  institutions <- c("NR", "BR")

  for (inst in institutions) {
    x <- get_committees(
      institution = inst,
      legis_period = 27
    )

    expect_true(
      is.data.frame(x) || is.null(x),
      info = paste("Failed for institution:", inst)
    )
  }
})

test_that("get_committees works with different parameter combinations", {
  skip_on_cran()
  skip_if_offline()

  # Test permanent = TRUE
  x1 <- get_committees(
    institution = "NR",
    legis_period = 27,
    permanent = TRUE
  )
  expect_true(is.data.frame(x1) || is.null(x1))

  # Test permanent = FALSE
  x2 <- get_committees(
    institution = "NR",
    legis_period = 27,
    permanent = FALSE
  )
  expect_true(is.data.frame(x2) || is.null(x2))

  # Test include_subcommittees = TRUE (only when permanent != TRUE)
  x3 <- get_committees(
    institution = "NR",
    legis_period = 27,
    include_subcommittees = TRUE
  )
  expect_true(is.data.frame(x3) || is.null(x3))
})

test_that("get_committees with search_string works", {
  skip_on_cran()
  skip_if_offline()

  x <- get_committees(
    institution = "NR",
    legis_period = 27,
    search_string = "Umwelt"
  )

  expect_true(is.data.frame(x) || is.null(x))
})

test_that("get_committees with details = TRUE works", {
  skip_on_cran()
  skip_if_offline()

  x <- get_committees(
    institution = "NR",
    legis_period = 27,
    details = TRUE
  )

  expect_true(is.data.frame(x))

  if (!is.null(x) && nrow(x) > 0) {
    # Should have additional detail columns
    detail_cols <- c(
      "legis_period",
      "title", 
      "citation",
      "committee_id",
      "date_start",
      "date_end"
    )
    expect_true(any(detail_cols %in% colnames(x)))
    
    # legis_period should be the first column when details = TRUE
    expect_equal(colnames(x)[1], "legis_period")
  }
})

test_that("get_committees handles empty results gracefully", {
  skip_on_cran()
  skip_if_offline()

  # Try a search that's likely to return no results
  x <- get_committees(
    institution = "NR",
    legis_period = 27,
    search_string = "ThisShouldNotExistAnywhere12345"
  )

  # Should return NULL for no results
  expect_true(is.null(x))
})

test_that("get_committees works with different legis_period types", {
  skip_on_cran()
  skip_if_offline()

  # Test numeric
  x1 <- get_committees(
    institution = "NR",
    legis_period = 27
  )
  expect_true(is.data.frame(x1))

  # Test character
  x2 <- get_committees(
    institution = "NR",
    legis_period = "27"
  )
  expect_true(is.data.frame(x2))
})

test_that("get_committee_details handles errors gracefully", {
  # Test with invalid URL
  expect_warning(
    result <- get_committee_details("https://invalid.url.com/test"),
    "Failed to fetch committee details"
  )

  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0)
})
