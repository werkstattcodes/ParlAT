# ==============================================================================
# Tests for get_committee_memberships()
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. BASIC FUNCTIONALITY TESTS - NAME SEARCH
# ------------------------------------------------------------------------------

test_that("get_committee_memberships returns valid data structure with name search", {
  skip_on_cran()
  skip_if_offline()

  x <- get_committee_memberships(name = "Maurer")

  # Test basic structure
  expect_true(is.data.frame(x) || is.null(x))

  if (!is.null(x) && nrow(x) > 0) {
    expect_gt(nrow(x), 0)

    # Test expected columns exist
    expected_cols <- c(
      "pad_intern", "name", "legis_period", "institution",
      "committee_function", "committee_name"
    )
    expect_true(all(expected_cols %in% colnames(x)))

    # Test data types
    expect_true(is.character(x$pad_intern))
    expect_true(is.character(x$name))
    expect_true(is.character(x$committee_name))
    expect_true(is.character(x$institution))
    expect_true(is.character(x$committee_function))

    # Test date columns are Date class
    if ("committee_date_start" %in% colnames(x)) {
      expect_s3_class(x$committee_date_start, "Date")
    }
    if ("committee_date_end" %in% colnames(x)) {
      expect_true(
        inherits(x$committee_date_end, "Date") ||
          all(is.na(x$committee_date_end))
      )
    }

    # Test institution values (can be NR or BR, no longer filtered)
    expect_true(all(x$institution %in% c("NR", "BR", NA)))

    # Test URLs have correct prefix
    if ("committee_url" %in% colnames(x)) {
      non_na_urls <- x$committee_url[!is.na(x$committee_url)]
      if (length(non_na_urls) > 0) {
        expect_true(all(stringr::str_starts(
          non_na_urls,
          "https://www.parlament.gv.at"
        )))
      }
    }
  }
})

# ------------------------------------------------------------------------------
# 2. BASIC FUNCTIONALITY TESTS - PAD_INTERN SEARCH
# ------------------------------------------------------------------------------

test_that("get_committee_memberships works with character pad_intern", {
  skip_on_cran()
  skip_if_offline()

  # Get a valid pad_intern using get_pad_intern
  person_info <- get_pad_intern("Maurer")

  if (!is.null(person_info) && nrow(person_info) > 0) {
    pad_id <- person_info$pad_intern[1]

    x <- get_committee_memberships(pad_intern = pad_id)

    expect_true(is.data.frame(x) || is.null(x))

    if (!is.null(x) && nrow(x) > 0) {
      expect_true("pad_intern" %in% colnames(x))
      expect_true(all(x$pad_intern == pad_id))
    }
  }
})

test_that("get_committee_memberships works with numeric pad_intern", {
  skip_on_cran()
  skip_if_offline()

  # Get a valid pad_intern and convert to numeric
  person_info <- get_pad_intern("Krisper")

  if (!is.null(person_info) && nrow(person_info) > 0) {
    pad_id_char <- person_info$pad_intern[1]

    # Only test if pad_intern is convertible to numeric
    if (!is.na(suppressWarnings(as.numeric(pad_id_char)))) {
      pad_id_numeric <- as.numeric(pad_id_char)

      x <- get_committee_memberships(pad_intern = pad_id_numeric)

      expect_true(is.data.frame(x) || is.null(x))

      if (!is.null(x) && nrow(x) > 0) {
        expect_true("pad_intern" %in% colnames(x))
        expect_true(all(x$pad_intern == pad_id_char))
      }
    }
  }
})

test_that("get_committee_memberships works with multiple pad_intern values", {
  skip_on_cran()
  skip_if_offline()

  # Get multiple person IDs
  person1 <- get_pad_intern("Maurer")
  person2 <- get_pad_intern("Krisper")

  if (!is.null(person1) && !is.null(person2) &&
    nrow(person1) > 0 && nrow(person2) > 0) {
    pad_ids <- c(person1$pad_intern[1], person2$pad_intern[1])

    x <- get_committee_memberships(pad_intern = pad_ids)

    expect_true(is.data.frame(x) || is.null(x))

    if (!is.null(x) && nrow(x) > 0) {
      expect_true(all(x$pad_intern %in% pad_ids))
    }
  }
})

# ------------------------------------------------------------------------------
# 3. PARAMETER VALIDATION TESTS
# ------------------------------------------------------------------------------

test_that("get_committee_memberships validates parameters correctly", {
  # Neither name nor pad_intern provided
  expect_error(
    get_committee_memberships(),
    "Either 'name' or 'pad_intern' must be provided"
  )

  # Both name and pad_intern provided
  expect_error(
    get_committee_memberships(
      name = "Test",
      pad_intern = "12345"
    ),
    "Provide either 'name' OR 'pad_intern', not both"
  )

  # Invalid details parameter
  expect_error(
    get_committee_memberships(
      name = "Test",
      details = "yes"
    )
  )

  # Invalid echo parameter
  expect_error(
    get_committee_memberships(
      name = "Test",
      echo = "true"
    )
  )

  # Empty string pad_intern
  expect_error(
    get_committee_memberships(pad_intern = ""),
    "Assertion on 'pad_intern' failed"
  )
})

test_that("get_committee_memberships validates name parameter type", {
  # Invalid name type (not character)
  expect_error(
    get_committee_memberships(name = 123),
    "Assertion on 'name' failed"
  )

  # NULL name with NULL pad_intern
  expect_error(
    get_committee_memberships(name = NULL, pad_intern = NULL),
    "Either 'name' or 'pad_intern' must be provided"
  )
})

# ------------------------------------------------------------------------------
# 4. EDGE CASES AND ERROR HANDLING
# ------------------------------------------------------------------------------

test_that("get_committee_memberships handles empty results gracefully", {
  skip_on_cran()
  skip_if_offline()

  # Search for unlikely name
  x <- get_committee_memberships(name = "ZzzzUnlikelyNameXxxx9999")

  expect_true(is.null(x))
})

test_that("get_committee_memberships handles persons with no committee memberships", {
  skip_on_cran()
  skip_if_offline()

  # This tests NULL return when person exists but has no memberships
  # Using a made-up pad_intern that won't have memberships
  x <- get_committee_memberships(pad_intern = "999999999")

  # Should return NULL or empty result, not error
  expect_true(is.null(x) || (is.data.frame(x) && nrow(x) == 0))
})

test_that("get_committee_memberships handles multiple name variants", {
  skip_on_cran()
  skip_if_offline()

  # Test that names_variants from get_pad_intern are handled correctly
  x <- get_committee_memberships(name = "Maurer")

  if (!is.null(x) && nrow(x) > 0) {
    # name column should exist (renamed from names_variants)
    expect_true("name" %in% colnames(x))
    expect_true(is.character(x$name))
  }
})

# ------------------------------------------------------------------------------
# 5. DATA QUALITY TESTS
# ------------------------------------------------------------------------------

test_that("get_committee_memberships returns no duplicate rows", {
  skip_on_cran()
  skip_if_offline()

  x <- get_committee_memberships(name = "Maurer")

  if (!is.null(x) && nrow(x) > 0) {
    # Check for duplicate rows
    expect_false(any(duplicated(x)))
  }
})

test_that("get_committee_memberships committee names are clean text", {
  skip_on_cran()
  skip_if_offline()

  x <- get_committee_memberships(name = "Krisper")

  if (!is.null(x) && nrow(x) > 0 && "committee_name" %in% colnames(x)) {
    # Filter out NA values for testing
    non_na_names <- x$committee_name[!is.na(x$committee_name)]

    if (length(non_na_names) > 0) {
      # Committee names should not contain HTML tags
      expect_false(any(stringr::str_detect(non_na_names, "<[^>]+>")))

      # Committee names should not contain "von dd.mm.yyyy bis dd.mm.yyyy" patterns
      expect_false(any(stringr::str_detect(
        non_na_names,
        "von\\s+\\d{2}\\.\\d{2}\\.\\d{4}"
      )))
    }
  }
})

test_that("get_committee_memberships URLs are properly formatted", {
  skip_on_cran()
  skip_if_offline()

  x <- get_committee_memberships(name = "Maurer")

  if (!is.null(x) && nrow(x) > 0 && "committee_url" %in% colnames(x)) {
    non_na_urls <- x$committee_url[!is.na(x$committee_url)]

    if (length(non_na_urls) > 0) {
      # All URLs should start with the correct prefix
      expect_true(all(stringr::str_starts(
        non_na_urls,
        "https://www.parlament.gv.at"
      )))

      # URLs should not be relative paths (no starting with /)
      expect_false(any(stringr::str_starts(non_na_urls, "^/")))
    }
  }
})

# ------------------------------------------------------------------------------
# 6. OPTIONAL PARAMETERS TESTS
# ------------------------------------------------------------------------------

test_that("get_committee_memberships details parameter works", {
  skip_on_cran()
  skip_if_offline()

  x <- get_committee_memberships(
    name = "Maurer",
    details = TRUE
  )

  if (!is.null(x) && nrow(x) > 0) {
    # With details, should have additional columns
    expect_true(is.data.frame(x))

    # Basic columns should still exist
    expect_true("committee_name" %in% colnames(x))

    # Details should add more columns (exact structure depends on implementation)
    # Just verify it doesn't break
    expect_gt(ncol(x), 9) # More than basic 9 columns
  }
})

test_that("get_committee_memberships echo parameter prints messages", {
  skip_on_cran()
  skip_if_offline()

  # Should print messages when echo = TRUE
  expect_message(
    get_committee_memberships(name = "Maurer", echo = TRUE),
    "Found"
  )

  expect_message(
    get_committee_memberships(name = "Maurer", echo = TRUE),
    "person\\(s\\) matching"
  )
})

test_that("get_committee_memberships echo = FALSE produces no messages", {
  skip_on_cran()
  skip_if_offline()

  # Default (echo = FALSE) should not print diagnostic messages
  # Note: Will still get message if no results found
  expect_silent({
    x <- get_committee_memberships(name = "Maurer", echo = FALSE)
  })
})

# ------------------------------------------------------------------------------
# 7. INTEGRATION AND CONSISTENCY TESTS
# ------------------------------------------------------------------------------

test_that("get_committee_memberships integrates correctly with get_pad_intern", {
  skip_on_cran()
  skip_if_offline()

  # Get person info using get_pad_intern
  person_info <- get_pad_intern("Krisper")

  if (!is.null(person_info) && nrow(person_info) > 0) {
    pad_id <- person_info$pad_intern[1]

    # Test with name
    x_name <- get_committee_memberships(name = "Krisper")

    # Test with pad_intern
    x_id <- get_committee_memberships(pad_intern = pad_id)

    # Both should return data or both return NULL
    expect_equal(is.null(x_name), is.null(x_id))

    # If both return data, should have same number of rows
    if (!is.null(x_name) && !is.null(x_id)) {
      expect_equal(nrow(x_name), nrow(x_id))
    }
  }
})

test_that("get_committee_memberships returns both NR and BR memberships", {
  skip_on_cran()
  skip_if_offline()

  # Without institution parameter, should return memberships from all institutions
  x <- get_committee_memberships(name = "Schennach")

  # Should return data or NULL, not error
  expect_true(is.data.frame(x) || is.null(x))

  if (!is.null(x) && nrow(x) > 0) {
    # Check institution column exists
    expect_true("institution" %in% colnames(x))

    # Can contain NR, BR, or both
    institutions_found <- unique(x$institution[!is.na(x$institution)])
    expect_true(all(institutions_found %in% c("NR", "BR")))
  }
})

test_that("get_committee_memberships numeric and character pad_intern return same results", {
  skip_on_cran()
  skip_if_offline()

  person_info <- get_pad_intern("Maurer")

  if (!is.null(person_info) && nrow(person_info) > 0) {
    pad_id_char <- person_info$pad_intern[1]

    # Only test if convertible to numeric
    if (!is.na(suppressWarnings(as.numeric(pad_id_char)))) {
      pad_id_num <- as.numeric(pad_id_char)

      x_char <- get_committee_memberships(pad_intern = pad_id_char)
      x_num <- get_committee_memberships(pad_intern = pad_id_num)

      # Both should return same type (both data.frame or both NULL)
      expect_equal(is.null(x_char), is.null(x_num))

      # If both return data, should have same rows
      if (!is.null(x_char) && !is.null(x_num)) {
        expect_equal(nrow(x_char), nrow(x_num))
        expect_equal(x_char$pad_intern, x_num$pad_intern)
      }
    }
  }
})

# ------------------------------------------------------------------------------
# 8. COLUMN STRUCTURE TESTS
# ------------------------------------------------------------------------------

test_that("get_committee_memberships returns expected column structure", {
  skip_on_cran()
  skip_if_offline()

  x <- get_committee_memberships(name = "Maurer")

  if (!is.null(x) && nrow(x) > 0) {
    # Core columns should always be present
    core_cols <- c(
      "pad_intern",
      "name",
      "legis_period",
      "institution",
      "committee_function",
      "committee_name"
    )

    expect_true(all(core_cols %in% colnames(x)))

    # Optional columns that may be present
    optional_cols <- c(
      "committee_date_start",
      "committee_date_end",
      "committee_url"
    )

    # At least some optional columns should be present
    expect_gt(sum(optional_cols %in% colnames(x)), 0)

    # Column order: identifiers should come first
    first_cols <- c("pad_intern", "name", "legis_period")
    col_positions <- match(first_cols, colnames(x))

    # These columns should be in first 3 positions
    expect_true(all(col_positions <= 3))
  }
})
