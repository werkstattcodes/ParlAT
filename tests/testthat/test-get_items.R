test_that("get_items returns correct structure with valid parameters", {
  # Test basic functionality with minimal parameters
  result <- run_api_call(
    {
      get_items(
        institution = "NR",
        item = "ANTR",
        date_start = "01-01-2024",
        date_end = "31-01-2026",
        echo = TRUE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_s3_class(result, "data.frame")
  expect_true(ncol(result) > 0)
  expect_true(
    nrow(result %>% dplyr::count(item_url) %>% dplyr::filter(n > 1)) == 0
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

test_that("get_items validates date_start must be <= date_end", {
  # date_start after date_end should error
  expect_error(
    get_items(date_start = "31-12-2024", date_end = "01-01-2024"),
    "date_start must be before or equal to date_end"
  )

  # Equal dates should work
  expect_no_error(
    get_items(date_start = "01-01-2024", date_end = "01-01-2024")
  )
})

test_that("get_items accepts multiple date formats", {
  # Test that all three date formats return the same result
  result1 <- run_api_call(
    {
      get_items(
        date_start = "01-01-2024",
        date_end = "01-03-2024",
        echo = TRUE
      )
    },
    fixture_subdir = "get_items"
  )
  expect_s3_class(result1, "data.frame")
  expect_equal(nrow(result1), 2526)

  result2 <- run_api_call(
    {
      get_items(
        date_start = "01.01.2024",
        date_end = "01.03.2024",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )
  expect_s3_class(result2, "data.frame")
  expect_equal(nrow(result2), 2526)

  result3 <- run_api_call(
    {
      get_items(
        date_start = "01/01/2024",
        date_end = "01/03/2024",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
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

test_that("get_items rejects legis_period before 5th period", {
  expect_error(get_items(legis_period = 4), "5th legislative period")
  expect_error(get_items(legis_period = "3"), "5th legislative period")
  expect_error(get_items(legis_period = c(2, 27)), "5th legislative period")
  expect_error(get_items(legis_period = "PN"), "5th legislative period")
  expect_error(get_items(legis_period = "KN"), "5th legislative period")
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
  # Use parameters likely to return no results
  result <- run_api_call(
    {
      get_items(
        topic = "Wirtschaft",
        date_start = "01-01-1900",
        date_end = "02-01-1900",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_null(result)
})

test_that("get_items works with multiple parameters", {
  result <- run_api_call(
    {
      get_items(
        institution = "NR",
        topic = "Bildung",
        legis_period = "27",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
  if (!is.null(result)) {
    expect_true(ncol(result) > 0)
  }
})

test_that("get_items works with multiple topics", {
  result <- run_api_call(
    {
      get_items(
        institution = "NR",
        topic = c("Sport", "Landesverteidigung"),
        legis_period = "27"
      )
    },
    fixture_subdir = "get_items"
  )

  expect_equal(nrow(result), 2013)
})

test_that("get_items works with multiple legis_periods and different input forms", {
  # Test with mixed input forms: numeric, character numeric, and historical abbreviations
  result <- run_api_call(
    {
      get_items(
        legis_period = c("KN", "PN", 10, "15"),
        institution = "NR",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 11212)

  # Check that all expected legislative periods are present in the results
  expected_periods <- c("KN", "PN", "X", "XV")
  actual_periods <- unique(result$legis_period)
  expect_true(all(expected_periods %in% actual_periods))
})

test_that("get_items validates type_doc for ANTR items in NR", {
  expect_error(
    get_items(item = "ANTR", type_doc = "INVALID", institution = "NR"),
    "Must be a subset of"
  )
})

test_that("get_items validates type_doc for ANTR items in BR", {
  expect_error(
    get_items(item = "ANTR", type_doc = "INVALID", institution = "BR"),
    "Must be a subset of"
  )
})

test_that("get_items validates type_doc for BNR items", {
  expect_error(
    get_items(item = "BNR", type_doc = "INVALID", institution = "NR"),
    "Must be a subset of"
  )
})

test_that("get_items validates type_doc for J_JPR_M items in NR", {
  expect_error(
    get_items(item = "J_JPR_M", type_doc = "INVALID", institution = "NR"),
    "Must be a subset of"
  )
})

test_that("get_items validates type_doc for J_JPR_M items in BR", {
  expect_error(
    get_items(item = "J_JPR_M", type_doc = "INVALID", institution = "BR"),
    "Must be a subset of"
  )
})

test_that("get_items validates type_doc without item", {
  expect_error(
    get_items(type_doc = "A"),
    "'type_doc' can be only specified in combination with 'item'"
  )
})

# Test removed: 'number' parameter was deprecated and removed from get_items()
# See git history for previous implementation

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
  result <- run_api_call(
    {
      get_items(
        item = "RV",
        legis_period = "27",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
})

# Test removed: 'search_string' parameter was deprecated and removed from get_items()
# See git history for previous implementation

# Test removed: 'number' parameter was deprecated and removed from get_items()
# See git history for previous implementation

test_that("get_items works with valid keyword", {
  result <- run_api_call(
    {
      get_items(
        keyword = "Gesundheit",
        legis_period = "27",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items works with valid eurovoc", {
  result <- run_api_call(
    {
      get_items(
        eurovoc = "health",
        legis_period = "27",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items parl_group_names_standard works", {
  # Test that the standardization function is called
  result <- run_api_call(
    {
      get_items(
        parl_group = "SPÖ",
        parl_group_names_standard = TRUE,
        legis_period = "27",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items echo parameter works", {
  skip_on_cran()
  # This test checks console output behavior - run only in live mode
  skip_if_mocked("Echo output testing requires live API")

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
  # This is a comprehensive integration test - run only in live mode
  skip_if_mocked("Complex integration test across all item types")

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

  cols_df <- tibble::tibble(item = items) %>%
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
  cols_unnested <- cols_df %>%
    dplyr::select(-res) %>%
    tidyr::unnest_longer(cols, values_to = "col_name")

  # Transform to wide: make each unique `col_name` a column and put the `item` value
  # into the corresponding cells (NA when an item does not have that column).
  cols_wide <- cols_unnested %>%
    dplyr::filter(!is.na(col_name)) %>%
    dplyr::mutate(.val = item) %>%
    tidyr::pivot_wider(
      id_cols = item,
      names_from = col_name,
      values_from = .val,
      values_fill = NA_character_
    )

  # keep rows where at least one (non-id) column contains NA
  cols_wide_na <- cols_wide %>%
    # dplyr::filter(dplyr::if_any(-dplyr::all_of("item"), ~ is.na(.x)))
    dplyr::filter(dplyr::if_any(everything(), ~ is.na(.x)))

  expect_true(nrow(cols_wide_na) == 0)
})

test_that("get_items returns a dataframe with a 'stage' column", {
  result <- run_api_call(
    {
      get_items(
        institution = "NR",
        item = "ANTR",
        legis_period = "27",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_s3_class(result, "data.frame")
  expect_true("stage" %in% names(result))
})

# Test removed: Duplicate detection depends on transient API data conditions
# The duplicate warning functionality is tested indirectly through actual usage
# See get_items.R:1272-1293 for duplicate detection implementation

test_that("get_items returns no duplicates for Bildung across multiple legislative periods", {
  result <- run_api_call(
    {
      get_items(
        topic = "Bildung",
        legis_period = c(26, 27, 28),
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  # Verify result is returned
  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)

  # Check that there are no duplicate rows
  n_total <- nrow(result)
  n_distinct <- result %>%
    dplyr::distinct() %>%
    nrow()

  expect_equal(
    n_total,
    n_distinct,
    info = "Result should contain no duplicate rows"
  )
})

# Tests for type_eu_submission parameter -------------------------------------

test_that("get_items validates type_eu_submission requires item='EU'", {
  expect_error(
    get_items(type_eu_submission = "BEU"),
    "'type_eu_submission' can only be specified when item = 'EU'"
  )

  expect_error(
    get_items(item = "ANTR", type_eu_submission = "BEU"),
    "'type_eu_submission' can only be specified when item = 'EU'"
  )
})

test_that("get_items validates type_eu_submission values", {
  expect_error(
    get_items(
      item = "EU",
      type_eu_submission = "INVALID_CODE",
      institution = "NR"
    ),
    "Must be a subset of"
  )

  expect_error(
    get_items(
      item = "EU",
      type_eu_submission = c("BEU", "INVALID"),
      institution = "NR"
    ),
    "Must be a subset of"
  )
})

test_that("get_items validates NR type_eu_submission codes require institution='NR'", {
  expect_error(
    get_items(item = "EU", type_eu_submission = "BEU"),
    "National Council type_eu_submission codes can only be used when institution = 'NR'"
  )

  expect_error(
    get_items(item = "EU", type_eu_submission = "S", institution = "BR"),
    "National Council type_eu_submission codes can only be used when institution = 'NR'"
  )
})

test_that("get_items accepts valid type_eu_submission values", {
  # Test single valid value
  result <- run_api_call(
    {
      get_items(
        item = "EU",
        type_eu_submission = "BEU",
        institution = "NR",
        legis_period = 27,
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items accepts multiple type_eu_submission values", {
  # Test multiple valid values
  result <- run_api_call(
    {
      get_items(
        item = "EU",
        type_eu_submission = c("BEU", "RGEU", "S"),
        institution = "NR",
        legis_period = 27,
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
  expect_equal(nrow(result), 8)
})

test_that("get_items type_eu_submission works with all valid codes", {
  skip_on_cran()
  # This is a comprehensive integration test - run only in live mode
  skip_if_mocked("Complex integration test across all EU submission types")

  valid_codes <- c(
    "BEU",
    "EUBTG",
    "JMINEU",
    "ABMINEU",
    "MTEU",
    "EUD",
    "RGEU",
    "SINF",
    "S",
    "SEU",
    "RVEU"
  )

  # Test that each valid code is accepted without error
  for (code in valid_codes) {
    result <- get_items(
      item = "EU",
      type_eu_submission = code,
      institution = "NR",
      legis_period = 28,
      echo = FALSE
    )

    expect_true(
      is.data.frame(result) || is.null(result),
      info = paste("Code", code, "should be valid")
    )
  }
})

test_that("get_items type_eu_submission combines with other parameters", {
  # Test combining type_eu_submission with multiple parameters
  result <- run_api_call(
    {
      get_items(
        item = "EU",
        type_eu_submission = "S",
        legis_period = 27,
        institution = "NR",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
})

# Tests for BR-specific type_eu_submission codes ------------------------------

test_that("get_items validates BR type_eu_submission codes require institution='BR'", {
  expect_error(
    get_items(item = "EU", type_eu_submission = "BEU-BR"),
    "Federal Council type_eu_submission codes can only be used when institution = 'BR'"
  )

  expect_error(
    get_items(item = "EU", type_eu_submission = "MT-BR", institution = "NR"),
    "Federal Council type_eu_submission codes can only be used when institution = 'BR'"
  )
})

test_that("get_items validates mixed NR+BR type_eu_submission codes", {
  # Mixing NR and BR codes with institution='NR' should error on BR codes
  expect_error(
    get_items(
      item = "EU",
      type_eu_submission = c("BEU", "BEU-BR"),
      institution = "NR"
    ),
    "Federal Council type_eu_submission codes can only be used when institution = 'BR'"
  )

  # Mixing NR and BR codes with institution='BR' should error on NR codes
  expect_error(
    get_items(
      item = "EU",
      type_eu_submission = c("BEU", "BEU-BR"),
      institution = "BR"
    ),
    "National Council type_eu_submission codes can only be used when institution = 'NR'"
  )
})

test_that("get_items accepts valid BR type_eu_submission values", {
  # Test single valid BR value
  result <- run_api_call(
    {
      get_items(
        item = "EU",
        type_eu_submission = "BEU-BR",
        institution = "BR",
        legis_period = 27,
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items BR type_eu_submission works with all valid BR codes", {
  skip_on_cran()
  # This is a comprehensive integration test - run only in live mode
  skip_if_mocked("Complex integration test across all BR EU submission types")

  valid_br_codes <- c(
    "AFEU-BR",
    "SBPL-BR",
    "SB-BR",
    "BEU-BR",
    "MEU-BR",
    "ADEU-BR",
    "MT-BR",
    "EUD-BR",
    "SINF-BR",
    "SLT-BR",
    "S-BR"
  )

  # Test that each valid BR code is accepted without error
  for (code in valid_br_codes) {
    result <- get_items(
      item = "EU",
      type_eu_submission = code,
      institution = "BR",
      legis_period = 28,
      echo = FALSE
    )

    expect_true(
      is.data.frame(result) || is.null(result),
      info = paste("BR code", code, "should be valid")
    )
  }
})

test_that("get_items accepts multiple BR type_eu_submission values", {
  # Test multiple valid BR values
  result <- run_api_call(
    {
      get_items(
        item = "EU",
        type_eu_submission = c("BEU-BR", "MT-BR"),
        institution = "BR",
        legis_period = 27,
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
})

# Tests for type_doc with J_JPR_M (Written Questions) ------------------------

test_that("get_items accepts valid type_doc values for J_JPR_M in NR", {
  # Test single valid value - JPR (Written Questions to Federal Government)
  result <- run_api_call(
    {
      get_items(
        item = "J_JPR_M",
        type_doc = "JPR",
        institution = "NR",
        legis_period = 27,
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items accepts valid type_doc values for J_JPR_M in BR", {
  # Test single valid value - JMIN-BR
  result <- run_api_call(
    {
      get_items(
        item = "J_JPR_M",
        type_doc = "JMIN-BR",
        institution = "BR",
        legis_period = 27,
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items type_doc works with all valid NR codes for J_JPR_M", {
  skip_on_cran()
  # This is a comprehensive integration test - run only in live mode
  skip_if_mocked("Complex integration test across all NR J_JPR_M codes")

  valid_codes <- c("J", "JPR", "M")

  # Test that each valid code is accepted without error
  for (code in valid_codes) {
    result <- get_items(
      item = "J_JPR_M",
      type_doc = code,
      institution = "NR",
      legis_period = 27,
      echo = FALSE
    )

    expect_true(
      is.data.frame(result) || is.null(result),
      info = paste("NR code", code, "should be valid for J_JPR_M")
    )
  }
})

test_that("get_items type_doc works with all valid BR codes for J_JPR_M", {
  skip_on_cran()
  # This is a comprehensive integration test - run only in live mode
  skip_if_mocked("Complex integration test across all BR J_JPR_M codes")

  valid_br_codes <- c("M-BR", "JMIN-BR", "JPRPR-BR")

  # Test that each valid BR code is accepted without error
  for (code in valid_br_codes) {
    result <- get_items(
      item = "J_JPR_M",
      type_doc = code,
      institution = "BR",
      legis_period = 27,
      echo = FALSE
    )

    expect_true(
      is.data.frame(result) || is.null(result),
      info = paste("BR code", code, "should be valid for J_JPR_M")
    )
  }
})

test_that("get_items accepts multiple type_doc values for J_JPR_M", {
  # Test multiple valid values
  result <- run_api_call(
    {
      get_items(
        item = "J_JPR_M",
        type_doc = c("J", "JPR"),
        institution = "NR",
        legis_period = 27,
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items rejects NR type_doc codes for J_JPR_M when institution is BR", {
  expect_error(
    get_items(
      item = "J_JPR_M",
      type_doc = "JPR",
      institution = "BR"
    ),
    "Must be a subset of"
  )
})

test_that("get_items rejects BR type_doc codes for J_JPR_M when institution is NR", {
  expect_error(
    get_items(
      item = "J_JPR_M",
      type_doc = "JMIN-BR",
      institution = "NR"
    ),
    "Must be a subset of"
  )
})

test_that("get_items type_doc for J_JPR_M combines with other parameters", {
  # Test combining type_doc with multiple parameters
  result <- run_api_call(
    {
      get_items(
        item = "J_JPR_M",
        type_doc = "JPR",
        legis_period = 27,
        institution = "NR",
        date_start = "01-01-2020",
        date_end = "31-12-2020",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  expect_true(is.data.frame(result) || is.null(result))
})

test_that("get_items returns 0 rows for SBPL-BR type_eu_submission (periods 24-27)", {
  result <- run_api_call(
    {
      get_items(
        item = "EU",
        type_eu_submission = "SBPL-BR",
        institution = "BR",
        legis_period = seq(24, 27, 1),
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  # Expect NULL for empty results (following package convention)
  expect_null(result)
})

test_that("get_items returns 71 rows for MT-BR type_eu_submission (periods 24-27)", {
  result <- run_api_call(
    {
      get_items(
        item = "EU",
        type_eu_submission = "MT-BR",
        institution = "BR",
        legis_period = seq(24, 27, 1),
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  # Check structure
  expect_s3_class(result, "data.frame")

  # Check row count
  expect_equal(nrow(result), 71)

  # Check for duplicates
  n_total <- nrow(result)
  n_distinct <- result %>%
    dplyr::distinct() %>%
    nrow()

  expect_equal(
    n_total,
    n_distinct,
    info = "Result should contain no duplicate rows"
  )
})

test_that("get_items returns 17 rows for S-BR type_eu_submission (periods 24-27)", {
  result <- run_api_call(
    {
      get_items(
        item = "EU",
        legis_period = seq(24, 27, 1),
        type_eu_submission = "S-BR",
        institution = "BR",
        echo = FALSE
      )
    },
    fixture_subdir = "get_items"
  )

  # Check structure
  expect_s3_class(result, "data.frame")

  # Check row count
  expect_equal(nrow(result), 17)

  # Check for duplicates
  n_total <- nrow(result)
  n_distinct <- result %>%
    dplyr::distinct() %>%
    nrow()

  expect_equal(
    n_total,
    n_distinct,
    info = "Result should contain no duplicate rows"
  )
})
