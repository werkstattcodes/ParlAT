test_that("get_plenary_meetings returns valid data structure", {
  x <- run_api_call({
    get_plenary_meetings(
      institution = "NR",
      legis_period = 28,
      meeting_and_activities = "meetings"
    )
  }, fixture_subdir = "get_plenary_meetings")

  expect_true(is.data.frame(x))
  expect_gt(nrow(x), 0)

  expected_cols <- c("institution", "legis_period", "date", "meeting_number")
  expect_true(all(expected_cols %in% colnames(x)))

  expect_true(is.character(x$institution))
  expect_s3_class(x$date, "Date")
  expect_true(is.character(x$meeting_number) || is.numeric(x$meeting_number))

  expect_true(all(x$institution == "NR"))
  expect_true(all(x$legis_period == as.character(28)))
})

test_that("get_plenary_meetings meetings mode returns expected columns", {
  x <- run_api_call({
    get_plenary_meetings(
      institution = "NR",
      meeting_and_activities = "meetings",
      legis_period = 28
    )
  }, fixture_subdir = "get_plenary_meetings")

  expected_cols <- c(
    "institution", "legis_period", "date", "meeting_number",
    "meeting_url", "meeting_type", "meeting_title", "session_type",
    "agenda_url_html", "agenda_url_pdf"
  )
  expect_true(all(expected_cols %in% colnames(x)))

  expect_true(is.character(x$meeting_type))
  expect_true(is.character(x$session_type))

  # Agenda URL columns are character (not list)
  expect_true(is.character(x$agenda_url_html))
  expect_true(is.character(x$agenda_url_pdf))

  non_na_html <- x$agenda_url_html[!is.na(x$agenda_url_html)]
  non_na_pdf <- x$agenda_url_pdf[!is.na(x$agenda_url_pdf)]

  if (length(non_na_html) > 0) {
    expect_true(all(stringr::str_starts(non_na_html, "https://www.parlament.gv.at")))
  }
  if (length(non_na_pdf) > 0) {
    expect_true(all(stringr::str_starts(non_na_pdf, "https://www.parlament.gv.at")))
  }
})

test_that("get_plenary_meetings activities mode returns expected columns", {
  x <- run_api_call({
    get_plenary_meetings(
      institution = "NR",
      legis_period = 27,
      meeting_and_activities = "activities"
    )
  }, fixture_subdir = "get_plenary_meetings")

  expect_true(is.data.frame(x))
  expect_gt(nrow(x), 0)

  expected_cols <- c(
    "institution", "legis_period", "date", "title",
    "url_item", "meeting_number", "url_meeting", "session_type",
    "activity_type", "doc_type", "citation"
  )
  expect_true(all(expected_cols %in% colnames(x)))

  expect_true(is.character(x$title))
  expect_true(is.character(x$activity_type))
  expect_true(is.character(x$session_type))

  non_na_item <- x$url_item[!is.na(x$url_item)]
  if (length(non_na_item) > 0) {
    expect_true(all(stringr::str_starts(non_na_item, "https://www.parlament.gv.at")))
  }

  non_na_meeting <- x$url_meeting[!is.na(x$url_meeting)]
  if (length(non_na_meeting) > 0) {
    expect_true(all(stringr::str_starts(non_na_meeting, "https://www.parlament.gv.at")))
  }
})

test_that("get_plenary_meetings adds URL prefix to meeting_url", {
  x <- run_api_call({
    get_plenary_meetings(
      institution = "NR",
      legis_period = 28,
      meeting_and_activities = "meetings"
    )
  }, fixture_subdir = "get_plenary_meetings")

  if (!is.null(x) && nrow(x) > 0 && "meeting_url" %in% colnames(x)) {
    non_na_urls <- x$meeting_url[!is.na(x$meeting_url)]
    if (length(non_na_urls) > 0) {
      expect_true(all(stringr::str_starts(non_na_urls, "https://www.parlament.gv.at")))
    }
  }
})

test_that("get_plenary_meetings works with BR and NR institutions", {
  for (inst in c("BR", "NR")) {
    for (mode in c("meetings", "activities")) {
      x <- run_api_call({
        get_plenary_meetings(
          institution = inst,
          legis_period = 27,
          meeting_and_activities = mode
        )
      }, fixture_subdir = "get_plenary_meetings")

      expect_true(
        is.data.frame(x),
        info = paste("Failed for", inst, mode)
      )

      if (!is.null(x) && nrow(x) > 0 && "institution" %in% colnames(x)) {
        expect_true(
          all(x$institution == inst),
          info = paste("Institution filter failed for", inst, mode)
        )
      }
    }
  }
})

test_that("get_plenary_meetings filters by session_type", {
  x <- run_api_call({
    get_plenary_meetings(
      institution = "NR",
      legis_period = 28,
      meeting_and_activities = "meetings",
      session_type = "N"
    )
  }, fixture_subdir = "get_plenary_meetings")

  expect_true(is.data.frame(x) || is.null(x))

  if (!is.null(x) && nrow(x) > 0) {
    expect_true("session_type" %in% colnames(x))
    expect_true(all(x$session_type == "N"))
    expect_s3_class(x$date, "Date")
  }
})

test_that("get_plenary_meetings filters by meeting_type", {
  x <- run_api_call({
    get_plenary_meetings(
      institution = "NR",
      legis_period = 28,
      meeting_and_activities = "meetings",
      meeting_type = "S"
    )
  }, fixture_subdir = "get_plenary_meetings")

  expect_true(is.data.frame(x) || is.null(x))

  if (!is.null(x) && nrow(x) > 0) {
    expect_true("meeting_type" %in% colnames(x))
    expect_true(all(x$meeting_type == "S"))
    expect_s3_class(x$date, "Date")
  }
})

test_that("get_plenary_meetings works with BV institution", {
  x <- run_api_call({
    get_plenary_meetings(
      institution = "BV",
      legis_period = NULL
    )
  }, fixture_subdir = "get_plenary_meetings")

  expect_true(is.data.frame(x) || is.null(x))
})

test_that("get_plenary_meetings BV does not include legis_period column", {
  x <- run_api_call({
    get_plenary_meetings(
      institution = "BV",
      legis_period = NULL
    )
  }, fixture_subdir = "get_plenary_meetings")

  if (!is.null(x) && nrow(x) > 0) {
    expect_false(
      "legis_period" %in% colnames(x),
      info = "BV results should not include legis_period column"
    )
    expect_true("institution" %in% colnames(x))
    expect_true("date" %in% colnames(x))
    expect_true(all(x$institution == "BV"))
  }
})

test_that("get_plenary_meetings validates BV institution parameters", {
  expect_error(
    get_plenary_meetings(
      institution = "BV",
      legis_period = NULL,
      meeting_and_activities = "meetings"
    )
  )

  expect_error(
    get_plenary_meetings(
      institution = "BV",
      legis_period = 27
    ),
    "legis_period must be NULL for institution 'BV'"
  )
})

test_that("get_plenary_meetings validates parameters correctly", {
  expect_error(
    get_plenary_meetings(institution = "INVALID", legis_period = 27),
    "Must be a subset of"
  )

  expect_error(
    get_plenary_meetings(institution = NULL, legis_period = 27),
    "not empty"
  )

  expect_error(
    get_plenary_meetings(
      institution = "NR",
      legis_period = 27,
      meeting_and_activities = "invalid"
    ),
    "Must be a subset of"
  )

  expect_error(
    get_plenary_meetings(institution = "NR", legis_period = "invalid"),
    "Invalid legislative period"
  )

  expect_error(
    get_plenary_meetings(
      institution = "NR",
      legis_period = 28,
      meeting_and_activities = "meetings",
      session_type = "INVALID"
    ),
    "Must be a subset of"
  )

  expect_error(
    get_plenary_meetings(
      institution = "NR",
      legis_period = 28,
      meeting_and_activities = "meetings",
      meeting_type = "INVALID"
    ),
    "Must be a subset of"
  )
})

test_that("get_plenary_meetings handles multiple legislative periods", {
  x <- run_api_call({
    get_plenary_meetings(
      institution = "NR",
      legis_period = c(27, 28),
      meeting_and_activities = "meetings"
    )
  }, fixture_subdir = "get_plenary_meetings")

  expect_true(is.data.frame(x) || is.null(x))
})

test_that("get_plenary_meetings handles NULL legislative period", {
  x <- run_api_call({
    get_plenary_meetings(
      institution = "NR",
      legis_period = NULL,
      meeting_and_activities = "meetings"
    )
  }, fixture_subdir = "get_plenary_meetings")

  expect_true(is.data.frame(x) || is.null(x))

  if (!is.null(x) && nrow(x) > 0) {
    expect_true(length(unique(x$legis_period)) > 1)
  }
})

test_that("get_plenary_meetings validates legis_period >= 20", {
  expect_error(
    get_plenary_meetings(
      institution = "NR",
      legis_period = 1,
      meeting_and_activities = "meetings"
    ),
    "Only data from the 20th legislative period onwards can be queried"
  )

  expect_error(
    get_plenary_meetings(
      institution = "NR",
      legis_period = 19,
      meeting_and_activities = "activities"
    ),
    "Only data from the 20th legislative period onwards can be queried"
  )
})
