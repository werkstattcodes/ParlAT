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

test_that("get_names returns the current name with cleaned variants", {
  local_mocked_bindings(
    aux_check_pad_intern_exists = function(pad_intern) TRUE,
    .parlat_fetch_detail_json_text = function(url) mock_person_json()
  )

  result <- get_names(pad_intern = "145")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_equal(result$name, "Mag. Anna Muster")
  expect_equal(result$name_clean, "Anna Muster")
  expect_equal(result$name_family, "Muster")
  expect_equal(result$index, 1)
})

test_that("get_names returns an empty tibble for unknown pad_intern", {
  local_mocked_bindings(
    aux_check_pad_intern_exists = function(pad_intern) FALSE
  )

  expect_message(
    result <- get_names(pad_intern = "999999"),
    "No MP registered"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true(all(
    c("index", "pad_intern", "name", "date_start", "date_end") %in%
      names(result)
  ))
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

  expect_s3_class(result, "tbl_df")
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

  expect_s3_class(result, "tbl_df")
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
