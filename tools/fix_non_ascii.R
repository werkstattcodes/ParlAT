# Script to replace non-ASCII characters in R source code lines
# Comments (lines starting with #) are left untouched so that
# roxygen2 documentation still renders German characters correctly.
#
# Unicode escape map for German special characters:
#   ae = \u00e4, oe = \u00f6, ue = \u00fc
#   Ae = \u00c4, Oe = \u00d6, Ue = \u00dc
#   ss = \u00df

files <- c(
  "R/aux_check_legis_period.R",
  "R/get_committees.R",
  "R/get_events.R",
  "R/get_items.R",
  "R/get_mps.R",
  "R/get_mps_current.R",
  "R/get_participation.R",

  "R/get_persons.R"
)

# Each entry: from = actual Unicode character, to = literal escape text
char_map <- list(
  list(from = "\u00e4", to = "\\u00e4"),
  list(from = "\u00f6", to = "\\u00f6"),
  list(from = "\u00fc", to = "\\u00fc"),
  list(from = "\u00c4", to = "\\u00c4"),
  list(from = "\u00d6", to = "\\u00d6"),
  list(from = "\u00dc", to = "\\u00dc"),
  list(from = "\u00df", to = "\\u00df")
)

total_replacements <- 0L

for (file_path in files) {
  if (!file.exists(file_path)) {
    message("Skipping missing file: ", file_path)
    next
  }

  lines <- readLines(file_path, encoding = "UTF-8", warn = FALSE)
  file_replacements <- 0L

  for (i in seq_along(lines)) {
    trimmed <- trimws(lines[i])

    # Skip pure comment lines (roxygen #' and regular #)
    if (startsWith(trimmed, "#")) next

    original <- lines[i]

    for (cm in char_map) {
      lines[i] <- gsub(cm$from, cm$to, lines[i], fixed = TRUE)
    }

    if (!identical(lines[i], original)) {
      file_replacements <- file_replacements + 1L
    }
  }

  # Write back with UTF-8 encoding (comments still have non-ASCII)
  con <- file(file_path, open = "w", encoding = "UTF-8")
  writeLines(lines, con, useBytes = TRUE)
  close(con)

  message(file_path, ": ", file_replacements, " code line(s) modified")
  total_replacements <- total_replacements + file_replacements
}

message("\nDone! Modified ", total_replacements, " code lines across ", length(files), " files.")
