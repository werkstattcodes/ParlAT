# Helper functions for dual-mode testing (mocked vs live API)
# These functions are automatically loaded by testthat before tests run
#
# Three modes:
#   1. Mocked (default): Uses httptest2 fixtures for fast offline testing
#   2. Live (PARLAT_LIVE_API=true): Makes real API calls
#   3. Recording (PARLAT_RECORD_FIXTURES=true): Makes real API calls AND saves
#      responses as fixtures for future mocked testing

# Determine test mode from environment variable
# Set PARLAT_LIVE_API=true to run tests against the live API
# Default (unset or "false") uses mocked responses from fixtures
.parlat_live_api <- function() {
  identical(Sys.getenv("PARLAT_LIVE_API", "false"), "true") ||
    .parlat_recording()
}

# Check if we're in fixture recording mode
.parlat_recording <- function() {
  identical(Sys.getenv("PARLAT_RECORD_FIXTURES", "false"), "true")
}

# Helper for fixture path
.httptest2_fixtures <- function() {
  testthat::test_path("fixtures")
}

#' Run API call in appropriate mode (mocked, live, or recording)
#'
#' In mocked mode (default), uses httptest2 fixtures from the specified subdirectory.
#' In live mode (PARLAT_LIVE_API=true), makes real API calls.
#' In recording mode (PARLAT_RECORD_FIXTURES=true), makes real API calls and
#' saves responses as fixtures.
#'
#' @param expr An expression containing API calls to execute
#' @param fixture_subdir Subdirectory within fixtures/ containing mock responses
#' @return Result of the API call
run_api_call <- function(expr, fixture_subdir = NULL) {
  if (.parlat_recording() && !is.null(fixture_subdir)) {
    # Recording mode: make real API calls and save responses as fixtures
    skip_if_offline()
    fixture_path <- file.path(.httptest2_fixtures(), fixture_subdir)
    if (!dir.exists(fixture_path)) {
      dir.create(fixture_path, recursive = TRUE)
    }
    old_paths <- httptest2::.mockPaths()
    httptest2::.mockPaths(fixture_path)
    httptest2::start_capturing()
    on.exit({
      httptest2::stop_capturing()
      httptest2::.mockPaths(old_paths)
    })
    force(expr)
  } else if (.parlat_live_api()) {
    # Live mode: skip if offline, then execute real API call
    skip_if_offline()
    force(expr)
  } else {
    # Mocked mode: use httptest2 fixtures
    # NOTE: We use .mockPaths() + with_mock_api() instead of with_mock_dir()
    # because with_mock_dir() has built-in path manipulation that prepends
    # "tests/testthat/" when it detects that directory exists. This causes
    # double-nesting when devtools::test() sets WD to tests/testthat.
    if (!is.null(fixture_subdir)) {
      fixture_path <- file.path(.httptest2_fixtures(), fixture_subdir)
      old_paths <- httptest2::.mockPaths()
      httptest2::.mockPaths(fixture_path)
      on.exit(httptest2::.mockPaths(old_paths))
      httptest2::with_mock_api(expr)
    } else {
      httptest2::with_mock_api(expr)
    }
  }
}

#' Flexible row count assertion for tests with exact counts
#'
#' In mocked mode, asserts exact equality (fixtures have known counts).
#' In live mode, asserts within a tolerance range (API data may change).
#'
#' @param actual Actual row count from the result
#' @param expected Expected row count (from fixture recording time)
#' @param tolerance Percentage tolerance for live API (default 0.1 = 10%)
expect_row_count <- function(actual, expected, tolerance = 0.1) {
  if (.parlat_live_api()) {
    # Live mode: allow for data changes within tolerance
    testthat::expect_gte(actual, floor(expected * (1 - tolerance)))
    testthat::expect_lte(actual, ceiling(expected * (1 + tolerance)))
  } else {
    # Mocked mode: exact count from fixture
    testthat::expect_equal(actual, expected)
  }
}

# Cache environment for the API index health check so the whole test run
# costs at most one extra request.
.parlat_canary_cache <- new.env(parent = emptyenv())

#' Check whether the parlament.gv.at search index is healthy
#'
#' The filter API's index can temporarily lose records (observed 2026-07-17,
#' see issue #33): a closed historical date window that matched exactly 2526
#' rows dropped to fluctuating counts (1766, 432) within hours, and entire
#' categories (item = "EU" with institution = "BR") vanished. Row-count
#' assertions against the live API are meaningless while the index is in that
#' state, so count-sensitive tests skip via skip_if_api_index_degraded().
#'
#' The canary queries a closed window (Jan-Mar 2024) whose healthy count is
#' known to be 2526; anything well below that means the index is degraded.
#' Request errors also count as unhealthy so tests skip rather than fail.
#'
#' @return List with elements `healthy` (logical) and `count` (integer or NA)
.parlat_api_index_health <- function() {
  if (!is.null(.parlat_canary_cache$result)) {
    return(.parlat_canary_cache$result)
  }

  healthy_reference <- 2526
  threshold <- 2400

  count <- tryCatch(
    {
      resp <- httr2::request(
        "https://www.parlament.gv.at/Filter/api/filter/data/101"
      ) |>
        httr2::req_method("POST") |>
        httr2::req_url_query(js = "eval", page = "1", pagesize = "1") |>
        httr2::req_headers(origin = "https://www.parlament.gv.at") |>
        httr2::req_body_raw(
          '{"DATUM_VON":["2024-01-01T00:00:00.000Z","2024-03-01T00:00:00.000Z"]}',
          "application/json"
        ) |>
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
        httr2::req_perform()
      httr2::resp_body_json(resp)$count
    },
    error = function(e) NA_integer_
  )

  result <- list(
    healthy = !is.na(count) && count >= threshold,
    count = count
  )
  .parlat_canary_cache$result <- result
  result
}

#' Skip test if the live API's search index is degraded
#'
#' No-op in mocked mode. In live mode, skips count-sensitive tests while the
#' upstream index is missing records (see .parlat_api_index_health), so the
#' weekly live-test workflow reports the known upstream problem as skips
#' instead of failures. Tests resume automatically once the index recovers.
skip_if_api_index_degraded <- function() {
  if (!.parlat_live_api()) {
    return(invisible(TRUE))
  }
  health <- .parlat_api_index_health()
  if (!health$healthy) {
    testthat::skip(paste0(
      "Upstream search index degraded (canary count: ",
      health$count,
      ", healthy: ~2526); see issue #33"
    ))
  }
  invisible(TRUE)
}

#' Skip test if running in mocked mode
#'
#' Use for tests that require live API access, such as:
#' - File download/export tests
#' - Complex integration tests
#' - Tests checking real-time data
#'
#' @param message Optional message explaining why test requires live API
skip_if_mocked <- function(message = "Test requires live API") {
  if (!.parlat_live_api()) {
    testthat::skip(message)
  }
}

#' Skip test if running in live mode
#'
#' Use for tests that should only run against fixtures, such as:
#' - Tests with hardcoded expected values that may change
#' - Tests checking specific edge cases in recorded responses
#'
#' @param message Optional message explaining why test uses fixed mock data
skip_if_live <- function(message = "Test uses fixed mock data") {
  if (.parlat_live_api()) {
    testthat::skip(message)
  }
}
