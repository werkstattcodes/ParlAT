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

test_that("current MP requests exclude browser fingerprint headers", {
  capture_request <- function(request_fn) {
    captured_request <- NULL
    local_mocked_bindings(
      req_perform = function(req) {
        captured_request <<- req
        req
      },
      .package = "httr2"
    )
    request_fn("{}")
    captured_request
  }

  requests <- list(
    capture_request(get_mps_NR_current_api_request),
    capture_request(get_mps_BR_current_api_request)
  )
  forbidden_headers <- c(
    "priority", "sec-ch-ua", "sec-ch-ua-mobile", "sec-ch-ua-platform",
    "sec-fetch-dest", "sec-fetch-mode", "sec-fetch-site", "user-agent"
  )

  purrr::walk(requests, \(req) {
    expect_identical(
      req$options$useragent,
      "ParlAT R package (http://werk.statt.codes)"
    )
    expect_identical(req$policies$retry_max_tries, 3)
    expect_length(
      intersect(tolower(names(req$headers)), forbidden_headers),
      0L
    )
  })
})

test_that("get_mps_current validates the institution argument", {
  expect_error(get_mps_current(institution = "XX"))
  expect_error(get_mps_current(institution = NULL))
})

test_that("get_mps_current returns a typed empty tibble when NR yields nothing", {
  nr_result <- mock_nr_raw()
  local_mocked_bindings(
    get_mps_NR_current = function(...) nr_result,
    get_names = function(pad_intern, ...) mock_names_result()
  )

  populated <- get_mps_current(institution = "NR", echo = FALSE)
  nr_result <- NULL
  empty <- get_mps_current(institution = "NR", echo = FALSE)

  expect_s3_class(empty, "tbl_df")
  expect_equal(nrow(empty), 0)
  expect_identical(names(empty), names(populated))
  expect_identical(lapply(empty, class), lapply(populated, class))
  expect_identical(
    attr(empty$time_stamp, "tzone"),
    attr(populated$time_stamp, "tzone")
  )
})

test_that("get_mps_current returns a typed empty tibble when BR yields nothing", {
  br_result <- mock_br_raw()
  local_mocked_bindings(
    get_mps_BR_current = function(...) br_result,
    get_names = function(pad_intern, ...) mock_names_result("Bernd Beispiel")
  )

  populated <- get_mps_current(institution = "BR", echo = FALSE)
  br_result <- NULL
  empty <- get_mps_current(institution = "BR", echo = FALSE)

  expect_s3_class(empty, "tbl_df")
  expect_equal(nrow(empty), 0)
  expect_identical(names(empty), names(populated))
  expect_identical(lapply(empty, class), lapply(populated, class))
  expect_identical(
    attr(empty$time_stamp, "tzone"),
    attr(populated$time_stamp, "tzone")
  )
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
