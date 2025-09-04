test_that("get_plenary_sessions returns valid data structure", {
  skip_on_cran()
  skip_if_offline()

  x <- get_plenary_sessions(
    institution = "NR",
    legis_period = 28,
    session_and_activities = "sessions"
  )

  # Test basic structure
  expect_true(is.data.frame(x))
  expect_gt(nrow(x), 0)

  # Test expected columns exist
  expected_cols <- c("institution", "legis_period", "date", "session_number")
  expect_true(all(expected_cols %in% colnames(x)))

  # Test data types
  expect_true(is.character(x$institution))
  expect_true(inherits(x$date, "Date"))
  expect_true(is.character(x$session_number) || is.numeric(x$session_number))

  # Test institution filter works
  expect_true(all(x$institution == "NR"))

  # Test legis_period filter works
  expect_true(all(x$legis_period == as.character(as.roman(28))))
})

test_that("get_plenary_sessions handles agenda_url column correctly", {
  skip_on_cran()
  skip_if_offline()

  x <- get_plenary_sessions(
    institution = "NR",
    session_and_activities = "sessions",
    legis_period = 28
  )

  # Test agenda_url column if it exists
  if ("agenda_url" %in% colnames(x)) {
    expect_true(is.list(x$agenda_url))

    # Test structure of agenda_url elements
    non_null_agenda <- x$agenda_url |>
      purrr::discard(\(y) all(is.na(y)))

    if (length(non_null_agenda) > 0) {
      # Check that elements are named vectors with 'html' and 'pdf'
      structure_check <- non_null_agenda |>
        purrr::map_lgl(\(y) {
          is.character(y) && length(y) == 2 && all(names(y) == c("html", "pdf"))
        })
      expect_true(all(structure_check))
    }
  }
})

# Test all combinations of institution and session_and_activities
test_that("get_plenary_sessions works with all BR and NR institution combinations", {
  skip_on_cran()
  skip_if_offline()

  institutions <- c("BR", "NR")
  session_modes <- c("sessions", "submitted", "held")

  for (inst in institutions) {
    for (mode in session_modes) {
      x <- get_plenary_sessions(
        institution = inst,
        legis_period = 27,
        session_and_activities = mode
      )
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
  skip_if_offline()

  submitted_values <- c("All", "AA", "J")

  for (sub_val in submitted_values) {
    x <- get_plenary_sessions(
      institution = "NR",
      legis_period = 28,
      session_and_activities = "submitted",
      submitted = sub_val
    )
    expect_true(
      is.data.frame(x) || is.null(x),
      info = paste("Failed for submitted =", sub_val)
    )
  }
})

test_that("get_plenary_sessions works with held parameter values", {
  skip_on_cran()
  skip_if_offline()

  held_values <- c("All", "AS", "FS")

  for (held_val in held_values) {
    x <- get_plenary_sessions(
      institution = "NR",
      legis_period = 28,
      session_and_activities = "held",
      held = held_val
    )
    expect_true(
      is.data.frame(x) || is.null(x),
      info = paste("Failed for held =", held_val)
    )
  }
})

test_that("get_plenary_sessions works with BV institution", {
  skip_on_cran()
  skip_if_offline()

  x <- get_plenary_sessions(
    institution = "BV",
    legis_period = 27
  )

  # BV should return data or NULL, not error
  expect_true(is.data.frame(x) || is.null(x))

  # BV should not accept session_and_activities parameter
  expect_error(
    get_plenary_sessions(
      institution = "BV", 
      legis_period = 27,
      session_and_activities = "sessions"
    )
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
    "invalid 'type' \\(character\\) of argument"
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
  skip_if_offline()
  
  x <- get_plenary_sessions(
    institution = "NR",
    legis_period = c(27, 28),
    session_and_activities = "sessions"
  )
  
  expect_true(is.data.frame(x) || is.null(x))
  
  if (!is.null(x) && nrow(x) > 0) {
    # Should contain data from both periods
    legis_periods_found <- unique(x$legis_period)
    expect_true(length(legis_periods_found) >= 1)
    expect_true(all(x$institution == "NR"))
  }
})

test_that("get_plenary_sessions handles NULL legislative period", {
  skip_on_cran()
  skip_if_offline()
  
  # This should get all periods from 20 onwards - limit to recent ones for testing
  x <- get_plenary_sessions(
    institution = "NR",
    legis_period = NULL,
    session_and_activities = "sessions"
  )
  
  expect_true(is.data.frame(x) || is.null(x))
  
  if (!is.null(x) && nrow(x) > 0) {
    # Should contain data from multiple periods (20+)
    expect_true(length(unique(x$legis_period)) > 1)
  }
})

test_that("get_plenary_sessions handles early legislative periods", {
  skip_on_cran()
  skip_if_offline()
  
  # Test that early legislative periods work (no lower boundary)
  x <- get_plenary_sessions(
    institution = "NR",
    legis_period = 1,
    session_and_activities = "sessions"
  )
  
  # Should return data or NULL, not error
  expect_true(is.data.frame(x) || is.null(x))
  
  if (!is.null(x) && nrow(x) > 0) {
    expect_true(all(x$legis_period == "I"))  # 1 in Roman numerals
  }
})
