test_that("get_items returns correct structure with valid parameters", {
  skip_on_cran()
  skip_if_offline()

  # Test basic functionality with minimal parameters
  result <- get_items(
    institution = "NR",
    item = "ANTR",
    date_start = "01-01-2024",
    date_end = "31-01-2026",
    echo = TRUE
  )

  expect_s3_class(result, "data.frame")
  expect_true(ncol(result) > 0)
  expect_true(
    nrow(result |> dplyr::count(item_url) |> dplyr::filter(n > 1)) == 0
  ) # check for duplicates
})

test_that("get_items handles invalid date formats", {
  expect_error(
    get_items(date_start = "2025-01-01"),
    "date_start must be a valid date in format dd-mm-yyyy, dd.mm.yyyy, or dd/mm/yyyy"
  )

  expect_error(
    get_items(date_end = "invalid-date"),
    "date_end must be a valid date in format dd-mm-yyyy, dd.mm.yyyy, or dd/mm/yyyy"
  )
})

test_that("get_items accepts multiple date formats", {
  skip_on_cran()
  skip_if_offline()

  # Test that all three date formats return the same result
  result1 <- get_items(
    date_start = "01-01-2024",
    date_end = "01-03-2024",
    echo = FALSE
  )
  expect_s3_class(result1, "data.frame")
  expect_equal(nrow(result1), 2526)

  result2 <- get_items(
    date_start = "01.01.2024",
    date_end = "01.03.2024",
    echo = FALSE
  )
  expect_s3_class(result2, "data.frame")
  expect_equal(nrow(result2), 2526)

  result3 <- get_items(
    date_start = "01/01/2024",
    date_end = "01/03/2024",
    echo = FALSE
  )
  expect_s3_class(result3, "data.frame")
  expect_equal(nrow(result3), 2526)
})

test_that("get_items validates institution parameter", {
  expect_error(
    get_items(institution = "INVALID"),
    "Must be a subset of"
  )
})

test_that("get_items validates topic parameter", {
  expect_error(
    get_items(topic = "Invalid Topic"),
    "Must be a subset of"
  )
})

test_that("get_items validates item parameter", {
  expect_error(
    get_items(item = "INVALID"),
    "Must be a subset of"
  )
})

test_that("get_items validates parl_group parameter", {
  expect_error(
    get_items(parl_group = "INVALID"),
    "Must be a subset of"
  )
})

test_that("get_items handles empty results gracefully", {
  skip_on_cran()
  skip_if_offline()

  # Use parameters likely to return no results
  result <- get_items(
    topic = "Wirtschaft",
    date_start = "01-01-1900",
    date_end = "02-01-1900",
    echo = FALSE
  )

  expect_null(result)
})

test_that("get_items works with multiple parameters", {
  skip_on_cran()
  skip_if_offline()

  result <- get_items(
    institution = "NR",
    topic = "Bildung",
    legis_period = "27",
    echo = FALSE
  )

  expect_true(is.data.frame(result) || is.null(result))
  if (!is.null(result)) {
    expect_true(ncol(result) > 0)
  }
})

test_that("get_items works with multiple topics", {
  skip_on_cran()
  skip_if_offline()

  result <- get_items(
    institution = "NR",
    topic = c("Sport", "Landesverteidigung"),
    legis_period = "27"
  )

  expect_true(nrow(result) == 2013)
})

test_that("get_items works with multiple legis_periods and different input forms", {
  skip_on_cran()
  skip_if_offline()

  # Test with mixed input forms: numeric, character numeric, and historical abbreviations
  result <- get_items(
    legis_period = c("KN", "PN", 10, "15"),
    institution = "NR",
    echo = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 11212)

  # Check that all expected legislative periods are present in the results
  expected_periods <- c("KN", "PN", "X", "XV")
  actual_periods <- unique(result$legis_period)
  expect_true(all(expected_periods %in% actual_periods))
})

test_that("get_items validates doc_type for ANTR items in NR", {
  expect_error(
    get_items(item = "ANTR", doc_type = "INVALID", institution = "NR"),
    "Must be a subset of"
  )
})

test_that("get_items validates doc_type for ANTR items in BR", {
  expect_error(
    get_items(item = "ANTR", doc_type = "INVALID", institution = "BR"),
    "Must be a subset of"
  )
})

test_that("get_items validates doc_type for BNR items", {
  expect_error(
    get_items(item = "BNR", doc_type = "INVALID", institution = "NR"),
    "Must be a subset of"
  )
})

test_that("get_items validates doc_type without item", {
  expect_error(
    get_items(doc_type = "A"),
    "'doc_type' can be only specified in combination with 'item'"
  )
})

test_that("get_items validates number parameter", {
  expect_error(
    get_items(number = c("123", "456")),
    "Must have length 1"
  )

  expect_error(
    get_items(number = c(123, 456)),
    "Must have length 1"
  )

  # Test that numeric input is accepted and converted
  expect_silent(
    get_items(number = 123, echo = FALSE)
  )
})

test_that("get_items validates keyword parameter", {
  expect_error(
    get_items(keyword = "Invalid Keyword"),
    "Must be a subset of"
  )
})

test_that("get_items validates eurovoc parameter", {
  expect_error(
    get_items(eurovoc = 123),
    "Must be of type 'character'"
  )
})

test_that("get_items works with NULL institution (both chambers)", {
  skip_on_cran()
  skip_if_offline()

  result <- get_items(
    item = "RV",
    legis_period = "27",
    echo = FALSE
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items works with search_string parameter", {
  skip_on_cran()
  skip_if_offline()

  result <- get_items(
    search_string = "Gesundheit",
    legis_period = "27",
    echo = FALSE
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items works with number parameter", {
  skip_on_cran()
  skip_if_offline()

  result <- get_items(
    number = "1",
    legis_period = "27",
    echo = FALSE
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items works with valid keyword", {
  skip_on_cran()
  skip_if_offline()

  result <- get_items(
    keyword = "Gesundheit",
    legis_period = "27",
    echo = FALSE
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items works with valid eurovoc", {
  skip_on_cran()
  skip_if_offline()

  result <- get_items(
    eurovoc = "health",
    legis_period = "27",
    echo = FALSE
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items parl_group_names_standard works", {
  skip_on_cran()
  skip_if_offline()

  # Test that the standardization function is called
  result <- get_items(
    parl_group = "SPÖ",
    parl_group_names_standard = TRUE,
    legis_period = "27",
    echo = FALSE
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items echo parameter works", {
  skip_on_cran()
  skip_if_offline()

  # Test with echo = TRUE (should print output)
  expect_output(
    get_items(
      item = "RV",
      legis_period = "27",
      echo = TRUE
    ),
    "https://www.parlament.gv.at"
  )

  # Test with echo = FALSE (should not print)
  expect_silent(
    get_items(
      item = "RV",
      legis_period = "27",
      echo = FALSE
    )
  )
})

test_that("get_items returns consistent columns across item types (tidyverse, legis_period = 27)", {
  skip_on_cran()
  skip_if_offline()

  items <- c(
    "ASEU",
    "AS",
    "J_JPR_M",
    "ANTR",
    "US",
    "AUB",
    "AB_ABPR_ABM",
    "III",
    "BNR",
    "BI",
    "E",
    "EBR",
    "EU",
    "FS",
    "GO",
    "GABR",
    "GABR13",
    "IMM",
    "KOMM",
    "PET",
    "RGER",
    "RV",
    "RVS",
    "TRAU",
    "RVS15",
    "VOLKBG",
    "W"
  )

  cols_df <- tibble::tibble(item = items) |>
    dplyr::mutate(
      res = purrr::map(
        item,
        ~ get_items(item = .x, legis_period = 27, echo = FALSE)
      ),
      cols = purrr::map(
        res,
        ~ if (is.null(.x)) NA_character_ else sort(names(.x))
      )
    )

  # Unnest so every column name gets its own row
  cols_unnested <- cols_df |>
    dplyr::select(-res) |>
    tidyr::unnest_longer(cols, values_to = "col_name")

  # Transform to wide: make each unique `col_name` a column and put the `item` value
  # into the corresponding cells (NA when an item does not have that column).
  cols_wide <- cols_unnested |>
    dplyr::filter(!is.na(col_name)) |>
    dplyr::mutate(.val = item) |>
    tidyr::pivot_wider(
      id_cols = item,
      names_from = col_name,
      values_from = .val,
      values_fill = NA_character_
    )

  # keep rows where at least one (non-id) column contains NA
  cols_wide_na <- cols_wide |>
    # dplyr::filter(dplyr::if_any(-dplyr::all_of("item"), ~ is.na(.x)))
    dplyr::filter(dplyr::if_any(everything(), ~ is.na(.x)))

  expect_true(nrow(cols_wide_na) == 0)
})

test_that("get_items returns a dataframe with a 'stage' column", {
  skip_on_cran()
  skip_if_offline()

  result <- get_items(
    institution = "NR",
    item = "ANTR",
    legis_period = "27",
    echo = FALSE
  )

  expect_s3_class(result, "data.frame")
  expect_true("stage" %in% names(result))
})

test_that("get_items returns no duplicates for topic Europäische Union and legis_period 28", {
  skip_on_cran()
  skip_if_offline()

  result <- get_items(
    topic = "Europäische Union",
    legis_period = 28,
    echo = FALSE
  )

  expect_true(nrow(result) == dplyr::n_distinct(result))
})

# Tests for get_item_details() -----------------------------------------------

test_that("get_item_details returns correct structure with absolute URL", {
  skip_on_cran()
  skip_if_offline()

  # Use a known item URL
  item_url <- "https://www.parlament.gv.at/gegenstand/XXVII/GAST/2"
  result <- get_item_details(item_url)

  expect_s3_class(result, "data.frame")
  expect_true(ncol(result) > 0)
  expect_true(nrow(result) > 0)
})

test_that("get_item_details works with relative URL", {
  skip_on_cran()
  skip_if_offline()

  # Test relative path normalization
  result <- get_item_details("/gegenstand/XXVIII/BI/24")

  expect_s3_class(result, "data.frame")
  expect_true(ncol(result) > 0)
})


test_that("get_item_details text column contains character data", {
  skip_on_cran()
  skip_if_offline()

  item_url <- "https://www.parlament.gv.at/gegenstand/XXVIII/BI/24"
  result <- get_item_details(item_url)

  # Verify text column is character type
  expect_type(result$text, "character")
})

test_that("get_item_details handles URL normalization correctly", {
  skip_on_cran()
  skip_if_offline()

  # Test that absolute and relative URLs return the same data
  absolute_url <- "https://www.parlament.gv.at/gegenstand/XXVIII/BI/24"
  relative_url <- "/gegenstand/XXVIII/BI/24"
  relative_no_slash <- "gegenstand/XXVIII/BI/24"

  result_absolute <- get_item_details(absolute_url)
  result_relative <- get_item_details(relative_url)
  result_no_slash <- get_item_details(relative_no_slash)

  # All should return same number of rows
  expect_equal(nrow(result_absolute), nrow(result_relative))
  expect_equal(nrow(result_absolute), nrow(result_no_slash))
})
