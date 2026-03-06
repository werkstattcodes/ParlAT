# Verify that no non-ASCII characters remain in code lines
# (Comments starting with # are excluded, matching R CMD check behavior)

files <- list.files("R", pattern = "[.]R$", full.names = TRUE)
has_issues <- FALSE

for (f in files) {
  lines <- readLines(f, encoding = "UTF-8", warn = FALSE)
  for (i in seq_along(lines)) {
    line <- lines[i]
    # Skip comment lines (including roxygen)
    if (grepl("^\\s*#", line)) next
    # Check for non-ASCII bytes
    raw <- charToRaw(enc2utf8(line))
    non_ascii <- raw[raw > as.raw(0x7e)]
    if (length(non_ascii) > 0) {
      cat(basename(f), " line ", i, ": ", substr(line, 1, 80), "\n", sep = "")
      has_issues <- TRUE
    }
  }
}

if (!has_issues) {
  cat("SUCCESS: No non-ASCII characters found in code lines!\n")
} else {
  cat("\nWARNING: Non-ASCII characters still present in code lines above.\n")
}
