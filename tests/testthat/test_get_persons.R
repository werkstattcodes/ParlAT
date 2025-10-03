# Tests that exercise the live Personen search endpoint of parlament.gv.at.
# No request mocking is used so that responses remain representative of the
# production API behaviour.

skip_if_not_installed("stringr")

# The Austrian parliament site is stable and should be reachable in normal
# circumstances. The following test verifies that we can retrieve at least one
# well known politician and that the response columns contain the documented
# fields.
test_that("get_persons returns expected columns for a known person", {
  result <- get_persons(names = "Van der Bellen Alexander", search_strict = TRUE)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) >= 1)
  expect_true(all(c("pad_intern", "name", "gender", "position", "link") %in% names(result)))
  expect_true("Van der Bellen Alexander" %in% result$name)
})

# search_strict = TRUE should only keep names that match the supplied string as a
# whole word, while disabling it keeps partial matches returned by the API.
# Using the short string "Kurz" ensures we receive a broader set of results.
test_that("search_strict narrows the result set", {
  loose <- get_persons(names = "Kurz", search_strict = FALSE)
  strict <- get_persons(names = "Kurz", search_strict = TRUE)

  expect_true(nrow(loose) >= nrow(strict))
  expect_true(all(stringr::str_detect(strict$name, stringr::regex("\\bKurz\\b"))))
})

# Validation for gender continues to be handled locally and therefore does not
# rely on an API call.
test_that("invalid gender values are rejected", {
  expect_error(get_persons(gender = "unknown"), regexp = "(all|female|male)")
})

# Likewise for invalid institutions we expect the underlying checkmate
# validation to surface an error.
test_that("invalid institutions are rejected", {
  expect_error(get_persons(institution = "Invalid Institution"), regexp = "subset")
})
