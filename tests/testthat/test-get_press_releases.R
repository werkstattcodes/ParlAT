# Tests for get_press_releases()

test_that("get_press_releases returns a data frame", {
  result <- run_api_call(
    {
      get_press_releases(category = "Bundesrat", year = 2024, echo = FALSE)
    },
    fixture_subdir = "get_press_releases"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_press_releases returns correct column names", {
  result <- run_api_call(
    {
      get_press_releases(category = "Bundesrat", year = 2024, echo = FALSE)
    },
    fixture_subdir = "get_press_releases"
  )

  expected_cols <- c(
    "date", "number", "title", "subtitle", "url",
    "topics", "category", "keywords"
  )
  expect_true(all(expected_cols %in% names(result)))
})

test_that("get_press_releases date column is class Date", {
  result <- run_api_call(
    {
      get_press_releases(category = "Bundesrat", year = 2024, echo = FALSE)
    },
    fixture_subdir = "get_press_releases"
  )

  expect_s3_class(result$date, "Date")
})

test_that("get_press_releases url column is fully qualified", {
  result <- run_api_call(
    {
      get_press_releases(category = "Bundesrat", year = 2024, echo = FALSE)
    },
    fixture_subdir = "get_press_releases"
  )

  expect_true(all(grepl("^https://www\\.parlament\\.gv\\.at", result$url)))
})

test_that("get_press_releases list columns are lists", {
  result <- run_api_call(
    {
      get_press_releases(category = "Bundesrat", year = 2024, echo = FALSE)
    },
    fixture_subdir = "get_press_releases"
  )

  expect_type(result$topics,   "list")
  expect_type(result$category, "list")
  expect_type(result$keywords, "list")
})

test_that("get_press_releases filters by category", {
  result_br <- run_api_call(
    {
      get_press_releases(category = "Bundesrat", year = 2024, echo = FALSE)
    },
    fixture_subdir = "get_press_releases"
  )

  result_pl <- run_api_call(
    {
      get_press_releases(
        category = "Plenarsitzungen des Nationalrats",
        year = 2024,
        echo = FALSE
      )
    },
    fixture_subdir = "get_press_releases"
  )

  expect_false(identical(result_br, result_pl))
})

test_that("get_press_releases filters by year", {
  result_2023 <- run_api_call(
    {
      get_press_releases(category = "Bundesrat", year = 2023, echo = FALSE)
    },
    fixture_subdir = "get_press_releases"
  )

  result_2024 <- run_api_call(
    {
      get_press_releases(category = "Bundesrat", year = 2024, echo = FALSE)
    },
    fixture_subdir = "get_press_releases"
  )

  skip_if_live("Row counts depend on live API state")
  expect_false(identical(result_2023, result_2024))
})

test_that("get_press_releases accepts multiple years", {
  result <- run_api_call(
    {
      get_press_releases(
        category = "Bundesrat",
        year = c(2023, 2024),
        echo = FALSE
      )
    },
    fixture_subdir = "get_press_releases"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  # Both years should be present
  expect_true(all(c("2023", "2024") %in% format(result$date, "%Y")))
})

test_that("get_press_releases search_string returns fewer results than unfiltered", {
  result_all <- run_api_call(
    {
      get_press_releases(year = 2024, echo = FALSE)
    },
    fixture_subdir = "get_press_releases"
  )

  result_filtered <- run_api_call(
    {
      get_press_releases(search_string = "Budget", year = 2024, echo = FALSE)
    },
    fixture_subdir = "get_press_releases"
  )

  expect_true(nrow(result_filtered) < nrow(result_all))
})

test_that("get_press_releases filters by topic", {
  result <- run_api_call(
    {
      get_press_releases(
        topic = "Klima, Umwelt und Energie",
        year = 2024,
        echo = FALSE
      )
    },
    fixture_subdir = "get_press_releases"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_press_releases filters by keyword", {
  result <- run_api_call(
    {
      get_press_releases(keyword = "Nationalrat", year = 2024, echo = FALSE)
    },
    fixture_subdir = "get_press_releases"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_press_releases returns NULL for no results", {
  result <- run_api_call(
    {
      get_press_releases(
        keyword = "DieserBegriffExistiertNicht99999",
        echo = FALSE
      )
    },
    fixture_subdir = "get_press_releases"
  )

  expect_null(result)
})

test_that("get_press_releases is sorted descending by date", {
  result <- run_api_call(
    {
      get_press_releases(category = "Bundesrat", year = 2024, echo = FALSE)
    },
    fixture_subdir = "get_press_releases"
  )

  if (nrow(result) > 1) {
    expect_true(all(diff(as.integer(result$date)) <= 0))
  }
})

test_that("get_press_releases respects echo = FALSE", {
  expect_silent(
    run_api_call(
      {
        get_press_releases(category = "Bundesrat", year = 2024, echo = FALSE)
      },
      fixture_subdir = "get_press_releases"
    )
  )
})

test_that("get_press_releases rejects invalid category", {
  expect_error(
    get_press_releases(category = "InvalidCategory", echo = FALSE),
    "Must be a subset of"
  )
})

test_that("get_press_releases rejects invalid topic", {
  expect_error(
    get_press_releases(topic = "InvalidTopic", echo = FALSE),
    "Must be a subset of"
  )
})
