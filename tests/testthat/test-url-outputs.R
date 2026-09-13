# Exercise public outputs against the unmodified recorded API responses.
expect_full_url_columns <- function(result, columns) {
  expect_true(all(columns %in% names(result)))
  for (column in columns) {
    values <- result[[column]]
    expect_type(values, "character")
    values <- values[!is.na(values)]
    if (length(values)) {
      expect_match(values, "^https?://[^/]+/", all = TRUE)
      expect_no_match(values, "parlament\\.gv\\.at/(https?:|/)", all = TRUE)
    }
  }
}

test_that("person and participation searches return full URLs", {
  persons <- run_api_call(get_persons(names = "Kurz"), "get_persons")
  expect_full_url_columns(persons, "link")
  expect_identical(persons$link, paste0("https://www.parlament.gv.at/person/", persons$pad_intern))

  mps <- run_api_call(
    get_mps(legis_period = 27, institution = "NR", gender = "female", echo = FALSE),
    "get_mps"
  )
  expect_full_url_columns(mps, "link")
  expect_identical(mps$link, paste0("https://www.parlament.gv.at/person/", mps$pad_intern))

  participation <- run_api_call(
    get_participation(topic = "Bildung", item = "RGES", active = "J"),
    "get_participation"
  )
  expect_full_url_columns(participation, "item_url")
})

test_that("event URLs are links rather than HTML fragments", {
  events <- run_api_call(get_events(legis_period = 27, institution = "NR", echo = FALSE), "get_events")
  expect_full_url_columns(events, c("link", "link2", "livestream_url"))
  expect_true(any(!is.na(events$livestream_url)))
  expect_no_match(stats::na.omit(events$livestream_url), "<", all = TRUE)
})

test_that("MP detail modes return full URLs", {
  plenary <- run_api_call(
    get_mps_details(pad_intern = 145, detail_type = "plenary", institution = "NR", echo = FALSE),
    "get_mps_details"
  )
  expect_full_url_columns(plenary, c("meeting_url", "speech_transcript_url", "speech_media_url"))
  activities <- run_api_call(
    get_mps_details(pad_intern = 145, detail_type = "activities", item = "A", echo = FALSE),
    "get_mps_details"
  )
  expect_full_url_columns(activities, "item_url")
  committees <- run_api_call(
    get_mps_details(pad_intern = 145, detail_type = "committees", echo = FALSE),
    "get_mps_details"
  )
  expect_full_url_columns(committees, "committee_url")
})

test_that("meeting and transcript searches return full URLs in both chambers", {
  for (mode in c("meetings", "activities")) {
    meetings <- run_api_call(
      get_plenary_meetings(institution = "NR", legis_period = if (mode == "meetings") 28 else 27,
                          meeting_and_activities = mode, echo = FALSE),
      "get_plenary_meetings"
    )
    columns <- if (mode == "meetings") {
      c("meeting_url", "agenda_url_html", "agenda_url_pdf")
    } else {
      c("url_item", "url_meeting")
    }
    expect_full_url_columns(meetings, columns)
  }
  for (chamber in c("NRSITZ", "BRSITZ")) {
    transcripts <- run_api_call(
      get_transcripts(meeting_type = chamber, legis_period = if (chamber == "NRSITZ") "XV" else "XXV", echo = FALSE),
      "get_transcripts"
    )
    expect_full_url_columns(transcripts, c("meeting_url", "meeting_transcript_html", "meeting_transcript_pdf"))
  }
})

test_that("item details preserve nested document and reference URL formats", {
  for (path in c("/gegenstand/XXVIII/A/5", "/gegenstand/XXVIII/BI/24", "/gegenstand/XX/I/1833")) {
    content <- run_api_call(
      .parlat_parse_detail_json(.parlat_fetch_detail_json_text(path))$data$content,
      "get_item_details"
    )
    for (include_stages in c(TRUE, FALSE)) {
      item <- run_api_call(get_item_details(path, stages = include_stages), "get_item_details")
      expect_full_url_columns(item, "item_url")
      expect_identical(item$item_documents[[1]], .parse_item_documents(content$documents))
      expect_identical(item$references[[1]], .parse_references(content$reference))
      expect_identical(item$introducers[[1]], .parse_introducers(content$names))
    }
  }
})

test_that("plenary details complete top-level URLs and preserve nested timeline URLs", {
  decisions <- run_api_call(
    get_plenary_meeting_details(url = "/gegenstand/XXVIII/NRSITZ/50", details_on = "decisions", echo = FALSE),
    "get_plenary_meeting_details"
  )
  expect_full_url_columns(decisions, c("meeting_url", "resolution_url"))
  timeline <- run_api_call(
    get_plenary_meeting_details(url = "/gegenstand/XXVIII/NRSITZ/50", details_on = "timeline", echo = FALSE),
    "get_plenary_meeting_details"
  )
  expect_full_url_columns(timeline, c("meeting_url", "stage_fsth_url"))
  speaker_urls <- unlist(lapply(timeline$statements, function(x) x$speaker_url))
  expect_true(any(startsWith(speaker_urls, "/person/"), na.rm = TRUE))
})

test_that("search URLs feed directly into detail functions", {
  items <- run_api_call(
    get_items(institution = "NR", item = "ANTR", date_start = "01-01-2024",
              date_end = "31-01-2026", echo = FALSE),
    "get_items"
  )
  item_url <- items$item_url[items$item_url == "https://www.parlament.gv.at/gegenstand/XXVIII/A/5"]
  expect_length(item_url, 1L)
  item <- run_api_call(get_item_details(item_url, stages = FALSE), "get_item_details")
  expect_identical(item$item_url, item_url)

  meetings <- run_api_call(
    get_plenary_meetings(institution = "NR", legis_period = 28, meeting_and_activities = "meetings", echo = FALSE),
    "get_plenary_meetings"
  )
  meeting_url <- meetings$meeting_url[meetings$meeting_url == "https://www.parlament.gv.at/gegenstand/XXVIII/NRSITZ/50"]
  expect_length(meeting_url, 1L)
  meeting <- run_api_call(get_plenary_meeting_details(url = meeting_url), "get_plenary_meeting_details")
  expect_identical(meeting$meeting_url, meeting_url)
})

test_that("event links handle mixed API encodings and preserve query strings", {
  payload <- list(
    header = lapply(c("Datum", "Link", "Link2", "Livestreamlink"), function(label) list(label = label)),
    rows = list(
      c("01.01.2026", "/aktuelles/termine/123", '<a href="../agenda.pdf?q=a%2Fb#page=2">Agenda</a>',
        '<a href="https://example.org/live?q=1&amp;b=2">Live</a>'),
      c("02.01.2026", "https://www.parlament.gv.at/aktuelles/termine/124", "https://example.org/agenda", ""),
      c("03.01.2026", "", "", "<span>No livestream</span>")
    )
  )
  local_mocked_bindings(
    req_perform = function(...) httr2::response(
      200, headers = list(`content-type` = "application/json"),
      body = charToRaw(jsonlite::toJSON(payload, auto_unbox = TRUE))
    ),
    .package = "httr2"
  )
  events <- get_events(echo = FALSE)
  expect_identical(events$link, c(NA_character_, "https://www.parlament.gv.at/aktuelles/termine/124",
                                 "https://www.parlament.gv.at/aktuelles/termine/123"))
  expect_identical(events$link2, c(NA_character_, "https://example.org/agenda",
                                  "https://www.parlament.gv.at/aktuelles/agenda.pdf?q=a%2Fb#page=2"))
  expect_identical(events$livestream_url, c(NA_character_, NA_character_, "https://example.org/live?q=1&b=2"))
})

test_that("items without stages preserve nested document URLs", {
  content <- list(
    title = "Example", type = "Item",
    documents = list(list(title = "Documents", documents = list(
      list(type = "PDF", link = "../example.pdf#page=2"),
      list(type = "HTML", link = "https://example.org/document")
    )))
  )
  local_mocked_bindings(
    .parlat_fetch_detail_json_text = function(...) jsonlite::toJSON(list(content = content), auto_unbox = TRUE)
  )
  item <- get_item_details("/gegenstand/XXVIII/A/5")
  expect_identical(item$item_documents[[1]]$link,
                   c("../example.pdf#page=2",
                     "https://example.org/document"))
  expect_null(item$stages[[1]])
})

test_that("transcript export receives full PDF URLs", {
  requested_urls <- character()
  local_mocked_bindings(
    .parlat_download_transcript_pdf = function(url, dest_file) {
      requested_urls <<- c(requested_urls, url)
      TRUE
    }
  )
  transcripts <- run_api_call(
    get_transcripts(meeting_type = "NRSITZ", legis_period = 15, echo = FALSE,
                    export = "pdf", export_destination = tempdir()),
    "get_transcripts"
  )
  expect_gt(length(requested_urls), 0L)
  expect_setequal(requested_urls, stats::na.omit(transcripts$meeting_transcript_pdf))
  expect_match(requested_urls, "^https://www\\.parlament\\.gv\\.at/", all = TRUE)
})

test_that("committee output completes top-level documents and preserves nested member URLs", {
  local_mocked_bindings(
    get_committee_details = function(url_committee, details_type) {
      expect_match(url_committee, "^https://www\\.parlament\\.gv\\.at/ausschuss/")
      tibble::tibble(
        url_pdf = "/dokument/members.pdf",
        url_html = "https://www.parlament.gv.at/dokument/members.html",
        members = list(tibble::tibble(
          name = "Example", member_type = "member", party = "SPÖ",
          member_url = "/person/145"
        ))
      )
    }
  )
  committees <- run_api_call(
    get_committees(institution = "NR", legis_period = 20, details_type = "members", echo = FALSE),
    "get_committees"
  )
  expect_gt(nrow(committees), 0L)
  expect_full_url_columns(committees, c("url_committee", "url_pdf", "url_html"))
  expect_true(all(committees$url_pdf == "https://www.parlament.gv.at/dokument/members.pdf"))
  expect_true(all(vapply(committees$members, function(members) {
    identical(members$member_url, "/person/145")
  }, logical(1))))
})
