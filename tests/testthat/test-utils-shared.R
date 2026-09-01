# Unit tests for the shared internal utilities in R/utils-shared.R

# --- .parlat_empty_tibble ----------------------------------------------------

test_that(".parlat_empty_tibble builds a typed zero-row tibble", {
  result <- .parlat_empty_tibble(
    c("id", "name", "date", "tags", "count", "active", "fetched_at"),
    date_cols = "date",
    list_cols = "tags",
    int_cols = "id",
    lgl_cols = "active",
    datetime_cols = "fetched_at"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_named(
    result,
    c("id", "name", "date", "tags", "count", "active", "fetched_at")
  )
  expect_type(result$id, "integer")
  expect_type(result$name, "character")
  expect_s3_class(result$date, "Date")
  expect_type(result$tags, "list")
  expect_type(result$active, "logical")
  expect_s3_class(result$fetched_at, "POSIXct")
})

test_that(".parlat_empty_tibble defaults untyped columns to character", {
  result <- .parlat_empty_tibble(c("a", "b"))
  expect_type(result$a, "character")
  expect_type(result$b, "character")
})

# --- .parlat_apply_renaming --------------------------------------------------

test_that(".parlat_apply_renaming renames mapped columns and ignores missing", {
  df <- tibble::tibble(gp_code = "XXVII", datum = "01.01.2024", other = 1)
  renaming_map <- c(
    "gp_code" = "legis_period",
    "datum" = "date",
    "not_present" = "never_used"
  )

  result <- .parlat_apply_renaming(df, renaming_map)

  expect_named(result, c("legis_period", "date", "other"))
  expect_equal(result$legis_period, "XXVII")
})

# --- .parlat_echo_request ----------------------------------------------------

test_that(".parlat_echo_request reports parameters, URL, and hit count", {
  body_params <- jsonlite::toJSON(list(GP = "XXVII"))

  msgs <- character(0)
  withCallingHandlers(
    .parlat_echo_request(
      body_params,
      url_base = "https://www.parlament.gv.at/test",
      param_prefix = "PFX_001",
      n_results = 42,
      search = "budget"
    ),
    message = function(m) {
      msgs <<- c(msgs, conditionMessage(m))
      invokeRestart("muffleMessage")
    }
  )

  all_msgs <- paste(msgs, collapse = "")
  expect_match(all_msgs, "PFX_001GP=XXVII", fixed = TRUE)
  expect_match(all_msgs, "search=budget", fixed = TRUE)
  expect_match(all_msgs, "42")
})

test_that(".parlat_echo_request appends the url_suffix", {
  body_params <- jsonlite::toJSON(list(A = "1"))

  expect_message(
    .parlat_echo_request(
      body_params,
      url_base = "https://www.parlament.gv.at/person/145",
      param_prefix = "BIO_250",
      url_suffix = "&selectedtab=PLENUM"
    ),
    "selectedtab=PLENUM"
  )
})

test_that(".parlat_echo_body_all_periods changes only unrestricted echoes", {
  body_params <- jsonlite::toJSON(list(NBVS = "NRSITZ"))
  expected_periods <- c(as.character(as.roman(1:28)), "KN", "PN")

  all_period_body <- .parlat_echo_body_all_periods(
    body_params,
    legis_period = character()
  ) |>
    jsonlite::fromJSON()

  expect_equal(all_period_body$NBVS, "NRSITZ")
  expect_equal(all_period_body$GP_CODE, expected_periods)
  expect_identical(
    .parlat_echo_body_all_periods(body_params, legis_period = "XXVII"),
    body_params
  )
})
