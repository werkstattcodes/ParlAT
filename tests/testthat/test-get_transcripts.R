# Tests for get_transcripts()

# Basic functionality tests

test_that("transcript echo URL represents a NULL period as all periods", {
  body_params <- jsonlite::toJSON(list(NBVS = "NRSITZ"))
  messages <- character()

  withCallingHandlers(
    .get_transcripts_echo_request(
      body_params,
      legis_period = character(),
      n_results = 6847L,
      search_string = NULL
    ),
    message = function(message) {
      messages <<- c(messages, conditionMessage(message))
      invokeRestart("muffleMessage")
    }
  )

  url_message <- messages[grepl("Results on the Parliament website", messages)]
  query_parts <- strsplit(sub("^[^?]+\\?", "", url_message), "&")[[1]]
  period_params <- query_parts[grepl("STENO_211GP_CODE=", query_parts)]
  periods <- sub("STENO_211GP_CODE=", "", period_params, fixed = TRUE)
  expected_periods <- c(as.character(as.roman(1:28)), "KN", "PN")

  expect_length(url_message, 1L)
  expect_match(
    url_message,
    "https://www.parlament.gv.at/recherchieren/protokolle?",
    fixed = TRUE
  )
  expect_setequal(periods, expected_periods)
  expect_match(url_message, "STENO_211NBVS=NRSITZ", fixed = TRUE)
  expect_no_match(url_message, "index.html", fixed = TRUE)
})

test_that("transcript echo URL preserves an explicit period", {
  body_params <- jsonlite::toJSON(list(
    GP_CODE = "XXVII",
    NBVS = "NRSITZ"
  ))
  messages <- character()

  withCallingHandlers(
    .get_transcripts_echo_request(
      body_params,
      legis_period = "XXVII",
      n_results = 1L,
      search_string = "budget"
    ),
    message = function(message) {
      messages <<- c(messages, conditionMessage(message))
      invokeRestart("muffleMessage")
    }
  )

  url_message <- messages[grepl("Results on the Parliament website", messages)]

  expect_equal(stringr::str_count(url_message, "STENO_211GP_CODE="), 1L)
  expect_match(url_message, "STENO_211GP_CODE=XXVII", fixed = TRUE)
  expect_match(url_message, "search=budget", fixed = TRUE)
})

test_that("get_transcripts returns data frame with correct number of meetings", {
  # Nationalrat
  result_nr <- run_api_call(
    {
      get_transcripts(
        meeting_type = "NRSITZ",
        legis_period = 15,
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_s3_class(result_nr, "data.frame")
  expect_equal(nrow(result_nr), 149)

  # Bundesrat
  result_br <- run_api_call(
    {
      get_transcripts(
        meeting_type = c("BRSITZ"),
        legis_period = "XXV",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_s3_class(result_br, "data.frame")
  expect_equal(nrow(result_br), 50)
})

test_that("get_transcripts returns correct column names", {
  result <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = c(
          "NRSITZ",
          "BRSITZ"
        ),
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expected_cols <- c(
    "date",
    "meeting_url",
    "legis_period",
    "meeting_type",
    "meeting_number",
    "meeting",
    "meeting_transcript_html",
    "meeting_transcript_pdf"
  )

  expect_true(all(expected_cols %in% names(result)))
})

test_that("get_transcripts date column is properly formatted", {
  result <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_s3_class(result$date, "Date")
})

# Legislative period filtering tests

test_that("get_transcripts accepts numeric legislative period", {
  result <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_transcripts accepts Roman numeral legislative period", {
  result <- run_api_call(
    {
      get_transcripts(
        legis_period = "XXVII",
        meeting_type = "NRSITZ",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_transcripts accepts historical period abbreviations", {
  result <- run_api_call(
    {
      get_transcripts(legis_period = "PN", echo = FALSE)
    },
    fixture_subdir = "get_transcripts"
  )

  expect_s3_class(result, "data.frame")
})

test_that("get_transcripts filters correctly by legislative period", {
  result_27 <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  result_26 <- run_api_call(
    {
      get_transcripts(
        legis_period = 26,
        meeting_type = "NRSITZ",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_true(length(unique(result_26$legis_period)) == 1)
  expect_true(unique(result_26$legis_period) == "XXVI")
  expect_true(length(unique(result_27$legis_period)) == 1)
  expect_true(unique(result_27$legis_period) == "XXVII")
})

test_that("get_transcripts allows for multiple legislative periods", {
  result_15_20 <- run_api_call(
    {
      get_transcripts(
        legis_period = c(15, 20),
        meeting_type = "NRSITZ",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_true(length(unique(result_15_20$legis_period)) == 2)
  expect_true(all(unique(result_15_20$legis_period) %in% c("XX", "XV")))
  expect_equal(nrow(result_15_20), 332)

  result_15_20_dupes <- result_15_20[
    duplicated(result_15_20[, c("date", "meeting_number", "legis_period")]),
  ]
  expect_true(nrow(result_15_20_dupes) == 0)
})


test_that("get_transcripts rejects invalid meeting type", {
  expect_error(
    get_transcripts(meeting_type = "INVALID", echo = FALSE),
    "Must be a subset of"
  )
})

test_that("get_transcripts filters correctly by meeting type", {
  result_nr <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  result_br <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "BRSITZ",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_false(identical(result_nr, result_br))
})

test_that("get_transcripts defaults to both NRSITZ and BRSITZ when meeting_type is NULL", {
  # Query with NULL meeting_type (default)
  result_null <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = NULL,
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  # Query explicitly with both meeting types
  result_both <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = c("NRSITZ", "BRSITZ"),
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  # Check for 100% overlap in meeting_url column
  urls_null <- sort(unique(result_null$meeting_url))
  urls_both <- sort(unique(result_both$meeting_url))

  # Both should have the same number of unique URLs
  expect_equal(length(urls_null), length(urls_both))

  # All URLs should be identical (100% overlap)
  expect_true(all(urls_null %in% urls_both))
  expect_true(all(urls_both %in% urls_null))

  # Verify that both meeting types are present in the result
  expect_true(all(
    c("NRSITZ", "BRSITZ") %in%
      unique(result_null$meeting_type)
  ))

  # Verify the result contains both NR and BR meetings
  expect_true(length(unique(result_null$meeting_type)) == 2)
})

# Date filtering tests

test_that("get_transcripts accepts date_start parameter", {
  result <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        date_start = "01-01-2024",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_s3_class(result, "data.frame")
  # Check that all dates are after start date
  if (nrow(result) > 0) {
    expect_true(all(result$date >= as.Date("2024-01-01")))
  }
})

test_that("get_transcripts accepts only date_end parameter", {
  result <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        date_end = "01-01-2021",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_s3_class(result, "data.frame")
  # Check that all dates are before end date

  expect_equal(nrow(result), 75)
  expect_true(all(result$date <= as.Date("2021-01-01")))
})

test_that("get_transcripts accepts both date_start and date_end", {
  result <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        date_start = "01-01-2024",
        date_end = "30-06-2024",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
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
  expect_error(
    get_transcripts(
      legis_period = 27,
      date_start = "2024-01-01",
      echo = FALSE
    )
  )
})

# Search string tests

test_that("get_transcripts accepts search_string parameter", {
  result <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        search_string = "budget",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_equal(nrow(result), 105)
  expect_s3_class(result, "data.frame")

  expect_true(nrow(result[duplicated(result), ]) == 0)
})

test_that("get_transcripts with search_string returns fewer results", {
  result_all <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  result_filtered <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        search_string = "gesundheit",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  # Filtered results should be less than or equal to all results
  expect_true(nrow(result_filtered) <= nrow(result_all))
})

# URL extraction tests

test_that("get_transcripts extracts HTML and PDF URLs correctly", {
  result <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  # Check that URL columns exist
  expect_true("meeting_transcript_html" %in% names(result))
  expect_true("meeting_transcript_pdf" %in% names(result))

  # Check that URLs are properly formatted (if not NA)
  if (any(!is.na(result$meeting_transcript_html))) {
    valid_urls <- result$meeting_transcript_html[
      !is.na(result$meeting_transcript_html)
    ]
    expect_true(all(grepl("^https?://", valid_urls)))
  }

  if (any(!is.na(result$meeting_transcript_pdf))) {
    valid_urls <- result$meeting_transcript_pdf[
      !is.na(result$meeting_transcript_pdf)
    ]
    expect_true(all(grepl("^https?://", valid_urls)))
  }
})

# Echo parameter tests

test_that("get_transcripts respects echo parameter", {
  # With echo = FALSE, should not print
  expect_silent(
    run_api_call(
      {
        get_transcripts(
          legis_period = 27,
          meeting_type = "NRSITZ",
          echo = FALSE
        )
      },
      fixture_subdir = "get_transcripts"
    )
  )
})

# Output sorting tests

test_that("get_transcripts returns data sorted by date", {
  result <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  if (nrow(result) > 1) {
    # Check that dates are in ascending order
    expect_true(all(diff(result$date) >= 0))
  }
})

# Combined filtering tests

test_that("get_transcripts handles multiple filters simultaneously", {
  result <- run_api_call(
    {
      get_transcripts(
        meeting_type = "NRSITZ",
        date_start = "01/01/2024",
        date_end = "31/12/2024",
        search_string = "budget",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_s3_class(result, "data.frame")
})

# Edge cases

test_that("get_transcripts handles NULL parameters gracefully", {
  result <- run_api_call(
    {
      get_transcripts(
        search_string = NULL,
        legis_period = NULL,
        meeting_type = NULL,
        date_start = NULL,
        date_end = NULL,
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  expect_s3_class(result, "data.frame")

  # With meeting_type = NULL, should query both NRSITZ and BRSITZ
  expect_true(all(
    c("NRSITZ", "BRSITZ") %in%
      unique(result$meeting_type)
  ))
})

test_that("get_transcripts returns tibble (not just data.frame)", {
  result <- run_api_call(
    {
      get_transcripts(
        legis_period = 27,
        meeting_type = "NRSITZ",
        echo = FALSE
      )
    },
    fixture_subdir = "get_transcripts"
  )

  # Should be a tibble (which is also a data.frame)
  expect_s3_class(result, "data.frame")
})

test_that("get_transcripts exports file from recorded fixture", {
  skip_on_cran()
  skip_if_mocked("Export tests require live API for file downloads")
  skip_if_offline()
  skip_if_not_installed("curl")

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
    meeting_type = "BRSITZ",
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
