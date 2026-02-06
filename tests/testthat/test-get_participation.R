test_that("get_participation returns a data frame with expected columns", {
  result <- run_api_call({
    get_participation(
      topic = "Bildung",
      item = "RGES",
      active = "J"
    )
  }, fixture_subdir = "get_participation")

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
    'initiative_type can only be specified when item = "RGES"'
  )
})

test_that("get_participation requires item = RGES when initiative_type is specified", {
  expect_error(
    get_participation(initiative_type = "A", item = "ME"),
    "initiative_type can only be specified when item = \"RGES\""
  )

  expect_error(
    get_participation(initiative_type = "RV"),
    "initiative_type can only be specified when item = \"RGES\""
  )
})

test_that("get_participation validates legislative period input", {
  expect_error(
    get_participation(legis_period = "invalid"),
    "Invalid input for legis_period"
  )
})

test_that("get_participation validates statement_type parameter", {
  expect_error(
    get_participation(statement_type = "INVALID"),
    'statement_type can only be specified when item = "SN"'
  )
})

test_that("get_participation requires item = SN when statement_type is specified", {
  expect_error(
    get_participation(statement_type = "SNME", item = "ME"),
    "statement_type can only be specified when item = \"SN\""
  )

  expect_error(
    get_participation(statement_type = "SN"),
    "statement_type can only be specified when item = \"SN\""
  )
})

test_that("get_participation returns correct data for multiple legislative periods and item type", {
  result <- run_api_call({
    get_participation(
      legis_period = c(26, 27),
      item = "ME"
    )
  }, fixture_subdir = "get_participation")

  expect_s3_class(result, "data.frame")
  expect_row_count(nrow(result), 516)
})

test_that("get_participation returns data for RGES item type", {

  result <- run_api_call({
    get_participation(item = "RGES", legis_period = 27)
  }, fixture_subdir = "get_participation")

  expect_s3_class(result, "data.frame")
  expect_row_count(nrow(result), 1403)
})
