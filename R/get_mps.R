#' Get Members of Parliament
#'
#' Retrieves information about Members of Parliament from the Austrian Parliament database.
#' This function mirrors the search functionality 'Parlamentarier:innen ab 1918'
#' from the Austrian Parliament website <a href="https://www.parlament.gv.at/recherchieren/personen/parlamentarierinnen-ab-1848/parlamentarierinnen-ab-1918/index.html" target="_blank">here</a>.

#' @param search_string Search string (not only names).
#' @param institution Chamber of Parliament. NR (Nationalrat), BR (Bundesrat), KonstNatVers (Konstituierende Nationalversammlung),
#' or ProvNatVers (Provisorische Nationalversammlung). NULL covers all institutions.
#' @param gender Gender filter. One of "all", "female", or "male"
#' @param legis_period Legislative period. Can be "all", a numeric value,
#'        "Provisorische Nationalversammlung", or "Konstituierende Nationalversammlung"
#' @param party Political party filter. See details for possible values.
#' @param parl_group Parliamentary group filter
#' @param electoral_district Electoral district filter
#' @param state State filter
#' @param presidents_only Logical. If TRUE, returns only presidents. Default is FALSE
#' @param echo Logical. If `TRUE`, the function prints the used search parametes and the url to the  pertaining search results on website of the Austrian Parlament.
#'
#' @return A dataframe containing information about Members of Parliament including:
#'   \item{name}{Name of the MP}
#'   \item{fraktion}{Parliamentary group}
#'   \item{bundesland}{Federal state}
#'   \item{gesetzgebungsperioden}{Legislative periods}
#'   And additional columns depending on the query parameters
#'
#' @details
#'
#' ## search_string
#' Specifying `search_string` will filter the results across all columns, not only names.
#' ## legis_period
#' Filtering for a legislative period is only possible for the Nationalrat, the Konstituierende Nationalversammlung, and
#' the Provisorische Nationalversammlung. Including a legislative period argument will exclude any results for the Bundesrat.
#'
#' Searching for multiple legislative periods will return only one match per individual, even if the person served in multiple periods.
#' The relevant information is provided in `gp_code` (Gesetzgbungsperiode, legislative period) which stipulates the periods served in.
#' The search does not return one row per legislative period.
#'
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
  search_string = NULL, #DOCUMENT search_string not only for names
  institution = NULL,
  gender = "all",
  legis_period = NULL,
  party = NULL,
  parl_group = NULL,
  state = NULL,
  electoral_district = NULL,
  presidents_only = NULL
  echo = TRUE
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
      M <- NULL
      W <- NULL
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

  #TODO: make that institution can be also all bodies
  checkmate::assert_subset(
    x = institution,
    choices = c(
      "NR",
      "BR",
      "KonstNatVers",
      "ProvNatVers"
    ),
    empty.ok = TRUE
  )

  # institution
  checkmate::assert_subset(
    x = institution,
    choices = c("KonstNatVers", "NR", "BR", "ProvNatVers"),
    empty.ok = TRUE
  )

  if (!is.null(institution)) {
    institution <- switch(
      institution,
      "NR" = "Nationalrat",
      "BR" = "Bundesrat",
      "KonstNatVers" = "Konstituierende Nationalversammlung",
      "ProvNatVers" = "Provisorische Nationalversammlung",
      institution # default: leave as is
    )
  }

  # legis_period
  # info message on implications of legis_period on BR search results
  if (
    !is.null(legis_period) &&
      (is.null(institution) ||
        !(institution %in%
          c(
            "Nationalrat",
            "Konstituierende Nationalversammlung",
            "Provisorische Nationalversammlung"
          )))
  ) {
    message(
      "Important: Specifying a legislative period will NOT return results for the Bundesrat."
    )
  }

  legis_period <- as.character(legis_period)
  checkmate::assert_subset(
    x = legis_period,
    choices = ParlAT::get_legis_periods()$legis_period_abbrev_num,
    empty.ok = TRUE
  )

  legis_period <- get_legis_periods(legis_period = legis_period) |>
    dplyr::pull(legis_period_name)

  # parl group (Klub/Fraktion)

  #DOCUMENT many different naming variations for same party
  choices_parl_group <- c(
    "Abgeordnetenverband des Landbundes für Österreich",
    "Bundesratsfraktion der Großdeutschen Volkspartei",
    "Bundesratsfraktion der Grünen; Grüne Fraktion im Bundesrat",
    "Bundesratsfraktion der SPÖ",
    "Bundesratsfraktion der WdU",
    "Bundesratsfraktion der ÖVP",
    "Christlichsoziale Fraktion im Bundesrate",
    "Christlichsoziale Vereinigung deutscher Abgeordneter",
    "Christlichsoziale Vereinigung deutscher Abgeordneter im österreichischen Parlamente",
    "Der Grüne Klub",
    "Der Grüne Klub - Klub der Grün-Alternativen Abgeordneten",
    "Der Grüne Klub im Parlament - Klub der Grünen Abgeordneten zum Nationalrat, Bundesrat und Europäischen Parlament",
    "Die Sozialdemokratische Parlamentsfraktion - Klub der sozialdemokratischen Abgeordneten zum Nationalrat, Bundesrat und Europäischen Parlament",
    "Fraktion der Freiheitlichen Bundesräte; Freiheitliche Bundesratsfraktion",
    "Fraktion der Sozialdemokratischen Bundesratsmitglieder",
    "Freiheitlicher Parlamentsklub",
    "Freiheitlicher Parlamentsklub; Freiheitlicher Parlamentsklub - BZÖ",
    "Großdeutsche Vereinigung",
    "Großdeutsche Volkspartei",
    "Klub Liberales Forum",
    "Klub der Freiheitlichen",
    "Klub der Freiheitlichen Partei Österreichs",
    "Klub der Kommunisten und Linkssozialisten",
    "Klub der Sozialistischen Abgeordneten und Bundesräte",
    "Klub der Sozialistischen Abgeordneten und Bundesräte; Sozialdemokratische Parlamentsfraktion - Klub der sozialdemokratischen Abgeordneten und Bundesräte",
    "Klub der Sozialistischen Partei Österreichs",
    "Klub der Sozialistischen Partei Österreichs; Klub der Sozialistischen Abgeordneten und Bundesräte",
    "Klub der Unabhängigen; Klub der Wahlpartei der Unabhängigen",
    "Klub der Wahlpartei der Unabhängigen",
    "Klub der Österreichischen Volksopposition",
    "Klub der Österreichischen Volkspartei",
    "Klub der Österreichischen Volkspartei; Parlamentsklub der Österreichischen Volkspartei",
    "Klub des Linksblocks (Kommunisten und Linkssozialisten)",
    "Klub von NEOS und LIF; Klub von NEOS",
    "Klub von NEOS; NEOS Parlamentsklub",
    "Liste Pilz",
    "NEOS Parlamentsklub",
    "Parlamentarischer Klub des Heimatblocks",
    "Parlamentsklub JETZT",
    "Parlamentsklub Liberales Forum",
    "Parlamentsklub Team Stronach",
    "Parlamentsklub der Kommunistischen Partei Österreichs",
    "Parlamentsklub der Sozialistischen Partei Österreichs; Klub der Sozialistischen Partei Österreichs",
    "Parlamentsklub der Österreichischen Volkspartei",
    "Parlamentsklub der Österreichischen Volkspartei; Klub der Österreichischen Volkspartei",
    "Parlamentsklub des BZÖ",
    "Parlamentsklub des Liberalen Forums",
    "Sozialdemokratische Parlamentsfraktion - Klub der sozialdemokratischen Abgeordneten und Bundesräte",
    "Sozialdemokratische Vereinigung",
    "Verband der Abgeordneten der Großdeutschen Volkspartei",
    "Verband der Abgeordneten des Nationalen Wirtschaftsblocks",
    "Verband der Sozialdemokratischen Abgeordneten zum Nationalrat",
    "Verband der Sozialdemokratischen Abgeordneten zum Nationalrat Deutschösterreichs",
    "Verband der Sozialdemokratischen Abgeordneten zum Nationalrat; Verband der Sozialdemokratischen Abgeordneten zum Nationalrat Deutschösterreichs",
    "Verband der deutschnationalen Parteien und weitere deutschnationale Klubs",
    "ohne Fraktionszugehörigkeit",
    "ohne Klubzugehörigkeit"
  )

  checkmate::assert_subset(
    x = parl_group,
    choices = choices_parl_group,
    empty.ok = TRUE
  )

  # party (Wahlpartei)

  vec_parties = c(
    "Bauernpartei (BP)",
    "Bündnis Zukunft Österreich (BZÖ)",
    "Bürgerlich-demokratische Partei (BDP)",
    "Bürgerliche Arbeitspartei (BAP)",
    "Christlichsoziale Partei (CSP)",
    "Die Freiheitlichen in Kärnten - BZÖ (BZÖK)",
    "Die Freiheitlichen in Kärnten - Liste Gerhard Dörfler (FPK)",
    "Die Grünen (Grüne)",
    "Freiheitliche Partei Österreichs (FPÖ)",
    "Großdeutsche Vereinigung (GdP)",
    "Großdeutsche Volkspartei (GdP)",
    "Heimatblock (HB)",
    "Jüdisch-Nationale Partei (JNP)",
    "Kommunisten und Linkssozialisten (KuL)",
    "Kommunistische Partei Österreichs (KPÖ)",
    "Landbund (LBd)",
    "Liberales Forum (L)",
    "Linksblock (LB)",
    "Liste Fritz Dinkhauser - FRITZ (FRITZ)",
    "Liste Peter Pilz (PILZ)",
    "NEOS - Das neue Österreich und Liberales Forum (NEOS)",
    "Nationaler Wirtschaftsblock (NWB)",
    "Österreichische Volkspartei (ÖVP)",
    "Sozialdemokratische Arbeiterpartei Deutschösterreichs (SdP)",
    "Sozialdemokratische Partei Österreichs (SPÖ)",
    "Sozialistische Partei Österreichs (SPÖ)",
    "Team Frank Stronach - Frank (STRONA)",
    "Tschechische Partei (TS)",
    "Volksopposition (VO)",
    "Wahlpartei der Unabhängigen (WdU)",
    "ohne Parteizugehörigkeit (OP)"
  )

  choices_party <- stringr::str_extract(vec_parties, "(?<=\\().+?(?=\\))")

  checkmate::assert_subset(
    x = party,
    choices = choices_party,
    empty.ok = TRUE
  )

  if (!is.null(party)) {
    search_OR <- glue::glue("({party})") %>% stringr::str_c(., collapse = "|")
    party <- stringr::str_subset(vec_parties, stringr::regex(search_OR))
  }

  # state
  choices_state <- c(
    "Bundeswahlvorschlag",
    "Burgenland",
    "Kärnten",
    "Niederösterreich",
    "Oberösterreich",
    "Salzburg",
    "Steiermark",
    "Tirol",
    "Wien",
    "Vorarlberg"
  )

  checkmate::assert_subset(
    x = state,
    choices = choices_state,
    empty.ok = TRUE
  )

  # electoral district

  choices_electoral_district <- c(
    "Bundeswahlvorschlag",
    "Burgenland",
    "Burgenland Nord",
    "Burgenland Süd",
    "Deutsch-Südtirol",
    "Flachgau/Tennengau",
    "Graz",
    "Graz und Umgebung",
    "Hausruckviertel",
    "Innsbruck-Land",
    "Innviertel",
    "Klagenfurt",
    "Kärnten",
    "Kärnten Ost",
    "Kärnten West",
    "Lienz",
    "Linz und Umgebung",
    "Lungau/Pinzgau/Pongau",
    "Mittel- und Untersteier",
    "Mostviertel",
    "Mühlviertel",
    "Niederösterreich",
    "Niederösterreich Mitte",
    "Niederösterreich Ost",
    "Niederösterreich Süd",
    "Niederösterreich Süd-Ost",
    "Nordtirol",
    "Oberland",
    "Obersteier",
    "Obersteiermark",
    "Oberösterreich",
    "Oststeier",
    "Oststeiermark",
    "Reststimmenmandat",
    "Salzburg",
    "Salzburg Stadt",
    "Steiermark",
    "Steiermark Mitte",
    "Steiermark Nord",
    "Steiermark Nord-West",
    "Steiermark Ost",
    "Steiermark Süd",
    "Steiermark Süd-Ost",
    "Steiermark West",
    "Thermenregion",
    "Tirol",
    "Traunviertel",
    "Unterland",
    "Viertel oberm Manhartsberg",
    "Viertel oberm Wienerwald",
    "Viertel unterm Manhartsberg",
    "Viertel unterm Wienerwald",
    "Villach",
    "Vorarlberg",
    "Vorarlberg Nord",
    "Vorarlberg Süd",
    "Wahlkreisverband I (Burgenland, Niederösterreich, Wien)",
    "Wahlkreisverband I (Wien)",
    "Wahlkreisverband II (K, OÖ, S, St, T u V)",
    "Wahlkreisverband II (Niederösterreich)",
    "Wahlkreisverband III (OÖ, S, T u. V)",
    "Wahlkreisverband III - Oberösterreich",
    "Wahlkreisverband III - Salzburg",
    "Wahlkreisverband III - Tirol",
    "Wahlkreisverband IV (B, K u St.)",
    "Wahlkreisverband IV - Burgenland",
    "Wahlkreisverband IV - Kärnten",
    "Wahlkreisverband IV - Steiermark",
    "Waldviertel",
    "Weinviertel",
    "Weststeiermark",
    "Wien",
    "Wien Innen-Ost",
    "Wien Innen-Süd",
    "Wien Innen-West",
    "Wien Nord",
    "Wien Nord-West",
    "Wien Nordost",
    "Wien Nordwest",
    "Wien Süd",
    "Wien Süd-West",
    "Wien Südost",
    "Wien Südwest",
    "Wien Umgebung",
    "Wien West"
  )

  checkmate::assert_subset(
    x = electoral_district,
    choices = choices_electoral_district,
    empty.ok = TRUE
  )

  # presidents only
  checkmate::assert_subset(
    x = presidents_only,
    choices = c(TRUE, FALSE),
    empty.ok = TRUE
  )

  # If presidents_only is TRUE, set PRAES to "J", otherwise NULL
  if (!is.null(presidents_only)) {
    presidents_only <- if (isTRUE(presidents_only)) "J" else NULL
  }
  # print(presidents_only)

  body_params <- list(
    GESCHL_CODE = c(W, M),
    ATTR_JSON.mandate_detail.gremium_name = institution,
    ATTR_JSON.mandate_detail.gp_text_full_short = legis_period,
    ATTR_JSON.mandate_detail.wahlpartei_full_txt = party,
    ATTR_JSON.mandate_detail.fraktion = parl_group,
    ATTR_JSON.mandate_detail.wahlkreis_bundesland = state,
    ATTR_JSON.mandate_detail.wahlkreis = electoral_district,
    PRAES = presidents_only
  ) |>
    purrr::compact() |>
    jsonlite::toJSON()

  res <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/409"
  ) |>
    httr2::req_method("POST") |>
    httr2::req_url_query(
      `1` = "1",
      page = "1",
      pagesize = "10000", #IMPROVE
      search = search_string,
      # showAll = "true",
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
    purrr::pluck("rows") %>%
    map(., \(x) x[[8]])

  df_res <- li_res %>%
    purrr::map(., fn_make_tibble) %>%
    purrr::list_rbind()

  # return(df_res)

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

  if (echo == TRUE) {
    print(body_params)
    # print url to results / transparency reasons / add search string parameter
    body_params_li <- jsonlite::fromJSON(body_params) %>%
      c(., "search" = search_string)

    query_string <- purrr::imap(
      body_params_li,
      \(x, y) glue::glue("PERSON_409{URLencode(y)}={URLencode(x)}")
    ) %>%
      unlist() %>%
      unname() %>%
      paste0(collapse = "&")

    print(glue::glue(
      "https://www.parlament.gv.at/recherchieren/personen/parlamentarierinnen-ab-1848/parlamentarierinnen-ab-1918?{query_string}"
    ))

    print(nrow(df_res))
  }

  if (nrow(df_res) == 0) {
    message("No results found for the search criteria provided.")
    return(NULL)
  }

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
#' @noRd
#'
#' @examples
#' \dontrun{
#' # Get all MPs from the current legislative period
#' mps <- get_mps(institution = "Nationalrat", legis_period = "27")
#'
#' # Get female MPs from a specific party
#' female_mps <- get_mps(gender = "female", party = "SPÖ")
#' }
get_mps_old <- function(
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


fn_make_tibble <- function(x) {
  tibble::tibble(
    !!!purrr::imap(x, function(value, name) {
      if (is.list(value) && !is.atomic(value)) {
        list(value) # bleibe list-column
      } else {
        value # einfacher atomic-Wert
      }
    })
  )
}
