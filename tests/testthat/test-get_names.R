# Unit tests for get_names() using mocked bindings (network-free).
# The person-detail JSON fetch and the pad_intern existence check are stubbed
# so the name-parsing logic can be tested deterministically.

mock_person_json <- function(title = "Mag. Anna Muster") {
  jsonlite::toJSON(
    list(
      content = list(
        headingbox = list(title = title),
        personInfo = list(dummy = "no previous names")
      )
    ),
    auto_unbox = TRUE
  )
}

expect_names_schema <- function(result) {
  expect_s3_class(result, "tbl_df")
  expect_identical(
    names(result),
    c(
      "index", "pad_intern", "name", "date_start", "date_end",
      "name_clean", "name_family", "name_given", "note"
    )
  )
  expect_type(result$index, "integer")
  expect_type(result$pad_intern, "character")
  expect_type(result$name, "character")
  expect_s3_class(result$date_start, "Date")
  expect_s3_class(result$date_end, "Date")
  expect_type(result$name_clean, "character")
  expect_type(result$name_family, "character")
  expect_type(result$name_given, "character")
  expect_type(result$note, "character")
}

test_that("get_names returns the current name with cleaned variants", {
  local_mocked_bindings(
    aux_check_pad_intern_exists = function(pad_intern) TRUE,
    .parlat_fetch_detail_json_text = function(url) mock_person_json()
  )

  result <- get_names(pad_intern = "145")

  expect_names_schema(result)
  expect_equal(nrow(result), 1)
  expect_equal(result$name, "Mag. Anna Muster")
  expect_equal(result$name_clean, "Anna Muster")
  expect_equal(result$name_family, "Muster")
  expect_equal(result$index, 1)
  expect_identical(result$date_start, as.Date(NA))
  expect_identical(result$date_end, as.Date(NA))
  expect_identical(result$note, NA_character_)
})

test_that("get_names returns an empty tibble for unknown pad_intern", {
  local_mocked_bindings(
    aux_check_pad_intern_exists = function(pad_intern) FALSE
  )

  expect_message(
    result <- get_names(pad_intern = "999999"),
    "No MP registered"
  )

  expect_names_schema(result)
  expect_equal(nrow(result), 0)
})

test_that("get_names warns and returns an empty tibble when the fetch fails", {
  local_mocked_bindings(
    aux_check_pad_intern_exists = function(pad_intern) TRUE,
    .parlat_fetch_detail_json_text = function(url) {
      stop("network down")
    }
  )

  expect_warning(
    result <- get_names(pad_intern = "145"),
    "Could not retrieve data"
  )

  expect_names_schema(result)
  expect_equal(nrow(result), 0)
})

test_that("get_names is vectorized over pad_intern", {
  local_mocked_bindings(
    aux_check_pad_intern_exists = function(pad_intern) TRUE,
    .parlat_fetch_detail_json_text = function(url) {
      pad <- stringr::str_extract(url, "\\d+")
      mock_person_json(title = paste("Person", pad))
    }
  )

  result <- get_names(pad_intern = c("111", "222"))

  expect_names_schema(result)
  expect_equal(nrow(result), 2)
  expect_setequal(result$pad_intern, c("111", "222"))
})

test_that("get_names latest = TRUE returns a single row", {
  local_mocked_bindings(
    aux_check_pad_intern_exists = function(pad_intern) TRUE,
    .parlat_fetch_detail_json_text = function(url) mock_person_json()
  )

  result <- get_names(pad_intern = "145", latest = TRUE)
  expect_equal(nrow(result), 1)
})
