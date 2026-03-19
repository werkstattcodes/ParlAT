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
#' - "PN" (Provisorische Nationalversammlung, Provisional National Assembly)
#' - NULL covers all institutions.
#' @param gender Gender filter. One of "all", "female", or "male"
#' @param legis_period Legislative period. Can be "all", a numeric value,
#'        "PN" (Provisorische Nationalversammlung), or "KN" (Konstituierende Nationalversammlung)
#' @param  date  Date for which active MPs are queried. Must be a single date
#'        (length 1) in format DD.MM.YYYY.
#' @param party Political party filter. See details for permissible values.
#' @param parl_group Parliamentary group filter
#' @param electoral_district Electoral district filter. See details for permissible values.
#' @param state State filter. See details for permissible values.
#' @param presidents_only Logical. If TRUE, returns only presidents. Default is FALSE
# # @param mandate_details logical. "all" or "filter" #PENDING
#' @param echo Logical. If `TRUE`, the function prints the used search parameters and the url to the  pertaining search results on website of the Austrian Parliament.
#'
#' @return A dataframe containing information about the MPs. One row per MP. Important: The API returns details
#' on all MPs who e.g. have been member of Parliament during the requested legislative period. The details
#' returned, however, are not limited to the requested period. The column `parl_group`
#' may also contain data on the MP's membership in a parliamentary group during the requested period, but also
#' also on his or her membership in other parliamentary groups in the past.
#'
#' Columns returned:
#' - `pad_intern`: Person's unique identification number
#' - `date`: Requested date (only included when `date` input is provided)
#' - `name`: Name of the MP
#' - `gender`: Gender (male, female)
#' - `parl_group`: Parliamentary group; note that the groups stated comprises *all* past and present groups of which the MP has been member of
#' - `parl_group_abbrev`: Abbreviation of the parliamentary group
#' - `legis_period`: Legislative period(s)
#' - `mandate_detail`: Details on mandates in Parliament at the queried period of time (not all mandates). To obtain all mandates, use `get_mandates()`.
#' - `electoral_district`: Electoral district
#'
#' @details
#'
#' ## search_string
#' Specifying `search_string` will filter the results across all columns, not only names.
#' ## legis_period
#' Filtering for a legislative period is only possible for the National Council (Nationalrat), the Constituent National Assembly (Konstituierende Nationalversammlung), and
#' the Provisional National Assembly (Provisorische Nationalversammlung). Including a legislative
#' period argument will exclude any results for the Federal Council (Bundesrat) since its composition #' follows different electoral cycles.
#'
#' Providing a 'legis_period' input will return one row per unique combination of MP and legislative period.
#' The list-column 'mp_details' contains all mandate details for that MP during the specified legislative period.
#' Since an MP can change within a single legislative period, for example, family name, party affiliation, parliamentary group, or the electoral district of her mandate,
#' 'mp_details' may include multiple rows reflecting these changes.
#'
#' ## parl_group
#' Permissible values:
#'   - Abgeordnetenverband des Landbundes für Österreich
#'   - Bundesratsfraktion der Großdeutschen Volkspartei
#'   - Bundesratsfraktion der Grünen; Grüne Fraktion im Bundesrat
#'   - Bundesratsfraktion der SPÖ
#'   - Bundesratsfraktion der WdU
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
#' \donttest{
#' # Get all MPs from the current legislative period
#' mps <- get_mps(institution = "NR", legis_period = "27")
#' dplyr::glimpse(mps)
#'
#' # Get female MPs from a specific party
#' female_mps <- get_mps(gender = "female", party = "SPÖ")
#' dplyr::glimpse(female_mps)
#' }
get_mps <- function(
  search_string = NULL,
  institution = NULL,
  gender = "all",
  legis_period = NULL,
  date = NULL,
  party = NULL,
  parl_group = NULL,
  state = NULL,
  electoral_district = NULL,
  presidents_only = NULL,
  echo = TRUE
) {
  if (!is.null(date) && !is.null(legis_period)) {
    stop("Please provide either date or legis_period, not both.")
  }

  # Validate date format early
  if (!is.null(date)) {
    if (length(date) != 1) {
      stop("Only date inputs of length 1 are allowed.")
    }

    parsed_date <- lubridate::dmy(date, quiet = TRUE)
    if (is.na(parsed_date)) {
      stop(
        "Invalid date: '",
        date,
        "'. Expected format: DD.MM.YYYY (e.g. '01.01.2020')."
      )
    }
  }

  if (!is.null(legis_period) && !is.null(institution) && institution == "BR") {
    stop(
      "Filtering the Federal Council (Bundesrat) by legislative period is not supported. Please use 'date' filter instead."
    )
  }

  if (
    !is.null(date) &&
      is.null(legis_period) &&
      !is.null(institution) &&
      institution == "NR"
  ) {
    legis_period_num <- get_legis_periods(date = date) %>%
      dplyr::pull("legis_period")
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

  # institution
  checkmate::assert_choice(
    x = institution,
    choices = c("KN", "NR", "BR", "PN"),
    null.ok = TRUE
  )

  institution_input <- if (is.null(institution)) {
    NULL
  } else {
    switch(
      institution,
      "NR" = "Nationalrat",
      "BR" = "Bundesrat",
      "KN" = "Konstituierende Nationalversammlung",
      "PN" = "Provisorische Nationalversammlung",
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
            "PN"
          )))
  ) {
    stop(
      "Filtering by legislative period is only supported for the National Council (Nationalrat). Either specify institution = 'NR', or, alternativley, use the date filter instead."
    )
  }

  # Check whether provided legis period is among existing periods
  if (!is.null(legis_period)) {
    legis_period_char <- aux_convert_legis_periods(legis_period)

    checkmate::assert_subset(
      x = legis_period_char,
      choices = ParlAT::get_legis_periods()$legis_period_abbrev_num,
      empty.ok = TRUE
    )
  }

  # Validate PN institution requires PN legis_period
  if (!is.null(institution) && institution == "PN") {
    checkmate::assert_true(
      !is.null(legis_period) && "PN" %in% as.character(legis_period),
      .var.name = "When institution is 'PN' (Provisorische Nationalversammlung), legis_period must also be 'PN'."
    )
  }

  # Validate PN legis_period requires PN institution
  if (!is.null(legis_period) && "PN" %in% as.character(legis_period)) {
    checkmate::assert_true(
      !is.null(institution) && institution == "PN",
      .var.name = "When legis_period is 'PN' (Provisorische Nationalversammlung), institution must also be 'PN'."
    )
  }

  # Validate KN institution requires KN legis_period
  if (!is.null(institution) && institution == "KN") {
    checkmate::assert_true(
      !is.null(legis_period) && "KN" %in% as.character(legis_period),
      .var.name = "When institution is 'KN' (Konstituierende Nationalversammlung), legis_period must also be 'KN'."
    )
  }

  # Validate KN legis_period requires KN institution
  if (!is.null(legis_period) && "KN" %in% as.character(legis_period)) {
    checkmate::assert_true(
      !is.null(institution) && institution == "KN",
      .var.name = "When legis_period is 'KN' (Konstituierende Nationalversammlung), institution must also be 'KN'."
    )
  }

  if (!is.null(legis_period)) {
    legis_period_name <- get_legis_periods(legis_period = legis_period) %>%
      dplyr::pull("legis_period_name")
  } else {
    legis_period_name <- NULL
  }

  # parl group (Klub/Fraktion)

  #DOCUMENT many different naming variations for same party
  choices_parl_group <- c(
    "Abgeordnetenverband des Landbundes f\u00fcr \u00d6sterreich",
    "Bundesratsfraktion der Gro\u00dfdeutschen Volkspartei",
    "Bundesratsfraktion der Gr\u00fcnen; Gr\u00fcne Fraktion im Bundesrat",
    "Bundesratsfraktion der SP\u00d6",
    "Bundesratsfraktion der WdU",
    "Bundesratsfraktion der \u00d6VP",
    "Christlichsoziale Fraktion im Bundesrate",
    "Christlichsoziale Vereinigung deutscher Abgeordneter",
    "Christlichsoziale Vereinigung deutscher Abgeordneter im \u00f6sterreichischen Parlamente",
    "Der Gr\u00fcne Klub",
    "Der Gr\u00fcne Klub - Klub der Gr\u00fcn-Alternativen Abgeordneten",
    "Der Gr\u00fcne Klub im Parlament - Klub der Gr\u00fcnen Abgeordneten zum Nationalrat, Bundesrat und Europ\u00e4ischen Parlament",
    "Die Sozialdemokratische Parlamentsfraktion - Klub der sozialdemokratischen Abgeordneten zum Nationalrat, Bundesrat und Europ\u00e4ischen Parlament",
    "Fraktion der Freiheitlichen Bundesr\u00e4te; Freiheitliche Bundesratsfraktion",
    "Fraktion der Sozialdemokratischen Bundesratsmitglieder",
    "Freiheitlicher Parlamentsklub",
    "Freiheitlicher Parlamentsklub; Freiheitlicher Parlamentsklub - BZ\u00d6",
    "Gro\u00dfdeutsche Vereinigung",
    "Gro\u00dfdeutsche Volkspartei",
    "Klub Liberales Forum",
    "Klub der Freiheitlichen",
    "Klub der Freiheitlichen Partei \u00d6sterreichs",
    "Klub der Kommunisten und Linkssozialisten",
    "Klub der Sozialistischen Abgeordneten und Bundesr\u00e4te",
    "Klub der Sozialistischen Abgeordneten und Bundesr\u00e4te; Sozialdemokratische Parlamentsfraktion - Klub der sozialdemokratischen Abgeordneten und Bundesr\u00e4te",
    "Klub der Sozialistischen Partei \u00d6sterreichs",
    "Klub der Sozialistischen Partei \u00d6sterreichs; Klub der Sozialistischen Abgeordneten und Bundesr\u00e4te",
    "Klub der Unabh\u00e4ngigen; Klub der Wahlpartei der Unabh\u00e4ngigen",
    "Klub der Wahlpartei der Unabh\u00e4ngigen",
    "Klub der \u00d6sterreichischen Volksopposition",
    "Klub der \u00d6sterreichischen Volkspartei",
    "Klub der \u00d6sterreichischen Volkspartei; Parlamentsklub der \u00d6sterreichischen Volkspartei",
    "Klub des Linksblocks (Kommunisten und Linkssozialisten)",
    "Klub von NEOS und LIF; Klub von NEOS",
    "Klub von NEOS; NEOS Parlamentsklub",
    "Liste Pilz",
    "NEOS Parlamentsklub",
    "Parlamentarischer Klub des Heimatblocks",
    "Parlamentsklub JETZT",
    "Parlamentsklub Liberales Forum",
    "Parlamentsklub Team Stronach",
    "Parlamentsklub der Kommunistischen Partei \u00d6sterreichs",
    "Parlamentsklub der Sozialistischen Partei \u00d6sterreichs; Klub der Sozialistischen Partei \u00d6sterreichs",
    "Parlamentsklub der \u00d6sterreichischen Volkspartei",
    "Parlamentsklub der \u00d6sterreichischen Volkspartei; Klub der \u00d6sterreichischen Volkspartei",
    "Parlamentsklub des BZ\u00d6",
    "Parlamentsklub des Liberalen Forums",
    "Sozialdemokratische Parlamentsfraktion - Klub der sozialdemokratischen Abgeordneten und Bundesr\u00e4te",
    "Sozialdemokratische Vereinigung",
    "Verband der Abgeordneten der Gro\u00dfdeutschen Volkspartei",
    "Verband der Abgeordneten des Nationalen Wirtschaftsblocks",
    "Verband der Sozialdemokratischen Abgeordneten zum Nationalrat",
    "Verband der Sozialdemokratischen Abgeordneten zum Nationalrat Deutsch\u00f6sterreichs",
    "Verband der Sozialdemokratischen Abgeordneten zum Nationalrat; Verband der Sozialdemokratischen Abgeordneten zum Nationalrat Deutsch\u00f6sterreichs",
    "Verband der deutschnationalen Parteien und weitere deutschnationale Klubs",
    "ohne Fraktionszugeh\u00f6rigkeit",
    "ohne Klubzugeh\u00f6rigkeit"
  )

  checkmate::assert_subset(
    x = parl_group,
    choices = choices_parl_group,
    empty.ok = TRUE
  )

  # party (Wahlpartei)

  vec_parties <- c(
    "Bauernpartei (BP)",
    "B\u00fcndnis Zukunft \u00d6sterreich (BZ\u00d6)",
    "B\u00fcrgerlich-demokratische Partei (BDP)",
    "B\u00fcrgerliche Arbeitspartei (BAP)",
    "Christlichsoziale Partei (CSP)",
    "Die Freiheitlichen in K\u00e4rnten - BZ\u00d6 (BZ\u00d6K)",
    "Die Freiheitlichen in K\u00e4rnten - Liste Gerhard D\u00f6rfler (FPK)",
    "Die Gr\u00fcnen (Gr\u00fcne)",
    "Freiheitliche Partei \u00d6sterreichs (FP\u00d6)",
    "Gro\u00dfdeutsche Vereinigung (GdP)",
    "Gro\u00dfdeutsche Volkspartei (GdP)",
    "Heimatblock (HB)",
    "J\u00fcdisch-Nationale Partei (JNP)",
    "Kommunisten und Linkssozialisten (KuL)",
    "Kommunistische Partei \u00d6sterreichs (KP\u00d6)",
    "Landbund (LBd)",
    "Liberales Forum (L)",
    "Linksblock (LB)",
    "Liste Fritz Dinkhauser - FRITZ (FRITZ)",
    "Liste Peter Pilz (PILZ)",
    "NEOS - Das neue \u00d6sterreich und Liberales Forum (NEOS)", #REVISE
    "Nationaler Wirtschaftsblock (NWB)",
    "\u00d6sterreichische Volkspartei (\u00d6VP)",
    "Sozialdemokratische Arbeiterpartei Deutsch\u00f6sterreichs (SdP)",
    "Sozialdemokratische Partei \u00d6sterreichs (SP\u00d6)",
    "Sozialistische Partei \u00d6sterreichs (SP\u00d6)",
    "Team Frank Stronach - Frank (STRONA)",
    "Tschechische Partei (TS)",
    "Volksopposition (VO)",
    "Wahlpartei der Unabh\u00e4ngigen (WdU)",
    "ohne Parteizugeh\u00f6rigkeit (OP)"
  )

  choices_party <- stringr::str_extract(vec_parties, "(?<=\\().+?(?=\\))")

  checkmate::assert_subset(
    x = party,
    choices = choices_party,
    empty.ok = TRUE,
    .var.name = "Party argument must be one of the valid party abbreviations. See function documentation for valid values."
  )

  if (!is.null(party)) {
    search_OR <- glue::glue("({party})") %>% stringr::str_c(collapse = "|")
    party <- stringr::str_subset(vec_parties, stringr::regex(search_OR))
  }

  # state
  choices_state <- c(
    "Bundeswahlvorschlag",
    "Burgenland",
    "K\u00e4rnten",
    "Nieder\u00f6sterreich",
    "Ober\u00f6sterreich",
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
    "Burgenland S\u00fcd",
    "Deutsch-S\u00fcdtirol",
    "Flachgau/Tennengau",
    "Graz",
    "Graz und Umgebung",
    "Hausruckviertel",
    "Innsbruck-Land",
    "Innviertel",
    "Klagenfurt",
    "K\u00e4rnten",
    "K\u00e4rnten Ost",
    "K\u00e4rnten West",
    "Lienz",
    "Linz und Umgebung",
    "Lungau/Pinzgau/Pongau",
    "Mittel- und Untersteier",
    "Mostviertel",
    "M\u00fchlviertel",
    "Nieder\u00f6sterreich",
    "Nieder\u00f6sterreich Mitte",
    "Nieder\u00f6sterreich Ost",
    "Nieder\u00f6sterreich S\u00fcd",
    "Nieder\u00f6sterreich S\u00fcd-Ost",
    "Nordtirol",
    "Oberland",
    "Obersteiermark",
    "Ober\u00f6sterreich",
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
    "Steiermark S\u00fcd",
    "Steiermark S\u00fcd-Ost",
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
    "Vorarlberg S\u00fcd",
    "Wahlkreisverband I (Burgenland, Nieder\u00f6sterreich, Wien)",
    "Wahlkreisverband I (Wien)",
    "Wahlkreisverband II (K, O\u00d6, S, St, T u V)",
    "Wahlkreisverband II (Nieder\u00f6sterreich)",
    "Wahlkreisverband III (O\u00d6, S, T u. V)",
    "Wahlkreisverband III - Ober\u00f6sterreich",
    "Wahlkreisverband III - Salzburg",
    "Wahlkreisverband III - Tirol",
    "Wahlkreisverband IV (B, K u St.)",
    "Wahlkreisverband IV - Burgenland",
    "Wahlkreisverband IV - K\u00e4rnten",
    "Wahlkreisverband IV - Steiermark",
    "Waldviertel",
    "Weinviertel",
    "Weststeiermark",
    "Wien",
    "Wien Innen-Ost",
    "Wien Innen-S\u00fcd",
    "Wien Innen-West",
    "Wien Nord",
    "Wien Nord-West",
    "Wien Nordost",
    "Wien Nordwest",
    "Wien S\u00fcd",
    "Wien S\u00fcd-West",
    "Wien S\u00fcdost",
    "Wien S\u00fcdwest",
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
  ) %>%
    purrr::compact() %>%
    jsonlite::toJSON()

  res <- httr2::request(
    "https://www.parlament.gv.at/Filter/api/filter/data/409"
  ) %>%
    httr2::req_method("POST") %>%
    httr2::req_url_query(
      `1` = "1",
      page = "1",
      pagesize = "10000", #IMPROVE
      search = search_string,
      # showAll = "true",
      sortrnr = "1",
      ascDesc = "ASC"
    ) %>%
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
    ) %>%
    httr2::req_body_raw(
      body_params,
      # '{"ATTR_JSON.mandate_detail.gp_text_full_short":["ab 24.10.2024: XXVIII. Gesetzgebungsperiode"]}',
      type = "application/json"
    ) %>%
    httr2::req_perform()

  # new format of returned data

  li_res <- res %>%
    httr2::resp_body_json() %>%
    purrr::pluck("rows") %>%
    purrr::map(\(x) x[[8]])

  df_res <- li_res %>%
    purrr::map(fn_make_tibble) %>%
    purrr::list_rbind()

  # PRINT ECHO
  #echo only if query without date fitler
  if (echo == TRUE && is.null(date)) {
    print(body_params)
    # print url to results / transparency reasons / add search string parameter
    body_params_li <- jsonlite::fromJSON(body_params) %>%
      c("search" = search_string)

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

  # UNNEST DATA
  # needed for date filtering
  # needed to keep only mandates pertaining to legilsative relevant legislative period

  # return(df_res) #REMOVE

  df_res <- df_res %>%
    tidyr::unnest_longer("mandate_detail") %>%
    tidyr::unnest_wider("mandate_detail", names_sep = "_") %>%
    dplyr::mutate(
      across(
        c("mandate_detail_mandat_von", "mandate_detail_mandat_bis"),
        function(x) {
          lubridate::dmy(x)
        }
      )
    ) %>%
    dplyr::mutate(
      mandate_detail_mandat_bis_cutoff = dplyr::case_when(
        is.na(.data$mandate_detail_mandat_bis) |
          .data$mandate_detail_mandat_bis == "" ~
          lubridate::today(),
        .default = .data$mandate_detail_mandat_bis
      )
    )

  # Recode gender variable
  df_res <- df_res %>%
    dplyr::mutate(
      geschlecht = dplyr::case_when(
        .data$geschlecht == "W" ~ "female",
        .data$geschlecht == "M" ~ "male",
        .default = .data$geschlecht
      )
    )

  # Apply filters only when arguments are not NULL
  if (!is.null(institution)) {
    df_res <- df_res %>%
      dplyr::filter(.data$mandate_detail_gremium_name %in% institution_input)
  }

  if (!is.null(legis_period)) {
    df_res <- df_res %>%
      dplyr::mutate(
        mandate_detail_gp_code_chr = aux_convert_legis_periods(
          .data$mandate_detail_gp_code
        )
      ) %>%
      dplyr::filter(
        .data$mandate_detail_gp_code_chr %in% {{ legis_period_char }}
      )
  }

  # DATE FILTERING##################################
  if (!is.null(date)) {
    date_filter <- lubridate::dmy(date)
    # print(nrow(df_res_filter_time_inst))
    df_res <- df_res %>%
      dplyr::filter(
        date_filter >= .data$mandate_detail_mandat_von &
          date_filter <= .data$mandate_detail_mandat_bis_cutoff
      )
    # print(nrow(df_res))
  }

  ### SELECT COLUMNS/REARRANGING
  cols_keep <- c(
    "pad_intern",
    "mandate_detail_gp_code",

    "zit",
    "fruehere_namen_nvg",
    # "fraktionen", #refers to all mandates; not only the filtered ones
    # "frak", #refers to all mandates; not only the filtered ones
    "geschlecht",
    "uri",
    "mandate_detail_fraktion",
    "mandate_detail_wahlkreis_bundesland",
    "mandate_detail_wahlkreis",

    "mandate_detail_wahlkreis_code",
    "mandate_detail_gremium_name",
    "mandate_detail_mand_code",
    # "mandate_detail_wahlpartei_full_txt",
    "mandate_detail_wahlpartei_txt",
    "mandate_detail_politische_partei_code",
    "mandate_detail_mandat_von",
    "mandate_detail_mandat_bis",
    "nrbr_praes"
    # "aktiv",
  )

  df_res <- df_res %>%
    dplyr::select(any_of(cols_keep))

  # RENAME OUTPUT TO ENGLISH
  renaming_map <- c(
    "zit" = "name",
    "geschlecht" = "gender",
    "uri" = "link",
    "mandate_detail_fraktion" = "parl_group", #parl_group_code missing
    "mandate_detail_wahlkreis_bundesland" = "electoral_district_state",
    "mandate_detail_wahlkreis" = "electoral_district_region",
    "mandate_detail_wahlkreis_code" = "electoral_district_region_code",
    "mandate_detail_gremium_name" = "chamber",
    "mandate_detail_mand_code" = "chamber_code",
    "mandate_detail_gp_code" = "legis_period",
    "mandate_detail_wahlpartei_txt" = "party",
    "mandate_detail_politische_partei_code" = "party_code",
    "mandate_detail_mandat_von" = "mandate_date_start",
    "mandate_detail_mandat_bis" = "mandate_date_end",
    "fruehere_namen_nvg" = "name_previous"

    # "mandate_detail_wahlpartei_full_txt",
    # "nrbr_praes",
    # "aktiv",

    #   / "wahlkreis_bundesland" = "electoral_state",
    #  / "wahlkreis" = "electoral_district_region",
    #   / "wahlkreis_code" = "electoral_district_region_code",
    #  / "gremium_name" = "chamber",
    #   /"mand_code" = "chamber_code",
    #   /"politische_partei" = "party",
    #   /"wahlpartei_txt" = "party_name",
    #   "fraktion" = "parl_group",
    #   /"fraktionscode" = "parl_group_code",
    #   /"mandat_von" = "mandate_date_start", #drop
    #   /"mandat_bis" = "mandate_date_end" #drop

    # "wahlpartei_code" = "party", #drop
    # "fraktionscode" = "", #drop?
    # "gp_von" = "", #drop
    # "gp_code" = "", #drop
    # "wahlpartei_txt" = "", #drop
    # "wahlpartei_sort" = "" #drop
  )

  df_res <- df_res %>%
    dplyr::rename_with(
      .fn = \(x) renaming_map[x], # For each selected old name, get its new name from the map
      .cols = any_of(names(renaming_map))
    )

  # SORT (most recent mandate on top)
  df_res <- df_res %>%
    dplyr::group_by(.data$pad_intern) %>%
    dplyr::arrange(desc(.data$mandate_date_start), .by_group = TRUE)

  # NESTING (return one row per MP and legislative period; mandate details are nested)
  df_res <- df_res %>%
    tidyr::nest(
      mp_details = -c("legis_period", "pad_intern", "link", "name", "gender")
    )

  if (!is.null(date)) {
    df_res <- df_res %>%
      dplyr::mutate(date = parsed_date) %>%
      dplyr::relocate("date")
  }

  return(df_res)

  #DATE FILTERING##################################
  # if date is provided, filter results by date
  # result should only contain mandates which are also within institutional scope.
  # otherwise possible that former NR MP who has BR mandate in relevant date is kept

  if (!is.null(date)) {
    #unnest mandates
    df_res_filter_time <- df_res %>%
      dplyr::select("pad_intern", "mandate_detail") %>%
      tidyr::unnest_longer("mandate_detail") %>%
      tidyr::unnest_wider("mandate_detail") %>%
      dplyr::mutate(
        across(c("mandat_von", "mandat_bis"), \(x) lubridate::dmy(x))
      ) %>%
      dplyr::relocate("mandat_bis", .after = "mandat_von")

    #active mandates: set mandat_bis to today
    df_res_filter_time <- df_res_filter_time %>%
      dplyr::mutate(
        mandat_bis = dplyr::case_when(
          is.na(.data$mandat_bis) | .data$mandat_bis == "" ~ lubridate::today(),
          .default = .data$mandat_bis
        )
      )

    # return(df_res_filter_time)

    #filter mandates by institution
    if (!is.null(institution) && institution == "NR") {
      df_res_filter_time_inst <- df_res_filter_time %>%
        dplyr::filter(.data$gremium_name == "Nationalrat")
    } else if (!is.null(institution) && institution == "BR") {
      df_res_filter_time_inst <- df_res_filter_time %>%
        dplyr::filter(.data$gremium_name == "Bundesrat")
    } else if (!is.null(institution) && institution == "KN") {
      df_res_filter_time_inst <- df_res_filter_time %>%
        dplyr::filter(
          .data$gremium_name == "Konstituierende Nationalversammlung"
        )
    } else if (!is.null(institution) && institution == "PN") {
      df_res_filter_time_inst <- df_res_filter_time %>%
        dplyr::filter(.data$gremium_name == "Provisorische Nationalversammlung")
    } #PENDING: what about Bundesrat1Rep; not mentioned on Parl Website/API

    if (!is.null(date)) {
      date <- lubridate::dmy(date)
      # print(nrow(df_res_filter_time_inst))
      df_res <- df_res_filter_time_inst %>%
        dplyr::filter(date >= .data$mandat_von & date <= .data$mandat_bis)
      # print(nrow(df_res))
    }

    ##############################
    # GET NAMES OF MPS (needed to get name of MP at specific date)
    pb_id <- cli::cli_progress_bar(
      "Fetching MPs' names at specific date",
      total = length(df_res$pad_intern),
      format = "{cli::pb_spin} Fetching MPs' names at specific date {cli::pb_current}/{cli::pb_total} | ETA: {cli::pb_eta}",
      format_done = "Fetched {cli::pb_total} MPs' names.",
      clear = FALSE
    )

    df_names <- map2(df_res$pad_intern, format(date, "%d/%m/%Y"), \(x, y) {
      cli::cli_progress_update(id = pb_id)
      name_result <- get_names(x, date = y)
      if (is.data.frame(name_result) && nrow(name_result) > 0) {
        # Collapse multiple names into single string separated by " / "
        name_result %>%
          dplyr::select("pad_intern", "name") %>%
          dplyr::mutate(name = paste(.data$name, collapse = "/"))
      } else {
        NULL
      }
    }) %>%
      purrr::list_rbind()

    df_res <- df_res %>%
      dplyr::left_join(df_names, by = "pad_intern") %>%
      dplyr::relocate("name", .after = "pad_intern")
    ##############################

    # CHECK legis_perios is null here since we are filtering for dates in
    # the parent condition
    if (!is.null(legis_period) && institution == "NR") {
      # print(nrow(df_res_filter_time_inst))
      # print(legis_period)
      # return(df_res_filter_time_inst)
      df_res <- df_res_filter_time_inst %>%
        dplyr::filter(as.roman(.data$gp_code) %in% as.roman(legis_period))
      # print(nrow(df_res))
    } #possible that MPs has multiple mandates in the same chamber during the legislative period; needs nesting

    #filter by date
    #df_dates_check <- data.frame(dates_check = lubridate::dmy(date))

    #keep only mandates which cover date
    # x <- y <- NULL # Silence R CMD check note
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

    #RENAME OUTPUT TO ENGLISH
    renaming_map <- c(
      "wahlkreis_bundesland" = "electoral_state",
      "wahlkreis" = "electoral_district_region",
      "wahlkreis_code" = "electoral_district_region_code",
      "gremium_name" = "chamber",
      "mand_code" = "chamber_code",
      "politische_partei" = "party",
      "wahlpartei_txt" = "party_name",
      "fraktion" = "parl_group",
      "fraktionscode" = "parl_group_code",
      "mandat_von" = "mandate_date_start", #drop
      "mandat_bis" = "mandate_date_end" #drop
      # "wahlpartei_code" = "party", #drop
      # "fraktionscode" = "", #drop?
      # "gp_von" = "", #drop
      # "gp_code" = "", #drop
      # "wahlpartei_txt" = "", #drop
      # "wahlpartei_sort" = "" #drop
    )

    df_res <- df_res %>%
      dplyr::rename_with(
        .fn = \(x) renaming_map[x], # For each selected old name, get its new name from the map
        .cols = any_of(names(renaming_map))
      ) %>%
      dplyr::select(
        "pad_intern",
        "name",
        "chamber",
        "chamber_code",
        "electoral_state",
        "electoral_district",
        "electoral_district_region_code",
        "party",
        "party_name",
        "parl_group",
        "parl_group_code",
        "mandate_date_start",
        "mandate_date_end"
      )

    # return(df_res)
  }

  return(df_res)
}
