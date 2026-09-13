test_that("URL conversion completes paths without changing absolute destinations", {
  paths <- c(
    "/person/145", "person/145", "//www.parlament.gv.at/person/145",
    "https://www.parlament.gv.at/person/145?selectedtab=PLENUM#speech",
    "http://www.parlament.gv.at/person/145", "https://example.org/document.pdf",
    "mailto:office@example.org", "", "  ", NA_character_,
    "/dokument/a%20b.pdf?x=a%2Fb&x=c#page=2"
  )
  expected <- c(
    rep("https://www.parlament.gv.at/person/145", 3), paths[4:7],
    rep(NA_character_, 3),
    "https://www.parlament.gv.at/dokument/a%20b.pdf?x=a%2Fb&x=c#page=2"
  )
  expect_identical(.parlat_absolute_url(paths), expected)
  expect_identical(.parlat_absolute_url(expected), expected)
  expect_identical(.parlat_absolute_url(character()), character())
  expect_identical(.parlat_absolute_url(NULL), character())
  expect_identical(
    .parlat_absolute_url(c("../file.pdf", "./page.html", "#p2", "?tab=2"),
                         "https://www.parlament.gv.at/dokument/example/index.html"),
    paste0("https://www.parlament.gv.at/dokument/",
           c("file.pdf", "example/page.html", "example/index.html#p2",
             "example/index.html?tab=2"))
  )
})

test_that("HTML URL fields accept anchors, plain links, and absent links", {
  expect_identical(
    .parlat_href_url(c('<a href="../video?a=1&amp;b=2">Watch</a>',
                      "https://example.org/video", "", NA_character_, "<span>None</span>"),
                    "https://www.parlament.gv.at/aktuelles/termine/123"),
    c("https://www.parlament.gv.at/aktuelles/video?a=1&b=2",
      "https://example.org/video", NA_character_, NA_character_, NA_character_)
  )
})

test_that("top-level URL conversion leaves nested contents unchanged", {
  input <- tibble::tibble(
    url = "/gegenstand/XXVIII/A/5",
    date = as.Date("2026-01-01"),
    description = '<a href="/person/145">Unchanged HTML</a>',
    link_text = "Read the document",
    nested = list(list(
      documents = tibble::tibble(link = c("/dokument/a.pdf", "https://example.org/a.pdf")),
      speeches = tibble::tibble(protocol_url = list(c("/a#p1", "/b#p2"))),
      cells = list(list(url = "/person/145")),
      missing_url = NA,
      absent = NULL,
      empty = tibble::tibble(url = character())
    ))
  )
  output <- .parlat_url_columns(input, "url")
  expect_identical(output$url, "https://www.parlament.gv.at/gegenstand/XXVIII/A/5")
  expect_identical(output[names(input) != "url"], input[names(input) != "url"])
})

test_that("detail JSON requests discard fragments and old queries", {
  for (path in c("/gegenstand/XXVIII/A/5#stage", "gegenstand/XXVIII/A/5?tab=2#stage",
                 "https://www.parlament.gv.at/gegenstand/XXVIII/A/5#stage")) {
    expect_identical(.parlat_detail_json_url(path),
                     "https://www.parlament.gv.at/gegenstand/XXVIII/A/5?json=TRUE")
  }
})
