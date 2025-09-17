test_that("get_items returns correct structure with valid parameters", {
  skip_on_cran()
  skip_if_offline()

  # Test basic functionality with minimal parameters
  result <- get_items(
    institution = "NR",
    item = "ANTR",
    date_start = "01-01-2024",
    date_end = "31-01-2024",
    echo = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true(ncol(result) > 0)
})

test_that("get_items handles invalid date formats", {
  expect_error(
    get_items(date_start = "2025-01-01"),
    "date_start must be in format dd-mm-yyyy"
  )

  expect_error(
    get_items(date_end = "2025/01/01"),
    "date_end must be in format dd-mm-yyyy"
  )
})

test_that("get_items validates institution parameter", {
  expect_error(
    get_items(institution = "INVALID"),
    "Must be a subset of"
  )
})

test_that("get_items validates topic parameter", {
  expect_error(
    get_items(topic = "Invalid Topic"),
    "Must be a subset of"
  )
})

test_that("get_items validates item parameter", {
  expect_error(
    get_items(item = "INVALID"),
    "Must be a subset of"
  )
})

test_that("get_items validates parl_group parameter", {
  expect_error(
    get_items(parl_group = "INVALID"),
    "Must be a subset of"
  )
})

test_that("get_items handles empty results gracefully", {
  skip_on_cran()
  skip_if_offline()

  # Use parameters likely to return no results
  result <- get_items(
    topic = "Wirtschaft",
    date_start = "01-01-1900",
    date_end = "02-01-1900",
    echo = FALSE
  )

  expect_null(result)
})

test_that("get_items works with multiple parameters", {
  skip_on_cran()
  skip_if_offline()

  result <- get_items(
    institution = "NR",
    topic = "Bildung",
    legis_period = "27",
    echo = FALSE
  )

  expect_true(is.data.frame(result) || is.null(result))
  if (!is.null(result)) {
    expect_true(ncol(result) > 0)
  }
})

test_that("get_items works with multiple topics", {
  skip_on_cran()
  skip_if_offline()

  result <- get_items(
    institution = "NR",
    topic = c("Sport", "Landesverteidigung"),
    legis_period = "27"
  )

  expect_true(nrow(result) == 2012)
})

test_that("get_items works with multiple legis_periods and different input forms", {
  skip_on_cran()
  skip_if_offline()

  # Test with mixed input forms: numeric, character numeric, and historical abbreviations
  result <- get_items(
    legis_period = c("KN", "PN", 10, "15"),
    echo = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 11212)
  
  # Check that all expected legislative periods are present in the results
  expected_periods <- c("KN", "PN", "X", "XV")
  actual_periods <- unique(result$legis_period)
  expect_true(all(expected_periods %in% actual_periods))
})

test_that("get_items validates doc_type for ANTR items in NR", {
  expect_error(
    get_items(item = "ANTR", doc_type = "INVALID", institution = "NR"),
    "Must be a subset of"
  )
})

test_that("get_items validates doc_type for ANTR items in BR", {
  expect_error(
    get_items(item = "ANTR", doc_type = "INVALID", institution = "BR"),
    "Must be a subset of"
  )
})

test_that("get_items validates doc_type for BNR items", {
  expect_error(
    get_items(item = "BNR", doc_type = "INVALID", institution = "NR"),
    "Must be a subset of"
  )
})

test_that("get_items validates doc_type without item", {
  expect_error(
    get_items(doc_type = "A"),
    "'doc_type' can be only specified in combination with 'item'"
  )
})

test_that("get_items validates number parameter", {
  expect_error(
    get_items(number = c("123", "456")),
    "Must have length 1"
  )
  
  expect_error(
    get_items(number = 123),
    "Must be of type 'character'"
  )
})

test_that("get_items validates keyword parameter", {
  expect_error(
    get_items(keyword = "Invalid Keyword"),
    "Must be a subset of"
  )
})

test_that("get_items validates eurovoc parameter", {
  expect_error(
    get_items(eurovoc = 123),
    "Must be of type 'character'"
  )
})

test_that("get_items works with NULL institution (both chambers)", {
  skip_on_cran()
  skip_if_offline()
  
  result <- get_items(
    item = "RV", 
    legis_period = "27",
    echo = FALSE
  )
  
  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items works with search_string parameter", {
  skip_on_cran()
  skip_if_offline()
  
  result <- get_items(
    search_string = "Gesundheit",
    legis_period = "27",
    echo = FALSE
  )
  
  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items works with number parameter", {
  skip_on_cran()
  skip_if_offline()
  
  result <- get_items(
    number = "1",
    legis_period = "27",
    echo = FALSE
  )
  
  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items works with valid keyword", {
  skip_on_cran()
  skip_if_offline()
  
  result <- get_items(
    keyword = "Gesundheit",
    legis_period = "27",
    echo = FALSE
  )
  
  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items works with valid eurovoc", {
  skip_on_cran()
  skip_if_offline()
  
  result <- get_items(
    eurovoc = "health",
    legis_period = "27",
    echo = FALSE
  )
  
  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items parl_group_names_standard works", {
  skip_on_cran()
  skip_if_offline()
  
  # Test that the standardization function is called
  result <- get_items(
    parl_group = "SPÖ",
    parl_group_names_standard = TRUE,
    legis_period = "27",
    echo = FALSE
  )
  
  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items echo parameter works", {
  skip_on_cran()
  skip_if_offline()
  
  # Test with echo = TRUE (should print output)
  expect_output(
    get_items(
      item = "RV",
      legis_period = "27",
      echo = TRUE
    ),
    "https://www.parlament.gv.at"
  )
  
  # Test with echo = FALSE (should not print)
  expect_silent(
    get_items(
      item = "RV",
      legis_period = "27", 
      echo = FALSE
    )
  )
})

test_that("get_items validates text input for suspicious content", {
  expect_error(
    get_items(search_string = "<script>alert('test')</script>"),
    "Suspicious content detected in search_string"
  )
  
  expect_error(
    get_items(person = "javascript:alert()"),
    "Suspicious content detected in person"
  )
  
  expect_error(
    get_items(number = "data:text/html,<script>"),
    "Suspicious content detected in number"
  )
})

test_that("get_items validates text input length", {
  long_string <- paste(rep("a", 1001), collapse = "")
  
  expect_error(
    get_items(search_string = long_string),
    "search_string exceeds maximum length of 1000 characters"
  )
  
  expect_error(
    get_items(person = long_string),
    "person exceeds maximum length of 1000 characters"
  )
  
  expect_error(
    get_items(number = long_string),
    "number exceeds maximum length of 1000 characters"
  )
})
