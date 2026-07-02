# Unit tests for the detail-page helpers in R/html_helpers.R
# (the fragile area documented in AGENTS.md; all tests are network-free)

# --- .parlat_detail_json_url -------------------------------------------------

test_that(".parlat_detail_json_url appends json=TRUE and strips old queries", {
  expect_equal(
    .parlat_detail_json_url("https://www.parlament.gv.at/person/145"),
    "https://www.parlament.gv.at/person/145?json=TRUE"
  )
  expect_equal(
    .parlat_detail_json_url(
      "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50?selectedStage=100"
    ),
    "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50?json=TRUE"
  )
})

# --- .parlat_parse_detail_json -----------------------------------------------

test_that(".parlat_parse_detail_json parses valid JSON", {
  result <- .parlat_parse_detail_json('{"content": {"title": "Test"}}')
  expect_type(result, "list")
  expect_equal(result$data$content$title, "Test")
})

test_that(".parlat_parse_detail_json respects simplifyVector", {
  json_text <- '{"values": [1, 2, 3]}'

  simplified <- .parlat_parse_detail_json(json_text, simplifyVector = TRUE)
  expect_type(simplified$data$values, "integer")

  raw <- .parlat_parse_detail_json(json_text, simplifyVector = FALSE)
  expect_type(raw$data$values, "list")
})

test_that(".parlat_parse_detail_json fails loudly on invalid JSON", {
  expect_error(
    .parlat_parse_detail_json("NA"),
    "Could not parse Parliament detail JSON"
  )
  expect_error(
    .parlat_parse_detail_json("<html>not json</html>"),
    "Could not parse Parliament detail JSON"
  )
})

# --- .parlat_extract_props_json ----------------------------------------------

test_that(".parlat_extract_props_json extracts the legacy props payload", {
  page <- rvest::minimal_html(
    '<html><head><script>init({props: {"a": 1}});</script></head></html>'
  )
  json_text <- .parlat_extract_props_json(page)
  expect_equal(jsonlite::fromJSON(json_text)$a, 1)
})

test_that(".parlat_extract_props_json fails loudly when payload is missing", {
  page <- rvest::minimal_html(
    "<html><head><script>var x = 1;</script></head></html>"
  )
  expect_error(
    .parlat_extract_props_json(page),
    "props"
  )
})

# --- .parlat_fetch_detail_json_text -----------------------------------------

test_that(".parlat_fetch_detail_json_text errors on empty response body", {
  local_mocked_bindings(
    req_perform = function(req, ...) structure(list(), class = "httr2_response"),
    resp_body_string = function(resp, ...) "",
    .package = "httr2"
  )

  expect_error(
    .parlat_fetch_detail_json_text("https://www.parlament.gv.at/person/145"),
    "empty"
  )
})
