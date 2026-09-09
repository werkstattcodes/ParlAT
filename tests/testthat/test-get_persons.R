# Tests that exercise the live Personen search endpoint of parlament.gv.at.
# Supports both mocked and live API modes via run_api_call().

skip_if_not_installed("stringr")

person_columns <- c("pad_intern", "name", "gender", "position", "link")

person_mandate_columns <- c(
  "pad_intern", "name", "position_text", "position_code", "position_name",
  "position_date_start", "position_date_end", "position_active", "parl_group",
  "party", "party_name", "substitute", "electoral_district_region_code",
  "electoral_district_region", "legis_period", "url_biography"
)

person_mandate_classes <- c(
  rep("character", 5), "Date", "Date", "logical",
  rep("character", 6), "list", "character"
)

expect_person_schema <- function(result, mandates = FALSE) {
  expected_columns <- person_columns
  expected_classes <- rep("character", length(person_columns))

  if (isTRUE(mandates)) {
    expected_columns <- c(
      expected_columns,
      paste0("mandates_", person_mandate_columns)
    )
    expected_classes <- c(expected_classes, person_mandate_classes)
  }

  expect_identical(names(result), expected_columns)
  expect_identical(
    unname(vapply(result, \(x) class(x)[[1]], character(1))),
    expected_classes
  )
}

test_that("get_persons returns expected columns for a known person", {
  result <- run_api_call({
    get_persons(names = "Kurz")
  }, fixture_subdir = "get_persons")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) >= 1)
  expect_true(all(
    c("pad_intern", "name", "gender", "position", "link") %in% names(result)
  ))
  expect_true(all(stringr::str_detect(result$name, stringr::regex("Kurz"))))
})

test_that("get_persons returns mode-specific schemas when no persons match", {
  local_mocked_bindings(
    get_persons_single = function(...) NULL
  )

  expect_message(
    result <- get_persons(names = "Nobody", mandates = FALSE),
    "No person found"
  )
  expect_identical(nrow(result), 0L)
  expect_person_schema(result, mandates = FALSE)

  expect_message(
    result_with_mandates <- get_persons(names = "Nobody", mandates = TRUE),
    "No person found"
  )
  expect_identical(nrow(result_with_mandates), 0L)
  expect_person_schema(result_with_mandates, mandates = TRUE)
})

test_that("get_persons keeps the mandate schema for persons without mandates", {
  local_mocked_bindings(
    get_persons_single = function(...) {
      tibble::tibble(
        pad_intern = "999999",
        name = "Example Person",
        gender = "M",
        position = "Example position",
        link = "/person/999999"
      )
    },
    get_mandates = function(...) .empty_mandates_tibble()
  )

  result <- get_persons(names = "Example Person", mandates = TRUE)

  expect_identical(nrow(result), 1L)
  expect_person_schema(result, mandates = TRUE)
  expect_identical(result$mandates_pad_intern, NA_character_)
  expect_s3_class(result$mandates_position_date_start, "Date")
  expect_type(result$mandates_legis_period, "list")
})


# Validation for gender continues to be handled locally and therefore does not
# rely on an API call.
test_that("invalid gender values are rejected", {

  expect_error(get_persons(gender = "unknown"), regexp = "(all|female|male)")
})

# Likewise for invalid institutions we expect the underlying checkmate
# validation to surface an error.
test_that("invalid institutions are rejected", {
  expect_error(
    get_persons(institution = "Invalid Institution")
  )
})
