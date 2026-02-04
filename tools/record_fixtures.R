#!/usr/bin/env Rscript
# Record/refresh API fixtures for httptest2
#
# This script captures real API responses and saves them as fixtures for
# mocked testing. Run this script to:
# - Initially populate fixtures for all test scenarios
# - Refresh fixtures when the API changes
#
# Usage:
#   Rscript tools/record_fixtures.R
#   # Or interactively:
#   source("tools/record_fixtures.R")
#
# Note: This script requires internet access and will make real API calls
# to the Austrian Parliament API.

library(httptest2)

# Load package functions
devtools::load_all()

# Base path for fixtures
fixture_base <- "tests/testthat/fixtures"

#' Record fixtures for a function by running expressions
#'
#' @param func_name Name of the function (used as subdirectory)
#' @param ... Expressions to execute and record
record_fixtures <- function(func_name, ...) {
  fixture_dir <- file.path(fixture_base, func_name)

  # Clear existing fixtures for clean recording
  if (dir.exists(fixture_dir)) {
    unlink(fixture_dir, recursive = TRUE)
  }
  dir.create(fixture_dir, recursive = TRUE)

  message("\n========================================")
  message("Recording fixtures for: ", func_name)
  message("========================================")

  # Set the mock path to the fixture directory, then start capturing
  # Note: start_capturing() takes simplify, NOT a directory path
  httptest2::.mockPaths(fixture_dir)
  httptest2::start_capturing()
  on.exit({
    httptest2::stop_capturing()
    httptest2::.mockPaths(NULL)
  }, add = TRUE)

  exprs <- rlang::enquos(...)
  for (i in seq_along(exprs)) {
    expr <- exprs[[i]]
    expr_text <- rlang::quo_text(expr)
    message(sprintf("  [%d/%d] %s", i, length(exprs), substr(expr_text, 1, 60)))

    tryCatch(
      {
        result <- rlang::eval_tidy(expr)
        message("        -> OK")
      },
      error = function(e) {
        message("        -> ERROR: ", e$message)
      }
    )
  }
}

# ============================================================================
# Record fixtures for each function
# ============================================================================

# --- get_legis_periods ---
record_fixtures(
  "get_legis_periods",
  get_legis_periods(),
  get_legis_periods(legis_period = 27),
  get_legis_periods(legis_period = c(26, 27)),
  get_legis_periods(legis_period = "XXVII"),
  get_legis_periods(date = "01.01.2020"),
  get_legis_periods(date = c("01.01.2020", "01.01.2015")),
  get_legis_periods(date = "15.05.1955"),
  get_legis_periods(legis_period = 999),
  get_legis_periods(legis_period = "27"),
  get_legis_periods(legis_period = c("26", "I", "PN"))
)

# --- get_events ---
record_fixtures(
  "get_events",
  get_events(institution = "NR"),
  get_events(institution = "BR"),
  get_events(institution = "ParlDir/Klub"),
  get_events(institution = NULL),
  get_events(institution = c("NR", "BR")),
  get_events(event_type = "Plenarsitzung"),
  get_events(location = "Nationalratssaal"),
  get_events(location = "virtuell"),
  get_events(legis_period = 28),
  get_events(legis_period = "28"),
  get_events(legis_period = NULL),
  get_events(legis_period = 28, institution = "NR"),
  get_events(
    date_start = "01-01-2099",
    date_end = "31-01-2099",
    institution = "NR"
  ),
  get_events(
    institution = "NR",
    date_start = "01-01-2024",
    date_end = "31-03-2024",
    event_type = "Plenarsitzung",
    location = "Nationalratssaal"
  )
)

# --- get_mps ---
record_fixtures(
  "get_mps",
  get_mps(legis_period = 27, institution = "NR", gender = "female"),
  get_mps(legis_period = 27, institution = "NR", gender = "male"),
  get_mps(legis_period = 27, institution = "NR", gender = "all"),
  get_mps(legis_period = 27, institution = "NR"),
  get_mps(legis_period = "XXVII", institution = "NR"),
  get_mps(legis_period = "PN", institution = "PN"),
  get_mps(legis_period = c(26, 27), institution = "NR"),
  get_mps(date = "01.01.2020", institution = "NR", gender = "female"),
  get_mps(date = "01.01.2020", institution = "NR", gender = "male"),
  get_mps(date = "01.01.2020", institution = "NR", gender = "all"),
  get_mps(legis_period = c("26", "XXVII"), institution = "NR"),
  get_mps(legis_period = character(0), institution = "NR"),
  get_mps(institution = "NR", legis_period = "5", party = "KPÖ"),
  get_mps(legis_period = 26, institution = "NR"),
  # For name changes test - multiple periods
  get_mps(
    institution = "NR",
    legis_period = c(12, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28)
  )
)

# --- get_items ---
record_fixtures(
  "get_items",
  get_items(
    institution = "NR",
    item = "ANTR",
    date_start = "01-01-2024",
    date_end = "31-01-2026",
    echo = FALSE
  ),
  get_items(date_start = "01-01-2024", date_end = "01-03-2024", echo = FALSE),
  get_items(date_start = "01.01.2024", date_end = "01.03.2024", echo = FALSE),
  get_items(date_start = "01/01/2024", date_end = "01/03/2024", echo = FALSE),
  get_items(
    topic = "Wirtschaft",
    date_start = "01-01-1900",
    date_end = "02-01-1900",
    echo = FALSE
  ),
  get_items(
    institution = "NR",
    topic = "Bildung",
    legis_period = "27",
    echo = FALSE
  ),
  get_items(
    institution = "NR",
    topic = c("Sport", "Landesverteidigung"),
    legis_period = "27",
    echo = FALSE
  ),
  get_items(
    legis_period = c("KN", "PN", 10, "15"),
    institution = "NR",
    echo = FALSE
  ),
  get_items(item = "RV", legis_period = "27", echo = FALSE),
  get_items(keyword = "Gesundheit", legis_period = "27", echo = FALSE),
  get_items(eurovoc = "health", legis_period = "27", echo = FALSE),
  get_items(
    parl_group = "SPÖ",
    parl_group_names_standard = TRUE,
    legis_period = "27",
    echo = FALSE
  ),
  get_items(
    institution = "NR",
    item = "ANTR",
    legis_period = "27",
    echo = FALSE
  ),
  get_items(topic = "Bildung", legis_period = c(26, 27, 28), echo = FALSE),
  # EU items
  get_items(
    item = "EU",
    type_eu_submission = "BEU",
    institution = "NR",
    legis_period = 27,
    echo = FALSE
  ),
  get_items(
    item = "EU",
    type_eu_submission = c("BEU", "RGEU", "S"),
    institution = "NR",
    legis_period = 27,
    echo = FALSE
  ),
  get_items(
    item = "EU",
    type_eu_submission = "S",
    legis_period = 27,
    institution = "NR",
    echo = FALSE
  ),
  # BR EU items
  get_items(
    item = "EU",
    type_eu_submission = "BEU-BR",
    institution = "BR",
    legis_period = 27,
    echo = FALSE
  ),
  get_items(
    item = "EU",
    type_eu_submission = c("BEU-BR", "MT-BR"),
    institution = "BR",
    legis_period = 27,
    echo = FALSE
  ),
  get_items(
    item = "EU",
    type_eu_submission = "SBPL-BR",
    institution = "BR",
    legis_period = seq(24, 27, 1),
    echo = FALSE
  ),
  get_items(
    item = "EU",
    type_eu_submission = "MT-BR",
    institution = "BR",
    legis_period = seq(24, 27, 1),
    echo = FALSE
  ),
  get_items(
    item = "EU",
    type_eu_submission = "S-BR",
    institution = "BR",
    legis_period = seq(24, 27, 1),
    echo = FALSE
  ),
  # J_JPR_M items
  get_items(
    item = "J_JPR_M",
    type_doc = "JPR",
    institution = "NR",
    legis_period = 27,
    echo = FALSE
  ),
  get_items(
    item = "J_JPR_M",
    type_doc = "JMIN-BR",
    institution = "BR",
    legis_period = 27,
    echo = FALSE
  ),
  get_items(
    item = "J_JPR_M",
    type_doc = c("J", "JPR"),
    institution = "NR",
    legis_period = 27,
    echo = FALSE
  ),
  get_items(
    item = "J_JPR_M",
    type_doc = "JPR",
    legis_period = 27,
    institution = "NR",
    date_start = "01-01-2020",
    date_end = "31-12-2020",
    echo = FALSE
  )
)

# --- get_item_details ---
record_fixtures(
  "get_item_details",
  get_item_details("https://www.parlament.gv.at/gegenstand/XXVII/GAST/2"),
  get_item_details("/gegenstand/XXVIII/BI/24"),
  get_item_details("gegenstand/XXVIII/BI/24")
)

# --- get_participation ---
record_fixtures(
  "get_participation",
  get_participation(topic = "Bildung", item = "RGES", active = "J"),
  get_participation(legis_period = c(26, 27), item = "ME"),
  get_participation(item = "RGES", legis_period = 27)
)

# --- get_committees ---
record_fixtures(
  "get_committees",
  get_committees(institution = "NR", legis_period = 20),
  get_committees(institution = "NR", legis_period = 27),
  get_committees(institution = "NR", legis_period = 27, permanent = TRUE),
  get_committees(institution = "NR", legis_period = 27, permanent = FALSE),
  get_committees(
    institution = "NR",
    legis_period = 27,
    include_subcommittees = TRUE
  ),
  get_committees(
    institution = "NR",
    legis_period = 27,
    search_string = "Umwelt"
  ),
  get_committees(
    institution = "NR",
    legis_period = 27,
    search_string = "ThisShouldNotExistAnywhere12345"
  ),
  get_committees(institution = "BR", legis_period = 27),
  get_committees(institution = "NR", legis_period = "27"),
  get_committees(institution = "NR", legis_period = "XXVII"),
  get_committees(
    legis_period = 22,
    institution = "NR",
    details_type = "members",
    citation = "1/SA-BU"
  )
)

# --- get_plenary_sessions ---
record_fixtures(
  "get_plenary_sessions",
  get_plenary_sessions(
    institution = "NR",
    legis_period = 28,
    session_and_activities = "sessions"
  ),
  get_plenary_sessions(
    institution = "NR",
    legis_period = 27,
    session_and_activities = "submitted"
  ),
  get_plenary_sessions(
    institution = "NR",
    legis_period = 27,
    session_and_activities = "sessions"
  ),
  get_plenary_sessions(
    institution = "NR",
    legis_period = 27,
    session_and_activities = "held"
  ),
  get_plenary_sessions(
    institution = "BR",
    legis_period = 27,
    session_and_activities = "sessions"
  ),
  get_plenary_sessions(
    institution = "BR",
    legis_period = 27,
    session_and_activities = "submitted"
  ),
  get_plenary_sessions(
    institution = "BR",
    legis_period = 27,
    session_and_activities = "held"
  ),
  get_plenary_sessions(
    institution = "NR",
    legis_period = 28,
    session_and_activities = "submitted",
    submitted = "All"
  ),
  get_plenary_sessions(
    institution = "NR",
    legis_period = 28,
    session_and_activities = "submitted",
    submitted = "AA"
  ),
  get_plenary_sessions(
    institution = "NR",
    legis_period = 28,
    session_and_activities = "submitted",
    submitted = "J"
  ),
  get_plenary_sessions(
    institution = "NR",
    legis_period = 28,
    session_and_activities = "held",
    held = "All"
  ),
  get_plenary_sessions(
    institution = "NR",
    legis_period = 28,
    session_and_activities = "held",
    held = "AS"
  ),
  get_plenary_sessions(
    institution = "NR",
    legis_period = 28,
    session_and_activities = "held",
    held = "FS"
  ),
  get_plenary_sessions(institution = "BV", legis_period = NULL),
  get_plenary_sessions(
    institution = "NR",
    legis_period = c(27, 28),
    session_and_activities = "sessions"
  ),
  get_plenary_sessions(
    institution = "NR",
    legis_period = NULL,
    session_and_activities = "sessions"
  )
)

# --- get_transcripts ---
# Note: Export tests download actual files - those use skip_if_mocked()
record_fixtures(
  "get_transcripts",
  get_transcripts(session_type = "NRSITZ", legis_period = 15, echo = FALSE),
  get_transcripts(session_type = "BRSITZ", legis_period = "XXV", echo = FALSE),
  get_transcripts(
    legis_period = 27,
    session_type = c("NRSITZ", "BRSITZ"),
    echo = FALSE
  ),
  get_transcripts(legis_period = 27, session_type = "NRSITZ", echo = FALSE),
  get_transcripts(legis_period = "XXVII", session_type = "NRSITZ", echo = FALSE),
  get_transcripts(legis_period = "PN", echo = FALSE),
  get_transcripts(legis_period = 26, session_type = "NRSITZ", echo = FALSE),
  get_transcripts(
    legis_period = c(15, 20),
    session_type = "NRSITZ",
    echo = FALSE
  ),
  get_transcripts(legis_period = 27, session_type = "BRSITZ", echo = FALSE),
  get_transcripts(
    legis_period = 27,
    session_type = NULL,
    echo = FALSE
  ),
  get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    date_start = "01-01-2024",
    echo = FALSE
  ),
  get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    date_end = "01-01-2021",
    echo = FALSE
  ),
  get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    date_start = "01-01-2024",
    date_end = "30-06-2024",
    echo = FALSE
  ),
  get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    search_string = "budget",
    echo = FALSE
  ),
  get_transcripts(
    legis_period = 27,
    session_type = "NRSITZ",
    search_string = "gesundheit",
    echo = FALSE
  ),
  get_transcripts(
    session_type = "NRSITZ",
    date_start = "01/01/2024",
    date_end = "31/12/2024",
    search_string = "budget",
    echo = FALSE
  ),
  get_transcripts(
    search_string = NULL,
    legis_period = NULL,
    session_type = NULL,
    date_start = NULL,
    date_end = NULL,
    echo = FALSE
  )
)

# --- get_mps_details ---
record_fixtures(
  "get_mps_details",
  # Plenary tests
  get_mps_details(
    pad_intern = 145,
    detail_type = "plenary",
    institution = "NR",
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "plenary",
    institution = "BR",
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "plenary",
    legis_period = 27,
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "plenary",
    legis_period = "XXVII",
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "plenary",
    legis_period = c(26, 27),
    echo = FALSE
  ),
  # Activities tests
  get_mps_details(
    pad_intern = 145,
    detail_type = "activities",
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "activities",
    legis_period = 22,
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "activities",
    item = "A",
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "activities",
    institution = "NR",
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "activities",
    search_string = "test",
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "activities",
    legis_period = c(22, 23),
    institution = "NR",
    echo = FALSE
  ),
  # Committees tests
  get_mps_details(
    pad_intern = 145,
    detail_type = "committees",
    legis_period = 27,
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "committees",
    legis_period = 26,
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "committees",
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "committees",
    legis_period = 27,
    search_string = "test",
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 2344,
    detail_type = "committees",
    legis_period = 26,
    committee = "Volksanwaltschaftsausschuss",
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "committees",
    legis_period = 27,
    committee_position = "Mitglied",
    echo = FALSE
  ),
  get_mps_details(
    pad_intern = 145,
    detail_type = "committees",
    legis_period = c(25, 26),
    echo = FALSE
  ),
  # Empty results test
  get_mps_details(
    pad_intern = 2345,
    detail_type = "plenary",
    legis_period = 20,
    echo = FALSE
  )
)

# --- get_pad_intern ---
record_fixtures(
  "get_pad_intern",
  get_pad_intern("Kurz"),
  get_pad_intern("Müller"),
  get_pad_intern("Schmidt"),
  get_pad_intern("XyZaNonExistentName123"),
  get_pad_intern("kurz"),
  get_pad_intern("KURZ"),
  get_pad_intern("Michael Pock"),
  get_pad_intern("Michael Bernhard"),
  get_pad_intern("Elisabeth Götze"),
  get_pad_intern("Stephanie Krisper")
)

# --- get_persons ---
record_fixtures(
  "get_persons",
  get_persons(names = "Kurz")
)

# --- get_mandates ---
# Note: test-get_mandates.R is entirely commented out, so no fixtures needed
# record_fixtures(
#   "get_mandates",
#   get_mandates(pad_intern = 83111)
# )

# --- aux_check_pad_intern_exists ---
record_fixtures(
  "aux_check_pad_intern_exists",
  aux_check_pad_intern_exists("145"),
  aux_check_pad_intern_exists(c("145", "2345")),
  aux_check_pad_intern_exists("0"),
  aux_check_pad_intern_exists(c("145", "999999")),
  aux_check_pad_intern_exists(c("999999", "1000000")),
  aux_check_pad_intern_exists(" 145"),
  aux_check_pad_intern_exists("145 "),
  aux_check_pad_intern_exists(" 145 "),
  aux_check_pad_intern_exists(145),
  aux_check_pad_intern_exists(c("145", "88641"))
)

# ============================================================================
# Summary
# ============================================================================

message("\n========================================")
message("Fixture recording complete!")
message("========================================\n")

# List recorded fixtures
fixture_dirs <- list.dirs(fixture_base, recursive = FALSE)
for (dir in fixture_dirs) {
  files <- list.files(dir, recursive = TRUE)
  message(sprintf("  %s: %d files", basename(dir), length(files)))
}

message("\nReview changes with: git diff tests/testthat/fixtures/")
message("Commit with: git add tests/testthat/fixtures/ && git commit -m 'chore: update API fixtures'")
