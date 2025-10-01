test_that("get_participation returns a data frame with expected columns", {
  skip_on_cran()
  skip_if_offline()

  result <- get_participation(
    topic = "Bildung",
    item = "RGES",
    active = "J"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(c("topic", "item", "date") %in% names(result)))
  expect_s3_class(result$date, "Date")
})

test_that("get_participation validates topic choices", {
  expect_error(
    get_participation(topic = "Invalid Topic"),
    "Must be a subset of"
  )
})

test_that("get_participation validates active flag", {
  expect_error(
    get_participation(active = "Y"),
    "Must be a subset of"
  )
})

test_that("get_participation validates item parameter", {
  expect_error(
    get_participation(item = "INVALID"),
    "Must be a subset of"
  )
})

test_that("get_participation validates initiative_type parameter", {
  expect_error(
    get_participation(initiative_type = "INVALID"),
    "Must be a subset of"
  )
})

test_that("get_participation validates legislative period input", {
  expect_error(
    get_participation(legis_period = "invalid"),
    "Invalid input for legis_period"
  )
})
