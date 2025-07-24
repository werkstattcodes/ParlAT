#' Get Members of Parliament
#'
#' `get_mps()` retrieves information about Members of Parliament based on specified filter criteria.
#' The function mirrors the search functionality 'Parlamentarier:innen ab 1918' _(Parliamentarians since 1918)_
#' from the Austrian Parliament website <a href="https://www.parlament.gv.at/recherchieren/personen/parlamentarierinnen-ab-1848/parlamentarierinnen-ab-1918/index.html" target="_blank">here</a>.
#' @param search_string Search string (not only names).
#' @param institution Chamber of Parliament.
#' - "NR" (Nationalrat, National Council)
#' - "BR" (Bundesrat, Federal Council)
#' - "KN" (Konstituierende Nationalversammlung, Constituent National Assembly)
#' - "PV" (Provisorische Nationalversammlung, Provisional National Assembly)
#' - NULL covers all institutions.
#' @param gender Gender filter. One of "all", "female", or "male"
#' @param legis_period Legislative period. Can be "all", a numeric value,
#'        "PV" (Provisorische Nationalversammlung), or "KN" (Konstituierende Nationalversammlung)
#' @param party Political party filter. See details for permissible values.
#' @param parl_group Parliamentary group filter
#' @param electoral_district Electoral district filter. See details for permissible values.
#' @param state State filter. See details for permissible values.
#' @param presidents_only Logical. If TRUE, returns only presidents. Default is FALSE
# # @param mandate_details logical. "all" or "filter" #PENDING
#' @param echo Logical. If `TRUE`, the function prints the used search parametes and the url to the  pertaining search results on website of the Austrian Parlament.
#'
#' @return A dataframe containing information about the MPs. One row per MP. Important: The API returns details
#' on all MPs who e.g. have been member of Parliament during the requested legislative period. The details
#' returned, however, are not limited to the requested period. The column `parl_group`
#' may also contain data on the MP's membership in a parliamentary group during the requested period, but also
#' also on his or her membership in other parliamentary groups in the past.
# However, if the interest is in getting MP details only within the scope of filter criteria set
# the function arugment `strict` to TRUE. #REVISE
#'
#'   \item{pad_intern}{Person's unique identification number}
#'   \item{name}{Name of the MP}
#'   \item{gender}{Gender}
#'   \item{parl_group}{Parliamentary group; note that the groups stated comprises *all* past and present groups of which the MP has been
#' member of}
#'   \item{parl_group_abbrev}{Abbreviation of the parliamentary group}
#'   \item{legis_period}{Legislative period(s)}
#'   \item{mandate_detail}{Details on madates in Parliament}
#'   \item{electoral_district}{Electoral district}
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
#' ## parl_group
#' Permissible values:
#'   - Abgeordnetenverband des Landbundes für Österreich
#'   - Bundesratsfraktion der Großdeutschen Volkspartei
#'   - Bundesratsfraktion der Grünen; Grüne Fraktion im Bundesrat
#'   - Bundesratsfraktion der SPÖ
#'   - Bundesratsfraktion der WdUe
#'   - Bundesratsfraktion der ÖVP
#'   - Christlichsoziale Fraktion im Bundesrate
#'   - Christlichsoziale Vereinigung deutscher Abgeordneter
#'   - Christlichsoziale Vereinigung deutscher Abgeordneter im österreichischen Parlamente
#'   - Der Grüne Klub
#'   - Der Grüne Klub - Klub der Grün-Alternativen Abgeordneten
#'   - Der Grüne Klub im Parlament - Klub der Grünen Abgeordneten zum Nationalrat, Bundesrat und Europäischen Parlament
#'   - Die Sozialdemokratische Parlamentsfraktion - Klub der sozialdemokratischen Abgeordneten zum Nationalrat, Bundesrat und Europäischen Parlament
#'   - Fraktion der Freiheitlichen Bundesräte; Freiheitliche Bundesratsfraktion
#'   - Fraktion der Sozialdemokratischen Bundesratsmitglieder
#'   - Freiheitlicher Parlamentsklub
#'   - Freiheitlicher Parlamentsklub; Freiheitlicher Parlamentsklub - BZÖ
#'   - Großdeutsche Vereinigung
#'   - Großdeutsche Volkspartei
#'   - Klub Liberales Forum
#'   - Klub der Freiheitlichen
#'   - Klub der Freiheitlichen Partei Österreichs
#'   - Klub der Kommunisten und Linkssozialisten
#'   - Klub der Sozialistischen Abgeordneten und Bundesräte
#'   - Klub der Sozialistischen Abgeordneten und Bundesräte; Sozialdemokratische Parlamentsfraktion - Klub der sozialdemokratischen Abgeordneten und Bundesräte
#'   - Klub der Sozialistischen Partei Österreichs
#'   - Klub der Sozialistischen Partei Österreichs; Klub der Sozialistischen Abgeordneten und Bundesräte
#'   - Klub der Unabhängigen; Klub der Wahlpartei der Unabhängigen
#'   - Klub der Wahlpartei der Unabhängigen
#'   - Klub der Österreichischen Volksopposition
#'   - Klub der Österreichischen Volkspartei
#'   - Klub der Österreichischen Volkspartei; Parlamentsklub der Österreichischen Volkspartei
#'   - Klub des Linksblocks (Kommunisten und Linkssozialisten)
#'   - Klub von NEOS und LIF; Klub von NEOS
#'   - Klub von NEOS; NEOS Parlamentsklub
#'   - Liste Pilz
#'   - NEOS Parlamentsklub
#'   - Parlamentarischer Klub des Heimatblocks
#'   - Parlamentsklub JETZT
#'   - Parlamentsklub Liberales Forum
#'   - Parlamentsklub Team Stronach
#'   - Parlamentsklub der Kommunistischen Partei Österreichs
#'   - Parlamentsklub der Sozialistischen Partei Österreichs; Klub der Sozialistischen Partei Österreichs
#'   - Parlamentsklub der Österreichischen Volkspartei
#'   - Parlamentsklub der Österreichischen Volkspartei; Klub der Österreichischen Volkspartei
#'   - Parlamentsklub des BZÖ
#'   - Parlamentsklub des Liberalen Forums
#'   - Sozialdemokratische Parlamentsfraktion - Klub der sozialdemokratischen Abgeordneten und Bundesräte
#'   - Sozialdemokratische Vereinigung
#'   - Verband der Abgeordneten der Großdeutschen Volkspartei
#'   - Verband der Abgeordneten des Nationalen Wirtschaftsblocks
#'   - Verband der Sozialdemokratischen Abgeordneten zum Nationalrat
#'   - Verband der Sozialdemokratischen Abgeordneten zum Nationalrat Deutschösterreichs
#'   - Verband der Sozialdemokratischen Abgeordneten zum Nationalrat; Verband der Sozialdemokratischen Abgeordneten zum Nationalrat Deutschösterreichs
#'   - Verband der deutschnationalen Parteien und weitere deutschnationale Klubs
#'   - ohne Fraktionszugehörigkeit
#'   - ohne Klubzugehörigkeit
#'
#' ## party
#' Parties to be searched for. Use abbreviation in parentheses as function
#' input.
#'   - Bauernpartei (BP)
#'   - Bündnis Zukunft Österreich (BZÖ)
#'   - Bürgerlich-demokratische Partei (BDP)
#'   - Bürgerliche Arbeitspartei (BAP)
#'   - Christlichsoziale Partei (CSP)
#'   - Die Freiheitlichen in Kärnten - BZÖ (BZÖK)
#'   - Die Freiheitlichen in Kärnten - Liste Gerhard Dörfler (FPK)
#'   - Die Grünen (Grüne)
#'   - Freiheitliche Partei Österreichs (FPÖ)
#'   - Großdeutsche Vereinigung (GdP)
#'   - Großdeutsche Volkspartei (GdP)
#'   - Heimatblock (HB)
#'   - Jüdisch-Nationale Partei (JNP)
#'   - Kommunisten und Linkssozialisten (KuL)
#'   - Kommunistische Partei Österreichs (KPÖ)
#'   - Landbund (LBd)
#'   - Liberales Forum (L)
#'   - Linksblock (LB)
#'   - Liste Fritz Dinkhauser - FRITZ (FRITZ)
#'   - Liste Peter Pilz (PILZ)
#'   - NEOS - Das neue Österreich und Liberales Forum (NEOS)
#'   - Nationaler Wirtschaftsblock (NWB)
#'   - Österreichische Volkspartei (ÖVP)
#'   - Sozialdemokratische Arbeiterpartei Deutschösterreichs (SdP)
#'   - Sozialdemokratische Partei Österreichs (SPÖ)
#'   - Sozialistische Partei Österreichs (SPÖ)
#'   - Team Frank Stronach - Frank (STRONA)
#'   - Tschechische Partei (TS)
#'   - Volksopposition (VO)
#'   - Wahlpartei der Unabhängigen (WdU)
#'   - ohne Parteizugehörigkeit (OP)
#'
#' ## electoral_district
#'
#' Permissible values:
#'   - Bundeswahlvorschlag
#'   - Burgenland
#'   - Burgenland Nord
#'   - Burgenland Süd
#'   - Deutsch-Südtirol
#'   - Flachgau/Tennengau
#'   - Graz
#'   - Graz und Umgebung
#'   - Hausruckviertel
#'   - Innsbruck-Land
#'   - Innviertel
#'   - Klagenfurt
#'   - Kärnten
#'   - Kärnten Ost
#'   - Kärnten West
#'   - Lienz
#'   - Linz und Umgebung
#'   - Lungau/Pinzgau/Pongau
#'   - Mittel- und Untersteier
#'   - Mostviertel
#'   - Mühlviertel
#'   - Niederösterreich
#'   - Niederösterreich Mitte
#'   - Niederösterreich Ost
#'   - Niederösterreich Süd
#'   - Niederösterreich Süd-Ost
#'   - Nordtirol
#'   - Oberland
#'   - Obersteier
#'   - Obersteiermark
#'   - Oberösterreich
#'   - Oststeier
#'   - Oststeiermark
#'   - Reststimmenmandat
#'   - Salzburg
#'   - Salzburg Stadt
#'   - Steiermark
#'   - Steiermark Mitte
#'   - Steiermark Nord
#'   - Steiermark Nord-West
#'   - Steiermark Ost
#'   - Steiermark Süd
#'   - Steiermark Süd-Ost
#'   - Steiermark West
#'   - Thermenregion
#'   - Tirol
#'   - Traunviertel
#'   - Unterland
#'   - Viertel oberm Manhartsberg
#'   - Viertel oberm Wienerwald
#'   - Viertel unterm Manhartsberg
#'   - Viertel unterm Wienerwald
#'   - Villach
#'   - Vorarlberg
#'   - Vorarlberg Nord
#'   - Vorarlberg Süd
#'   - Wahlkreisverband I (Burgenland, Niederösterreich, Wien)
#'   - Wahlkreisverband I (Wien)
#'   - Wahlkreisverband II (K, OÖ, S, St, T u V)
#'   - Wahlkreisverband II (Niederösterreich)
#'   - Wahlkreisverband III (OÖ, S, T u. V)
#'   - Wahlkreisverband III - Oberösterreich
#'   - Wahlkreisverband III - Salzburg
#'   - Wahlkreisverband III - Tirol
#'   - Wahlkreisverband IV (B, K u St.)
#'   - Wahlkreisverband IV - Burgenland
#'   - Wahlkreisverband IV - Kärnten
#'   - Wahlkreisverband IV - Steiermark
#'   - Waldviertel
#'   - Weinviertel
#'   - Weststeiermark
#'   - Wien
#'   - Wien Innen-Ost
#'   - Wien Innen-Süd
#'   - Wien Innen-West
#'   - Wien Nord
#'   - Wien Nord-West
#'   - Wien Nordost
#'   - Wien Nordwest
#'   - Wien Süd
#'   - Wien Süd-West
#'   - Wien Südost
#'   - Wien Südwest
#'   - Wien Umgebung
#'   - Wien West
#'
#' ## state
#' Permissible values:
#'
#'   - Bundeswahlvorschlag
#'   - Burgenland
#'   - Kärnten
#'   - Niederösterreich
#'   - Oberösterreich
#'   - Salzburg
#'   - Steiermark
#'   - Tirol
#'   - Vorarlberg
#'   - Wien
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
  search_string = NULL,
  institution = NULL,
  gender = "all",
  legis_period = NULL,
  party = NULL,
  parl_group = NULL,
  state = NULL,
  electoral_district = NULL,
  presidents_only = NULL,
  # strict = FALSE, #PENDING
  date = NULL, #PENDING
  echo = TRUE
) {
  if (!is.null(date) && !is.null(legis_period)) {
    stop("Please provide either date or legis_period, not both.")
  }

  if (!is.null(legis_period) && !is.null(institution) && institution == "BR") {
    stop(
      "Filtering the Federal Council (Bundesrat) by legislative period is not supported. Please use 'date' filter instead."
    )
  }

  if (!is.null(date) && is.null(legis_period) && institution == "NR") {
    legis_period_num <- get_legis_periods(date = date) %>%
      dplyr::pull(legis_period)
  }

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
      "KN",
      "PV"
    ),
    empty.ok = TRUE
  )

  # institution
  checkmate::assert_subset(
    x = institution,
    choices = c("KN", "NR", "BR", "PV"),
    empty.ok = TRUE
  )

  institution_input <- if (is.null(institution)) {
    NULL
  } else {
    switch(
      institution,
      "NR" = "Nationalrat",
      "BR" = "Bundesrat",
      "KN" = "Konstituierende Nationalversammlung",
      "PV" = "Provisorische Nationalversammlung",
      NULL # default if no match
    )
  }

  # legis_period
  # info message on implications of legis_period on BR search results
  if (
    !is.null(legis_period) &&
      (is.null(institution) ||
        !(institution %in%
          c(
            "NR",
            "KN",
            "PV"
          )))
  ) {
    stop(
      "Filtering by legislative period is only supported for the National Council (Nationalrat). Either specify institution = 'NR', or, alternativley, use the date filter instead."
    )
  }

  legis_period_char <- as.character(legis_period)
  checkmate::assert_subset(
    x = legis_period_char,
    choices = ParlAT::get_legis_periods()$legis_period_abbrev_num,
    empty.ok = TRUE
  )

  if (!is.null(legis_period)) {
    legis_period_name <- get_legis_periods(legis_period = legis_period) |>
      dplyr::pull(legis_period_name)
  } else {
    legis_period_name <- NULL
  }

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
    "NEOS - Das neue Österreich und Liberales Forum (NEOS)", #REVISE
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
    ATTR_JSON.mandate_detail.gremium_name = institution_input,
    ATTR_JSON.mandate_detail.gp_text_full_short = legis_period_name,
    ATTR_JSON.mandate_detail.wahlpartei_full_txt = party,
    ATTR_JSON.mandate_detail.fraktion = parl_group,
    ATTR_JSON.mandate_detail.wahlkreis_bundesland = state,
    ATTR_JSON.mandate_detail.wahlkreis = electoral_district,
    PRAES = presidents_only
  ) |>
    purrr::compact() |>
    jsonlite::toJSON()
  #print(body_params)

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

  #echo only if query without date fitler
  if (echo == TRUE && is.null(date)) {
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

  #make column names more meaningful
  df_res <- df_res %>%
    dplyr::select(
      pad_intern = dplyr::any_of("pad_intern"),
      name = dplyr::any_of("name_nvg"),
      gender = dplyr::any_of("geschlecht"),
      parl_group = dplyr::any_of("fraktionen"),
      parl_group_abbrev = dplyr::any_of("frak"),
      legis_period = dplyr::any_of("gp_code"),
      mandate_detail = dplyr::any_of("mandate_detail"),
      electoral_district = dplyr::any_of("wahlkreise")
    )

  # return(df_res)

  # if (strict == T) { #PENDING

  #EXPAND API RESULTS AND RETURN ONLY DATA PERTAINING
  #TO SPECIFIC LEGISLATIVE PERIOD
  # df_res <- df_res %>%
  #   dplyr::select(pad_intern, name, gender, mandate_detail) %>%
  #   tidyr::unnest_longer(mandate_detail) %>%
  #   tidyr::unnest_wider(mandate_detail)

  # Apply filters only when arguments are not NULL
  # if (!is.null(institution)) {
  #   df_res <- df_res %>% filter(gremium_name %in% institution)
  # }

  # if (!is.null(legis_period)) {
  #   df_res <- df_res %>% filter(gp_text_full_short %in% legis_period)
  # }

  # if (!is.null(party)) {
  #   df_res <- df_res %>% filter(wahlpartei_full_txt %in% party)
  # }

  # if (!is.null(parl_group)) {
  #   df_res <- df_res %>% filter(fraktion %in% parl_group)
  # }

  # if (!is.null(electoral_district)) {
  #   df_res <- df_res %>% filter(wahlkreis %in% electoral_district)
  # }

  # if (!is.null(state)) {
  #   df_res <- df_res %>% filter(wahlkreis_bundesland %in% state)
  # }
  # }

  #DATE FILTERING
  # if date is provided, filter results by date
  # result should only contain mandates which are also within institutional scope.
  # otherwise possible that former NR MP who has BR mandate in relevant date is kept

  if (!is.null(date)) {
    #unnest mandates
    df_res_filter_time <- df_res %>%
      dplyr::select(pad_intern, mandate_detail) %>%
      tidyr::unnest_longer(mandate_detail) %>%
      tidyr::unnest_wider(mandate_detail) %>%
      dplyr::mutate(
        across(c("mandat_von", "mandat_bis"), \(x) lubridate::dmy(x))
      ) %>%
      dplyr::relocate(mandat_bis, .after = "mandat_von")

    #active mandates: set mandat_bis to today
    df_res_filter_time <- df_res_filter_time %>%
      dplyr::mutate(
        mandat_bis = dplyr::case_when(
          is.na(mandat_bis) | mandat_bis == "" ~ lubridate::today(),
          .default = mandat_bis
        )
      )

    # return(df_res_filter_time)

    #filter mandates by institution
    if (!is.null(institution) && institution == "NR") {
      df_res_filter_time_inst <- df_res_filter_time %>%
        dplyr::filter(gremium_name == "Nationalrat")
    } else if (!is.null(institution) && institution == "BR") {
      df_res_filter_time_inst <- df_res_filter_time %>%
        dplyr::filter(gremium_name == "Bundesrat")
    } else if (!is.null(institution) && institution == "KN") {
      df_res_filter_time_inst <- df_res_filter_time %>%
        dplyr::filter(gremium_name == "Konstituierende Nationalversammlung")
    } else if (!is.null(institution) && institution == "PV") {
      df_res_filter_time_inst <- df_res_filter_time %>%
        dplyr::filter(gremium_name == "Provisorische Nationalversammlung")
    } #PENDING: what about Bundesrat1Rep; not mentioned on Parl Website/API

    if (!is.null(date)) {
      date <- lubridate::dmy(date)
      # print(nrow(df_res_filter_time_inst))
      df_res <- df_res_filter_time_inst %>%
        dplyr::filter(date >= mandat_von & date <= mandat_bis)
      # print(nrow(df_res))
    }

    # Get names of MPs (needed to get first name and last name sequence)

    pb <- progress::progress_bar$new(
      format = "Fetching MPs' names [:bar] :percent :current/:total ETA: :eta",
      total = length(df_res$pad_intern),
      clear = FALSE
    )

    df_names <- map2(df_res$pad_intern, format(date, "%d/%m/%Y"), \(x, y) {
      pb$tick()
      name_result <- get_names(x, date = y)
      if (is.data.frame(name_result) && nrow(name_result) > 0) {
        # Collapse multiple names into single string separated by " / "
        name_result %>%
          dplyr::select(pad_intern, name) %>%
          dplyr::mutate(name = paste(name, collapse = "/"))
      } else {
        NULL
      }
    }) %>%
      purrr::list_rbind()

    df_res <- df_res %>%
      dplyr::left_join(., df_names, by = "pad_intern") %>%
      dplyr::relocate(name, .after = "pad_intern")

    if (!is.null(legis_period) && institution == "NR") {
      # print(nrow(df_res_filter_time_inst))
      # print(legis_period)
      # return(df_res_filter_time_inst)
      df_res <- df_res_filter_time_inst %>%
        dplyr::filter(as.roman(gp_code) %in% as.roman(legis_period))
      # print(nrow(df_res))
    } #possible that MPs has multiple mandates in the same chamber during the legislative period; needs nesting

    #filter by date
    #df_dates_check <- data.frame(dates_check = lubridate::dmy(date))

    #keep only mandates which cover date
    # df_res_filter_time_inst <- df_res_filter_time_inst %>%
    #   dplyr::semi_join(
    #     .,
    #     df_dates_check,
    #     by = dplyr::join_by(between(y$dates_check, x$mandat_von, x$mandat_bis))
    #   ) %>%
    #   dplyr::select(pad_intern)

    #keep only those MPs which have mandates in relevant date
    # df_res <- df_res %>%
    #   dplyr::semi_join(
    #     .,
    #     df_res_filter_time_inst,
    #     by = "pad_intern"
    #   )

    # return(df_res)
  }
  #CONTINUE
  #rename output to English
  renaming_map <- c(
    "wahlkreis_bundesland" = "state",
    "wahlpartei_code" = "",
    "fraktionscode" = "",
    "gp_von" = "",
    "wahlpartei_full_txt" = "",
    "gp_code" = "",
    "mandat_von" = "",
    "mandat_bis" = "",
    "gremium_name" = "",
    "wahlpartei_txt" = "",
    "mand_code" = "",
    "wahlpartei_sort" = "",
    "wahlkreis" = "electoral_district",
    "fraktion" = "parl_group",
    "politische_partei" = "party"
  )

  df_res <- df_res %>%
    dplyr::rename_with(
      .fn = \(x) renaming_map[x], # For each selected old name, get its new name from the map
      .cols = any_of(names(renaming_map))
    )

  return(df_res)
}
