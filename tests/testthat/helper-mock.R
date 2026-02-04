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

#' Skip test if running in mocked mode
#'
#' Use for tests that require live API access, such as:
#' - File download/export tests
#' - Complex integration tests
#' - Tests checking real-time data
#'
#' @param message Optional message explaining why test requires live API
skip_if_mocked <- function(message = "Test requires live API")
{
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
