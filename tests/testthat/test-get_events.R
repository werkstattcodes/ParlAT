test_that("get_events parameter validation works", {
  # Test institution parameter validation
  expect_error(get_events(institution = "INVALID"))
  expect_no_error(get_events(institution = "NR"))
  expect_no_error(get_events(institution = "BR"))
  expect_no_error(get_events(institution = "ParlDir/Klub"))
  expect_no_error(get_events(institution = NULL))
  expect_no_error(get_events(institution = c("NR", "BR")))

  # Test event_type parameter validation
  expect_error(get_events(event_type = "Invalid Event Type"))
  expect_no_error(get_events(event_type = "Plenarsitzung"))

  # Test location parameter validation
  expect_error(get_events(location = "Invalid Location"))
  expect_no_error(get_events(location = "Nationalratssaal"))
  expect_no_error(get_events(location = "virtuell"))

  # Test echo parameter validation
  expect_error(get_events(echo = "not_logical"))
  expect_no_error(get_events(echo = TRUE))
  expect_no_error(get_events(echo = FALSE))

  # Test legis_period parameter validation
  expect_no_error(get_events(legis_period = 28))
  expect_no_error(get_events(legis_period = "28"))
  expect_no_error(get_events(legis_period = NULL))
  expect_error(get_events(legis_period = c(27, 28))) # Should fail - multiple values
})

test_that("legis_period mutual exclusivity with dates works", {
  # Test mutual exclusivity with date parameters
  expect_error(get_events(
    legis_period = 28,
    date_start = "01-01-2024",
    date_end = "31-01-2024"
  ))

  # Test that legis_period works when dates are NULL
  expect_no_error(get_events(legis_period = 28))
})

test_that("get_events returns a tibble for non-empty results", {
  res <- run_api_call(
    {
      get_events(legis_period = 27, institution = "NR")
    },
    fixture_subdir = "get_events"
  )

  expect_s3_class(res, "tbl_df")
})

test_that("get_events handles empty results gracefully", {
  # Search for a date range in the far future where no events should exist
  res <- run_api_call(
    {
      get_events(
        date_start = "01-01-2099",
        date_end = "31-01-2099",
        institution = "NR"
      )
    },
    fixture_subdir = "get_events"
  )

  expect_s3_class(res, "tbl_df")
  expect_identical(nrow(res), 0L)
  expected_cols <- c("title", "institution", "location")
  expect_true(all(expected_cols %in% names(res)))
})

test_that("get_events works with complex parameter combinations", {
  res <- run_api_call(
    {
      get_events(
        institution = "NR",
        date_start = "01-01-2024",
        date_end = "31-03-2024",
        event_type = "Plenarsitzung",
        location = "Nationalratssaal"
      )
    },
    fixture_subdir = "get_events"
  )

  expect_s3_class(res, "tbl_df")

  # If data returned, verify filtering worked
  if (nrow(res) > 0) {
    # Check location filtering
    expect_true(all(grepl("Nationalratssaal", res$location)))
  }
})

test_that("echo does not change returned event data", {
  get_filtered_events <- function(echo) {
    run_api_call(
      {
        get_events(
          institution = "NR",
          date_start = "01-01-2024",
          date_end = "31-03-2024",
          event_type = "Plenarsitzung",
          location = "Nationalratssaal",
          echo = echo
        )
      },
      fixture_subdir = "get_events"
    )
  }

  expect_identical(
    get_filtered_events(echo = TRUE),
    get_filtered_events(echo = FALSE)
  )
})

test_that("empty event filters serialize as a JSON object", {
  expect_identical(.get_events_body_to_json(list()), "{}")

  body <- .get_events_body_to_json(list(GREMIUM = "Nationalrat")) |>
    jsonlite::fromJSON()
  expect_equal(body$GREMIUM, "Nationalrat")
})

test_that("event echo derives filters that override website defaults", {
  response <- list(
    header = data.frame(
      feld_name = c("DATUM", "VERFUEGBAR", "TITLE")
    ),
    rows = data.frame(
      date = c("17.07.2027", "10.11.1920", "01.09.2026"),
      available = c("J", "V", "J"),
      title = c("Future", "Historical", "Current")
    )
  )
  body <- jsonlite::toJSON(list(GREMIUM = "Nationalrat"))

  echo_body <- .get_events_echo_body(body, response) |>
    jsonlite::fromJSON()

  expect_equal(echo_body$GREMIUM, "Nationalrat")
  expect_equal(echo_body$DATERANGE, "1920-11-09T23:00:00.000Z")
  expect_equal(echo_body$VERFUEGBAR, c("J", "V"))
})

test_that("event echo preserves explicit dates and empty results", {
  response <- list(
    header = data.frame(feld_name = c("DATUM", "VERFUEGBAR")),
    rows = data.frame(
      date = "10.11.1920",
      available = "V"
    )
  )
  date_range <- c(
    "2024-01-01T00:00:00.000Z",
    "2024-12-31T23:59:59.000Z"
  )
  body <- jsonlite::toJSON(list(DATERANGE = date_range))

  echo_body <- .get_events_echo_body(body, response) |>
    jsonlite::fromJSON()

  expect_equal(echo_body$DATERANGE, date_range)
  expect_equal(echo_body$VERFUEGBAR, "V")

  empty_response <- list(
    header = response$header,
    rows = data.frame(date = character(), available = character())
  )
  expect_identical(
    .get_events_echo_body("{}", empty_response),
    "{}"
  )
})

test_that("aux_transform_event_date works correctly", {
  # Test valid dates
  expect_no_error(ParlAT:::aux_transform_event_date(
    "01-01-2024",
    "test_date",
    FALSE
  ))
  expect_no_error(ParlAT:::aux_transform_event_date(
    "31-12-2024",
    "test_date",
    TRUE
  ))

  # Test invalid format
  expect_error(ParlAT:::aux_transform_event_date(
    "2024-01-01",
    "test_date",
    FALSE
  ))

  # Test invalid dates
  expect_error(ParlAT:::aux_transform_event_date(
    "32-01-2024",
    "test_date",
    FALSE
  ))
  expect_error(ParlAT:::aux_transform_event_date(
    "01-13-2024",
    "test_date",
    FALSE
  ))
  expect_error(ParlAT:::aux_transform_event_date(
    "29-02-2023",
    "test_date",
    FALSE
  ))

  # Test NULL input
  expect_null(ParlAT:::aux_transform_event_date(NULL, "test_date", FALSE))
})

test_that("aux_transform_event_date returns correct format", {
  expect_equal(
    ParlAT:::aux_transform_event_date(
      "10-11-1920",
      "date_start",
      FALSE
    ),
    "1920-11-09T23:00:00.000Z"
  )
  expect_equal(
    ParlAT:::aux_transform_event_date(
      "01-01-2024",
      "date_start",
      FALSE
    ),
    "2023-12-31T23:00:00.000Z"
  )
  expect_equal(
    ParlAT:::aux_transform_event_date(
      "01-07-2024",
      "date_start",
      FALSE
    ),
    "2024-06-30T22:00:00.000Z"
  )
  expect_equal(
    ParlAT:::aux_transform_event_date(
      "01-07-2024",
      "date_end",
      TRUE
    ),
    "2024-07-01T21:59:59.000Z"
  )
})
