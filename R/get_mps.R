#' Internal function to get MPs for a single legislative period
#' @noRd
get_mps_single <- function(
  institution = institution,
  gender = gender,
  legis_period = legis_period,
  party = party,
  parl_group = parl_group,
  electoral_district = electoral_district,
  state = state,
  presidents_only = presidents_only,
  make_unique = make_unique
) {
  gender <- match.arg(gender)
  if (gender == "all") {
    M <- "M"
    W <- "W"
  } else if (gender == "male") {
    M <- "M"
    W <- NULL
  } else if (gender == "female") {
    M <- NULL
    W <- "W"
  }

  institution <- match.arg(institution)
  institution <- switch(
    institution,
    all = "ALLE",
    Nationalrat = "NR",
    Bundesrat = "BR"
  )

  if (
    !(is.numeric(legis_period) ||
      legis_period %in%
        c(
          "all",
          "Provisorische Nationalversammlung",
          "Konstituierende Nationalversammlung"
        ))
  ) {
    stop(
      "Invalid input for legis_period. Must be a numeric value or one of 'all', 'Provisorisch Nationalversammlung', or 'Konstituierende Nationalversammlung'."
    )
  }

  if (is.numeric(legis_period)) {
    legis_period <- as.character(as.roman(legis_period))
  } else if (legis_period == "all") {
    legis_period <- "ALLE"
  }

  party <- match.arg(party, several.ok = FALSE)
  if (party == "all") {
    party <- "ALLE"
  }

  parl_group <- match.arg(parl_group, several.ok = FALSE)
  if (parl_group == "all") {
    parl_group <- "ALLE"
  }

  if (!presidents_only %in% c(TRUE, FALSE)) {
    stop(
      "Invalid input for `presidents_only`. Must be logical (TRUE or FALSE). Default is FALSE"
    )
  } else if (presidents_only == TRUE) {
    presidents_only <- "J"
  } else {
    presidents_only <- NULL
  }

  electoral_district <- match.arg(electoral_district, several.ok = FALSE)
  electoral_district <- purrr::map_chr(
    electoral_district,
    \(x)
      switch(
        x,
        "all" = "ALLE",
        "Bundeswahlvorschlag" = "FB",
        "Burgenland" = "F1",
        "Kärnten" = "F2",
        "Niederösterreich" = "F3",
        "Oberösterreich" = "F4",
        "Salzburg" = "F5",
        "Steiermark" = "F6",
        "Tirol" = "F7",
        "Vorarlberg" = "F8",
        "Wien" = "F9",
        "Burgenland Nord" = "F1A",
        "Burgenland Süd" = "F1B",
        "Klagenfurt" = "F2A",
        "Villach" = "F2B",
        "Kärnten West" = "F2C",
        "Kärnten Ost" = "F2D",
        "Weinviertel" = "F3A",
        "Waldviertel" = "F3B",
        "Mostviertel" = "F3C",
        "Niederösterreich Mitte" = "F3D",
        "Niederösterreich Süd" = "F3E",
        "Thermenregion" = "F3F",
        "Niederösterreich Ost" = "F3G",
        "Linz und Umgebung" = "F4A",
        "Innviertel" = "F4B",
        "Hausruckviertel" = "F4C",
        "Traunviertel" = "F4D",
        "Mühlviertel" = "F4E",
        "Salzburg Stadt" = "F5A",
        "Flachgau/Tennengau" = "F5B",
        "Lungau/Pinzgau/Pongau" = "F5C",
        "Graz und Umgebung" = "F6A",
        "Oststeiermark" = "F6B",
        "Weststeiermark" = "F6C",
        "Obersteiermark" = "F6D",
        "Innsbruck" = "F7A",
        "Innsbruck-Land" = "F7B",
        "Unterland" = "F7C",
        "Oberland" = "F7D",
        "Osttirol" = "F7E",
        "Vorarlberg Nord" = "F8A",
        "Vorarlberg Süd" = "F8B",
        "Wien Innen-Süd" = "F9A",
        "Wien Innen-West" = "F9B",
        "Wien Innen-Ost" = "F9C",
        "Wien Süd" = "F9D",
        "Wien Süd-West" = "F9E",
        "Wien Nord-West" = "F9F",
        "Wien Nord" = "F9G"
      )
  )

  body_params <- list(
    M = M,
    W = W,
    NRBR = institution,
    GP = legis_period,
    WP = party,
    FR = parl_group,
    PR = presidents_only,
    WK = electoral_district
  ) |>
    purrr::compact() |>
    jsonlite::toJSON()

  res <- httr2::request("https://www.parlament.gv.at/Filter/api/json/post") |>
    httr2::req_url_query(
      jsMode = "EVAL",
      FBEZ = "WFW_008",
      listeId = "undefined",
      showAll = "true",
      feldRnr = "3",
      ascDesc = "ASC"
    ) |>
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      `content-type` = "application/json",
      dnt = "1",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i"
    ) |>
    httr2::req_body_raw(body_params) |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
    httr2::req_verbose(
      body_req = TRUE,
      header_req = FALSE,
      header_resp = FALSE
    ) |>
    httr2::req_perform()

  vec_headings <- res |>
    httr2::resp_body_json(simplifyVector = TRUE) |>
    purrr::pluck("header", "label") |>
    janitor::make_clean_names()

  df_res <- res |>
    httr2::resp_body_json(simplifyVector = TRUE) |>
    purrr::pluck("rows") |>
    as.data.frame()

  if (nrow(df_res) == 0) {
    message("No results found for the given search criteria.")
    return(NULL)
  }

  colnames(df_res) <- vec_headings
  df_res <- df_res |> dplyr::select(-sortier)

  if (make_unique == TRUE) {
    df_res <- df_res |>
      dplyr::group_by(across(-all_of("name"))) |>
      dplyr::summarise(name = list(name), name_variants_n = dplyr::n()) |>
      dplyr::ungroup() |>
      dplyr::relocate(c(name, name_variants_n), .after = 1)
  }

  df_res <- df_res |>
    dplyr::mutate(across(
      any_of(c("fraktion", "bundesland", "gesetzgebungsperioden")),
      \(x) purrr::map(x, \(y) aux_parse_html_text(html = y))
    ))

  print(nrow(df_res))
  return(df_res)
}

#' Get Members of Parliament
#'
#' Retrieves information about Members of Parliament from the Austrian Parliament database.
#' This function mirrors the search functionality 'Parlamentarier:innen ab 1918'
#' from the Austrian Parliament website <a href="https://www.parlament.gv.at/recherchieren/personen/parlamentarierinnen-ab-1848/parlamentarierinnen-ab-1918/index.html" target="_blank">here</a>.

#'
#' @param institution Chamber of Parliament. One of "all", "Bundesrat", or "Nationalrat"
#' @param gender Gender filter. One of "all", "female", or "male"
#' @param legis_period Legislative period. Can be "all", a numeric value,
#'        "Provisorische Nationalversammlung", or "Konstituierende Nationalversammlung"
#' @param party Political party filter. See details for possible values.
#' @param parl_group Parliamentary group filter
#' @param electoral_district Electoral district filter
#' @param state State filter
#' @param presidents_only Logical. If TRUE, returns only presidents. Default is FALSE
#' @param make_unique Logical. If TRUE, returns unique entries. Default is FALSE
#'
#' @return A dataframe containing information about Members of Parliament including:
#'   \item{name}{Name of the MP}
#'   \item{fraktion}{Parliamentary group}
#'   \item{bundesland}{Federal state}
#'   \item{gesetzgebungsperioden}{Legislative periods}
#'   And additional columns depending on the query parameters
#'
#' @details
#' Available party values include: "all", "BP", "BZÖ", "BAP", "CSP", "Grüne", "FPÖ",
#' "GdP", "HB", "KuL", "KPÖ", "LBd", "L", "LB", "PILZ", "NWB", "NEOS", "ÖVP",
#' "SdP", "SPÖ", "STRONACH", "VO", "WdU"
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get all MPs from the current legislative period
#' mps <- get_mps(institution = "Nationalrat", legis_period = "27")
#'
#' # Get female MPs from a specific party
#' female_mps <- get_mps(gender = "female", party = "SPÖ")
#' }
get_mps <- function(
  institution = c("all", "Bundesrat", "Nationalrat"),
  gender = c("all", "female", "male"),
  legis_period = "all",
  party = c(
    "all",
    "BP",
    "BZÖ",
    "BAP",
    "CSP",
    "Grüne",
    "FPÖ",
    "GdP",
    "HB",
    "KuL",
    "KPÖ",
    "LBd",
    "L",
    "LB",
    "PILZ",
    "NWB",
    "NEOS",
    "ÖVP",
    "SdP",
    "SPÖ",
    "STRONACH",
    "VO",
    "WdU"
  ),
  parl_group = c(
    "all",
    "LBd",
    "CSP",
    "GRÜNE",
    "SPÖ",
    "F-BZÖ",
    "GdP",
    "F",
    "FPÖ",
    "KuL",
    "VO",
    "WdU",
    "LB",
    "NEOS-LIF",
    "PILZ",
    "NEOS",
    "OK",
    "HB",
    "KPÖ",
    "ÖVP",
    "BZÖ",
    "JETZT",
    "L",
    "STRONACH",
    "NWB",
    "SdP"
  ),
  electoral_district = c(
    "all",
    "Bundeswahlvorschlag",
    "Burgenland",
    "Kärnten",
    "Niederösterreich",
    "Oberösterreich",
    "Salzburg",
    "Steiermark",
    "Tirol",
    "Vorarlberg",
    "Wien",
    # Add all other electoral districts here...
    "Wien Nord"
  ),
  state = NULL,
  presidents_only = FALSE,
  make_unique = FALSE
) {
  li_mps <- purrr::map(
    legis_period,
    \(x)
      get_mps_single(
        legis_period = x,
        institution = institution,
        gender = gender,
        party = party,
        parl_group = parl_group,
        electoral_district = electoral_district,
        state = state,
        presidents_only = presidents_only,
        make_unique = make_unique
      ),
    .progress = "Get MPs"
  )

  li_mps |> purrr::list_rbind()
}
