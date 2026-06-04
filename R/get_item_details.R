# Strip HTML tags from a string, returning plain text.
# Returns NA_character_ for NULL/NA input; falls back to the raw string on
# parse error (the input may already be plain text).
.strip_html <- function(x) {
  if (is.null(x) || is.na(x)) {
    return(NA_character_)
  }
  tryCatch(
    rvest::read_html(x) |> rvest::html_text2(),
    error = function(e) x
  )
}

.df_col_chr <- function(df, col) {
  if (col %in% names(df)) {
    return(df[[col]])
  }

  rep(NA_character_, nrow(df))
}

# Parse item-level documents from the API JSON.
# Returns a tibble with columns doc_title, link, type, or NULL if empty.
.parse_document_rows <- function(inner, title) {
  if (is.null(inner) || length(inner) == 0) {
    return(tibble::tibble())
  }

  if (is.data.frame(inner)) {
    n_docs <- nrow(inner)
    return(tibble::tibble(
      doc_title = rep(title %||% NA_character_, n_docs),
      link = inner$link %||% rep(NA_character_, n_docs),
      type = inner$type %||% rep(NA_character_, n_docs)
    ))
  }

  tibble::tibble(
    doc_title = title %||% NA_character_,
    link = purrr::map_chr(inner, \(d) d$link %||% NA_character_),
    type = purrr::map_chr(inner, \(d) d$type %||% NA_character_)
  )
}

.parse_item_documents <- function(docs_list) {
  if (is.null(docs_list) || length(docs_list) == 0) {
    return(NULL)
  }
  if (is.data.frame(docs_list)) {
    # jsonlite may simplify to a data.frame with a nested documents column
    purrr::map2(docs_list$title, docs_list$documents, \(title, inner) {
      .parse_document_rows(inner, title)
    }) |>
      purrr::list_rbind()
  } else {
    purrr::map(docs_list, \(doc) {
      .parse_document_rows(doc$documents, doc$title)
    }) |>
      purrr::list_rbind()
  }
}

# Parse introducer information from the API JSON `names` field.
# Returns a tibble with columns role, name, frak_code, url, or NULL if empty.
.parse_introducers <- function(names_list) {
  if (is.null(names_list) || length(names_list) == 0) {
    return(NULL)
  }
  base_url <- "https://www.parlament.gv.at"
  if (is.data.frame(names_list)) {
    url <- .df_col_chr(names_list, "url")
    tibble::tibble(
      role = .df_col_chr(names_list, "funktext"),
      name = .df_col_chr(names_list, "name"),
      frak_code = .df_col_chr(names_list, "frak_code"),
      url = ifelse(
        is.na(url),
        NA_character_,
        stringr::str_c(base_url, url)
      )
    )
  } else {
    tibble::tibble(
      role = purrr::map_chr(names_list, \(n) n$funktext %||% NA_character_),
      name = purrr::map_chr(names_list, \(n) n$name %||% NA_character_),
      frak_code = purrr::map_chr(names_list, \(n) {
        n$frak_code %||% NA_character_
      }),
      url = purrr::map_chr(names_list, \(n) {
        if (is.null(n$url)) {
          NA_character_
        } else {
          stringr::str_c(base_url, n$url)
        }
      })
    )
  }
}

# Parse related-item references from the API JSON.
# Returns a tibble with columns text, subject, zitation, url, art, or NULL.
.parse_references <- function(ref_list) {
  if (is.null(ref_list) || length(ref_list) == 0) {
    return(NULL)
  }
  if (is.data.frame(ref_list)) {
    tibble::tibble(
      text = .df_col_chr(ref_list, "text"),
      subject = .df_col_chr(ref_list, "subject"),
      zitation = .df_col_chr(ref_list, "zitation"),
      url = .df_col_chr(ref_list, "url"),
      art = .df_col_chr(ref_list, "art")
    )
  } else {
    tibble::tibble(
      text = purrr::map_chr(ref_list, \(r) r$text %||% NA_character_),
      subject = purrr::map_chr(ref_list, \(r) r$subject %||% NA_character_),
      zitation = purrr::map_chr(ref_list, \(r) r$zitation %||% NA_character_),
      url = purrr::map_chr(ref_list, \(r) r$url %||% NA_character_),
      art = purrr::map_chr(ref_list, \(r) r$art %||% NA_character_)
    )
  }
}

# Extract label strings from a "bubbles" rendertype object.
# Returns a character vector of labels, or character(0) if empty.
.extract_bubble_labels <- function(bubbles_obj) {
  bubbles <- bubbles_obj$data$bubbles
  if (is.null(bubbles) || length(bubbles) == 0) {
    return(character(0))
  }
  if (is.data.frame(bubbles)) {
    return(bubbles$label)
  }
  purrr::map_chr(bubbles, \(b) b$label %||% NA_character_)
}

# Parse reden (speech) data from a character matrix of rows.
# jsonlite simplifies reden$data$rows (an array-of-arrays) into a single
# character matrix, collapsing all stages. Callers are responsible for
# passing the right matrix and placing the result in the right list slot.
# Returns a tibble with one row per speaker, or NULL if rows is not a matrix.
.parse_reden <- function(rows) {
  if (!is.matrix(rows) || nrow(rows) == 0) {
    return(NULL)
  }

  base_url <- "https://www.parlament.gv.at"

  speaker_html <- rows[, 1]
  position <- rows[, 2]
  protocol_html <- rows[, 3]
  video_html <- rows[, 4]

  extract_text <- function(html) {
    tryCatch(
      rvest::read_html(html) |> rvest::html_text2(),
      error = function(e) html
    )
  }
  extract_href <- function(html) {
    href <- tryCatch(
      rvest::read_html(html) |>
        rvest::html_element("a") |>
        rvest::html_attr("href"),
      error = function(e) NA_character_
    )
    if (!is.na(href)) stringr::str_c(base_url, href) else NA_character_
  }
  extract_hrefs <- function(html) {
    hrefs <- tryCatch(
      rvest::read_html(html) |>
        rvest::html_elements("a") |>
        rvest::html_attr("href"),
      error = function(e) character(0)
    )
    hrefs <- hrefs[!is.na(hrefs)]
    if (length(hrefs) == 0) NA_character_ else stringr::str_c(base_url, hrefs)
  }

  tibble::tibble(
    speaker = purrr::map_chr(speaker_html, extract_text),
    speaker_url = purrr::map_chr(speaker_html, extract_href),
    position = position,
    protocol_page = purrr::map_chr(protocol_html, extract_text),
    protocol_url = purrr::map(protocol_html, extract_hrefs),
    video_url = purrr::map_chr(video_html, extract_href)
  )
}

.normalise_item_url <- function(item_url) {
  prefix <- "https://www.parlament.gv.at/"

  if (stringr::str_starts(item_url, prefix)) {
    return(item_url)
  }

  item_url |>
    stringr::str_replace("^/+", "") |>
    (\(x) stringr::str_c(prefix, x))()
}

.get_item_details_code_path <- function(item_url) {
  item_url <- .normalise_item_url(item_url)
  page <- .parlat_fetch_html(item_url)
  json_text <- .parlat_extract_props_json(page)
  content <- jsonlite::fromJSON(json_text)$data$content

  if (!is.null(content$phase$stages)) {
    return("phase_stages")
  }

  if (!is.null(content$stages)) {
    return("flat_stages")
  }

  if (!is.null(content$stages) || !is.null(content$phase)) {
    return("unknown_structure")
  }

  "no_stages"
}

#' Get detailed information for a parliamentary item ('Verhandlungsgegenstand')
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Returns detailed information for a specific parliamentary item
#' ('Verhandlungsgegenstand') by retrieving data from its detail page on the
#' Austrian Parliament website. The function returns item-level metadata and,
#' optionally, structured information about legislative stages and votes.
#'
#' @param item_url Character. A single URL or path to an item ('Verhandlungsgegenstand') on the Austrian
#'   Parliament website. Can be an absolute URL starting with
#'   "https://www.parlament.gv.at/" or a relative path (with or without
#'   leading slashes). The function will normalize relative paths automatically. URLs are best
#'  obtained via a preceding call with `get_items()`.
#' @param stages Logical. If `TRUE` (default), extract stage information and
#'   add it as the `stages` list-column. If `FALSE`, return only item-level
#'   metadata.
#' @param votes Logical. If `TRUE` (default), add vote information from the
#'   item page as the `votes` list-column. *Returns only data for votes on items
#'   under consideration in the third reading ('dritte Lesung') in the National Council.
#'   If `FALSE`, omits vote extraction and the `votes` column.
#' @return A one-row tibble containing detailed information about the
#'   parliamentary item. The `stages` list-column is included only when
#'   `stages = TRUE`; it contains stage information, or `NULL` if the item has
#'   no stages yet. The `votes` list-column is included only when
#'   `votes = TRUE`; Emits a warning if the page structure is
#'   unrecognised.
#'
#' **Item-level columns:**
#' - `item_url` (character): The URL of the parliamentary item.
#' - `item_type` (character): Raw item type code from `ityp`.
#' - `type_doc` (character): Raw document type code from `doktyp`.
#' - `type_doc_long` (character): Human-readable document type.
#' - `title` (character): The title of the item.
#' - `item_number` (character): The citation number (e.g. "61/A").
#' - `item_description` (character): A brief description of the item.
#' - `state_statements` (character): Statement stage information.
#' - `state_approval` (character): The current approval state.
#' - `date_introduced` (Date): The date the item was introduced to parliament.
#' - `legis_period` (character): Legislative period code (e.g. "XXVII").
#' - `status_number` (integer): Current status number.
#' - `status_description` (character): Current status description (HTML stripped).
#' - `item_documents` (list): Tibble with columns `doc_title`, `link`, `type`
#'   for item-level documents. `NULL` if none.
#' - `introducers` (list): Tibble with columns `role`, `name`, `frak_code`,
#'   `url` for the persons who introduced the item. `NULL` if unavailable.
#' - `references` (list): Tibble with columns `text`, `subject`, `zitation`,
#'   `url`, `art` for related parliamentary items. `NULL` if none.
#' - `topics` (list): Character vector of topic labels.
#' - `headwords` (list): Character vector of headword labels.
#' - `eurovoc` (list): Character vector of EuroVoc terms.
#' - `votes` (list): Vote information from the item page. `votes[[1]]` is
#'   either `NULL` or a list with fields `result`, `infavor`, `code`, `text`,
#'   and `comment`. The nested `result` field is a data frame with columns
#'   `text`, `code`, `color`, `fraction`, and `infavor`.
#'
#' **Stage-level columns** (inside `stages`):
#' - `phase` (character): The phase of the legislative stage (e.g.
#'   "Ausschussbehandlung"). `NA` for items with flat stages (no phase wrapper).
#' - `stage_date` (Date): The date of the stage.
#' - `stage_name` (character): The name/description of the stage (HTML stripped).
#' - `stage_names` (list): Stage-level names/introducer information, if present.
#' - `speeches` (list): Nested tibble with columns `speaker`, `speaker_url`,
#'   `position`, `protocol_page`, `protocol_url`, `video_url`. `NULL` for
#'   stages without debate contributions.
#'
#' @seealso
#' * [get_items()] for searching parliamentary items and retrieving URLs
#'
#' @examples
#' \donttest{
#' # Get details for a specific item with vote information
#' item_url <- "https://www.parlament.gv.at/gegenstand/XX/I/1833"
#' details <- get_item_details(item_url, stages = FALSE)
#' dplyr::glimpse(details)
#' details$votes[[1]]
#' details$votes[[1]]$result
#'
#' # Also works with relative paths
#' details <- get_item_details("/gegenstand/XX/I/1833", stages = FALSE)
#' dplyr::glimpse(details)
#' }
#'
#' @export
get_item_details <- function(item_url, stages = TRUE, votes = TRUE) {
  checkmate::assert_logical(stages, len = 1, any.missing = FALSE)
  checkmate::assert_logical(votes, len = 1, any.missing = FALSE)

  # Normalise the URL: accept absolute URLs, relative paths with or without a
  # leading slash.  Strip any leading slashes, then prepend the base URL.
  item_url <- .normalise_item_url(item_url)

  # Fetch the item detail page through httr2 so fixture recording can capture
  # the HTML response before we parse it with rvest.
  page <- .parlat_fetch_html(item_url)

  # ── JSON extraction ────────────────────────────────────────────────────────
  # The page embeds its data as a JavaScript object literal:
  #   ReactDOM.render(..., document.getElementById("app"), { props: { ... } });
  # We pick the <script> block that contains "props:", then carve out
  # everything from "props:" onward and strip the trailing "})" that closes the
  # ReactDOM.render() call, leaving a valid JSON string.
  json_text <- .parlat_extract_props_json(page)

  # fromJSON() with its default simplifyVector = TRUE recursively collapses
  # JSON arrays into R vectors/data frames wherever possible.  This is helpful
  # for flat fields (scalars, simple arrays) but can produce inconsistent types
  # for deeply nested structures like reden (speeches) — see the note in the
  # flat-stages code path below.
  data_list <- jsonlite::fromJSON(json_text) |> (\(x) x$data)()

  # ── Item-level metadata ────────────────────────────────────────────────────
  # These fields are always present regardless of the item type or structure.
  # `zitation` is the official citation number (e.g. "28/A"); `approvalstate`
  # reflects the current legislative status (e.g. "beschlossen").
  content <- data_list$content

  df_res <- tibble::tibble(
    item_url = item_url,
    item_type = content$ityp %||% NA_character_,
    type_doc = content$doktyp %||% NA_character_,
    type_doc_long = content$type,
    title = content$title,
    item_number = content$zitation,
    item_description = content$description,
    state_statements = content$statementsstate,
    state_approval = content$approvalstate,
    date_introduced = if (!is.null(content$einlangen)) {
      as.Date(content$einlangen)
    } else {
      as.Date(NA)
    },
    legis_period = content$gp_code %||% NA_character_,
    status_number = content$status$number %||% NA_integer_,
    status_description = .strip_html(
      content$status$description %||% NA_character_
    ),
    item_documents = list(.parse_item_documents(content$documents)),
    introducers = list(.parse_introducers(content$names)),
    references = list(.parse_references(content$reference)),
    topics = list(.extract_bubble_labels(content$topics)),
    headwords = list(.extract_bubble_labels(content$headwords)),
    eurovoc = list(.extract_bubble_labels(content$eurovoc))
  )

  if (votes) {
    df_res <- df_res |>
      dplyr::mutate(votes = list(content$vote %||% NULL))
  }

  if (!stages) {
    return(df_res)
  }

  # ── Code path A: phase/stages structure ───────────────────────────────────
  # Some item types (e.g. Selbständige Anträge, LP XXVIII) nest stages inside a
  # "phase" wrapper: content$phase$stages.  The phase object carries a `name`
  # field (the phase label, e.g. "Ausschussbehandlung") that applies to all
  # stages within it.
  if (!is.null(content$phase$stages)) {
    # Unnest the stages list-column into one row per stage, then spread the
    # stage fields into individual columns.  The `names_sep` argument prevents
    # name collisions between stage fields and the outer phase fields.
    df_stages <- content$phase %>%
      dplyr::rename(stage = "stages") %>%
      tidyr::unnest_longer("stage") %>%
      tidyr::unnest_wider("stage", names_sep = "_") %>%
      dplyr::rename(phase = "name", stage_name = "stage_text")

    # stage_text often contains raw HTML (e.g. links to documents embedded in
    # the stage description).  Strip tags to get readable plain text; fall back
    # to the raw string if parsing fails (it may already be plain text).
    df_stages <- df_stages %>%
      dplyr::mutate(stage_name = purrr::map_chr(.data$stage_name, .strip_html))

    # ── Speech parsing (phase/stages path) ──────────────────────────────────
    # `stage_reden` is present when the stage contains floor debate
    # contributions ("Wortmeldungen in der Debatte").  Each element of
    # stage_reden$data$rows[[i]] is a 4-column matrix row: speaker HTML,
    # position, protocol HTML, video HTML.
    #
    # IMPORTANT: speeches must be parsed *before* fsth unnesting.  The `fsth`
    # field (Fundstellen = session references) can expand one stage into
    # multiple rows (one per session).  If we parsed speeches after expansion,
    # each speech tibble would be duplicated across the extra rows, breaking the
    # one-to-one correspondence between rows and speeches.
    #
    # In the phase/stages path, tidyr::unnest_wider() preserves the nested
    # matrix structure inside stage_reden, so we can index directly with [[i]].
    # No re-parse via parse_json() is needed here (contrast with path B below).
    if ("stage_reden" %in% names(df_stages)) {
      speeches_list <- purrr::map(
        seq_len(nrow(df_stages)),
        \(i) .parse_reden(df_stages$stage_reden$data$rows[[i]])
      )
      df_stages <- df_stages |>
        dplyr::mutate(speeches = speeches_list) |>
        dplyr::select(-dplyr::any_of("stage_reden"))
    }

    df_stages <- df_stages |>
      dplyr::select(dplyr::any_of(c(
        "phase",
        "stage_name",
        "stage_date",
        "stage_names",
        "speeches"
      )))

    # Add the stage table as a list-column while preserving one row per item.
    result <- df_res |>
      dplyr::mutate(stages = list(df_stages))

    return(result)
  }

  # ── Code path B: flat stages structure ────────────────────────────────────
  # Other item types (e.g. Bürgerinitiativen, Berichte) expose stages directly
  # under content$stages without a phase wrapper.
  if (!is.null(content$stages)) {
    df_stages <- content$stages

    # ── Speech parsing (flat stages path) ───────────────────────────────────
    # `reden` is present when any stage has floor debate contributions.
    #
    # Why re-parse with parse_json() instead of using data_list?
    # jsonlite::fromJSON() applies aggressive simplification: when it encounters
    # the nested reden structure (a list of tables-within-tables), it sometimes
    # collapses rows into a matrix, sometimes into a data frame, and sometimes
    # leaves them as a list — depending on how homogeneous the data looks.  The
    # result is unpredictable across different items and impossible to index
    # uniformly.  jsonlite::parse_json() parses the same text WITHOUT
    # simplification, always returning a plain nested list, so each stage is a
    # separate list element and stage$reden$data$rows is always a list of rows.
    #
    # IMPORTANT: parse before fsth unnesting — same reason as path A above.
    if ("reden" %in% names(df_stages)) {
      raw_stages <- jsonlite::parse_json(json_text)$data$content$stages
      speeches_list <- purrr::map(raw_stages, \(stage) {
        rows <- stage$reden$data$rows
        if (is.null(rows) || length(rows) == 0) {
          return(NULL)
        }
        # Each row is a list of 4 cells; rbind + unlist produces the character
        # matrix that .parse_reden() expects.
        rows_mat <- do.call(
          rbind,
          lapply(rows, \(r) unlist(r, use.names = FALSE))
        )
        .parse_reden(rows_mat)
      })

      # Sanity check: the number of parsed stages should equal the number of
      # rows in df_stages.  A mismatch would mean some stages were merged or
      # split during JSON simplification.  We warn and NULL-pad/truncate rather
      # than silently producing misaligned output.
      n_stage_rows <- nrow(df_stages)
      if (length(speeches_list) != n_stage_rows) {
        cli::cli_warn(
          c(
            "Speech-stage alignment mismatch in {.fn get_item_details}.",
            "i" = "Parsed speeches for {length(speeches_list)} stage(s), but found {n_stage_rows} stage row(s) before {.code fsth} expansion.",
            "i" = "Continuing with NULL-padding/truncation to preserve output shape."
          )
        )
        speeches_aligned <- rep(list(NULL), n_stage_rows)
        n_copy <- min(length(speeches_list), n_stage_rows)
        if (n_copy > 0) {
          speeches_aligned[seq_len(n_copy)] <- speeches_list[seq_len(n_copy)]
        }
        speeches_list <- speeches_aligned
      }

      df_stages <- df_stages %>%
        dplyr::mutate(speeches = speeches_list) %>%
        dplyr::select(-dplyr::any_of("reden"))
    }

    # `text` contains the human-readable stage description, usually as raw HTML.
    # Strip tags to plain text; fall back to the raw string on parse failure.
    if ("text" %in% names(df_stages)) {
      df_stages <- df_stages %>%
        dplyr::mutate(text = purrr::map_chr(.data$text, .strip_html))
    }

    df_stages <- df_stages |>
      dplyr::select(dplyr::any_of(c("text", "date", "names", "speeches")))

    # Harmonise column names with path A so that bind_rows() across both paths
    # produces a single consistent schema.
    df_stages <- df_stages |>
      dplyr::rename(dplyr::any_of(c(
        stage_name = "text",
        stage_date = "date",
        stage_names = "names"
      ))) |>
      dplyr::mutate(phase = NA_character_, .before = 1L)

    # Add the stage table as a list-column while preserving one row per item.
    result <- df_res |>
      dplyr::mutate(stages = list(df_stages))

    return(result)
  }

  # No recognised stage structure found.
  # Distinguish "no stages yet" (expected for fresh items) from truly unknown
  # structures that may need a new code path.
  has_stages_field <- !is.null(content$stages)
  has_phase_field <- !is.null(content$phase)

  if (has_stages_field || has_phase_field) {
    cli::cli_warn(c(
      "Unknown page structure in {.fn get_item_details}.",
      "i" = "URL: {.url {item_url}}",
      "i" = "Top-level content keys: {paste(names(content), collapse = ', ')}",
      "i" = "Please report this at {.url https://github.com/werkstattcodes/ParlAT/issues}."
    ))
  }

  df_res |>
    dplyr::mutate(stages = list(NULL))
}
