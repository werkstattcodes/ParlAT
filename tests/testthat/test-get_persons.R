# Tests that exercise the live Personen search endpoint of parlament.gv.at.
# No request mocking is used so that responses remain representative of the
# production API behaviour.

skip_on_cran()
skip_if_offline()
skip_if_not_installed("stringr")

# The Austrian parliament site is stable and should be reachable in normal
# circumstances. The following test verifies that we can retrieve at least one
# well known politician and that the response columns contain the documented
# fields.
test_that("get_persons returns expected columns for a known person", {
  result <- get_persons(names = "Kurz")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) >= 1)
  expect_true(all(
    c("pad_intern", "name", "gender", "position", "link") %in% names(result)
  ))
  expect_true(all(stringr::str_detect(result$name, stringr::regex("Kurz"))))
})


# Validation for gender continues to be handled locally and therefore does not
# rely on an API call.
test_that("invalid gender values are rejected", {
  expect_error(get_persons(gender = "unknown"), regexp = "(all|female|male)")
})

# Likewise for invalid institutions we expect the underlying checkmate
# validation to surface an error.
test_that("invalid institutions are rejected", {
  expect_error(
    get_persons(institution = "Invalid Institution")
  )
})
