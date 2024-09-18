#' get_mps
#'
#' The `get_mps` searches the database on all Members of Parliament since 1918. It mirrors the search functionality 'Parlamentarier:innen ab 1918'
#' on the website of the Austrian Parliament (see [here](https://www.parlament.gv.at/recherchieren/personen/parlamentarierinnen-ab-1848/parlamentarierinnen-ab-1918))
#' Does not allow searching for specific name(s).
#'
#' @param institution
#' @param gender
#' @param legis_period *Gesetzgebungsperiode*
#' @param parl_group *Fraktion*
#' @param party *Wahlpartei* defaults to "all" possible values:  all (*'Alle Wahlparteien'*), BP (*'Bauernpartei'*), BZÖ (*'Bündnis Zukunft Österreich'*), BAP (*'Bürgerliche Arbeitspartei'*), CSP (*'Christlichsoziale Partei'*), Grüne (*'Die Grünen'*), FPÖ (*'Freiheitliche Partei Österreichs'*), GdP (*'Großdeutsche Volkspartei'*), HB (*'Heimatblock'*), KuL (*'Kommunisten und Linkssozialisten'*), KPÖ (*'Kommunistische Partei Österreichs'*), LBd (*'Landbund'*), L (*'Liberales Forum'*), LB (*'Linksblock'*), PILZ (*'Liste Peter Pilz'*), NWB (*'Nationaler Wirtschaftsblock'*), NEOS (*'NEOS - Das neue Österreich und Liberales Forum'*), ÖVP (*'Österreichische Volkspartei'*), SdP (*'Sozialdemokratische Arbeiterpartei Deutschösterreichs'*), SPÖ (*'Sozialistische Partei Österreichs'*), SPÖ (*'Sozialdemokratische Partei Österreichs'*), STRONA (*'Team Frank Stronach - Frank'*), VO (*'Volksoppostition'*), WdU (*'Wahlpartei der Unabhängigen'*)
#' @param electoral_district Documentation not clear; search only on level of Bundesland;
#'
#' @param presidents_only
#' @param make_unique Default is FALSE. If TRUE output contains only one single row per MP. Name variants are nested into a list.
#'
#' @return
#' @export
#'
#' @details
#''
#'
#' @examples
get_mps_single <- function(institution = institution,
                    gender = gender,
                    legis_period = legis_period,
                    party = party,
                    parl_group = parl_group,
                    electoral_district =electoral_district,
                    state=state,
                    presidents_only = presidents_only,
                    make_unique = make_unique) {


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

  if (!(is.numeric(legis_period) ||
        legis_period %in% c("all",
      "Provisorische Nationalversammlung",
      "Konstituierende Nationalversammlung"
    )
  )) {
    stop(
      "Invalid input for legis_period. Must be a numeric value or one of 'all', 'Provisorisch Nationalversammlung', or 'Konstituierende Nationalversammlung'."
    )
  }

  if (is.numeric(legis_period)) {
    legis_period <- as.character(as.roman(legis_period))
  } else if (legis_period == "all") {
    legis_period <- "ALLE"
  } else {
    legis_period
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
  electoral_district <- purrr::map_chr(electoral_district, \(x) switch(
    x,
    "all" = "ALLE",
    "Bundeswahlvorschlag"="FB",
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
    "Wien Nord" = "F9G")
    )

  body_params <- list(
    M = M,
    #male MPs
    W = W,
    #female MPs
    NRBR = institution,
    GP = legis_period, #ONLY ACCEPTS VECTOR OF LENGTH 1
    WP = party,
    FR = parl_group,
    PR = presidents_only,
    WK = electoral_district
  ) |>
    purrr::compact() |>  #keep only non-empty elements
    jsonlite::toJSON()

  res <- httr2::request("https://www.parlament.gv.at/Filter/api/json/post") |>
    httr2::req_url_query(
      jsMode = "EVAL",
      FBEZ = "WFW_008",
      listeId = "undefined",
      # pageNumber = "1",
      # pagesize = "10",
      showAll = "true",
      feldRnr = "3",
      ascDesc = "ASC",
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
    httr2::req_verbose(body_req = TRUE,
                       header_req = FALSE,
                       header_resp = FALSE) |>
    httr2::req_perform()

  # Extract headings; rename to make more informative
  vec_headings <- res |>
    httr2::resp_body_json(simplifyVector = TRUE) |>
    purrr::pluck("header", "label") |>
    janitor::make_clean_names()

  # extract the actual substantive data
  df_res <- res |>
    httr2::resp_body_json(simplifyVector = TRUE) |>
    purrr::pluck("rows") |>
    as.data.frame()

  if (nrow(df_res) == 0) {
    message("No results found for the given search criteria.")
    return(NULL)
  }

  colnames(df_res) <- vec_headings

  df_res <- df_res |>
    dplyr::select(-sortier)

  # #rename to english and make names more informative
  # df_res <- df_res |>
  #   dplyr::rename(
  #     party=wahlpartei,
  #     electoral_district=bundesland
  #   )

  if (make_unique == TRUE) {
    df_res <- df_res |>
      dplyr::group_by(across(-all_of("name"))) |>
      dplyr::summarise(name = list(name), name_variants_n = dplyr::n()) |>
      dplyr::ungroup() |>
      dplyr::relocate(c(name, name_variants_n), .after = 1)
  }

  #parse html content in fraktion, gesetzgebungsperiode, bundesland
  df_res <- df_res |>
    dplyr::mutate(across(any_of(c("fraktion", "bundesland", "gesetzgebungsperioden")), \(x) purrr::map(x, \(y) aux_parse_html_text(html=y))))

  print(nrow(df_res))

  return(df_res)

}


#' Title
#'
#' @param institution
#' @param gender
#' @param legis_period
#' @param party
#' @param parl_group
#' @param electoral_district
#' @param state
#' @param presidents_only
#' @param make_unique
#'
#' @return
#' @export
#'
#' @examples
get_mps <- function(institution = c("all", "Bundesrat", "Nationalrat"),
                             gender = c("all", "female", "male"),
                             legis_period = "all",
                             party = c(
                               "all", "BP","BZÖ","BAP","CSP","Grüne","FPÖ","GdP","HB","KuL","KPÖ","LBd","L","LB","PILZ","NWB","NEOS",
                               "ÖVP","SdP","SPÖ","SPÖ","STRONACH","VO","WdU"),
                             parl_group = c(
                               "all","LBd","CSP","GRÜNE","SPÖ","F-BZÖ","GdP","F","FPÖ","KuL","VO","WdU","LB","NEOS-LIF","PILZ",
                               "NEOS","OK","HB","KPÖ","ÖVP","BZÖ","JETZT","L","STRONACH","NWB","SdP"
                             ),
                             electoral_district = c(
                               "all",

                               "Bundeswahlvorschlag",

                               "Burgenland","Kärnten","Niederösterreich","Oberösterreich","Salzburg","Steiermark",
                               "Tirol","Vorarlberg","Wien","Burgenland Nord","Burgenland Süd","Klagenfurt","Villach",

                               "Kärnten West","Kärnten Ost",
                               "Weinviertel","Waldviertel","Mostviertel","Niederösterreich Mitte","Niederösterreich Süd","Thermenregion","Niederösterreich Ost",
                               "Linz und Umgebung","Innviertel","Hausruckviertel","Traunviertel","Mühlviertel",
                               "Salzburg Stadt","Flachgau/Tennengau","Lungau/Pinzgau/Pongau",
                               "Graz und Umgebung","Oststeiermark","Weststeiermark","Obersteiermark",
                               "Innsbruck","Innsbruck-Land","Unterland","Oberland","Osttirol",
                               "Vorarlberg Nord","Vorarlberg Süd",
                               "Wien Innen-Süd","Wien Innen-West","Wien Innen-Ost","Wien Süd","Wien Süd-West","Wien Nord-West","Wien Nord"),

                             state=NULL,

                             presidents_only = FALSE,
                             make_unique = FALSE){


li_mps <- purrr::map(legis_period, \(x) get_mps_single(legis_period=x, institution=institution, gender=gender, party=party,
                                         parl_group=parl_group, electoral_district=electoral_district,state=state,
                                         presidents_only=presidents_only, make_unique=make_unique), .progress="Get MPs")
li_mps |> purrr::list_rbind()


}


