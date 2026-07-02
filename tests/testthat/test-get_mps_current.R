# Unit tests for get_mps_current() using mocked bindings (network-free).
# The NR/BR API internals and the per-MP name lookup are stubbed so the
# wrapper's parsing, empty handling, and validation can be tested.

mock_nr_raw <- function() {
  tibble::tibble(
    name = "PLACEHOLDER",
    klub = '<span title="Sozialdemokratische Parlamentsfraktion">S</span>',
    bundesland = '<span title="Wien">W</span>',
    link = "/person/12345",
    wahlkreis = "9A Wien Innen-Süd",
    sort_wp = "SPÖ"
  )
}

mock_br_raw <- function() {
  tibble::tibble(
    pad_intern = "678",
    pad_sortier = "x",
    fraktion = '<span class="zeigeTooltip" title="Bundesratsfraktion der SPÖ">SPÖ</span>',
    wahlpartei = '<span class="zeigeTooltip" title="Sozialdemokratische Partei Österreichs">SPÖ</span>',
    bundesland = "Wien",
    wahlkreis = "9"
  )
}

mock_names_result <- function(name = "Anna Muster") {
  tibble::tibble(index = 1L, name = name)
}

test_that("get_mps_current validates the institution argument", {
  expect_error(get_mps_current(institution = "XX"))
  expect_error(get_mps_current(institution = NULL))
})

test_that("get_mps_current returns a typed empty tibble when NR yields nothing", {
  local_mocked_bindings(
    get_mps_NR_current = function(...) NULL
  )

  result <- get_mps_current(institution = "NR", echo = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true(all(
    c("time_stamp", "pad_intern", "name", "chamber") %in% names(result)
  ))
})

test_that("get_mps_current returns a typed empty tibble when BR yields nothing", {
  local_mocked_bindings(
    get_mps_BR_current = function(...) NULL
  )

  result <- get_mps_current(institution = "BR", echo = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("get_mps_current parses NR results and fetches names", {
  local_mocked_bindings(
    get_mps_NR_current = function(...) mock_nr_raw(),
    get_names = function(pad_intern, ...) mock_names_result()
  )

  result <- get_mps_current(institution = "NR", echo = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_equal(result$name, "Anna Muster")
  expect_equal(result$pad_intern, "12345")
  expect_equal(result$parl_group, "Sozialdemokratische Parlamentsfraktion")
  expect_equal(result$state, "Wien")
  expect_equal(result$chamber, "NR")
  expect_s3_class(result$time_stamp, "POSIXct")
})

test_that("get_mps_current parses BR results and fetches names", {
  local_mocked_bindings(
    get_mps_BR_current = function(...) mock_br_raw(),
    get_names = function(pad_intern, ...) mock_names_result("Bernd Beispiel")
  )

  result <- get_mps_current(institution = "BR", echo = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_equal(result$name, "Bernd Beispiel")
  expect_equal(result$parl_group, "Bundesratsfraktion der SPÖ")
  expect_equal(result$parl_group_code, "SPÖ")
  expect_equal(result$party_name, "Sozialdemokratische Partei Österreichs")
  expect_equal(result$state, "Wien")
  expect_equal(result$chamber, "BR")
  expect_false("fraktion" %in% names(result))
  expect_false("wahlpartei" %in% names(result))
})

test_that("get_mps_current warns when a name lookup fails", {
  local_mocked_bindings(
    get_mps_NR_current = function(...) mock_nr_raw(),
    get_names = function(pad_intern, ...) tibble::tibble()
  )

  expect_warning(
    result <- get_mps_current(institution = "NR", echo = FALSE),
    "Failed to fetch name"
  )
  expect_true(is.na(result$name))
})
