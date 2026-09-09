# Unit tests for pure auxiliary helpers (no network access required)

# --- fn_check_legis_period_elements ----------------------------------------

test_that("fn_check_legis_period_elements converts numeric input to Roman", {
  expect_equal(fn_check_legis_period_elements("27"), "XXVII")
  expect_equal(fn_check_legis_period_elements(27), "XXVII")
  expect_equal(fn_check_legis_period_elements("5"), "V")
})

test_that("fn_check_legis_period_elements handles special values", {
  expect_equal(fn_check_legis_period_elements("all"), "ALLE")
  expect_equal(fn_check_legis_period_elements("PN"), "PN")
  expect_equal(fn_check_legis_period_elements("KN"), "KN")
})

test_that("fn_check_legis_period_elements rejects invalid input", {
  expect_error(
    fn_check_legis_period_elements(NULL),
    "required"
  )
  expect_error(
    fn_check_legis_period_elements("NotAPeriod"),
    "Invalid input for legis_period"
  )
})

# --- aux_convert_legis_periods ---------------------------------------------

test_that("aux_convert_legis_periods standardizes to character", {
  expect_equal(aux_convert_legis_periods(27), "27")
  expect_equal(aux_convert_legis_periods("XXVII"), "27")
  expect_equal(aux_convert_legis_periods("PN"), "PN")
  expect_equal(
    aux_convert_legis_periods(c(26, "XXVII", "PN")),
    c("26", "27", "PN")
  )
})

test_that("aux_convert_legis_periods converts to Roman when requested", {
  expect_equal(aux_convert_legis_periods(27, output = "roman"), "XXVII")
  expect_equal(aux_convert_legis_periods("27", output = "roman"), "XXVII")
  expect_equal(aux_convert_legis_periods("XXVII", output = "roman"), "XXVII")
})

test_that("aux_convert_legis_periods passes NULL through", {
  expect_null(aux_convert_legis_periods(NULL))
})

# --- aux_parl_group_names_standard -----------------------------------------

test_that("aux_parl_group_names_standard expands related group names", {
  result <- aux_parl_group_names_standard("FPÖ")
  expect_true(all(c("F", "FPÖ", "F-BZÖ") %in% result))

  result_neos <- aux_parl_group_names_standard("NEOS")
  expect_true(all(c("NEOS", "NEOS-LIF") %in% result_neos))
})

test_that("aux_parl_group_names_standard leaves unrelated names unchanged", {
  expect_equal(
    aux_parl_group_names_standard("SPÖ"),
    "SPÖ"
  )
})

test_that("aux_parl_group_names_standard deduplicates and handles empty input", {
  result <- aux_parl_group_names_standard(c("FPÖ", "F"))
  expect_equal(anyDuplicated(result), 0)

  expect_null(aux_parl_group_names_standard(NULL))
  expect_length(aux_parl_group_names_standard(character(0)), 0)
})

# --- fn_make_tibble / aux_json_to_tibble -----------------------------------

test_that("fn_make_tibble creates one-row tibble with list-columns", {
  x <- list(a = 1, b = "two", nested = list(c = 3, d = 4))
  result <- fn_make_tibble(x)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_equal(result$a, 1)
  expect_true(is.list(result$nested))
})

test_that("aux_json_to_tibble flattens simple JSON and nests complex parts", {
  json_data <- list(
    id = 42L,
    title = "Item",
    documents = list(list(name = "doc1"), list(name = "doc2"))
  )
  result <- aux_json_to_tibble(json_data)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_equal(result$id, 42L)
  expect_true(is.list(result$documents))
})

# --- aux_parse_html_title ---------------------------------------------------

test_that("aux_parse_html_title extracts span title attribute", {
  html <- '<span title="Full Group Name">FGN</span>'
  expect_equal(aux_parse_html_title(html), "Full Group Name")
})

test_that("aux_parse_html_title returns NA when no span title exists", {
  expect_true(is.na(aux_parse_html_title("<p>no span</p>")))
})
