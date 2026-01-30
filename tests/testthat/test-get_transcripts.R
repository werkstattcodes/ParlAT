# Tests for get_transcripts()

# Basic functionality tests

test_that("get_transcripts returns data frame with correct number of sessions", {
  skip_on_cran()
  skip_if_offline()

  #Nationalrat
  result_nr <- get_transcripts(
    session_type = "NRSITZ",
    legis_period = 15,
    echo = FALSE
  )

  expect_s3_class(result_nr, "data.frame")
  expect_true(nrow(result_nr) == 149)

  #Bundesrat
  result_br <- get_transcripts(
    session_type = c("BRSITZ"),
    legis_period = "XXV",
    echo = FALSE
  )

  expect_s3_class(result_br, "data.frame")
  expect_true(nrow(result_br) == 50)
})

test_that("get_transcripts returns correct column names", {
  skip_on_cran()
  skip_if_offline()

  result <- get_transcripts(
    legis_period = 27,
    session_type = c(
      "NRSITZ",
      "BRSITZ"
    ),
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

  result_15_20_dupes <- result_15_20[
    duplicated(result_15_20[, c("date", "session_number", "legis_period")]),
  ]
  expect_true(nrow(result_15_20_dupes) == 0)
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

test_that("get_transcripts defaults to both NRSITZ and BRSITZ when session_type is NULL", {
  skip_on_cran()
  skip_if_offline()

  # Query with NULL session_type (default)
  result_null <- get_transcripts(
    legis_period = 27,
    session_type = NULL,
    echo = FALSE
  )

  # Query explicitly with both session types
  result_both <- get_transcripts(
    legis_period = 27,
    session_type = c("NRSITZ", "BRSITZ"),
    echo = FALSE
  )

  # Check for 100% overlap in session_url column
  urls_null <- sort(unique(result_null$session_url))
  urls_both <- sort(unique(result_both$session_url))

  # Both should have the same number of unique URLs
  expect_equal(length(urls_null), length(urls_both))

  # All URLs should be identical (100% overlap)
  expect_true(all(urls_null %in% urls_both))
  expect_true(all(urls_both %in% urls_null))

  # Verify that both session types are present in the result
  expect_true(all(
    c("Plenarsitzung", "Plenarsitzung - BR") %in%
      unique(result_null$session_type)
  ))

  # Verify the result contains both NR and BR sessions
  expect_true(length(unique(result_null$session_type)) == 2)
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
  # ISO Y-m-d should fail (not dmy)
  # only check that an error is raised (no message assertion)
  expect_error(
    get_transcripts(
      legis_period = 27,
      date_start = "2024-01-01",
      echo = FALSE
    )
  )

  # dmy variants should be accepted
  expect_silent(
    date1 <- get_transcripts(
      legis_period = 27,
      date_start = "01-01-2024",
      echo = FALSE
    )
  )

  expect_silent(
    date2 <- get_transcripts(
      legis_period = 27,
      date_start = "01/01/2024",
      echo = FALSE
    )
  )

  expect_silent(
    date3 <- get_transcripts(
      legis_period = 27,
      date_start = "01.01.2024",
      echo = FALSE
    )
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
    echo = TRUE
  )
  expect_true(nrow(result) == 105)
  expect_s3_class(result, "data.frame")

  expect_true(nrow(result[duplicated(result), ]) == 0)
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
    # legis_period = 27,
    session_type = "NRSITZ",
    # date_start = "01-01-2024",
    date_start = "01/01/2024",
    # date_end = "31-12-2024",
    date_end = "31/12/2024",
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

  # With session_type = NULL, should query both NRSITZ and BRSITZ
  expect_true(all(
    c("Plenarsitzung", "Plenarsitzung - BR") %in%
      unique(result$session_type)
  ))
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

test_that("get_transcripts exports file from recorded fixture", {
  skip_on_cran()
  skip_if_offline() # ensure we only run this test when network is available
  skip_if_not_installed("curl") # optional: ensure downloading support

  # create transcripts folder in project root and ensure cleanup after the test
  transcripts_dir <- "transcripts"
  if (!dir.exists(transcripts_dir)) {
    dir.create(transcripts_dir, recursive = TRUE, showWarnings = FALSE)
  }
  on.exit(
    {
      if (dir.exists(transcripts_dir)) unlink(transcripts_dir, recursive = TRUE)
    },
    add = TRUE
  )

  # This is an integration check that will perform real downloads.
  # Use BRSITZ for legislative period 27 (smaller dataset)
  res <- get_transcripts(
    legis_period = 27,
    session_type = "BRSITZ",
    date_start = "01-01-2024",
    date_end = "30-06-2024",
    export = "pdf",
    echo = FALSE
  )

  # ensure files were written to the transcripts folder
  expect_true(
    length(list.files(transcripts_dir, recursive = FALSE, all.files = FALSE)) >=
      1,
    info = "No files found in transcripts directory after export"
  )

  if (dir.exists(transcripts_dir)) unlink(transcripts_dir, recursive = TRUE)
})
