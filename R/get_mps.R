#' Internal function to get MPs for a single legislative period
#' @noRd

get_mps_single <- function(
  institution = institution,
  gender = "all"
  # legis_period = legis_period,
  # party = party,
  # parl_group = parl_group,
  # electoral_district = electoral_district,
  # state = state,
  # presidents_only = presidents_only,
  # make_unique = make_unique
) {
  # gender
  checkmate::assert_subset(
    x = gender,
    choices = c("all", "female", "male"),
    empty.ok = TRUE
  )

  switch(
    gender,
    "all" = {
      M <- "M"
      W <- "W"
    },
    "male" = {
      M <- "M"
      W <- NULL
    },
    "female" = {
      M <- NULL
      W <- "W"
    }
  )

  # instiutiton
  checkmate::assert_subset(
    x = institution,
    choices = c(
      "KonstNatVers",
      "NR",
      "BR",
      "ProvNatVers"
    ),
    empty.ok = TRUE
  )

  switch(
    institution,
    "NR" = {
      institution <- "Nationalrat"
      W <- "W"
    },
    "BR" = {
      institution <- "Bundesrat"
    },
    "KonstNatVers" = {
      institution <- "Konstituierende Nationalversammlung"
    },
    "ProvNatVers" = {
      institution <- "Provisorische Nationalversammlung"
    }
  )

  # legis_period
  #CONTINUE HERE; USE THE FUNCTION get_legis_periods()

  # if (
  #   !(is.numeric(legis_period) ||
  #     legis_period %in%
  #       c(
  #         "all",
  #         "Provisorische Nationalversammlung",
  #         "Konstituierende Nationalversammlung"
  #       ))
  # ) {
  #   stop(
  #     "Invalid input for legis_period. Must be a numeric value or one of 'all', 'Provisorisch Nationalversammlung', or 'Konstituierende Nationalversammlung'."
  #   )
  # }

  # if (is.numeric(legis_period)) {
  #   legis_period <- as.character(as.roman(legis_period))
  # } else if (legis_period == "all") {
  #   legis_period <- "ALLE"
  # }

  # party <- match.arg(party, several.ok = FALSE)
  # if (party == "all") {
  #   party <- "ALLE"
  # }

  # parl_group <- match.arg(parl_group, several.ok = FALSE)
  # if (parl_group == "all") {
  #   parl_group <- "ALLE"
  # }

  # if (!presidents_only %in% c(TRUE, FALSE)) {
  #   stop(
  #     "Invalid input for `presidents_only`. Must be logical (TRUE or FALSE). Default is FALSE"
  #   )
  # } else if (presidents_only == TRUE) {
  #   presidents_only <- "J"
  # } else {
  #   presidents_only <- NULL
  # }

  # electoral_district <- match.arg(electoral_district, several.ok = FALSE)
  # electoral_district <- purrr::map_chr(
  #   electoral_district,
  #   \(x)
  #     switch(
  #       x,
  #       "all" = "ALLE",
  #       "Bundeswahlvorschlag" = "FB",
  #       "Burgenland" = "F1",
  #       "Kärnten" = "F2",
  #       "Niederösterreich" = "F3",
  #       "Oberösterreich" = "F4",
  #       "Salzburg" = "F5",
  #       "Steiermark" = "F6",
  #       "Tirol" = "F7",
  #       "Vorarlberg" = "F8",
  #       "Wien" = "F9",
  #       "Burgenland Nord" = "F1A",
  #       "Burgenland Süd" = "F1B",
  #       "Klagenfurt" = "F2A",
  #       "Villach" = "F2B",
  #       "Kärnten West" = "F2C",
  #       "Kärnten Ost" = "F2D",
  #       "Weinviertel" = "F3A",
  #       "Waldviertel" = "F3B",
  #       "Mostviertel" = "F3C",
  #       "Niederösterreich Mitte" = "F3D",
  #       "Niederösterreich Süd" = "F3E",
  #       "Thermenregion" = "F3F",
  #       "Niederösterreich Ost" = "F3G",
  #       "Linz und Umgebung" = "F4A",
  #       "Innviertel" = "F4B",
  #       "Hausruckviertel" = "F4C",
  #       "Traunviertel" = "F4D",
  #       "Mühlviertel" = "F4E",
  #       "Salzburg Stadt" = "F5A",
  #       "Flachgau/Tennengau" = "F5B",
  #       "Lungau/Pinzgau/Pongau" = "F5C",
  #       "Graz und Umgebung" = "F6A",
  #       "Oststeiermark" = "F6B",
  #       "Weststeiermark" = "F6C",
  #       "Obersteiermark" = "F6D",
  #       "Innsbruck" = "F7A",
  #       "Innsbruck-Land" = "F7B",
  #       "Unterland" = "F7C",
  #       "Oberland" = "F7D",
  #       "Osttirol" = "F7E",
  #       "Vorarlberg Nord" = "F8A",
  #       "Vorarlberg Süd" = "F8B",
  #       "Wien Innen-Süd" = "F9A",
  #       "Wien Innen-West" = "F9B",
  #       "Wien Innen-Ost" = "F9C",
  #       "Wien Süd" = "F9D",
  #       "Wien Süd-West" = "F9E",
  #       "Wien Nord-West" = "F9F",
  #       "Wien Nord" = "F9G"
  #     )
  # )

  body_params <- list(
    GESCHL_CODE = c(W, M),
    ATTR_JSON.mandate_detail.gremium_name = institution
    # NRBR = institution,
    # GP = legis_period,
    # WP = party,
    # FR = parl_group,
    # PR = presidents_only,
    # WK = electoral_district
  ) |>
    purrr::compact() |>
    jsonlite::toJSON()

  res <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/409"
  ) |>
    httr2::req_method("POST") |>
    httr2::req_url_query(
      # `1` = "1",
      # page = "1",
      # pagesize = "10",
      showAll = "true",
      sortrnr = "1",
      ascDesc = "ASC"
    ) |>
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i",
      # referer = "https://www.parlament.gv.at/recherchieren/personen/parlamentarierinnen-ab-1848/parlamentarierinnen-ab-1918?PERSON_409ATTR_JSON.mandate_detail.gp_text_full_short=ab+24.10.2024%3A+XXVIII.+Gesetzgebungsperiode",
      `sec-ch-ua` = '"Microsoft Edge";v="135", "Not-A.Brand";v="8", "Chromium";v="135"',
      `sec-ch-ua-mobile` = "?0",
      `sec-ch-ua-platform` = '"Windows"',
      `sec-fetch-dest` = "empty",
      `sec-fetch-mode` = "cors",
      `sec-fetch-site` = "same-origin",
      # `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36 Edg/135.0.0.0",
      # cookie = "JSESSIONID=pN97GWuE97dOwd5gd4SG5E0J43ZVqtoIrKulcoal.appsrv05e; JSESSIONID=xfhR-hntwcCuRSfdJx-vH3jQPmU6JPJ3SadXoMcm.appsrv06e; JSESSIONID=xfhR-hntwcCuRSfdJx-vH3jQPmU6JPJ3SadXoMcm.appsrv06e; pddsgvo=j; _pk_id.1.26ca=2b9c3ab31363e4f4.1742073577.; _pk_ref.1.26ca=%5B%22%22%2C%22%22%2C1745953947%2C%22https%3A%2F%2Fwww.bing.com%2F%22%5D; _pk_ses.1.26ca=1"
    ) |>
    httr2::req_body_raw(
      body_params,
      # '{"ATTR_JSON.mandate_detail.gp_text_full_short":["ab 24.10.2024: XXVIII. Gesetzgebungsperiode"]}',
      type = "application/json"
    ) |>
    httr2::req_perform()

  # new format of returned data

  li_res <- res %>%
    httr2::resp_body_json() |>
    purrr::pluck("rows")

  df_res <- li_res %>%
    map(., \(x) x[[8]] %>% tibble::enframe() %>% tidyr::pivot_wider()) %>%
    list_rbind()

  cols_keep <- c(
    "zit",
    "fraktionen",
    "frak",
    "geschlecht",
    "gp_code",
    "uri",
    "mandate_detail",
    "name_nvg",
    "mandate_kompakt",
    "wahlkreise",
    "pad_intern"
  )

  df_res <- df_res %>%
    dplyr::select(any_of(cols_keep))

  if (nrow(df_res) == 0) {
    message("No results found for the search criteria provided.")
    return(NULL)
  }

  #CHECK
  # if (make_unique == TRUE) {
  #   df_res <- df_res |>
  #     dplyr::group_by(across(-all_of("name"))) |>
  #     dplyr::summarise(name = list(name), name_variants_n = dplyr::n()) |>
  #     dplyr::ungroup() |>
  #     dplyr::relocate(c(name, name_variants_n), .after = 1)
  # }

  # df_res <- df_res |>
  #   dplyr::mutate(across(
  #     any_of(c("fraktion", "bundesland", "gesetzgebungsperioden")),
  #     \(x) purrr::map(x, \(y) aux_parse_html_text(html = y))
  #   ))

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
  name = NULL,
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
        # name = name,
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
