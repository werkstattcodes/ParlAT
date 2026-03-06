# Test parameter validation

test_that("get_mps_details validates detail_type parameter", {
  expect_error(
    get_mps_details(pad_intern = 145),
    "`detail_type` is a required parameter"
  )

  expect_error(
    get_mps_details(pad_intern = 145, detail_type = NULL),
    "`detail_type` is a required parameter"
  )

  expect_error(
    get_mps_details(pad_intern = 145, detail_type = "invalid"),
    "Must be element of set"
  )
})

test_that("get_mps_details validates pad_intern parameter", {
  expect_error(
    get_mps_details(pad_intern = -999, detail_type = "plenary"),
    "`pad_intern` can only contain numeric characters"
  )
})

test_that("get_mps_details validates institution parameter", {
  expect_no_error(
    run_api_call(
      {
        get_mps_details(
          pad_intern = 145,
          detail_type = "plenary",
          institution = "NR",
          echo = FALSE
        )
      },
      fixture_subdir = "get_mps_details"
    )
  )

  expect_no_error(
    run_api_call(
      {
        get_mps_details(
          pad_intern = 145,
          detail_type = "plenary",
          institution = "BR",
          echo = FALSE
        )
      },
      fixture_subdir = "get_mps_details"
    )
  )
})

test_that("get_mps_details validates item parameter usage", {
  expect_error(
    get_mps_details(
      pad_intern = 145,
      detail_type = "plenary",
      item = "A"
    ),
    "`item` is only supported for details type 'activities'"
  )

  expect_error(
    get_mps_details(
      pad_intern = 145,
      detail_type = "committees",
      item = "A"
    ),
    "`item` is only supported for details type 'activities'"
  )
})

test_that("get_mps_details validates item choices for activities", {
  expect_no_error(
    run_api_call(
      {
        get_mps_details(
          pad_intern = 145,
          detail_type = "activities",
          item = "A",
          echo = FALSE
        )
      },
      fixture_subdir = "get_mps_details"
    )
  )

  expect_error(
    get_mps_details(
      pad_intern = 145,
      detail_type = "activities",
      item = "INVALID"
    ),
    "Must be element of set"
  )
})

test_that("get_mps_details validates search_string usage", {
  expect_error(
    get_mps_details(
      pad_intern = 145,
      detail_type = "plenary",
      search_string = "test",
      echo = FALSE
    ),
    "search_string is only supported for details type 'activities' and 'committees'"
  )
})

# Test function dispatch

test_that("get_mps_details dispatches to correct sub-functions", {
  # Test plenary dispatch
  result_plenary <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "plenary",
        legis_period = 27,
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )
  expect_s3_class(result_plenary, "data.frame")
  expect_equal(nrow(result_plenary), 2)

  # Test activities dispatch
  result_activities <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "activities",
        legis_period = 22,
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )
  expect_s3_class(result_activities, "data.frame")
  expect_equal(nrow(result_activities), 38)

  # Test committees dispatch
  result_committees <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "committees",
        legis_period = 26,
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )
  expect_s3_class(result_committees, "data.frame")
})

# Test plenary details functionality

test_that("get_mps_details plenary returns expected structure", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "plenary",
        institution = "NR",
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")

  expected_cols <- c(
    "pad_intern",
    "name",
    "position_name",
    "date",
    "legis_period",
    "institution",
    "speech_title",
    "meeting_url",
    "meeting_name",
    "speech_transcript_url",
    "speech_media_url"
  )

  expect_true(all(expected_cols %in% colnames(result)))

  # Check data types
  expect_type(result$pad_intern, "character")
  expect_s3_class(result$date, "Date")
  expect_type(result$institution, "character")
})

test_that("get_mps_details plenary filters by institution", {
  result_nr <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "plenary",
        institution = "NR",
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  if (nrow(result_nr) > 0) {
    expect_true(all(result_nr$institution == "NR"))
  }
})

test_that("get_mps_details plenary filters by legis_period", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "plenary",
        legis_period = 27,
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  if (nrow(result) > 0) {
    expect_true(all(result$legis_period == "XXVII"))
  }
})

test_that("get_mps_details plenary accepts Roman numeral legis_period", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "plenary",
        legis_period = "XXVII",
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")
})

# Test activities details functionality

test_that("get_mps_details activities returns expected structure", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "activities",
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")

  expected_cols <- c(
    "pad_intern",
    "legis_period",
    "institution",
    "frmdate",
    "ityp_komm",
    "item_number",
    "item_type",
    "title",
    "date_updated",
    "item_url",
    "status_text",
    "status_numeric"
  )

  # Check that at least some expected columns are present
  common_cols <- intersect(expected_cols, colnames(result))
  expect_true(length(common_cols) > 5)
})

test_that("get_mps_details activities filters by item type", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "activities",
        item = "A",
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")

  if (nrow(result) > 0) {
    expect_true(all(result$item_type == "A"))
  }
})

test_that("get_mps_details activities filters by institution", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "activities",
        institution = "NR",
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")

  if (nrow(result) > 0) {
    expect_true(all(result$institution == "NR"))
  }
})

# Test committees details functionality

test_that("get_mps_details committees returns expected structure", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "committees",
        legis_period = 27,
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")
})

test_that("get_mps_details committees requires legis_period", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "committees",
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")
})

# Test multiple pad_intern values

test_that("get_mps_details does not accept multiple pad_intern values", {
  expect_error(
    get_mps_details(
      pad_intern = c(145, 2345),
      detail_type = "plenary",
      echo = FALSE
    )
  )
})

# Test echo parameter

test_that("get_mps_details echo parameter works", {
  skip_if_mocked("Echo output testing requires live API")
  skip_if_offline()

  # Test that echo = TRUE produces output
  expect_no_error({
    get_mps_details(
      pad_intern = 145,
      detail_type = "plenary",
      echo = TRUE
    )
  })
})

# Test edge cases

test_that("get_mps_details handles empty results gracefully", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 2345,
        detail_type = "plenary",
        legis_period = 20,
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_true(is.null(result) || (is.data.frame(result) && nrow(result) >= 0))
})

test_that("get_mps_details validates legis_period minimum value", {
  expect_error(
    get_mps_details(
      pad_intern = 145,
      detail_type = "plenary",
      legis_period = 5,
      echo = FALSE
    ),
    "Only data from the 20th legislative period onwards can be queried"
  )

  expect_error(
    get_mps_details(
      pad_intern = 145,
      detail_type = "activities",
      legis_period = 15,
      echo = FALSE
    ),
    "Only data from the 20th legislative period onwards can be queried"
  )

  expect_error(
    get_mps_details(
      pad_intern = 145,
      detail_type = "committees",
      legis_period = 19,
      echo = FALSE
    ),
    "Only data from the 20th legislative period onwards can be queried"
  )
})

# Test search_string functionality

test_that("get_mps_details search_string works for activities", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "activities",
        search_string = "test",
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")
})

test_that("get_mps_details search_string works for committees", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "committees",
        legis_period = 27,
        search_string = "test",
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")
})

# Test committee-specific parameters

test_that("get_mps_details committee parameters work", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 2344,
        detail_type = "committees",
        legis_period = 26,
        committee = "Volksanwaltschaftsausschuss",
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")
})

test_that("get_mps_details committee_position parameter works", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "committees",
        legis_period = 27,
        committee_position = "Mitglied",
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")
})

# Test multiple legis_periods functionality

test_that("get_mps_details accepts multiple legis_periods for plenary", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "plenary",
        legis_period = c(26, 27),
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")

  if (nrow(result) > 0) {
    unique_periods <- unique(result$legis_period)
    expect_true(length(unique_periods) >= 1)
    expect_true(all(unique_periods %in% c("XXVI", "XXVII")))
  }
})

test_that("get_mps_details accepts multiple legis_periods for activities", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "activities",
        legis_period = c(22, 23),
        institution = "NR",
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")

  if (nrow(result) > 0) {
    unique_periods <- unique(result$legis_period)
    expect_true(length(unique_periods) >= 1)
    expect_true(all(unique_periods %in% c("XXII", "XXIII")))
  }
})

test_that("get_mps_details accepts multiple legis_periods for committees", {
  result <- run_api_call(
    {
      get_mps_details(
        pad_intern = 145,
        detail_type = "committees",
        legis_period = c(25, 26),
        echo = FALSE
      )
    },
    fixture_subdir = "get_mps_details"
  )

  expect_s3_class(result, "data.frame")

  if (nrow(result) > 0) {
    unique_periods <- unique(result$legis_period)
    expect_true(length(unique_periods) >= 1)
    expect_true(all(unique_periods %in% c("XXV", "XXVI")))
  }
})
