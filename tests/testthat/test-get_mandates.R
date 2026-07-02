# Tests for get_mandates()

# Helper: builds a mock return value for get_mandates_single().
# Columns mirror the real API structure before get_mandates() renames them.
mock_mandate_row <- function(
  pad_intern = "145",
  name = "Doris Bures",
  bez = "Abgeordnete zum Nationalrat (XXVII. GP)",
  funktion = "NR",
  funktion_text = "Abgeordnete zum Nationalrat",
  funktion_von = as.Date("2019-10-23"),
  funktion_bis = NA_real_,
  aktiv = TRUE,
  klub = "SP\u00d6",
  wahlpartei = "SP\u00d6",
  wahlpartei_text = "Sozialdemokratische Partei \u00d6sterreichs",
  eingetreten_txt = NA_character_,
  wahlkreis = "7A - Ober\u00f6sterreich"
) {
  tibble::tibble(
    pad_intern = pad_intern,
    name = name,
    bez = bez,
    funktion = funktion,
    funktion_text = funktion_text,
    funktion_von = funktion_von,
    funktion_bis = as.Date(funktion_bis),
    aktiv = aktiv,
    klub = klub,
    wahlpartei = wahlpartei,
    wahlpartei_text = wahlpartei_text,
    eingetreten_txt = eingetreten_txt,
    wahlkreis = wahlkreis
  )
}

# Build a multi-row mock dataset covering different institution codes
mock_mandates_multi <- function() {
  dplyr::bind_rows(
    mock_mandate_row(
      pad_intern = "145",
      bez = "Abgeordnete zum Nationalrat (XXVII. GP)",
      funktion = "NR",
      funktion_text = "Abgeordnete zum Nationalrat",
      funktion_von = as.Date("2019-10-23"),
      funktion_bis = NA_real_,
      aktiv = TRUE
    ),
    mock_mandate_row(
      pad_intern = "145",
      bez = "Zweite Pr\u00e4sidentin des Nationalrates (XXV. GP, XXVI. GP)",
      funktion = "2PNR",
      funktion_text = "Zweite Pr\u00e4sidentin des Nationalrates",
      funktion_von = as.Date("2014-09-29"),
      funktion_bis = as.Date("2019-10-22"),
      aktiv = FALSE
    ),
    mock_mandate_row(
      pad_intern = "145",
      bez = "Bundesministerin f\u00fcr Unterricht, Kunst und Kultur",
      funktion = "BM",
      funktion_text = "Bundesministerin",
      funktion_von = as.Date("2008-12-02"),
      funktion_bis = as.Date("2014-09-28"),
      aktiv = FALSE
    ),
    mock_mandate_row(
      pad_intern = "145",
      bez = "Mitglied des Bundesrates (XX. GP)",
      funktion = "BR",
      funktion_text = "Mitglied des Bundesrates",
      funktion_von = as.Date("1997-01-01"),
      funktion_bis = as.Date("1999-10-28"),
      aktiv = FALSE,
      wahlkreis = "Bundeswahlvorschlag"
    )
  )
}


# --- Input validation tests (no API needed) --------------------------------

test_that("get_mandates rejects invalid institution", {
  expect_error(
    get_mandates(pad_intern = "145", institution = "INVALID"),
    "Must be a subset of"
  )
})

test_that("get_mandates accepts valid institution values", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandate_row()
  )

  for (inst in c("NR", "BR", "KN", "PN")) {
    expect_no_error(
      get_mandates(pad_intern = "145", institution = inst)
    )
  }
})

test_that("get_mandates accepts NULL institution", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandate_row()
  )

  expect_no_error(
    get_mandates(pad_intern = "145", institution = NULL)
  )
})


# --- Mocked unit tests for processing logic --------------------------------

test_that("get_mandates returns expected output columns", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandates_multi()
  )

  result <- get_mandates(pad_intern = "145")

  expect_s3_class(result, "data.frame")

  expected_cols <- c(
    "pad_intern",
    "name",
    "position_text",
    "position_code",
    "position_name",
    "position_date_start",
    "position_date_end",
    "position_active",
    "parl_group",
    "party",
    "party_name",
    "electoral_district_region_code",
    "electoral_district_region",
    "legis_period",
    "url_biography"
  )

  expect_true(
    all(expected_cols %in% names(result)),
    info = paste(
      "Missing columns:",
      paste(setdiff(expected_cols, names(result)), collapse = ", ")
    )
  )
})

test_that("get_mandates renames columns correctly", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandate_row()
  )

  result <- get_mandates(pad_intern = "145")

  # Old column names should be gone
  old_names <- c(
    "bez", "funktion", "funktion_text",
    "funktion_von", "funktion_bis", "aktiv",
    "klub", "wahlpartei", "wahlpartei_text"
  )
  expect_false(any(old_names %in% names(result)))
})

test_that("get_mandates extracts electoral district from wahlkreis", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandate_row(
      wahlkreis = "7A - Ober\u00f6sterreich"
    )
  )

  result <- get_mandates(pad_intern = "145")

  expect_equal(result$electoral_district_region_code, "7A")
  expect_equal(result$electoral_district_region, "Ober\u00f6sterreich")
})

test_that("get_mandates handles Bundeswahlvorschlag in wahlkreis", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandate_row(
      wahlkreis = "Bundeswahlvorschlag"
    )
  )

  result <- get_mandates(pad_intern = "145")

  expect_equal(result$electoral_district_region_code, "FB")
})

test_that("get_mandates extracts legis_period from bez as list-column", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandate_row(
      bez = "Zweite Pr\u00e4sidentin des Nationalrates (XXV. GP, XXVI. GP)"
    )
  )

  result <- get_mandates(pad_intern = "145")

  expect_type(result$legis_period, "list")
  expect_equal(result$legis_period[[1]], c("XXV", "XXVI"))
})

test_that("get_mandates adds url_biography column", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandate_row(
      pad_intern = "145"
    )
  )

  result <- get_mandates(pad_intern = "145")

  expect_equal(
    result$url_biography,
    "https://www.parlament.gv.at/person/145"
  )
})

test_that("get_mandates removes duplicate pad_interns", {
  call_count <- 0L
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) {
      call_count <<- call_count + 1L
      mock_mandate_row(pad_intern = pad_intern)
    }
  )

  result <- get_mandates(pad_intern = c("145", "145", "2345"))

  # Should deduplicate: only 2 unique pad_interns called
  expect_equal(call_count, 2L)
})

test_that("get_mandates returns an empty tibble when no data found", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) NULL
  )

  expect_message(
    result <- get_mandates(pad_intern = "999999"),
    "No mandates found"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true(all(
    c("pad_intern", "name", "position_code", "position_name") %in%
      names(result)
  ))
})


# --- Institution filtering tests -------------------------------------------

test_that("get_mandates filters by institution = 'NR'", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandates_multi()
  )

  result <- get_mandates(pad_intern = "145", institution = "NR")

  expect_s3_class(result, "data.frame")
  # NR filter keeps NR, 1PNR, 2PNR, 3PNR, ZON, ZSN
  expect_true(all(
    result$position_code %in% c("NR", "1PNR", "2PNR", "3PNR", "ZON", "ZSN")
  ))
  # Should include NR and 2PNR rows but NOT BR or BM rows
  expect_equal(nrow(result), 2)
})

test_that("get_mandates filters by institution = 'BR'", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandates_multi()
  )

  result <- get_mandates(pad_intern = "145", institution = "BR")

  expect_s3_class(result, "data.frame")
  expect_true(all(
    result$position_code %in% c("BR", "PB", "SPB", "PRAES", "ZOB", "ZSB")
  ))
  expect_equal(nrow(result), 1)
})

test_that("get_mandates returns an empty tibble when institution filter yields no results", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandate_row(funktion = "BM")
  )

  expect_message(
    result <- get_mandates(pad_intern = "145", institution = "NR"),
    "No mandates found for institution NR"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("get_mandates with institution = NULL returns all mandates", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandates_multi()
  )

  result <- get_mandates(pad_intern = "145", institution = NULL)

  # All 4 rows from mock (NR, 2PNR, BM, BR) should be returned
  expect_equal(nrow(result), 4)
})


# --- Date filtering tests --------------------------------------------------

test_that("get_mandates filters by date correctly", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandates_multi()
  )

  # Date in 2020: only the current NR mandate should match
  result <- get_mandates(pad_intern = "145", date = "01.06.2020")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) >= 1)
  # All returned mandates should span the filter date
  expect_true(all(result$position_date_start <= as.Date("2020-06-01")))
})

test_that("get_mandates date filter handles active mandates (NA end date)", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandate_row(
      funktion_von = as.Date("2019-10-23"),
      funktion_bis = NA_real_,
      aktiv = TRUE
    )
  )

  # Date after start: active mandate should be included
  result <- get_mandates(pad_intern = "145", date = "01.01.2025")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  # End date should be restored to NA after filtering
  expect_true(is.na(result$position_date_end))
})

test_that("get_mandates date filter excludes expired mandates", {
  local_mocked_bindings(
    get_mandates_single = function(pad_intern) mock_mandate_row(
      funktion_von = as.Date("2014-09-29"),
      funktion_bis = as.Date("2019-10-22"),
      aktiv = FALSE
    )
  )

  # Date after mandate ended: returns 0-row data frame
  # (date filter does not convert empty results to NULL, unlike institution filter)
  result <- get_mandates(pad_intern = "145", date = "01.01.2020")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})


# --- Name-based lookup tests (mocked) --------------------------------------

test_that("get_mandates looks up pad_intern when name is provided", {
  local_mocked_bindings(
    get_pad_intern = function(name) {
      tibble::tibble(pad_intern = "145", names_variants = "Doris Bures")
    },
    get_mandates_single = function(pad_intern) mock_mandate_row(
      pad_intern = pad_intern
    )
  )

  result <- get_mandates(name = "Doris Bures")

  expect_s3_class(result, "data.frame")
  expect_equal(result$pad_intern, "145")
})

test_that("get_mandates returns an empty tibble when name lookup yields no results", {
  local_mocked_bindings(
    get_pad_intern = function(name) NULL
  )

  expect_message(
    result <- get_mandates(name = "NonExistentPerson"),
    "No mandates found"
  )
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})


# --- Live integration tests ------------------------------------------------

test_that("get_mandates returns data for a known MP (Doris Bures)", {
  skip_on_cran()
  skip_if_mocked("Integration test requires live API")
  skip_if_offline()

  result <- get_mandates(pad_intern = "145")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)

  # Check key columns exist
  expect_true(all(c(
    "pad_intern", "name", "position_code",
    "position_date_start", "url_biography"
  ) %in% names(result)))

  # Doris Bures should have NR mandates
  expect_true(any(result$position_code == "NR"))
})

test_that("get_mandates institution filter works on live API", {
  skip_on_cran()
  skip_if_mocked("Integration test requires live API")
  skip_if_offline()

  result_nr <- get_mandates(pad_intern = "145", institution = "NR")
  result_all <- get_mandates(pad_intern = "145")

  expect_s3_class(result_nr, "data.frame")
  expect_true(nrow(result_nr) > 0)
  expect_true(nrow(result_all) >= nrow(result_nr))

  # NR filter should only return NR-related position codes
  expect_true(all(
    result_nr$position_code %in% c("NR", "1PNR", "2PNR", "3PNR", "ZON", "ZSN")
  ))
})

test_that("get_mandates works with name input on live API", {
  skip_on_cran()
  skip_if_mocked("Integration test requires live API")
  skip_if_offline()

  result <- get_mandates(name = "Sebastian Kurz")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true(any(result$position_code == "NR"))
})

test_that("get_mandates handles multiple pad_interns on live API", {
  skip_on_cran()
  skip_if_mocked("Integration test requires live API")
  skip_if_offline()

  result <- get_mandates(pad_intern = c("145", "2344"))

  expect_s3_class(result, "data.frame")
  expect_true(length(unique(result$pad_intern)) == 2)
})
