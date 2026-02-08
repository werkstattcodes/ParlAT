# Run tests and export results to CSV
#
# Usage:
#   source("run_tests.R")
#   test_to_csv()                        # run all tests, write CSV
#   test_to_csv(filter = "get_mps")      # run subset
#   test_to_csv(append = TRUE)           # append to existing file

test_to_csv <- function(csv_path = "test_results.csv", append = FALSE, ...) {
  results <- devtools::test(...)

  df_raw <- as.data.frame(results)

  # Determine test mode using same env var logic as helper-mock.R

  test_mode <- if (identical(Sys.getenv("PARLAT_RECORD_FIXTURES", "false"), "true")) {
    "recording"
  } else if (identical(Sys.getenv("PARLAT_LIVE_API", "false"), "true")) {
    "live"
  } else {
    "mocked"
  }

  df_export <- df_raw |>
    dplyr::transmute(
      test_file = file,
      test_name = test,
      test_result = dplyr::case_when(
        skipped    ~ "skip",
        error      ~ "error",
        failed > 0 ~ "fail",
        warning > 0 ~ "warning",
        TRUE       ~ "pass"
      ),
      test_mode = test_mode,
      datetime = format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    )

  if (append && file.exists(csv_path)) {
    readr::write_csv(df_export, csv_path, append = TRUE)
  } else {
    readr::write_csv(df_export, csv_path)
  }

  cli::cli_alert_success(
    "Test results written to {.file {csv_path}} ({nrow(df_export)} tests, mode: {test_mode})"
  )

  invisible(results)
}
