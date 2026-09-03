#' Get colors for Austrian political parties
#'
#' `get_party_colors()` returns a named vector or tibble of colors for Austrian
#' political parties and parliamentary groups. It accepts common party codes,
#' short parliamentary abbreviations, and full party or parliamentary group
#' names.
#'
#' @param parties Character vector of party or parliamentary group names,
#'   abbreviations, or codes. If `NULL`, returns the default plotting palette.
#' @param legis_period Optional legislative period. If supplied, the historical
#'   color for the Austrian People's Party (`"ÖVP"`) is returned as `"black"`
#'   before legislative period 26 and as the modern palette color from period 26
#'   onward. May be length 1 or the same length as `parties`.
#' @param output Character string. `"vector"` returns a named character vector;
#'   `"tibble"` returns a tibble with party names and colors.
#' @param unmatched Character string. `"NA"` returns `NA` for unmatched inputs;
#'   `"error"` throws an error if any input cannot be matched.
#'
#' @return A named character vector by default. With `output = "tibble"`, a
#'   tibble with columns `party`, `canonical_party`, and `color`.
#' @export
#'
#' @examples
#' get_party_colors()
#' get_party_colors(c("SPÖ", "ÖVP", "FPÖ"))
#' get_party_colors(c("S", "V", "F"))
#' get_party_colors(c("ÖVP", "ÖVP"), legis_period = c(25, 26))
#'
#' # Display the default plotting palette.
#' party_colors <- get_party_colors(output = "tibble")
#' party_colors$party <- factor(
#'   party_colors$party,
#'   levels = rev(party_colors$party)
#' )
#'
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   ggplot2::ggplot(
#'     party_colors,
#'     ggplot2::aes(x = party, y = 1, fill = color)
#'   ) +
#'     ggplot2::geom_col(width = 0.8) +
#'     ggplot2::scale_fill_identity() +
#'     ggplot2::coord_flip() +
#'     ggplot2::labs(
#'       title = "Default party color palette",
#'       x = NULL,
#'       y = NULL
#'     ) +
#'     ggplot2::theme_minimal() +
#'     ggplot2::theme(
#'       axis.text.x = ggplot2::element_blank(),
#'       axis.ticks.x = ggplot2::element_blank(),
#'       panel.grid = ggplot2::element_blank()
#'     )
#' }
#'
#' # The ÖVP color changed from black to turquoise in legislative period 26.
#' oevp_data <- data.frame(
#'   legis_period = c(25, 26),
#'   party = c("ÖVP", "ÖVP"),
#'   value = c(1, 1)
#' )
#' oevp_data$party_color <- get_party_colors(
#'   parties = oevp_data$party,
#'   legis_period = oevp_data$legis_period
#' )
#'
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#'   ggplot2::ggplot(
#'     oevp_data,
#'     ggplot2::aes(
#'       x = factor(legis_period),
#'       y = value,
#'       fill = party_color
#'     )
#'   ) +
#'     ggplot2::geom_col(width = 0.7) +
#'     ggplot2::scale_fill_identity() +
#'     ggplot2::labs(
#'       title = "Change in the ÖVP party color",
#'       subtitle = paste(
#'         "Black before legislative period 26,",
#'         "turquoise from period 26"
#'       ),
#'       x = "Legislative period",
#'       y = NULL
#'     ) +
#'     ggplot2::theme_minimal() +
#'     ggplot2::theme(
#'       axis.text.y = ggplot2::element_blank(),
#'       axis.ticks.y = ggplot2::element_blank()
#'     )
#' }
get_party_colors <- function(parties = NULL,
                             legis_period = NULL,
                             output = c("vector", "tibble"),
                             unmatched = c("NA", "error")) {
  output <- match.arg(output)
  unmatched <- match.arg(unmatched)
  lookup <- .parlat_party_color_lookup()

  if (is.null(parties)) {
    if (!is.null(legis_period) && length(legis_period) != 1) {
      cli::cli_abort(
        "{.arg legis_period} must be length 1 when {.arg parties} is NULL."
      )
    }

    result <- lookup[lookup$default, c("key", "color")]
    result$color <- .parlat_apply_legis_period_colors(
      key = result$key,
      color = result$color,
      legis_period = legis_period
    )
    names(result) <- c("party", "color")

    if (output == "tibble") {
      return(tibble::tibble(
        party = result$party,
        canonical_party = result$party,
        color = result$color
      ))
    }

    return(stats::setNames(result$color, result$party))
  }

  checkmate::assert_character(parties, any.missing = TRUE, null.ok = FALSE)
  if (!is.null(legis_period) && !(length(legis_period) %in% c(1, length(parties)))) {
    cli::cli_abort(
      "{.arg legis_period} must be length 1 or the same length as {.arg parties}."
    )
  }

  canonical_party <- .parlat_match_party_keys(parties, lookup)
  missing <- is.na(canonical_party) & !is.na(parties)

  if (any(missing) && unmatched == "error") {
    cli::cli_abort(
      "Could not match party input: {.val {parties[missing]}}."
    )
  }

  color <- lookup$color[match(canonical_party, lookup$key)]
  color <- .parlat_apply_legis_period_colors(
    key = canonical_party,
    color = color,
    legis_period = legis_period
  )

  if (output == "tibble") {
    return(tibble::tibble(
      party = parties,
      canonical_party = canonical_party,
      color = color
    ))
  }

  stats::setNames(color, parties)
}

.parlat_party_color_lookup <- function() {
  tibble::tibble(
    key = c(
      "SP\u00d6",
      "\u00d6VP",
      "FP\u00d6",
      "F",
      "F-BZ\u00d6",
      "GR\u00dcNE",
      "NEOS",
      "NEOS-LIF",
      "STRONACH",
      "BZ\u00d6",
      "LIF",
      "L",
      "FRANK",
      "JETZT",
      "PILZ",
      "OK",
      "OF"
    ),
    color = c(
      "#CE000C",
      "#63C3D0",
      "#0056A2",
      "#0056A2",
      "#0056A2",
      "#88B626",
      "#E3257B",
      "#E3257B",
      "#F47100",
      "#F47100",
      "#FFD200",
      "#FFD200",
      "#F47100",
      "lightgrey",
      "lightgrey",
      "grey",
      "grey"
    ),
    default = c(
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE,
      TRUE
    ),
    aliases = list(
      c(
        "S",
        "SPOE",
        "SPO",
        "Sozialdemokratische Partei \u00d6sterreichs",
        "Sozialistische Partei \u00d6sterreichs",
        "Sozialdemokratischer Parlamentsklub",
        "Sozialdemokratische Parlamentsfraktion",
        "Bundesratsfraktion der SP\u00d6"
      ),
      c(
        "V",
        "OEVP",
        "OVP",
        "Volkspartei",
        "\u00d6sterreichische Volkspartei",
        "Parlamentsklub der \u00d6sterreichischen Volkspartei",
        "Klub der \u00d6sterreichischen Volkspartei",
        "Bundesratsfraktion der \u00d6VP"
      ),
      c(
        "FPOE",
        "FPO",
        "Freiheitliche Partei \u00d6sterreichs",
        "Freiheitlicher Parlamentsklub",
        "Klub der Freiheitlichen Partei \u00d6sterreichs",
        "Freiheitliche Bundesratsfraktion"
      ),
      c("F"),
      c("F BZ\u00d6", "F BZOE", "Freiheitlicher Parlamentsklub BZ\u00d6"),
      c(
        "G",
        "GRUENE",
        "GRUNE",
        "Gr\u00fcne",
        "Die Gr\u00fcnen",
        "Der Gr\u00fcne Klub",
        "Gr\u00fcne Fraktion im Bundesrat",
        "Bundesratsfraktion der Gr\u00fcnen"
      ),
      c(
        "N",
        "NEOS Das neue \u00d6sterreich",
        "NEOS Das Neue \u00d6sterreich",
        "NEOS Parlamentsklub"
      ),
      c(
        "NEOS LIF",
        "NEOS/NEOS-LIF",
        "Klub von NEOS und LIF",
        "NEOS Das neue \u00d6sterreich und Liberales Forum"
      ),
      c(
        "Team Stronach",
        "Team Frank Stronach",
        "Parlamentsklub Team Stronach",
        "STRONA"
      ),
      c("BZOE", "BZO", "B\u00fcndnis Zukunft \u00d6sterreich"),
      c("Liberales Forum"),
      c("L"),
      c("FRANK", "Team Frank Stronach Frank"),
      c("Liste Jetzt", "Parlamentsklub JETZT"),
      c("Liste Pilz", "Liste Peter Pilz", "Parlamentsklub Liste Pilz"),
      c("Ohne Klub", "Ohne Klubzugeh\u00f6rigkeit", "Without parliamentary group"),
      c(
        "Ohne Fraktion",
        "Ohne Fraktionszugeh\u00f6rigkeit",
        "Without parliamentary group affiliation"
      )
    )
  )
}

.parlat_match_party_keys <- function(parties, lookup) {
  aliases <- unlist(
    purrr::map2(lookup$key, lookup$aliases, \(key, aliases) {
      stats::setNames(rep(key, length(c(key, aliases))), c(key, aliases))
    })
  )
  aliases <- stats::setNames(unname(aliases), .parlat_normalise_party(names(aliases)))

  unname(aliases[.parlat_normalise_party(parties)])
}

.parlat_normalise_party <- function(x) {
  x <- as.character(x)
  is_missing <- is.na(x)
  x <- stringr::str_trim(x)
  x <- stringr::str_replace_all(x, "\u00c4", "AE")
  x <- stringr::str_replace_all(x, "\u00d6", "OE")
  x <- stringr::str_replace_all(x, "\u00dc", "UE")
  x <- stringr::str_replace_all(x, "\u00e4", "ae")
  x <- stringr::str_replace_all(x, "\u00f6", "oe")
  x <- stringr::str_replace_all(x, "\u00fc", "ue")
  x <- stringr::str_replace_all(x, "\u00df", "ss")
  x <- stringr::str_to_upper(x)
  x <- stringr::str_replace_all(x, "[^A-Z0-9]+", " ")
  x <- stringr::str_squish(x)
  x[is_missing] <- NA_character_
  x
}

.parlat_apply_legis_period_colors <- function(key, color, legis_period = NULL) {
  if (is.null(legis_period)) {
    return(color)
  }

  legis_period <- aux_convert_legis_periods(legis_period)
  legis_period <- suppressWarnings(as.numeric(legis_period))

  if (length(legis_period) == 1) {
    legis_period <- rep(legis_period, length(color))
  }

  dplyr::if_else(
    key == "\u00d6VP" & !is.na(legis_period) & legis_period < 26,
    "black",
    color
  )
}
