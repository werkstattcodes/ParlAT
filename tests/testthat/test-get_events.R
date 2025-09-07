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
  # Test that the function returns ISO 8601 UTC format
  result <- ParlAT:::aux_transform_event_date("01-01-2024", "test_date", FALSE)
  expect_match(result, "^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.000Z$")

  # Test end date processing (should add 1 day minus 1 second)
  start_result <- ParlAT:::aux_transform_event_date(
    "01-01-2024",
    "start_date",
    FALSE
  )
  end_result <- ParlAT:::aux_transform_event_date(
    "01-01-2024",
    "end_date",
    TRUE
  )
  expect_false(start_result == end_result)
})
