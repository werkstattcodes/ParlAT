test_that("get_mps returns correct number of female MPs for 27th legislative period", {
  result <- get_mps(legis_period = 27, institution = "NR", gender = "female")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 88)
})

# Tests for legis_period argument

test_that("get_mps accepts numeric legis_period", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = 27, institution = "NR")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps accepts Roman numeral legis_period", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = "XXVII", institution = "NR")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps accepts historical period abbreviations", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = "PN", institution = "PN")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps accepts multiple legis_periods", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = c(26, 27), institution = "NR")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps filters correctly by legis_period", {
  skip_on_cran()
  skip_if_offline()

  # Test that results are actually filtered by period
  result_27 <- get_mps(legis_period = 27, institution = "NR")
  result_26 <- get_mps(legis_period = 26, institution = "NR")

  expect_false(identical(result_27, result_26))
})

test_that("get_mps rejects legis_period for Bundesrat", {
  expect_error(
    get_mps(legis_period = 27, institution = "BR"),
    "Filtering the Federal Council \\(Bundesrat\\) by legislative period is not supported"
  )
})

test_that("get_mps validates legis_period input", {
  expect_error(
    get_mps(legis_period = 999, institution = "NR"),
    "Must be a subset of"
  )
})

test_that("get_mps handles mixed legis_period types", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = c("26", "XXVII"), institution = "NR")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps returns empty result for non-existent legis_period", {
  skip_on_cran()
  skip_if_offline()

  # This should not error but return empty results
  result <- get_mps(legis_period = character(0), institution = "NR")

  expect_s3_class(result, "data.frame")
})

test_that("get_mps with legis_period requires institution to be NR or NULL", {
  expect_error(
    get_mps(legis_period = 27, institution = "something_else"),
    "Must be element of set"
  )
})

test_that("get_mps validates PN institution requires PN legis_period", {
  expect_error(
    get_mps(institution = "PN", legis_period = 27),
    "When institution is 'PN'"
  )
})

test_that("get_mps validates PN legis_period requires PN institution", {
  expect_error(
    get_mps(legis_period = "PN", institution = "NR"),
    "When legis_period is 'PN'"
  )
})

test_that("get_mps allows PN institution with PN legis_period", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(institution = "PN", legis_period = "PN")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

#check what happens with get_mps if name was changed
#check what happens if legis period is of length > 1
