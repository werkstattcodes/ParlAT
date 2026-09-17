test_that("content parsing preserves HTML, readable text and every attachment", {
  html <- "<p>First &amp; second<br>Next line</p><p>Last paragraph</p>"
  local_mocked_bindings(.parlat_fetch_detail_json_text = function(url) {
    jsonlite::toJSON(list(content = list(
      gp_code = "XXVIII", ityp = "SNME", inr = 2458,
      statement = html,
      documents = list(list(title = "Submission", documents = list(
        list(link = "/dokument/example.pdf", type = "PDF"),
        list(link = "https://www.parlament.gv.at/dokument/example.html", type = "HTML")
      )))
    )), auto_unbox = TRUE)
  })
  result <- .parlat_submission_content("https://www.parlament.gv.at/gegenstand/XXVIII/SNME/2458")
  expect_identical(result$submission_html, html)
  expect_identical(result$submission_text, "First & second\nNext line\n\nLast paragraph")
  expect_identical(result$documents$type, c("PDF", "HTML"))
  expect_identical(result$documents$link, paste0(
    "https://www.parlament.gv.at/dokument/example.", c("pdf", "html")
  ))
})

test_that("missing content returns typed placeholders", {
  local_mocked_bindings(.parlat_fetch_detail_json_text = function(url) {
    '{"content":{"gp_code":"XXVIII","ityp":"SN","inr":10,"statementsstate":"Not submission text"}}'
  })
  expect_identical(
    .parlat_submission_content("https://www.parlament.gv.at/gegenstand/XXVIII/SN/10/"),
    .parlat_empty_submission_content()
  )
})

test_that("enrichment preserves rows and fetches each published URL once", {
  requested <- character()
  local_mocked_bindings(.parlat_submission_content = function(url) {
    requested <<- c(requested, url)
    result <- .parlat_empty_submission_content()
    result$submission_text <- url
    result
  })
  input <- tibble::tibble(submission_url = c("a", NA, "b", "a"), id = 1:4)
  result <- .parlat_add_submission_text(input, echo = FALSE)
  expect_identical(requested, c("a", "b"))
  expect_identical(result$id, input$id)
  expect_identical(result$submission_text, input$submission_url)
  expect_identical(result$documents[[2]], .parlat_empty_submission_content()$documents)
  empty <- .parlat_add_submission_text(input[0, ], echo = FALSE)
  expect_identical(empty$submission_text, character())
  expect_identical(empty$submission_html, character())
  expect_identical(empty$documents, list())
})

test_that("detail failures identify the affected URL", {
  url <- "https://www.parlament.gv.at/gegenstand/XXVIII/SN/10"
  for (response in c("not json", "{}", '{"content":{"gp_code":"XXVIII","ityp":"SN","inr":11}}')) {
    local_mocked_bindings(.parlat_fetch_detail_json_text = function(url) response)
    error <- tryCatch(.parlat_submission_content(url), error = identity)
    expect_s3_class(error, "error")
    expect_match(conditionMessage(error), url, fixed = TRUE)
  }
  local_mocked_bindings(.parlat_fetch_detail_json_text = function(url) stop("HTTP failure"))
  expect_snapshot(error = TRUE, .parlat_submission_content(url))
})

test_that("recorded submission details include inline text and attachments", {
  for (path in c("XXVIII/SNME/2458", "XXVIII/SNME/2446", "XXVIII/SN/980")) {
    result <- run_api_call(
      .parlat_submission_content(paste0("https://www.parlament.gv.at/gegenstand/", path)),
      fixture_subdir = "sn_text"
    )
    expect_named(result, c("submission_text", "submission_html", "documents"))
    expect_type(result$submission_text, "character")
    expect_named(result$documents, c("doc_title", "link", "type"))
    if (path == "XXVIII/SNME/2458") expect_match(result$submission_text, "EMRK")
    if (path == "XXVIII/SNME/2446") {
      expect_identical(result$documents$type, "PDF")
      expect_match(result$documents$link, "^https://")
      expect_identical(result$submission_text, NA_character_)
    }
  }
})
