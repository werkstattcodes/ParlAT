# _temp/discover_page_structures.R
# One-off discovery script for get_item_details() page structure analysis.
# NOT part of the ParlAT package. Run interactively from the project root.
#
# Purpose: Discover how many distinct page structures exist across ~380K
# parliamentary items, so that get_item_details() can handle them all.
#
# Output files:
#   _temp/all_items.csv            - cached item listing (run once)
#   _temp/structure_results.csv    - one row per probed URL
#   _temp/structure_errors.csv     - failed fetches
#   _temp/fingerprint_summary.csv  - aggregated fingerprint inventory
#   _temp/path_by_type.csv         - item_type x path cross-tabulation

devtools::load_all()

library(dplyr)
library(purrr)
library(stringr)
library(tibble)
library(rvest)
library(jsonlite)
library(digest)

# -- Configuration ------------------------------------------------------------
SAMPLE_N      <- 3L        # URLs to sample per stratum
REQUEST_DELAY <- 0.5       # seconds between fetches
MAX_RETRIES   <- 3L        # retry attempts per URL
ALL_ITEMS_FILE    <- "_temp/all_items.csv"
RESULTS_FILE      <- "_temp/structure_results.csv"
ERRORS_FILE       <- "_temp/structure_errors.csv"
SUMMARY_FILE      <- "_temp/fingerprint_summary.csv"
PATH_BY_TYPE_FILE <- "_temp/path_by_type.csv"

# -- Helper: write/append CSV -------------------------------------------------
write_or_append <- function(tbl, path) {
  if (file.exists(path)) {
    readr::write_csv(tbl, path, append = TRUE, col_names = FALSE)
  } else {
    readr::write_csv(tbl, path)
  }
}

# -- Phase 1: Fetch all items (one-time, cached) ------------------------------
if (file.exists(ALL_ITEMS_FILE)) {
  message("Reading cached item listing from ", ALL_ITEMS_FILE)
  df_all <- readr::read_csv(ALL_ITEMS_FILE, show_col_types = FALSE)
} else {
  message("Phase 1: fetching all items (LP 5-28 x NR/BR)...")
  params <- tidyr::expand_grid(lp = seq(5, 28), inst = c("NR", "BR"))
  list_all <- purrr::map2(
    params$lp, params$inst,
    \(lp, inst) tryCatch(
      get_items(legis_period = lp, institution = inst),
      error = function(e) {
        message("  [SKIP] LP ", lp, "/", inst, ": ", conditionMessage(e))
        NULL
      }
    ),
    .progress = TRUE
  )
  df_all <- purrr::list_rbind(purrr::compact(list_all))
  readr::write_csv(df_all, ALL_ITEMS_FILE)
  message("  -> ", nrow(df_all), " items saved to ", ALL_ITEMS_FILE)
}

# -- Phase 2: Stratified sampling ---------------------------------------------
# Extract numeric legislative period for binning
df_all <- df_all |>
  mutate(
    lp_num = as.integer(as.roman(legis_period)),
    period_bin = case_when(
      lp_num <= 15 ~ "old",
      lp_num <= 25 ~ "mid",
      TRUE         ~ "recent"
    )
  )

set.seed(42)
df_sample <- df_all |>
  slice_sample(n = SAMPLE_N, by = c(item_type, institution, period_bin)) |>
  select(item_url, item_type, institution, legis_period, period_bin) |>
  distinct(item_url, .keep_all = TRUE)

message("Phase 2: ", nrow(df_sample), " URLs sampled from ",
        n_distinct(df_sample$item_type), " item types")

# -- Helper: fetch and extract content JSON -----------------------------------
# Mirrors get_item_details.R lines 235-256, but uses parse_json() for
# unsimplified structural discovery. Retries with exponential backoff.
fetch_content <- function(item_url) {
  prefix <- "https://www.parlament.gv.at/"
  if (!str_starts(item_url, prefix)) {
    item_url <- str_c(prefix, str_replace(item_url, "^/+", ""))
  }

  attempt <- 0L
  last_error <- NULL


  while (attempt < MAX_RETRIES) {
    attempt <- attempt + 1L
    result <- tryCatch({
      page <- rvest::read_html(item_url)
      json_text <- page |>
        rvest::html_elements("script") |>
        rvest::html_text2() |>
        (\(x) x[str_detect(x, "props:")])() |>
        str_extract("(?s)props:.*") |>
        str_remove("props:\\s*") |>
        str_remove("\\}\\);\\s*$")

      jsonlite::parse_json(json_text)$data$content
    }, error = function(e) {
      e
    })

    if (!inherits(result, "error")) return(result)
    last_error <- result

    if (attempt < MAX_RETRIES) {
      wait <- (2^attempt) + runif(1, 0, 1)
      message("    Retry ", attempt, "/", MAX_RETRIES, " in ", round(wait, 1), "s")
      Sys.sleep(wait)
    }
  }

  stop("Failed after ", MAX_RETRIES, " attempts: ", conditionMessage(last_error))
}

# -- Helper: recursively collect key paths ------------------------------------
# For unnamed lists (JSON arrays), sample the first element's keys using []
# notation.  E.g. phase is an unnamed list of phase objects, so we record
# "phase[].name", "phase[].stages", etc.
collect_key_paths <- function(obj, prefix = "", max_depth = 3L, depth = 1L) {
  if (!is.list(obj) || depth > max_depth) return(character(0))
  paths <- character(0)
  nms <- names(obj)

  if (is.null(nms)) {
    # Unnamed list (JSON array) — sample first element
    if (length(obj) > 0 && is.list(obj[[1]])) {
      array_prefix <- if (nchar(prefix) == 0) "[]" else str_c(prefix, "[]")
      paths <- c(paths, collect_key_paths(obj[[1]], array_prefix, max_depth, depth))
    }
    return(paths)
  }

  for (key in nms) {
    path <- if (nchar(prefix) == 0) key else str_c(prefix, ".", key)
    paths <- c(paths, path)
    child <- obj[[key]]
    if (is.list(child)) {
      paths <- c(paths, collect_key_paths(child, path, max_depth, depth + 1L))
    }
  }
  paths
}

# -- Helper: fingerprint a content object -------------------------------------
fingerprint_content <- function(content) {
  all_paths <- sort(unique(collect_key_paths(content)))
  list(
    hash          = digest::digest(all_paths, algo = "md5"),
    example_paths = paste(head(all_paths, 8), collapse = ", ")
  )
}

# -- Helper: classify structure -----------------------------------------------
# Returns coarse path (A/B/C/D) plus key inventories.
# Uses union of keys across all stages (or first 3) to catch rare keys.
#
# With parse_json() (no simplification):
#   - "phase" is an unnamed list of phase objects, each containing $stages
#     (fromJSON would simplify this into a data.frame where $stages is a column)
#   - "stages" is an unnamed list of stage objects
classify_structure <- function(content) {
  # Detect phase/stages: phase is an unnamed list; each element has $stages
  has_phase_stages <- FALSE
  if (!is.null(content$phase) && is.list(content$phase) && is.null(names(content$phase))) {
    # Unnamed list — check if first element has stages
    has_phase_stages <- length(content$phase) > 0 && !is.null(content$phase[[1]]$stages)
  }
  has_flat_stages <- !is.null(content$stages) && is.list(content$stages)

  top_level_keys <- paste(sort(names(content)), collapse = "|")

  # Collect stage keys: union across stages (capped at first 3)
  stage_keys <- NA_character_

  collect_stage_keys <- function(stages_list) {
    n <- min(length(stages_list), 3L)
    if (n == 0) return(NA_character_)
    all_keys <- purrr::map(stages_list[seq_len(n)], names) |>
      purrr::list_c() |>
      unique() |>
      sort()
    paste(all_keys, collapse = "|")
  }

  if (has_phase_stages) {
    # Collect stage keys across all phases (capped at first 3 stages total)
    all_stages <- purrr::map(content$phase, \(p) p$stages) |> purrr::list_c()
    stage_keys <- collect_stage_keys(all_stages)
  } else if (has_flat_stages) {
    stage_keys <- collect_stage_keys(content$stages)
  }

  # Classify: A (phase/stages), B (flat stages), C (no stages), D (unknown)
  path <- if (has_phase_stages) {
    "A_phase_stages"
  } else if (has_flat_stages) {
    "B_flat_stages"
  } else if (!is.null(content$type) || !is.null(content$title)) {
    "C_no_stages"
  } else {
    "D_unknown_structure"
  }

  list(
    path           = path,
    top_level_keys = top_level_keys,
    stage_keys     = stage_keys
  )
}

# -- Sanity check probes ------------------------------------------------------
message("\nSanity check: probing 2 known URLs...")
sanity_urls <- c(
  "/gegenstand/XXVIII/A/5",   # expected: A_phase_stages

"/gegenstand/XXVIII/BI/24"  # expected: B_flat_stages
)
for (url in sanity_urls) {
  content <- fetch_content(url)
  cls <- classify_structure(content)
  message("  ", url, " -> ", cls$path)
}
message("Sanity check passed.\n")

# -- Phase 3: Fetch loop with resume support -----------------------------------
already_done <- character(0)
if (file.exists(RESULTS_FILE)) {
  already_done <- c(already_done,
                    readr::read_csv(RESULTS_FILE, show_col_types = FALSE)$item_url)
}
if (file.exists(ERRORS_FILE)) {
  already_done <- c(already_done,
                    readr::read_csv(ERRORS_FILE, show_col_types = FALSE)$item_url)
}

todo <- df_sample |> filter(!item_url %in% already_done)

if (length(already_done) > 0) {
  message("Resuming: ", length(already_done), " URLs already processed, ",
          nrow(todo), " remaining")
}

message("Phase 3: fetching ", nrow(todo), " pages...")

for (i in seq_len(nrow(todo))) {
  row <- todo[i, ]
  if (i %% 10 == 0) message("  ", i, " / ", nrow(todo))

  Sys.sleep(REQUEST_DELAY)

  tryCatch({
    content <- fetch_content(row$item_url)
    fp  <- fingerprint_content(content)
    cls <- classify_structure(content)

    result_row <- tibble(
      item_url       = row$item_url,
      item_type      = row$item_type,
      institution    = row$institution,
      legis_period   = row$legis_period,
      period_bin     = row$period_bin,
      path           = cls$path,
      top_level_keys = cls$top_level_keys,
      stage_keys     = cls$stage_keys,
      fingerprint    = fp$hash,
      example_paths  = fp$example_paths
    )
    write_or_append(result_row, RESULTS_FILE)

  }, error = function(e) {
    err_row <- tibble(
      item_url     = row$item_url,
      item_type    = row$item_type,
      institution  = row$institution,
      legis_period = row$legis_period,
      error_msg    = conditionMessage(e)
    )
    write_or_append(err_row, ERRORS_FILE)
    message("  [ERROR] ", row$item_url, ": ", conditionMessage(e))
  })
}

# -- Phase 4: Summary ---------------------------------------------------------
message("\nPhase 4: generating summaries...")

full_results <- readr::read_csv(RESULTS_FILE, show_col_types = FALSE)
n_total <- nrow(full_results)

# Summary 1: fingerprint inventory
fingerprint_summary <- full_results |>
  summarise(
    n_urls        = n(),
    coverage_pct  = round(n() / n_total * 100, 1),
    item_types    = paste(sort(unique(item_type)), collapse = ", "),
    institutions  = paste(sort(unique(institution)), collapse = ", "),
    periods       = paste(sort(unique(period_bin)), collapse = ", "),
    example_url   = first(item_url),
    example_paths = first(example_paths),
    .by = c(path, fingerprint, stage_keys)
  ) |>
  arrange(path, desc(n_urls))

readr::write_csv(fingerprint_summary, SUMMARY_FILE)

# Summary 2: path by item type
path_by_type <- full_results |>
  count(item_type, institution, path) |>
  tidyr::pivot_wider(names_from = path, values_from = n, values_fill = 0)

readr::write_csv(path_by_type, PATH_BY_TYPE_FILE)

# -- Print results -------------------------------------------------------------
message("\n", strrep("=", 60))
message("RESULTS")
message(strrep("=", 60))

message("\nCoarse path distribution:")
full_results |> count(path) |> print()

message("\nUnique fingerprints: ", n_distinct(full_results$fingerprint))
message("\nFingerprint summary:")
print(fingerprint_summary |>
        select(path, n_urls, coverage_pct, item_types, stage_keys))

message("\nPath by item type:")
print(path_by_type)

if (file.exists(ERRORS_FILE)) {
  errors <- readr::read_csv(ERRORS_FILE, show_col_types = FALSE)
  message("\n", nrow(errors), " fetch errors:")
  print(errors)
}

message("\nOutput files:")
message("  ", RESULTS_FILE, " (", n_total, " rows)")
message("  ", SUMMARY_FILE)
message("  ", PATH_BY_TYPE_FILE)
if (file.exists(ERRORS_FILE)) message("  ", ERRORS_FILE)
message("\nDone.")
