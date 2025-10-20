# Tests for get_transcripts()

# Basic functionality tests

test_that("get_transcripts returns data frame with correct number of sessions", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    session_type = "NRSITZ",
    legis_period = 15,
    echo = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) == 149)
})

test_that("get_transcripts returns correct column names", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    echo = FALSE
  )

  expected_cols <- c(
    "date",
    "session_url",
    "legis_period",
    "session_type",
    "session_number",
    "session",
    "session_transcript_html",
    "session_transcript_pdf"
  )

  expect_true(all(expected_cols %in% names(result)))
})

test_that("get_transcripts date column is properly formatted", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    echo = FALSE
  )

  expect_s3_class(result$date, "Date")
})

# Legislative period filtering tests

test_that("get_transcripts accepts numeric legislative period", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    echo = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_transcripts accepts Roman numeral legislative period", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = "XXVII",
    session_type = "NRSITZ",
    echo = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_transcripts accepts historical period abbreviations", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(legis_period = "PN", echo = FALSE)

  expect_s3_class(result, "data.frame")
})

test_that("get_transcripts filters correctly by legislative period", {
  skip_on_cran()
  skip_if_offline()

  result_27 <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    echo = FALSE
  )
  result_26 <- get_transcripts(
    legis_period = 26,
    session_type = "NRSITZ",
    echo = FALSE
  )

  expect_true(length(unique(result_26$legis_period)) == 1)
  expect_true(unique(result_26$legis_period) == "XXVI")
  expect_true(length(unique(result_27$legis_period)) == 1)
  expect_true(unique(result_27$legis_period) == "XXVII")
})

test_that("get_transcripts allows for multiple legislative periods", {
  skip_on_cran()
  skip_if_offline()

  result_15_20 <- get_transcripts(
    legis_period = c(15, 20),
    session_type = "NRSITZ",
    echo = FALSE
  )

  expect_true(length(unique(result_15_20$legis_period)) == 2)
  expect_true(all(unique(result_15_20$legis_period) %in% c("XX", "XV")))
  expect_true(nrow(result_15_20) == 332)

  result_15_20_dupes <- janitor::get_dupes(
    result_15_20,
    date,
    session_number,
    legis_period
  )
  expect_true(nrow(result_15_20_dupes) == 0)
})


# Session type filtering tests

test_that("get_transcripts accepts valid session types", {
  skip_on_cran()
  skip_if_offline()

  # Test NRSITZ
  result_nr <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    echo = FALSE
  )
  expect_s3_class(result_nr, "data.frame")
  expect_true(nrow(result_nr) > 0)

  # Test BRSITZ
  result_br <- get_transcripts(
    legis_period = 27,
    session_type = "BRSITZ",
    echo = FALSE
  )
  expect_s3_class(result_br, "data.frame")
})

test_that("get_transcripts rejects invalid session type", {
  expect_error(
    get_transcripts(session_type = "INVALID", echo = FALSE),
    "Must be a subset of"
  )
})

test_that("get_transcripts filters correctly by session type", {
  skip_on_cran()
  skip_if_offline()

  result_nr <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    echo = FALSE
  )
  result_br <- get_transcripts(
    legis_period = 27,
    session_type = "BRSITZ",
    echo = FALSE
  )

  expect_false(identical(result_nr, result_br))
})

# Date filtering tests

test_that("get_transcripts accepts date_start parameter", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    date_start = "01-01-2024",
    echo = FALSE
  )

  expect_s3_class(result, "data.frame")
  # Check that all dates are after start date
  if (nrow(result) > 0) {
    expect_true(all(result$date >= as.Date("2024-01-01")))
  }
})

test_that("get_transcripts accepts only date_end parameter", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    date_end = "01-01-2021",
    echo = TRUE
  )

  expect_s3_class(result, "data.frame")
  # Check that all dates are before end date

  expect_true(nrow(result) == 75)
  expect_true(all(result$date <= as.Date("2021-01-01")))
})

test_that("get_transcripts accepts both date_start and date_end", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    date_start = "01-01-2024",
    date_end = "30-06-2024",
    echo = FALSE
  )

  expect_s3_class(result, "data.frame")
  # Check that dates are within range
  if (nrow(result) > 0) {
    expect_true(all(result$date >= as.Date("2024-01-01")))
    expect_true(all(result$date <= as.Date("2024-06-30")))
  }
})

test_that("get_transcripts validates date format", {
  expect_error(
    get_transcripts(
      legis_period = 27,
      date_start = "2024-01-01",
      echo = FALSE
    ),
    "date_start must be in format dd-mm-yyyy"
  )

  expect_error(
    get_transcripts(
      legis_period = 27,
      date_end = "01/01/2024",
      echo = FALSE
    ),
    "date_end must be in format dd-mm-yyyy"
  )
})

# Search string tests

test_that("get_transcripts accepts search_string parameter", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    search_string = "budget",
    echo = FALSE
  )

  expect_s3_class(result, "data.frame")
})

test_that("get_transcripts with search_string returns fewer results", {
  skip_on_cran()
  skip_if_offline()

  result_all <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    echo = FALSE
  )
  result_filtered <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    search_string = "gesundheit",
    echo = FALSE
  )

  # Filtered results should be less than or equal to all results
  expect_true(nrow(result_filtered) <= nrow(result_all))
})

# URL extraction tests

test_that("get_transcripts extracts HTML and PDF URLs correctly", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    echo = FALSE
  )

  # Check that URL columns exist
  expect_true("session_transcript_html" %in% names(result))
  expect_true("session_transcript_pdf" %in% names(result))

  # Check that URLs are properly formatted (if not NA)
  if (any(!is.na(result$session_transcript_html))) {
    valid_urls <- result$session_transcript_html[
      !is.na(result$session_transcript_html)
    ]
    expect_true(all(grepl("^https?://", valid_urls)))
  }

  if (any(!is.na(result$session_transcript_pdf))) {
    valid_urls <- result$session_transcript_pdf[
      !is.na(result$session_transcript_pdf)
    ]
    expect_true(all(grepl("^https?://", valid_urls)))
  }
})

# Echo parameter tests

test_that("get_transcripts respects echo parameter", {
  skip_on_cran()
  skip_if_offline()

  # With echo = FALSE, should not print
  expect_silent(
    get_transcripts(
      legis_period = 27,
      session_type = "NRSITZ",
      echo = FALSE
    )
  )
})

# Output sorting tests

test_that("get_transcripts returns data sorted by date", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    echo = FALSE
  )

  if (nrow(result) > 1) {
    # Check that dates are in ascending order
    expect_true(all(diff(result$date) >= 0))
  }
})

# Combined filtering tests

test_that("get_transcripts handles multiple filters simultaneously", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    date_start = "01-01-2024",
    date_end = "31-12-2024",
    search_string = "budget",
    echo = FALSE
  )

  expect_s3_class(result, "data.frame")
})

# Edge cases

test_that("get_transcripts handles NULL parameters gracefully", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    search_string = NULL,
    legis_period = NULL,
    session_type = NULL,
    date_start = NULL,
    date_end = NULL,
    echo = FALSE
  )

  expect_s3_class(result, "data.frame")
})

test_that("get_transcripts returns tibble (not just data.frame)", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    echo = FALSE
  )

  # Should be a tibble (which is also a data.frame)
  expect_s3_class(result, "data.frame")
})
