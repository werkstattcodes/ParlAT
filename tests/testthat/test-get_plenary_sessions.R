test_that("get_plenary_sessions returns valid data structure", {
  skip_on_cran()

  x <- run_api_call({
    get_plenary_sessions(
      institution = "NR",
      legis_period = 28,
      session_and_activities = "sessions"
    )
  }, fixture_subdir = "get_plenary_sessions")

  # Test basic structure
  expect_true(is.data.frame(x))
  expect_gt(nrow(x), 0)

  # Test for no duplicate sessions (check by session_url and session day)
  expect_false(any(duplicated(x[, c("session_url", "session_day")])))

  # Test expected columns exist
  expected_cols <- c("institution", "legis_period", "date", "session_number")
  expect_true(all(expected_cols %in% colnames(x)))

  # Test data types
  expect_true(is.character(x$institution))
  expect_s3_class(x$date, "Date")
  expect_true(is.character(x$session_number) || is.numeric(x$session_number))

  # Test institution filter works
  expect_true(all(x$institution == "NR"))

  # Test legis_period filter works
  expect_true(all(x$legis_period == as.character(28)))
})

test_that("get_plenary_sessions handles agenda_url columns correctly", {
  skip_on_cran()

  x <- run_api_call({
    get_plenary_sessions(
      institution = "NR",
      session_and_activities = "sessions",
      legis_period = 28
    )
  }, fixture_subdir = "get_plenary_sessions")

  # Test agenda_url columns exist and are character type (not list)
  if ("agenda_url_html" %in% colnames(x)) {
    expect_true(is.character(x$agenda_url_html))
    expect_true(is.character(x$agenda_url_pdf))

    # Check that non-NA URLs have the correct prefix
    non_na_html <- x$agenda_url_html[!is.na(x$agenda_url_html)]
    non_na_pdf <- x$agenda_url_pdf[!is.na(x$agenda_url_pdf)]

    if (length(non_na_html) > 0) {
      expect_true(all(stringr::str_starts(
        non_na_html,
        "https://www.parlament.gv.at"
      )))
    }
    if (length(non_na_pdf) > 0) {
      expect_true(all(stringr::str_starts(
        non_na_pdf,
        "https://www.parlament.gv.at"
      )))
    }
  }
})

test_that("get_plenary_sessions adds URL prefix to all url columns", {
  skip_on_cran()

  # Test sessions mode
  x_sessions <- run_api_call({
    get_plenary_sessions(
      institution = "NR",
      legis_period = 28,
      session_and_activities = "sessions"
    )
  }, fixture_subdir = "get_plenary_sessions")

  if (!is.null(x_sessions) && nrow(x_sessions) > 0) {
    # Check session_url has prefix
    if ("session_url" %in% colnames(x_sessions)) {
      non_na_urls <- x_sessions$session_url[!is.na(x_sessions$session_url)]
      if (length(non_na_urls) > 0) {
        expect_true(all(stringr::str_starts(
          non_na_urls,
          "https://www.parlament.gv.at"
        )))
      }
    }

    # Check agenda URLs have prefix
    if ("agenda_url_html" %in% colnames(x_sessions)) {
      non_na_html <- x_sessions$agenda_url_html[
        !is.na(x_sessions$agenda_url_html)
      ]
      if (length(non_na_html) > 0) {
        expect_true(all(stringr::str_starts(
          non_na_html,
          "https://www.parlament.gv.at"
        )))
      }
    }
  }

  # Test submitted mode
  x_submitted <- run_api_call({
    get_plenary_sessions(
      institution = "NR",
      legis_period = 27,
      session_and_activities = "submitted"
    )
  }, fixture_subdir = "get_plenary_sessions")

  if (!is.null(x_submitted) && nrow(x_submitted) > 0) {
    # Check url_session and url_session_item have prefix
    url_cols <- c("url_session", "url_session_item")
    for (col in url_cols) {
      if (col %in% colnames(x_submitted)) {
        non_na_urls <- x_submitted[[col]][!is.na(x_submitted[[col]])]
        if (length(non_na_urls) > 0) {
          expect_true(
            all(stringr::str_starts(
              non_na_urls,
              "https://www.parlament.gv.at"
            )),
            info = paste("Failed for column:", col)
          )
        }
      }
    }
  }
})

# Test all combinations of institution and session_and_activities
test_that("get_plenary_sessions works with all BR and NR institution combinations", {
  skip_on_cran()

  institutions <- c("BR", "NR")
  session_modes <- c("sessions", "submitted", "held")

  for (inst in institutions) {
    for (mode in session_modes) {
      x <- run_api_call({
        get_plenary_sessions(
          institution = inst,
          legis_period = 27,
          session_and_activities = mode
        )
      }, fixture_subdir = "get_plenary_sessions")

      expect_true(
        is.data.frame(x),
        info = paste("Failed for", inst, mode)
      )

      if (!is.null(x) && nrow(x) > 0) {
        if ("institution" %in% colnames(x)) {
          expect_true(
            all(x$institution == inst),
            info = paste("Institution filter failed for", inst, mode)
          )
        }
      }
    }
  }
})

test_that("get_plenary_sessions works with submitted parameter values", {
  skip_on_cran()

  submitted_values <- c("All", "AA", "J")

  for (sub_val in submitted_values) {
    x <- run_api_call({
      get_plenary_sessions(
        institution = "NR",
        legis_period = 28,
        session_and_activities = "submitted",
        submitted = sub_val
      )
    }, fixture_subdir = "get_plenary_sessions")

    expect_true(
      is.data.frame(x) || is.null(x),
      info = paste("Failed for submitted =", sub_val)
    )

    # Test date column is Date class
    if (!is.null(x) && nrow(x) > 0 && "date" %in% colnames(x)) {
      expect_s3_class(x$date, "Date")
    }
  }
})

test_that("get_plenary_sessions works with held parameter values", {
  skip_on_cran()

  held_values <- c("All", "AS", "FS")

  for (held_val in held_values) {
    x <- run_api_call({
      get_plenary_sessions(
        institution = "NR",
        legis_period = 28,
        session_and_activities = "held",
        held = held_val
      )
    }, fixture_subdir = "get_plenary_sessions")

    expect_true(
      is.data.frame(x) || is.null(x),
      info = paste("Failed for held =", held_val)
    )

    # Test date column is Date class
    if (!is.null(x) && nrow(x) > 0 && "date" %in% colnames(x)) {
      expect_s3_class(x$date, "Date")
    }
  }
})

test_that("get_plenary_sessions works with BV institution", {
  skip_on_cran()

  x <- run_api_call({
    get_plenary_sessions(
      institution = "BV",
      legis_period = NULL
    )
  }, fixture_subdir = "get_plenary_sessions")

  # BV should return data or NULL, not error
  expect_true(is.data.frame(x) || is.null(x))
})

test_that("get_plenary_sessions BV does not include legis_period column", {
  skip_on_cran()

  x <- run_api_call({
    get_plenary_sessions(
      institution = "BV",
      legis_period = NULL
    )
  }, fixture_subdir = "get_plenary_sessions")

  if (!is.null(x) && nrow(x) > 0) {
    # BV should NOT have legis_period column
    expect_false(
      "legis_period" %in% colnames(x),
      info = "BV results should not include legis_period column"
    )

    # Check required columns exist
    expect_true("institution" %in% colnames(x))
    expect_true("date" %in% colnames(x))
    expect_true(all(x$institution == "BV"))
  }
})

test_that("get_plenary_sessions validates BV institution parameters", {
  # BV should not accept session_and_activities parameter
  expect_error(
    get_plenary_sessions(
      institution = "BV",
      legis_period = NULL,
      session_and_activities = "sessions"
    )
  )

  # BV should not accept non-NULL legis_period
  expect_error(
    get_plenary_sessions(
      institution = "BV",
      legis_period = 27
    ),
    "legis_period must be NULL for institution 'BV'"
  )
})

test_that("get_plenary_sessions validates parameters correctly", {
  # Invalid institution
  expect_error(
    get_plenary_sessions(institution = "INVALID", legis_period = 27),
    "Must be a subset of"
  )

  # NULL institution
  expect_error(
    get_plenary_sessions(institution = NULL, legis_period = 27),
    "not empty"
  )

  # Invalid session_and_activities
  expect_error(
    get_plenary_sessions(
      institution = "NR",
      legis_period = 27,
      session_and_activities = "invalid"
    ),
    "Must be a subset of"
  )

  # Non-numeric legislative period
  expect_error(
    get_plenary_sessions(institution = "NR", legis_period = "invalid"),
    "Invalid legislative period\\(s\\) provided"
  )
})

test_that("get_plenary_sessions validates parameter combinations", {
  # submitted parameter used with wrong session_and_activities
  expect_error(
    get_plenary_sessions(
      institution = "NR",
      legis_period = 27,
      session_and_activities = "sessions",
      submitted = "AA"
    ),
    "'submitted' parameter can only be used when session_and_activities is 'submitted'"
  )

  # held parameter used with wrong session_and_activities
  expect_error(
    get_plenary_sessions(
      institution = "NR",
      legis_period = 27,
      session_and_activities = "sessions",
      held = "AS"
    ),
    "'held' parameter can only be used when session_and_activities is 'held'"
  )
})

test_that("get_plenary_sessions handles multiple legislative periods", {
  skip_on_cran()

  x <- run_api_call({
    get_plenary_sessions(
      institution = "NR",
      legis_period = c(27, 28),
      session_and_activities = "sessions"
    )
  }, fixture_subdir = "get_plenary_sessions")

  expect_true(is.data.frame(x) || is.null(x))

  if (!is.null(x) && nrow(x) > 0) {
    expect_false(any(duplicated(x[, c("session_url", "session_day")])))
  }
})


test_that("get_plenary_sessions handles NULL legislative period", {
  skip_on_cran()

  # This should get all periods from 20 onwards - limit to recent ones for testing
  x <- run_api_call({
    get_plenary_sessions(
      institution = "NR",
      legis_period = NULL,
      session_and_activities = "sessions"
    )
  }, fixture_subdir = "get_plenary_sessions")

  expect_true(is.data.frame(x) || is.null(x))

  if (!is.null(x) && nrow(x) > 0) {
    # Should contain data from multiple periods (20+)
    expect_true(length(unique(x$legis_period)) > 1)
  }
})

test_that("get_plenary_sessions validates legis_period >= 20", {
  # Test that early legislative periods are rejected
  expect_error(
    get_plenary_sessions(
      institution = "NR",
      legis_period = 1,
      session_and_activities = "sessions"
    ),
    "Only data from the 20th legislative period onwards can be queried"
  )

  # Test that legis_period = 19 is also rejected
  expect_error(
    get_plenary_sessions(
      institution = "NR",
      legis_period = 19,
      session_and_activities = "submitted"
    ),
    "Only data from the 20th legislative period onwards can be queried"
  )
})
