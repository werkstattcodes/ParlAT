# Tests for get_plenary_meeting_details() ------------------------------------

test_that("get_plenary_meeting_details validates mutually exclusive input modes", {
  expect_error(
    get_plenary_meeting_details(
      url = "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50",
      institution = "NR",
      legis_period = 28,
      meeting_number = 50
    ),
    "Provide either"
  )

  expect_error(
    get_plenary_meeting_details(),
    "Supply either"
  )

  expect_error(
    get_plenary_meeting_details(institution = "NR", legis_period = 28),
    "must all be supplied together"
  )
})

test_that("get_plenary_meeting_details validates institution and details_on", {
  expect_error(
    get_plenary_meeting_details(institution = "BV", legis_period = 28, meeting_number = 50),
    "Must be element of set"
  )

  expect_error(
    get_plenary_meeting_details(
      institution = "NR",
      legis_period = 28,
      meeting_number = 50,
      details_on = "invalid"
    ),
    "Must be element of set"
  )
})

test_that("get_plenary_meeting_details normalizes relative URLs", {
  result_absolute <- run_api_call(
    get_plenary_meeting_details(
      url = "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50"
    ),
    fixture_subdir = "get_plenary_meeting_details"
  )
  result_relative <- run_api_call(
    get_plenary_meeting_details(
      url = "/gegenstand/XXVIII/NRSITZ/50"
    ),
    fixture_subdir = "get_plenary_meeting_details"
  )

  expect_equal(result_absolute, result_relative)
})

test_that("get_plenary_meeting_details builds the same URL from structured inputs", {
  from_url <- run_api_call(
    get_plenary_meeting_details(
      url = "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50"
    ),
    fixture_subdir = "get_plenary_meeting_details"
  )
  from_parts <- run_api_call(
    get_plenary_meeting_details(
      institution = "NR",
      legis_period = 28,
      meeting_number = 50
    ),
    fixture_subdir = "get_plenary_meeting_details"
  )
  from_roman <- run_api_call(
    get_plenary_meeting_details(
      institution = "NR",
      legis_period = "XXVIII",
      meeting_number = "50"
    ),
    fixture_subdir = "get_plenary_meeting_details"
  )

  expect_equal(from_url, from_parts)
  expect_equal(from_url, from_roman)
})

test_that("get_plenary_meeting_details ignores selectedStage query differences", {
  result_100 <- run_api_call(
    get_plenary_meeting_details(
      url = "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50?selectedStage=100"
    ),
    fixture_subdir = "get_plenary_meeting_details"
  )
  result_110 <- run_api_call(
    get_plenary_meeting_details(
      url = "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50?selectedStage=110"
    ),
    fixture_subdir = "get_plenary_meeting_details"
  )

  result_100$meeting_url <- NULL
  result_110$meeting_url <- NULL

  expect_equal(result_100, result_110)
})

test_that("get_plenary_meeting_details default mode returns meeting metadata", {
  result <- run_api_call(
    get_plenary_meeting_details(
      institution = "NR",
      legis_period = 28,
      meeting_number = 50
    ),
    fixture_subdir = "get_plenary_meeting_details"
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_true(all(c(
    "meeting_url",
    "meeting_title",
    "meeting_citation",
    "legis_period",
    "meeting_type",
    "meeting_type_short",
    "meeting_nr",
    "date",
    "state",
    "start_time",
    "end_time"
  ) %in% names(result)))
  expect_s3_class(result$date, "Date")
  expect_s3_class(result$start_time, "POSIXct")
  expect_s3_class(result$end_time, "POSIXct")
})

test_that("get_plenary_meeting_details speakers mode returns expected columns", {
  result <- run_api_call(
    get_plenary_meeting_details(
      institution = "NR",
      legis_period = 28,
      meeting_number = 50,
      details_on = "speakers"
    ),
    fixture_subdir = "get_plenary_meeting_details"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(c(
    "meeting_url",
    "meeting_title",
    "meeting_citation",
    "legis_period",
    "meeting_type",
    "debate_id",
    "debate_type",
    "speech_nr",
    "speaker_name",
    "pad_intern",
    "start_time",
    "duration"
  ) %in% names(result)))
})

test_that("get_plenary_meeting_details decisions mode returns expected columns", {
  result <- run_api_call(
    get_plenary_meeting_details(
      institution = "NR",
      legis_period = 28,
      meeting_number = 50,
      details_on = "decisions"
    ),
    fixture_subdir = "get_plenary_meeting_details"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(c(
    "meeting_url",
    "meeting_title",
    "meeting_citation",
    "legis_period",
    "meeting_type",
    "resolution_top",
    "resolution_title",
    "resolution_url",
    "resolution_citation"
  ) %in% names(result)))
})

test_that("get_plenary_meeting_details timeline mode keeps nested statements structure", {
  result <- run_api_call(
    get_plenary_meeting_details(
      institution = "NR",
      legis_period = 28,
      meeting_number = 50,
      details_on = "timeline"
    ),
    fixture_subdir = "get_plenary_meeting_details"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(all(c(
    "meeting_url",
    "meeting_title",
    "meeting_citation",
    "legis_period",
    "meeting_type",
    "stage_date",
    "agenda_item",
    "stage_text",
    "statements",
    "stage_fsth_url",
    "stage_fsth_title"
  ) %in% names(result)))
  expect_type(result$statements, "list")
  expect_true(all(vapply(result$statements, \(x) is.null(x) || is.data.frame(x), logical(1))))
  expect_true(any(!is.na(result$agenda_item)))
  expect_true(any(!is.na(result$stage_date)))
  expect_true(all(
    is.na(result$stage_fsth_url) |
      grepl("^https://www.parlament.gv.at|^/", result$stage_fsth_url)
  ))
})

test_that("get_plenary_meeting_details supports BR meetings in mocked mode", {
  result <- run_api_call(
    get_plenary_meeting_details(
      institution = "BR",
      legis_period = 27,
      meeting_number = 898
    ),
    fixture_subdir = "get_plenary_meeting_details"
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_match(result$meeting_citation, "BRSITZ", fixed = TRUE)
})
