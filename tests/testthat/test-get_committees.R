committee_result_cols <- function(details_type = NULL) {
  cols <- c(
    "legis_period",
    "committee",
    "citation",
    "id_number",
    "url_committee"
  )

  if (identical(details_type, "members")) {
    cols <- c(
      cols,
      "date_start",
      "date_end",
      "url_pdf",
      "url_html",
      "members"
    )
  }

  cols
}

expect_committee_result_schema <- function(result, details_type = NULL) {
  expect_s3_class(result, "tbl_df")
  expect_identical(names(result), committee_result_cols(details_type))
  expect_type(result$legis_period, "character")
  expect_type(result$committee, "character")
  expect_type(result$citation, "character")
  expect_type(result$id_number, "integer")
  expect_type(result$url_committee, "character")

  if (identical(details_type, "members")) {
    expect_identical(class(result$date_start), c("POSIXct", "POSIXt"))
    expect_identical(class(result$date_end), c("POSIXct", "POSIXt"))
    expect_identical(attr(result$date_start, "tzone"), "UTC")
    expect_identical(attr(result$date_end, "tzone"), "UTC")
    expect_type(result$url_pdf, "character")
    expect_type(result$url_html, "character")
    expect_type(result$members, "list")
  }
}

test_that("get_committees returns valid data structure", {
  x <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 20
    )
  }, fixture_subdir = "get_committees")

  # Test basic structure
  expect_committee_result_schema(x)

  if (!is.null(x) && nrow(x) > 0) {
    # Test expected columns exist
    expected_cols <- c("committee", "url_committee")
    expect_true(all(expected_cols %in% colnames(x)))

    # Test data types
    expect_true(is.character(x$committee))
    expect_true(is.character(x$url_committee))

    # Test URL format
    expect_true(all(grepl("^https://www.parlament.gv.at", x$url_committee)))
  }
})

test_that("get_committees validates parameters correctly", {
  # Missing institution
  expect_error(
    get_committees(legis_period = 27),
    "not empty"
  )

  # Invalid institution
  expect_error(
    get_committees(institution = "INVALID", legis_period = 27),
    "Must be a subset of"
  )

  # Missing legis_period
  expect_error(
    get_committees(institution = "NR")
  )

  # Multiple legis_period values
  expect_error(
    get_committees(institution = "NR", legis_period = c(26, 27)),
    "Function allows only for one single legislative period"
  )

  # Invalid legis_period type (not numeric or character)
  expect_error(
    get_committees(institution = "NR", legis_period = TRUE)
  )

  # Invalid search_string
  expect_error(
    get_committees(
      institution = "NR",
      legis_period = 27,
      search_string = c("a", "b")
    ),
    "Must have length 1"
  )

  # Invalid echo parameter
  expect_error(
    get_committees(institution = "NR", legis_period = 27, echo = "invalid"),
    "Must be of type 'logical'"
  )
})

test_that("get_committees parameter combination validation works", {
  # permanent = TRUE with include_subcommittees = TRUE should fail
  expect_error(
    get_committees(
      institution = "NR",
      legis_period = 27,
      permanent = TRUE,
      include_subcommittees = TRUE
    ),
    "Searching for subcommittees is only possible if `permanent` is not TRUE"
  )
})

test_that("get_committees warns for legislative periods before 20", {
  for (details_type in list(NULL, "members")) {
    expect_warning(
      result <- get_committees(
        institution = "NR",
        legis_period = 19,
        details_type = details_type
      ),
      "Data only available from legislative period 20 onwards"
    )

    expect_equal(nrow(result), 0)
    expect_committee_result_schema(result, details_type)
  }

  # Test with period 1 as well
  expect_warning(
    result2 <- get_committees(
      institution = "NR",
      legis_period = 1
    ),
    "Data only available from legislative period 20 onwards"
  )
  expect_s3_class(result2, "tbl_df")
  expect_equal(nrow(result2), 0)

  # Test with Roman numeral input
  expect_warning(
    result3 <- get_committees(
      institution = "NR",
      legis_period = "XIX"
    ),
    "Data only available from legislative period 20 onwards"
  )
  expect_s3_class(result3, "tbl_df")
  expect_equal(nrow(result3), 0)
})

test_that("get_committees works with different institutions", {
  institutions <- c("NR", "BR")

  for (inst in institutions) {
    x <- run_api_call({
      get_committees(
        institution = inst,
        legis_period = 27
      )
    }, fixture_subdir = "get_committees")

    expect_true(
      is.data.frame(x) || is.null(x),
      info = paste("Failed for institution:", inst)
    )
  }
})

test_that("get_committees works with different parameter combinations", {
  # Test permanent = TRUE
  x1 <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27,
      permanent = TRUE
    )
  }, fixture_subdir = "get_committees")
  expect_true(is.data.frame(x1) || is.null(x1))

  # Test permanent = FALSE
  x2 <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27,
      permanent = FALSE
    )
  }, fixture_subdir = "get_committees")
  expect_true(is.data.frame(x2) || is.null(x2))

  # Test include_subcommittees = TRUE (only when permanent != TRUE)
  x3 <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27,
      include_subcommittees = TRUE
    )
  }, fixture_subdir = "get_committees")
  expect_true(is.data.frame(x3) || is.null(x3))
})

test_that("get_committees with search_string works", {
  x <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27,
      search_string = "Umwelt"
    )
  }, fixture_subdir = "get_committees")

  expect_true(is.data.frame(x) || is.null(x))
})

test_that("get_committees handles empty results gracefully", {
  for (details_type in list(NULL, "members")) {
    x <- run_api_call({
      get_committees(
        institution = "NR",
        legis_period = 27,
        search_string = "ThisShouldNotExistAnywhere12345",
        details_type = details_type
      )
    }, fixture_subdir = "get_committees")

    expect_equal(nrow(x), 0)
    expect_committee_result_schema(x, details_type)
  }
})

test_that("get_committees preserves schemas after citation filtering", {
  for (details_type in list(NULL, "members")) {
    result <- run_api_call({
      get_committees(
        institution = "NR",
        legis_period = 27,
        citation = "ThisCitationDoesNotExist12345",
        details_type = details_type
      )
    }, fixture_subdir = "get_committees")

    expect_equal(nrow(result), 0)
    expect_committee_result_schema(result, details_type)
  }
})

test_that("get_committees normalizes unavailable member details", {
  result <- .parlat_normalize_committees(
    tibble::tibble(
      committee = "Ausschuss",
      citation = "1/A",
      id_number = 1L,
      url_committee = "https://www.parlament.gv.at/ausschuss/XXVII/A/1",
      details = list(tibble::tibble())
    ),
    legis_period = "XXVII",
    details_type = "members"
  )

  expect_committee_result_schema(result, "members")
  expect_identical(nrow(result), 1L)
  expect_identical("details" %in% names(result), FALSE)
  expect_s3_class(result$members[[1]], "tbl_df")
  expect_identical(
    names(result$members[[1]]),
    c("name", "member_type", "party", "member_url")
  )
  expect_identical(nrow(result$members[[1]]), 0L)
  expect_identical(
    unname(vapply(result$members[[1]], is.character, logical(1))),
    rep(TRUE, 4)
  )
})

ordinary_membership_html <- function(
  include_header_table = FALSE,
  include_column_header = FALSE
) {
  header <- if (include_header_table) {
    "<table><tr><td>Stand</td><td>3. März 2025</td></tr></table>"
  } else {
    ""
  }
  column_header <- if (include_column_header) {
    paste0(
      "<thead><tr><th>Fraktion</th><th>Mitglieder</th>",
      "<th>Ersatzmitglieder</th></tr></thead>"
    )
  } else {
    ""
  }

  paste0(
    "<html><body>",
    header,
    "<table>",
    column_header,
    "<tr><td></td><td>Mitglieder:</td><td>Ersatzmitglieder:</td></tr>",
    "<tr><td>SPÖ :</td>",
    "<td><a href='/person/1'>Anna Beispiel</a></td>",
    "<td><a href='/person/2'>Berta Beispiel</a></td></tr>",
    "<tr><td></td><td>Vorsitzende/r:</td>",
    "<td><a href='/person/3'>Clara Beispiel</a></td></tr>",
    "</table></body></html>"
  )
}

test_that("committee members parse an ordinary NR table in position one", {
  fetch_count <- 0L
  local_mocked_bindings(
    .parlat_fetch_html = function(url) {
      fetch_count <<- fetch_count + 1L
      rvest::read_html(ordinary_membership_html())
    }
  )

  result <- get_committee_members("/dokument/XXVIII/A-AS/1/MIT_1.html")

  expect_identical(fetch_count, 1L)
  expect_identical(
    names(result),
    c("name", "member_type", "party", "member_url")
  )
  expect_setequal(
    result$name,
    c("Anna Beispiel", "Berta Beispiel", "Clara Beispiel")
  )
  expect_identical(
    unname(vapply(result, is.character, logical(1))),
    rep(TRUE, 4)
  )
})

test_that("committee members select a BR membership table after its header", {
  local_mocked_bindings(
    .parlat_fetch_html = function(url) {
      rvest::read_html(ordinary_membership_html(include_header_table = TRUE))
    }
  )

  result <- get_committee_members(
    "/dokument/BR/A-AK-BR/1/00311/MIT_00311.html"
  )

  expect_identical(nrow(result), 3L)
  expect_setequal(
    result$name,
    c("Anna Beispiel", "Berta Beispiel", "Clara Beispiel")
  )
})

test_that("ordinary member names remain aligned with URLs after a th header", {
  local_mocked_bindings(
    .parlat_fetch_html = function(url) {
      rvest::read_html(ordinary_membership_html(include_column_header = TRUE))
    }
  )

  result <- get_committee_members("/dokument/XXVIII/A-AS/1/MIT_1.html")
  urls_by_name <- stats::setNames(result$member_url, result$name)

  expect_identical(urls_by_name[["Anna Beispiel"]], "/person/1")
  expect_identical(urls_by_name[["Berta Beispiel"]], "/person/2")
  expect_identical(urls_by_name[["Clara Beispiel"]], "/person/3")
})

test_that("committee members preserve the two-column Hauptausschuss layout", {
  html <- paste0(
    "<html><body><table>",
    "<tr><td><b>ÖVP</b><a href='/person/1'>Anna Beispiel</a></td>",
    "<td>Mitglied</td></tr>",
    "<tr><td><a href='/dokument/XXVIII/A-HA/1'>Dokument</a></td>",
    "<td>Navigation</td></tr>",
    "</table></body></html>"
  )
  local_mocked_bindings(
    .parlat_fetch_html = function(url) rvest::read_html(html)
  )

  result <- get_committee_members(
    "/dokument/XXVIII/A-HA/1/00915/MIT_00915.html"
  )

  expect_identical(nrow(result), 1L)
  expect_identical(result$name, "Anna Beispiel")
  expect_identical(result$member_type, "member")
  expect_identical(result$party, "ÖVP")
  expect_identical(result$member_url, "/person/1")
})

test_that("SA-P9 tables are paired with content markers, not positions", {
  html <- paste0(
    "<html><body>",
    "<table><tr><td>Nationalrat entsendet</td></tr></table>",
    "<table><tr><td>Unrelated</td><td>three</td><td>columns</td></tr></table>",
    "<table>",
    "<tr><td>SPÖ :</td><td><a href='/person/1'>Anna NR</a></td>",
    "<td><a href='/person/2'>Berta NR</a></td></tr>",
    "</table>",
    "<table><tr><td>Bundesrat entsendet</td></tr></table>",
    "<table>",
    "<tr><td>ÖVP :</td><td><a href='/person/3'>Clara BR</a></td>",
    "<td><a href='/person/4'>Dora BR</a></td></tr>",
    "</table>",
    "</body></html>"
  )
  local_mocked_bindings(
    .parlat_fetch_html = function(url) {
      rvest::read_html(html)
    }
  )

  result <- get_committee_members(
    "/dokument/XXVII/SA-P9/1/00876/MIT_00876.html"
  )
  neutral_result <- get_committee_members(
    "/dokument/XXVII/A-TEST/1/00876/MIT_00876.html"
  )

  expect_identical(neutral_result, result)
  expect_setequal(result$name, c("Anna NR", "Berta NR", "Clara BR", "Dora BR"))
  expect_identical(
    names(result),
    c("name", "member_type", "party", "member_url")
  )
  expect_identical(
    unname(vapply(result, is.character, logical(1))),
    rep(TRUE, 4)
  )
})

test_that("malformed committee membership pages warn and return typed empty data", {
  local_mocked_bindings(
    .parlat_fetch_html = function(url) {
      rvest::read_html(
        "<html><body><table><tr><td>Header</td><td>Value</td></tr></table></body></html>"
      )
    }
  )

  warnings <- list()
  result <- withCallingHandlers(
    get_committee_members("/dokument/BR/A-BR/1/MIT_1.html"),
    warning = function(condition) {
      warnings[[length(warnings) + 1L]] <<- condition
      invokeRestart("muffleWarning")
    }
  )

  expect_length(warnings, 1L)
  expect_match(
    conditionMessage(warnings[[1]]),
    "No supported committee membership table was found"
  )
  expect_s3_class(result, "tbl_df")
  expect_identical(nrow(result), 0L)
  expect_identical(
    names(result),
    c("name", "member_type", "party", "member_url")
  )
  expect_identical(
    unname(vapply(result, is.character, logical(1))),
    rep(TRUE, 4)
  )
})

test_that("committee detail documents collapse into one non-photo row", {
  detail_data <- list(
    content = list(
      gp_code = "XXVII",
      aus_von = "2019-10-23T00:00:00",
      aus_bis = "2024-10-23T00:00:00",
      documents = list(
        list(
          title = "Bebildertes Mitgliederverzeichnis",
          documents = list(
            list(type = "PDF", link = "/MITFOTO_1.pdf"),
            list(type = "HTML", link = "/MITFOTO_1.html")
          )
        ),
        list(
          title = "Mitgliederliste",
          documents = list(
            list(type = "PDF", link = "/MIT_1.pdf"),
            list(type = "HTML", link = "/MIT_1.html")
          )
        )
      )
    )
  )
  local_mocked_bindings(
    .parlat_fetch_detail_json_text = function(url) "detail JSON",
    .parlat_parse_detail_json = function(json_text, ...) {
      list(data = detail_data)
    },
    safe_get_committee_members = function(url) {
      tibble::tibble(
        name = "Anna Beispiel",
        member_type = "member",
        party = "SPÖ",
        member_url = "/person/1"
      )
    }
  )

  result <- get_committee_details(
    "https://www.parlament.gv.at/ausschuss/XXVII/A-AS/1/1",
    "members"
  )

  expect_identical(nrow(result), 1L)
  expect_identical(result$url_pdf, "/MIT_1.pdf")
  expect_identical(result$url_html, "/MIT_1.html")
  expect_identical(length(result$members), 1L)
  expect_identical(result$members[[1]]$name, "Anna Beispiel")
})

test_that("flat mixed documents discard photo records, not the ordinary pair", {
  documents <- tibble::tibble(
    type = c("PDF", "HTML", "PDF", "HTML"),
    link = c(
      "/MITFOTO_1.pdf",
      "/MITFOTO_1.html",
      "/MIT_1.pdf",
      "/MIT_1.html"
    )
  )

  result <- .parlat_select_committee_documents(documents)

  expect_identical(result$url_pdf, "/MIT_1.pdf")
  expect_identical(result$url_html, "/MIT_1.html")
})

test_that("exact committee citations accept both display orders", {
  response <- httr2::response(
    headers = list(`content-type` = "application/json"),
    body = charToRaw(jsonlite::toJSON(
      list(
        header = list(
          list(label = "Ausschuss"),
          list(label = "link")
        ),
        rows = list(
          c(
            "Ständiger Unterausschuss 1",
            "/ausschuss/XXII/SA-BU/1/00034"
          ),
          c(
            "Ständiger Unterausschuss 10",
            "/ausschuss/XXII/SA-BU/10/00035"
          )
        )
      ),
      auto_unbox = TRUE
    ))
  )
  local_mocked_bindings(
    get_committees_api_request = function(body_params) response
  )

  number_first <- get_committees(
    institution = "NR",
    legis_period = 22,
    citation = "1/SA-BU",
    echo = FALSE
  )
  canonical <- get_committees(
    institution = "NR",
    legis_period = 22,
    citation = "SA-BU/1",
    echo = FALSE
  )
  regex_result <- get_committees(
    institution = "NR",
    legis_period = 22,
    citation = "SA-BU/1[0]?",
    echo = FALSE
  )

  expect_identical(number_first, canonical)
  expect_identical(nrow(number_first), 1L)
  expect_identical(nrow(regex_result), 2L)
  expect_identical(canonical$citation, "SA-BU/1")
  expect_identical(
    .parlat_normalize_committee_citation("^1/SA-BU$"),
    "^1/SA-BU$"
  )
})

test_that("committee citation validation rejects missing and vector inputs", {
  missing_error <- tryCatch(
    get_committees(
      institution = "NR",
      legis_period = 22,
      citation = NA_character_,
      echo = FALSE
    ),
    error = identity
  )
  vector_error <- tryCatch(
    get_committees(
      institution = "NR",
      legis_period = 22,
      citation = c("SA-BU/1", "SA-BU/10"),
      echo = FALSE
    ),
    error = identity
  )

  expect_s3_class(missing_error, "error")
  expect_match(conditionMessage(missing_error), "May not be NA")
  expect_s3_class(vector_error, "error")
  expect_match(conditionMessage(vector_error), "Must have length 1")
})

test_that("get_committees works with different legis_period types", {
  # Test numeric
  x1 <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27
    )
  }, fixture_subdir = "get_committees")
  expect_true(is.data.frame(x1))

  # Test character
  x2 <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = "27"
    )
  }, fixture_subdir = "get_committees")
  expect_true(is.data.frame(x2))
})

test_that("get_committees returns identical results for different legis_period formats", {
  # Get results with numeric input
  result_numeric <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = 27
    )
  }, fixture_subdir = "get_committees")

  # Get results with character numeric input
  result_character <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = "27"
    )
  }, fixture_subdir = "get_committees")

  # Get results with Roman numeral input
  result_roman <- run_api_call({
    get_committees(
      institution = "NR",
      legis_period = "XXVII"
    )
  }, fixture_subdir = "get_committees")

  # All three should produce data frames
  expect_true(is.data.frame(result_numeric))
  expect_true(is.data.frame(result_character))
  expect_true(is.data.frame(result_roman))

  # All should have the same number of rows
  expect_equal(nrow(result_numeric), nrow(result_character))
  expect_equal(nrow(result_numeric), nrow(result_roman))

  # All should have the same columns
  expect_equal(colnames(result_numeric), colnames(result_character))
  expect_equal(colnames(result_numeric), colnames(result_roman))

  # The actual data should be identical (ignoring row order)
  # Sort by committee name to ensure consistent ordering
  result_numeric_sorted <- result_numeric[order(result_numeric$committee), ]
  result_character_sorted <- result_character[
    order(result_character$committee),
  ]
  result_roman_sorted <- result_roman[order(result_roman$committee), ]

  # Reset row names for comparison
  rownames(result_numeric_sorted) <- NULL
  rownames(result_character_sorted) <- NULL
  rownames(result_roman_sorted) <- NULL

  # Compare the sorted data frames
  expect_equal(result_numeric_sorted, result_character_sorted)
  expect_equal(result_numeric_sorted, result_roman_sorted)
})

test_that("get_committees handles committees with empty documents", {
  detail_data <- list(
    content = list(
      gp_code = "XXII",
      aus_von = "2003-01-01T00:00:00",
      aus_bis = "2006-01-01T00:00:00"
    )
  )
  local_mocked_bindings(
    .parlat_fetch_detail_json_text = function(url) "detail JSON",
    .parlat_parse_detail_json = function(json_text, ...) {
      list(data = detail_data)
    }
  )

  result <- get_committee_details(
    "https://www.parlament.gv.at/ausschuss/XXII/SA-BU/1/00034",
    "members"
  )

  expect_identical(nrow(result), 1L)
  expect_identical(result$url_pdf, NA_character_)
  expect_identical(result$url_html, NA_character_)
  expect_identical(length(result$members), 1L)
  expect_identical(result$members[[1]], .parlat_empty_committee_members())
})

test_that("get_committees with details_type='members' has no unexpected list-columns", {
  skip_on_cran()
  # This is a comprehensive integration test - run only in live mode
  skip_if_mocked("Complex integration test across multiple periods")

  # Fetch committee membership data across multiple legislative periods
  all_members <- seq(20, 28, 1) |>
    purrr::map(\(x) {
      get_committees(
        legis_period = x,
        institution = "NR",
        details_type = "members",
        echo = FALSE
      )
    })

  # Check each result
  all_members |>
    purrr::iwalk(\(result, idx) {
      if (!is.null(result) && nrow(result) > 0) {
        # Get column types using map
        col_types <- result |>
          purrr::map(class)

        # Find list-columns (columns where class contains "list" or "data.frame")
        list_cols <- col_types |>
          purrr::keep(\(x) "list" %in% x | "data.frame" %in% x) |>
          names()

        # Only "members" should be a list-column
        expect_true(
          all(list_cols == "members") || length(list_cols) == 0,
          info = paste(
            "Unexpected list-columns found in legis_period",
            19 + idx,
            ":",
            paste(setdiff(list_cols, "members"), collapse = ", ")
          )
        )

        # If members column exists, it should be a list
        if ("members" %in% colnames(result)) {
          expect_true(
            "list" %in% class(result$members),
            info = paste(
              "members column should be a list in legis_period",
              19 + idx
            )
          )
        }
      }
    })
})
