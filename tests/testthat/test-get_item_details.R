# Tests for get_item_details() -----------------------------------------------

test_that("get_item_details returns expected one-row structure for an absolute URL", {
  result <- run_api_call(
    get_item_details("https://www.parlament.gv.at/gegenstand/XXVII/GAST/2"),
    fixture_subdir = "get_item_details"
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_true(all(c("item_url", "type_doc_long", "title", "stages", "votes") %in% names(result)))
  expect_type(result$stages, "list")
  expect_s3_class(result$stages[[1]], "data.frame")
  expect_true(all(c("stage_name", "stage_date", "phase") %in% names(result$stages[[1]])))
  expect_null(result$votes[[1]])
})

test_that("get_item_details normalizes relative URLs consistently", {
  absolute_url <- "https://www.parlament.gv.at/gegenstand/XXVIII/BI/24"

  result_absolute <- run_api_call(
    get_item_details(absolute_url),
    fixture_subdir = "get_item_details"
  )
  result_relative <- run_api_call(
    get_item_details("/gegenstand/XXVIII/BI/24"),
    fixture_subdir = "get_item_details"
  )
  result_no_slash <- run_api_call(
    get_item_details("gegenstand/XXVIII/BI/24"),
    fixture_subdir = "get_item_details"
  )

  expect_equal(result_absolute, result_relative)
  expect_equal(result_absolute, result_no_slash)
})

test_that("get_item_details can skip stage extraction", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/A/5", stages = FALSE),
    fixture_subdir = "get_item_details"
  )

  expect_equal(nrow(result), 1)
  expect_false("stages" %in% names(result))
})

test_that("get_item_details can skip vote extraction", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/A/5", votes = FALSE),
    fixture_subdir = "get_item_details"
  )

  expect_equal(nrow(result), 1)
  expect_false("votes" %in% names(result))
})

test_that("get_item_details includes non-null vote results", {
  result <- run_api_call(
    get_item_details("/gegenstand/XX/I/1833", stages = FALSE),
    fixture_subdir = "get_item_details"
  )

  vote <- result$votes[[1]]

  expect_equal(nrow(result), 1)
  expect_true("votes" %in% names(result))
  expect_type(vote, "list")
  expect_named(
    vote,
    c("result", "infavor", "code", "text", "comment"),
    ignore.order = TRUE
  )
  expect_true(vote$infavor)
  expect_equal(vote$code, "SVflg")
  expect_equal(vote$text, "Dafür: S, V. Dagegen: F, L, G")
  expect_null(vote$comment)
  expect_s3_class(vote$result, "data.frame")
  expect_named(
    vote$result,
    c("text", "code", "color", "fraction", "infavor"),
    ignore.order = TRUE
  )
  expect_equal(nrow(vote$result), 5)
})

test_that("get_item_details includes stable item-level metadata fields", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVII/UEA/283"),
    fixture_subdir = "get_item_details"
  )

  expect_true(all(c(
    "date_introduced",
    "legis_period",
    "item_type",
    "type_doc",
    "type_doc_long",
    "item_number",
    "status_number",
    "status_description",
    "item_documents",
    "introducers",
    "references",
    "topics",
    "headwords",
    "eurovoc",
    "votes",
    "stages"
  ) %in% names(result)))
  expect_equal(nrow(result), 1)
  expect_s3_class(result$date_introduced, "Date")
  expect_type(result$item_documents, "list")
  expect_type(result$introducers, "list")
  expect_type(result$references, "list")
  expect_type(result$topics, "list")
  expect_type(result$headwords, "list")
  expect_type(result$eurovoc, "list")
  expect_type(result$votes, "list")
  expect_null(result$votes[[1]])
  expect_false("type" %in% names(result))
  expect_equal(result$item_type, "UEA")
  expect_equal(result$type_doc, "UEAM")
  expect_equal(result$type_doc_long, "Misstrauensantrag")
  expect_equal(length(unique(result$legis_period)), 1)
  expect_equal(length(unique(result$date_introduced)), 1)
})

test_that("get_item_details nested item metadata keeps expected columns", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVII/UEA/283"),
    fixture_subdir = "get_item_details"
  )

  intro <- result$introducers[[1]]
  refs <- result$references[[1]]

  expect_s3_class(intro, "data.frame")
  expect_s3_class(refs, "data.frame")
  expect_named(intro, c("role", "name", "frak_code", "url"), ignore.order = TRUE)
  expect_named(refs, c("text", "subject", "zitation", "url", "art"), ignore.order = TRUE)
})

test_that("get_item_details parses item documents with missing fields", {
  docs <- data.frame(
    title = "Document group",
    stringsAsFactors = FALSE
  )
  docs$documents <- list(data.frame(
    document_name = "Document without link or type",
    stringsAsFactors = FALSE
  ))

  result <- .parse_item_documents(docs)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("doc_title", "link", "type"))
  expect_equal(result$doc_title, "Document group")
  expect_true(is.na(result$link))
  expect_true(is.na(result$type))
})

test_that("get_item_details parses introducers with missing URLs", {
  names <- data.frame(
    funktext = c("Antragsteller", "Antragstellerin"),
    name = c("Person A", "Person B"),
    frak_code = c("A", "B"),
    stringsAsFactors = FALSE
  )

  result <- .parse_introducers(names)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("role", "name", "frak_code", "url"))
  expect_equal(nrow(result), 2)
  expect_true(all(is.na(result$url)))
})

test_that("get_item_details parses references with missing fields", {
  refs <- data.frame(
    text = c("Reference A", "Reference B"),
    zitation = c("1/A", "2/A"),
    stringsAsFactors = FALSE
  )

  result <- .parse_references(refs)

  expect_s3_class(result, "data.frame")
  expect_named(result, c("text", "subject", "zitation", "url", "art"))
  expect_equal(nrow(result), 2)
  expect_true(all(is.na(result$subject)))
  expect_true(all(is.na(result$url)))
  expect_true(all(is.na(result$art)))
})

test_that("get_item_details nests phase stages in stages", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/A/5"),
    fixture_subdir = "get_item_details"
  )

  stage_tbl <- result$stages[[1]]

  expect_equal(nrow(result), 1)
  expect_s3_class(stage_tbl, "data.frame")
  expect_named(stage_tbl, c("phase", "stage_name", "stage_date", "speeches"), ignore.order = TRUE)
  expect_gt(nrow(stage_tbl), 1)
  expect_false(all(is.na(stage_tbl$phase)))
})

test_that("get_item_details nests flat stages in stages", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVII/UEA/283"),
    fixture_subdir = "get_item_details"
  )

  stage_tbl <- result$stages[[1]]

  expect_equal(nrow(result), 1)
  expect_s3_class(stage_tbl, "data.frame")
  expect_named(stage_tbl, c("phase", "stage_name", "stage_date"), ignore.order = TRUE)
  expect_gt(nrow(stage_tbl), 1)
  expect_true(all(is.na(stage_tbl$phase)))
})

test_that("get_item_details speech extraction preserves list-column structure", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/A/5"),
    fixture_subdir = "get_item_details"
  )

  stage_tbl <- result$stages[[1]]

  expect_true("speeches" %in% names(stage_tbl))
  expect_type(stage_tbl$speeches, "list")
  expect_equal(length(stage_tbl$speeches), nrow(stage_tbl))
  expect_true(all(vapply(stage_tbl$speeches, \(x) is.null(x) || is.data.frame(x), logical(1))))
  expect_true(any(vapply(stage_tbl$speeches, is.null, logical(1))))
})

test_that("get_item_details nested speech tibbles keep expected columns and types", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/A/5"),
    fixture_subdir = "get_item_details"
  )

  stage_tbl <- result$stages[[1]]
  speeches_tbl <- stage_tbl$speeches[!vapply(stage_tbl$speeches, is.null, logical(1))][[1]]

  expect_s3_class(speeches_tbl, "data.frame")
  expect_named(
    speeches_tbl,
    c(
      "speaker",
      "speaker_url",
      "position",
      "protocol_page",
      "protocol_url",
      "video_url"
    ),
    ignore.order = TRUE
  )
  expect_type(speeches_tbl$protocol_url, "list")
  expect_type(speeches_tbl$speaker_url, "character")
  expect_type(speeches_tbl$video_url, "character")
})

test_that("get_item_details keeps split protocol links together for a single speech", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/A/5"),
    fixture_subdir = "get_item_details"
  )

  stage_tbl <- result$stages[[1]]
  all_speeches <- dplyr::bind_rows(stage_tbl$speeches[!vapply(stage_tbl$speeches, is.null, logical(1))])
  hafenecker <- all_speeches[grepl("Hafenecker", all_speeches$speaker), ]
  split_row <- hafenecker[vapply(hafenecker$protocol_url, length, integer(1)) == 2L, ]

  expect_gt(nrow(hafenecker), 0)
  expect_equal(nrow(split_row), 1)
  expect_match(split_row$protocol_page, "RN/70", fixed = TRUE)
  expect_match(split_row$protocol_page, "RN/72", fixed = TRUE)
  expect_true(all(grepl("^https://www.parlament.gv.at", split_row$protocol_url[[1]])))
})

test_that("get_item_details uses NA_character_ instead of empty protocol_url vectors", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/A/5"),
    fixture_subdir = "get_item_details"
  )

  stage_tbl <- result$stages[[1]]
  all_speeches <- dplyr::bind_rows(stage_tbl$speeches[!vapply(stage_tbl$speeches, is.null, logical(1))])
  url_lengths <- vapply(all_speeches$protocol_url, length, integer(1))

  expect_true(all(url_lengths >= 1L))
})

test_that("get_item_details handles items with missing optional debate fields", {
  result <- run_api_call(
    get_item_details("/gegenstand/XXVIII/BI/24"),
    fixture_subdir = "get_item_details"
  )

  stage_tbl <- result$stages[[1]]

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_true(all(c("date_introduced", "legis_period", "stages") %in% names(result)))
  expect_s3_class(stage_tbl, "data.frame")
  expect_false("speeches" %in% names(stage_tbl))
})
