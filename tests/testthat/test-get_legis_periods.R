test_that("get_legis_periods returns all periods when no parameters provided", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods()

  expect_s3_class(result, "data.frame")
  expect_true(all(
    c(
      "legis_period",
      "legis_period_current",
      "date_start",
      "date_end",
      "legis_period_name",
      "legis_period_abbrev",
      "legis_period_abbrev_num"
    ) %in%
      colnames(result)
  ))
  expect_true(nrow(result) > 25)
  expect_true(any(result$legis_period_current))
})

test_that("get_legis_periods validates input parameters", {
  expect_error(
    get_legis_periods(legis_period = 25, date = "01.01.2020"),
    "Please provide either legis_period or date, not both."
  )
})

test_that("get_legis_periods filters by numeric legislative period", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods(legis_period = 27)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_equal(result$legis_period, 27)
})

test_that("get_legis_periods filters by multiple legislative periods", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods(legis_period = c(26, 27))

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_true(all(result$legis_period %in% c(26, 27)))
})

test_that("get_legis_periods handles Roman numeral input", {
  skip_on_cran()
  skip_if_offline()

  result_roman <- get_legis_periods(legis_period = "XXVII")
  result_numeric <- get_legis_periods(legis_period = 27)

  expect_s3_class(result_roman, "data.frame")
  expect_equal(result_roman$legis_period, 27)
  expect_identical(result_roman, result_numeric)
})

test_that("get_legis_periods filters by date", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods(date = "01.01.2020")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_true(as.Date("2020-01-01") >= result$date_start)
  expect_true(
    is.na(result$date_end) || as.Date("2020-01-01") <= result$date_end
  )
})

test_that("get_legis_periods filters by multiple dates", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods(date = c("01.01.2020", "01.01.2015"))

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) >= 1)
  expect_true(nrow(result) <= 2)
})

test_that("get_legis_periods includes historical periods", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods()

  historical_periods <- c("PN", "KN", "Bundesrat1Rep")
  expect_true(any(result$legis_period_abbrev %in% historical_periods))

  pn_period <- result[result$legis_period_abbrev == "PN", ]
  expect_true(nrow(pn_period) == 1) #
  expect_equal(pn_period$date_start, as.Date("1918-10-21")) #
  expect_equal(pn_period$date_end, as.Date("1919-02-16")) #
})

test_that("get_legis_periods date columns are properly formatted", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods()

  expect_s3_class(result$date_start, "Date")
  expect_s3_class(result$date_end, "Date")
  expect_true(all(!is.na(result$date_start)))
  expect_true(any(is.na(result$date_end)))
})

test_that("get_legis_periods current period identification works", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods()

  current_periods <- result[result$legis_period_current == TRUE, ]
  expect_equal(nrow(current_periods), 1)
  expect_true(is.na(current_periods$date_end))
})

test_that("get_legis_periods returns correct structure for specific historical date", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods(date = "15.05.1955")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_true(as.Date("1955-05-15") >= result$date_start)
  expect_true(as.Date("1955-05-15") <= result$date_end)
})

test_that("get_legis_periods handles edge case of non-existent period", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods(legis_period = 999)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("get_legis_periods name formatting is consistent", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods()

  current_period <- result[result$legis_period_current == TRUE, ]
  expect_true(grepl(
    "^ab \\d{2}\\.\\d{2}\\.\\d{4}:",
    current_period$legis_period_name
  ))

  past_periods <- result[
    result$legis_period_current == FALSE & !is.na(result$legis_period),
  ]
  if (nrow(past_periods) > 0) {
    expect_true(all(grepl(
      "\\d{2}\\.\\d{2}\\.\\d{4} - \\d{2}\\.\\d{2}\\.\\d{4}:",
      past_periods$legis_period_name
    )))
  }
})

test_that("get_legis_periods data is sorted by start date", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods()

  expect_true(all(diff(result$date_start) >= 0))
})

test_that("get_legis_periods handles string input for numeric periods", {
  skip_on_cran()
  skip_if_offline()

  result_string <- get_legis_periods(legis_period = "27")
  result_numeric <- get_legis_periods(legis_period = 27)

  expect_identical(result_string, result_numeric)
})

test_that("get_legis_periods handles mixed input types", {
  skip_on_cran()
  skip_if_offline()

  result <- get_legis_periods(legis_period = c("26", "I", "PN"))

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)

  # Should include period 26, period I (1), and historical period PN
  expected_periods <- c("26", "1", "PN")
  expect_true(all(result$legis_period_abbrev_num %in% expected_periods))

  # Check that all requested periods are found
  expect_setequal(result$legis_period_abbrev_num, expected_periods)
})
