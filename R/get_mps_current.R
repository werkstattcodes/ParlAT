#' Get Current Members of Parliament
#'
#' @description
#' Fetches current members of parliament based on provided search criteria. Depending on the
#' chamber of interest, different search parameters are applicable.
#'
#' @param institution Character. The parliamentary institution, accepted values are "NR" (Nationalrat, National
#' Council) or "BR" (Bundesrat, Federal Council). Note that "NR" and "BR" return all positions in the respective chamber,
#' including presidents, secretaries etc.
#' @param gender Character. Gender filter to apply; options are "all", "female", or "male". Default is "all".
#' @param position Character. Position filter. For National Council (NR), acceptable values are:
#'   \itemize{
#'     \item "all": Alle Abgeordnete (all members of parliament)
#'     \item "1PNR": Präsident des Nationalrates (President of the National Council)
#'     \item "2PNR": Zweiter Präsident des Nationalrates (Second President of the National Council)
#'     \item "3PNR": Dritter Präsident des Nationalrates (Third President of the National Council)
#'     \item "PRAES": Präsidialkonferenz (Presidential Conference)
#'     \item "ZON":  Ordner des Nationalrates (Regulators of the National Council)
#'     \item "ZSN": Schriftführer des Nationalrates (Secretary of the National Council)
#'   }
#'   For Federal Council (BR), acceptable values are:
#'   \itemize{
#'     \item "all": Alle Mitglieder des Bundesrates (All Members of the Federal Council)
#'     \item "PB": Präsident des Bundesrates (President of the Federal Council)
#'     \item "SPB": Vizepräsident des Bundesrates (Vice-President of the Federal Council)
#'     \item "PRAES": Präsidialkonferenz (Presidential Conference)
#'     \item "ZOB": Ordner des Bundesrates (Usher/Sergeant-at-Arms of the Federal Council)
#'     \item "ZSB": Schriftführer des Bundesrates (Secretary/Scrutineer of the Federal Council)
#'   }
#' @param party Character vector of length 1. For National Council, acceptable values include
#'   "all", "SPÖ", "ÖVP", "FPÖ", "GRÜNE", "NEOS", and historical parties.
#'   For Federal Council, acceptable values are:
#'   \itemize{
#'     \item "all": Alle Wahlparteien (All Electoral Parties)
#'     \item "GRÜNE": Die Grünen (The Greens)
#'     \item "FPÖ": Freiheitliche Partei Österreichs (Freedom Party of Austria)
#'     \item "NEOS": NEOS - Das neue Österreich und Liberales Forum
#'     \item "ÖVP": Österreichische Volkspartei (Austrian People's Party)
#'     \item "SPÖ": Sozialdemokratische Partei Österreichs (Social Democratic Party of Austria)
#'   }
#' @param parl_group Character vector of length 1. Parliamentary group filter.
#' For *National Council*, acceptable values are:
#'   \itemize{
#'     \item "all": All parliamentary groups
#'     \item "LBd": Landbund
#'     \item "CSP": Christlichsoziale Partei
#'     \item "GRÜNE": Die Grünen
#'     \item "SPÖ": Sozialdemokratische Partei Österreichs
#'     \item "F-BZÖ": Freiheitliche und Bündnis Zukunft Österreich
#'     \item "GdP": Großdeutsche Partei
#'     \item "F": Freiheitliche
#'     \item "FPÖ": Freiheitliche Partei Österreichs
#'     \item "KuL": Kunst und Leben
#'     \item "VO": Völkische Opposition
#'     \item "WdU": Wahlpartei der Unabhängigen
#'     \item "LB": Landbund
#'     \item "NEOS-LIF": NEOS – Das Neue Österreich und Liberales Forum
#'     \item "PILZ": Liste Peter Pilz
#'     \item "NEOS": NEOS – Das Neue Österreich
#'     \item "OK": Ohne Klub/Without parliamentary group
#'     \item "HB": Heimatblock
#'     \item "KPÖ": Kommunistische Partei Österreichs
#'     \item "ÖVP": Österreichische Volkspartei
#'     \item "BZÖ": Bündnis Zukunft Österreich
#'     \item "JETZT": Liste Jetzt
#'     \item "L": Liberale
#'     \item "STRONACH": Team Stronach
#'     \item "NWB": Nationale Wahlbewegung
#'     \item "SdP": Sudetendeutsche Partei
#'   }
#'   For *Federal Council*, acceptable values are:
#'   \itemize{
#'     \item "all": Alle Fraktionen (All Parliamentary Groups)
#'     \item "ÖVP": Bundesratsfraktion der ÖVP
#'     \item "SPÖ": Bundesratsfraktion der SPÖ
#'     \item "FPÖ": Freiheitliche Bundesratsfraktion
#'     \item "GRÜNE": Grüne Fraktion im Bundesrat
#'     \item "OF": ohne Fraktionszugehörigkeit (Without Parliamentary Group Affiliation)
#'   }
# @param postal_code Character or numeric vector of length 1. Four digit postal code filter.
#   Only applicable for National Council (NR).
#' @param state Character vector of length 1. For National Council, acceptable values include
#'   "all", "B", "K", "N", "O", "S", "St", "T", "V", "W", and "BWV".
#'   For Federal Council, acceptable values are:
#'   \itemize{
#'     \item "all": Alle Bundesländer (All Federal States)
#'     \item "B": Burgenland
#'     \item "K": Kärnten (Carinthia)
#'     \item "N": Niederösterreich (Lower Austria)
#'     \item "O": Oberösterreich (Upper Austria)
#'     \item "S": Salzburg
#'     \item "St": Steiermark (Styria)
#'     \item "T": Tirol (Tyrol)
#'     \item "V": Vorarlberg
#'     \item "W": Wien (Vienna)
#'   }
#' @param electoral_district Character vector of length 1. Electoral district filter.
#'   Only applicable for National Council (NR). Valid electoral districts are:
#'   \itemize{
#'     \item "ALLE": Alle Wahlkreise (All Constituencies)
#'     \item "FB": Bundeswahlvorschlag (Federal Electoral Proposal)
#'     \item "F1": Burgenland
#'     \item "F1A": Burgenland Nord (Burgenland North)
#'     \item "F1B": Burgenland Süd (Burgenland South)
#'     \item "F5B": Flachgau/Tennengau
#'     \item "F6A": Graz und Umgebung (Graz and Surroundings)
#'     \item "F4C": Hausruckviertel
#'     \item "F7A": Innsbruck
#'     \item "F7B": Innsbruck-Land (Innsbruck-Country)
#'     \item "F4B": Innviertel
#'     \item "F2": Kärnten (Carinthia)
#'     \item "F2D": Kärnten Ost (Carinthia East)
#'     \item "F2C": Kärnten West (Carinthia West)
#'     \item "F2A": Klagenfurt
#'     \item "F4A": Linz und Umgebung (Linz and Surroundings)
#'     \item "F5C": Lungau/Pinzgau/Pongau
#'     \item "F3C": Mostviertel
#'     \item "F4E": Mühlviertel
#'     \item "F3": Niederösterreich (Lower Austria)
#'     \item "F3D": Niederösterreich Mitte (Lower Austria Central)
#'     \item "F3G": Niederösterreich Ost (Lower Austria East)
#'     \item "F3E": Niederösterreich Süd (Lower Austria South)
#'     \item "F0": noch offen (still open/pending)
#'     \item "F7D": Oberland (Oberland/Upper Country)
#'     \item "F4": Oberösterreich (Upper Austria)
#'     \item "F6D": Obersteiermark (Upper Styria)
#'     \item "F6B": Oststeiermark (East Styria)
#'     \item "F7E": Osttirol (East Tyrol)
#'     \item "F5": Salzburg
#'     \item "F5A": Salzburg Stadt (Salzburg City)
#'     \item "F6": Steiermark (Styria)
#'     \item "F3F": Thermenregion (Thermal Region)
#'     \item "F7": Tirol (Tyrol)
#'     \item "F4D": Traunviertel
#'     \item "F7C": Unterland (Unterland/Lower Country)
#'     \item "F2B": Villach
#'     \item "F8": Vorarlberg
#'     \item "F8A": Vorarlberg Nord (Vorarlberg North)
#'     \item "F8B": Vorarlberg Süd (Vorarlberg South)
#'     \item "F3B": Waldviertel
#'     \item "F3A": Weinviertel
#'     \item "F6C": Weststeiermark (West Styria)
#'     \item "F9": Wien (Vienna)
#'     \item "F9C": Wien Innen-Ost (Vienna Inner-East)
#'     \item "F9A": Wien Innen-Süd (Vienna Inner-South)
#'     \item "F9B": Wien Innen-West (Vienna Inner-West)
#'     \item "F9G": Wien Nord (Vienna North)
#'     \item "F9F": Wien Nord-West (Vienna North-West)
#'     \item "F9D": Wien Süd (Vienna South)
#'     \item "F9E": Wien Süd-West (Vienna South-West)
#'   }
#' @param echo Logical. Whether to print debug information. Default is TRUE.
#'
#' @return A data frame containing the list of current members of parliament that match the search criteria with the following columns:
#' - `time_stamp`: Timestamp of when the data was retrieved
#' - `pad_intern`: Person's unique identification number
#' - `name`: Full name of the MP
#' - `gender`: Gender of the MP
#' - `parl_group`: Full name of the parliamentary group
#' - `parl_group_code`: Code/abbreviation of the parliamentary group
#' - `party_name`: Full name of the political party
#' - `party_code`: Code/abbreviation of the political party
#' - `state`: Federal state (Bundesland)
#' - `electoral_district_region_code`: Electoral district region code
#' - `chamber`: Chamber of Parliament ("NR" or "BR")
#'
#' Returns a zero-row tibble with the documented columns if no results are found.
#'
#' @examples
#' \donttest{
#'   # Get all current National Council members
#'   nr_members <- get_mps_current(institution = "NR")
#'   dplyr::glimpse(nr_members)
#'
#'   # Get female Federal Council members from Vienna
#'   br_female_vienna <- get_mps_current(
#'     institution = "BR",
#'     gender = "female",
#'     state = "W"
#'   )
#'   dplyr::glimpse(br_female_vienna)
#'
#'   # Get SPÖ members from National Council
#'   spo_nr <- get_mps_current(
#'     institution = "NR",
#'     party = "SPÖ"
#'   )
#'   dplyr::glimpse(spo_nr)
#' }
#'
#' @export
get_mps_current <- function(
    institution,
    gender = "all",
    position = NULL,
    party = NULL,
    parl_group = NULL,
    #postal_code = NULL,
    state = NULL,
    electoral_district = NULL,
    echo = TRUE
) {
    # Validate institution parameter
    checkmate::assert_choice(
        institution,
        choices = c("NR", "BR"),
        null.ok = FALSE
    )

    if (institution == "NR") {
        df_NR <- get_mps_NR_current(
            institution = institution,
            gender = gender,
            position = position,
            party = party,
            parl_group = parl_group,
            # postal_code = postal_code,
            state = state,
            electoral_district = electoral_district,
            echo = echo
        )

        if (is.null(df_NR) || nrow(df_NR) == 0) {
            return(.empty_mps_current_tibble())
        }

        df_NR <- df_NR %>%
            dplyr::mutate(time_stamp = Sys.time()) #add timestamp to make 'current' specific

        #Parse output; get meaningful column names
        df_res <- df_NR %>%
            dplyr::mutate(
                parl_group = purrr::map_chr(.data$klub, function(x) aux_parse_html_title(x)),
                state = purrr::map_chr(
                    .data$bundesland,
                    function(x) aux_parse_html_title(x)
                ),
                pad_intern = stringr::str_extract(
                    .data$link,
                    stringr::regex("[0-9]+$")
                ), #extract pad_intern from link
                electoral_district_region_code = stringr::str_extract(
                    .data$wahlkreis,
                    stringr::regex("^\\w+")
                ),
                electoral_district_region = .data$wahlkreis %>%
                    as.character() %>%
                    stringr::str_remove(stringr::regex("^\\w+")) %>%
                    stringr::str_trim("both") #,
                # name2 = map_chr(rss_description, \(x) aux_extract_name(x)) #name now called via get_names
            ) %>%
            dplyr::select(
                "time_stamp",
                "name",
                # name2,
                "pad_intern",
                party = "sort_wp",
                "parl_group",
                "electoral_district_region_code",
                "electoral_district_region",
                "state",
                "link"
            ) %>%
            dplyr::as_tibble()

        # Add MP names for the specified date #CHECK
        # df_res <- df_res %>%
        #     dplyr::mutate(
        #         name = purrr::map2_chr(
        #             pad_intern,
        #             format(date, "%d/%m/%Y"),
        #             ~ {
        #                 name_result <- get_names(.x, date = .y)
        #                 if (
        #                     is.data.frame(name_result) && nrow(name_result) > 0
        #                 ) {
        #                     # Collapse multiple names into single string separated by " / "
        #                     paste(name_result$name, collapse = " / ")
        #                 } else {
        #                     NA_character_
        #                 }
        #             }
        #         ),
        #         .after = pad_intern
        #     )

        # return(df_NR)
    } else if (institution == "BR") {
        # For BR, postal_code and electoral_district are not applicable
        # if (!is.null(postal_code)) {
        #     stop("Postal code filter only applicable for Nationalrat (NR).")
        # }
        if (!is.null(electoral_district)) {
            cli::cli_warn(
                "electoral_district parameter is not applicable for Federal Council (BR) and will be ignored."
            )
        }

        #GET CURRENT BR MEMBERS
        df_res <- get_mps_BR_current(
            gender = gender,
            position = position,
            party = party,
            parl_group = parl_group,
            state = state,
            echo = echo
        )

        if (is.null(df_res) || nrow(df_res) == 0) {
            return(.empty_mps_current_tibble())
        }

        #add/drop/rename columns
        df_res <- df_res %>%
            dplyr::as_tibble() %>%
            dplyr::mutate(
                time_stamp = Sys.time(),
                .before = 1
            ) %>%
            dplyr::mutate(
                parl_group = purrr::map_chr(
                    .data$fraktion,
                    \(x) aux_parse_html_title(x)
                ),
                parl_group_code = purrr::map_chr(
                    .data$fraktion,
                    \(x) {
                        rvest::read_html(x) %>%
                            rvest::html_element("span.zeigeTooltip") %>%
                            rvest::html_text(trim = TRUE)
                    }
                ),
                party_name = purrr::map_chr(.data$wahlpartei, \(x) {
                    aux_parse_html_title(x)
                }),
                party_code = purrr::map_chr(.data$wahlpartei, \(x) {
                    rvest::read_html(x) %>%
                        rvest::html_element("span.zeigeTooltip") %>%
                        rvest::html_text(trim = TRUE)
                })
            ) %>%
            dplyr::rename(
                state = "bundesland",
                electoral_district_region_code = "wahlkreis"
            ) %>%
            dplyr::select(
                -"pad_sortier",
                -"wahlpartei",
                -"fraktion"
            )
    } #CONTINUE  do  order of columns; add chamber column

    ##############################
    # GET NAMES OF MPS (NR and BR) IN FIRST NAME - SECOND NAME FORMAT
    # slows down extraction, but otherwise inconsistencies in name formatting

    if (is.null(df_res)) {
        return(NULL)
    }

    pb_id <- cli::cli_progress_bar(
        "Fetching MPs' names",
        total = length(df_res$pad_intern),
        format = "{cli::pb_spin} Fetching MPs' names {cli::pb_current}/{cli::pb_total} | ETA: {cli::pb_eta}",
        format_done = "Fetched {cli::pb_total} MPs' names.",
        clear = FALSE
    )

    # transient network failures are retried at the httr2 layer (req_retry)
    df_res <- df_res %>%
        dplyr::mutate(
            name = purrr::map_chr(.data$pad_intern, \(pad_id) {
                result <- tryCatch(
                    {
                        name_df <- get_names(pad_intern = pad_id)

                        if (!is.data.frame(name_df) || nrow(name_df) == 0) {
                            NA_character_
                        } else {
                            name_df %>%
                                dplyr::filter(.data$index == 1) %>%
                                dplyr::pull("name")
                        }
                    },
                    error = \(e) NA_character_
                )

                if (is.na(result)) {
                    cli::cli_warn(
                        "Failed to fetch name for pad_intern {pad_id}."
                    )
                }

                cli::cli_progress_update(id = pb_id)
                result
            }),
            .after = 1
        )

    df_res <- df_res %>%
        dplyr::mutate(chamber = institution)

    return(df_res)
}


#' Get Current Members of Parliament
#'
#' @description
#' Fetches current members of parliament based on provided search criteria. Mirrors
#' the search functionality on the Austrian Parliament website at
#' <a href="https://www.parlament.gv.at/recherchieren/personen/nationalrat" target="_blank">here</a>.
#'
#' @param institution Character. The parliamentary institution, accepted values are "NR" (Nationalrat, National
#' Council) or "BR" (Bundesrat, Federal Council).
#' @param gender Character. Gender filter to apply; options are "all", "female", or "male". Default is "all".
#' @param position Character. Position filter with acceptable values:
#'   \itemize{
#'     \item "ALLE": Alle (all members of parliament)
#'     \item "1PNR": Präsident des Nationalrates (President of the National Council)
#'     \item "2PNR": Zweiter Präsident des Nationalrates (Second President of the National Council)
#'     \item "3PNR": Dritter Präsident des Nationalrates (Third President of the National Council)
#'     \item "PRAES": Präsidialkonferenz (Presidential Conference)
#'     \item "ZON":  Ordner des Nationalrates (Regulators of the National Council)
#'     \item "ZSN": Schriftführer des Nationalrates (Secretary of the National Council)
#'   }
#' @param parl_group Character. Parliamentary group filter. See Details below.
#' @param party Character vector of length 1.
# @param postal_code Character or numeric vector of length 1. Four digit postal code filter.
#' @param state Character vector of length 1. See details below
#' @param electoral_district Character vector of length 1. See details below.
#' @details
#' ## parl_group
#' Permissible values are:
#'   \itemize{
#'     \item "all": All parliamentary groups
#'     \item "LBd": Landbund
#'     \item "CSP": Christlichsoziale Partei
#'     \item "GRÜNE": Die Grünen
#'     \item "SPÖ": Sozialdemokratische Partei Österreichs
#'     \item "F-BZÖ": Freiheitliche und Bündnis Zukunft Österreich
#'     \item "GdP": Großdeutsche Partei
#'     \item "F": Freiheitliche
#'     \item "FPÖ": Freiheitliche Partei Österreichs
#'     \item "KuL": Kunst und Leben
#'     \item "VO": Völkische Opposition
#'     \item "WdU": Wahlpartei der Unabhängigen
#'     \item "LB": Landbund
#'     \item "NEOS-LIF": NEOS – Das Neue Österreich und Liberales Forum
#'     \item "PILZ": Liste Peter Pilz
#'     \item "NEOS": NEOS – Das Neue Österreich
#'     \item "OK": Ohne Klub/Without parliamentary group
#'     \item "HB": Heimatblock
#'     \item "KPÖ": Kommunistische Partei Österreichs
#'     \item "ÖVP": Österreichische Volkspartei
#'     \item "BZÖ": Bündnis Zukunft Österreich
#'     \item "JETZT": Liste Jetzt
#'     \item "L": Liberale
#'     \item "STRONACH": Team Stronach
#'     \item "NWB": Nationale Wahlbewegung
#'     \item "SdP": Sudetendeutsche Partei
#'   }
#' ## party
#' Permissible values are:
#'   \itemize{
#'     \item "all": All parties
#'     \item "BP": Bürgerpartei
#'     \item "BZÖ": Bündnis Zukunft Österreich
#'     \item "BAP": Bauernpartei
#'     \item "CSP": Christlichsoziale Partei
#'     \item "Grüne": Die Grünen
#'     \item "FPÖ": Freiheitliche Partei Österreichs
#'     \item "GdP": Großdeutsche Partei
#'     \item "HB": Heimatblock
#'     \item "KuL": Kunst und Leben
#'     \item "KPÖ": Kommunistische Partei Österreichs
#'     \item "LBd": Landbund
#'     \item "L": Liberale
#'     \item "LB": Landbund
#'     \item "PILZ": Liste Peter Pilz
#'     \item "NWB": Nationale Wahlbewegung
#'     \item "NEOS": NEOS – Das Neue Österreich
#'     \item "ÖVP": Österreichische Volkspartei
#'     \item "SdP": Sudetendeutsche Partei
#'     \item "SPÖ": Sozialdemokratische Partei Österreichs
#'     \item "STRONACH": Team Stronach
#'     \item "VO": Völkische Opposition
#'     \item "WdU": Wahlpartei der Unabhängigen
#'   }
#' ## state
#' Permissible values are:
#'   \itemize{
#'     \item "all" (Alle Bundesländer + Bundeswahlvorschlag, All Federal States + Federal Electoral Proposal)
#'     \item "all_states" (Alle Bundesländer, All Federal States)
#'     \item "B" (Burgenland, Burgenland)
#'     \item "K" (Kärnten, Carinthia)
#'     \item "N" (Niederösterreich, Lower Austria)
#'     \item "O" (Oberösterreich, Upper Austria)
#'     \item "S" (Salzburg, Salzburg)
#'     \item "St" (Steiermark, Styria)
#'     \item "T" (Tirol, Tyrol)
#'     \item "V" (Vorarlberg, Vorarlberg)
#'     \item "W" (Wien, Vienna)
#'     \item "BWV" (Bundeswahlvorschlag, Federal Electoral Proposal)
#'   }
#'
#' ## electoral_district
#' Permissible values are:
#'   \itemize{
#'     \item "ALLE" (Alle Wahlkreise, All Constituencies)
#'     \item "FB" (Bundeswahlvorschlag, Federal Electoral Proposal)
#'     \item "F1" (Burgenland, Burgenland)
#'     \item "F1A" (Burgenland Nord, Burgenland North)
#'     \item "F1B" (Burgenland Süd, Burgenland South)
#'     \item "F5B" (Flachgau/Tennengau, Flachgau/Tennengau)
#'     \item "F6A" (Graz und Umgebung, Graz and Surroundings)
#'     \item "F4C" (Hausruckviertel, Hausruckviertel)
#'     \item "F7A" (Innsbruck, Innsbruck)
#'     \item "F7B" (Innsbruck-Land, Innsbruck-Country)
#'     \item "F4B" (Innviertel, Innviertel)
#'     \item "F2" (Kärnten, Carinthia)
#'     \item "F2D" (Kärnten Ost, Carinthia East)
#'     \item "F2C" (Kärnten West, Carinthia West)
#'     \item "F2A" (Klagenfurt, Klagenfurt)
#'     \item "F4A" (Linz und Umgebung, Linz and Surroundings)
#'     \item "F5C" (Lungau/Pinzgau/Pongau, Lungau/Pinzgau/Pongau)
#'     \item "F3C" (Mostviertel, Mostviertel)
#'     \item "F4E" (Mühlviertel, Mühlviertel)
#'     \item "F3" (Niederösterreich, Lower Austria)
#'     \item "F3D" (Niederösterreich Mitte, Lower Austria Central)
#'     \item "F3G" (Niederösterreich Ost, Lower Austria East)
#'     \item "F3E" (Niederösterreich Süd, Lower Austria South)
#'     \item "F0" (noch offen, still open/pending)
#'     \item "F7D" (Oberland, Oberland/Upper Country)
#'     \item "F4" (Oberösterreich, Upper Austria)
#'     \item "F6D" (Obersteiermark, Upper Styria)
#'     \item "F6B" (Oststeiermark, East Styria)
#'     \item "F7E" (Osttirol, East Tyrol)
#'     \item "F5" (Salzburg, Salzburg)
#'     \item "F5A" (Salzburg Stadt, Salzburg City)
#'     \item "F6" (Steiermark, Styria)
#'     \item "F3F" (Thermenregion, Thermal Region)
#'     \item "F7" (Tirol, Tyrol)
#'     \item "F4D" (Traunviertel, Traunviertel)
#'     \item "F7C" (Unterland, Unterland/Lower Country)
#'     \item "F2B" (Villach, Villach)
#'     \item "F8" (Vorarlberg, Vorarlberg)
#'     \item "F8A" (Vorarlberg Nord, Vorarlberg North)
#'     \item "F8B" (Vorarlberg Süd, Vorarlberg South)
#'     \item "F3B" (Waldviertel, Waldviertel)
#'     \item "F3A" (Weinviertel, Weinviertel)
#'     \item "F6C" (Weststeiermark, West Styria)
#'     \item "F9" (Wien, Vienna)
#'     \item "F9C" (Wien Innen-Ost, Vienna Inner-East)
#'     \item "F9A" (Wien Innen-Süd, Vienna Inner-South)
#'     \item "F9B" (Wien Innen-West, Vienna Inner-West)
#'     \item "F9G" (Wien Nord, Vienna North)
#'     \item "F9F" (Wien Nord-West, Vienna North-West)
#'     \item "F9D" (Wien Süd, Vienna South)
#'     \item "F9E" (Wien Süd-West, Vienna South-West)
#'   }
#'
#' @return A data frame containing the list of current members of parliament that match the search criteria.
#'
#' @examples
#' \donttest{
#'   df_members <- get_mps_current(
#'     institution = "Nationalrat",
#'     gender = "female",
#'     party = "SPÖ",
#'     electoral_district = "Wien"
#'   )
#'
#'   if (!is.null(df_members)) {
#'     print(df_members)
#'   }
#' }
#'
#' @importFrom checkmate assert_choice assert_scalar assert_subset
#' @importFrom httr2 request req_method req_perform req_body_raw req_headers req_url_query req_user_agent resp_body_json
#' @importFrom jsonlite toJSON
#' @importFrom purrr map_chr map2_chr compact pluck imap
#' @keywords internal
#' @noRd
get_mps_NR_current <- function(
    institution = NULL,
    gender = "all",
    position = NULL,
    party = NULL,
    parl_group = NULL,
    # postal_code = NULL,
    state = NULL,
    electoral_district = NULL,
    echo = TRUE
) {
    #GENDER
    choices_gender <- c("all", "female", "male")
    checkmate::assert_subset(
        gender,
        choices_gender,
        empty.ok = FALSE
    )
    ## encode

    if (gender == "all") {
        M_input <- "M"
        W_input <- "W"
    } else if (gender == "male") {
        M_input <- "M"
        W_input <- NULL
    } else {
        #exhaustive; must be female
        M_input <- NULL
        W_input <- "W"
    }

    #POSITION
    choices_position <- c(
        "all", #Alle Abgeordnete (All Members of Parliament)
        "1PNR", #Pr\u00e4sidentIn des Nationalrates (President of the National Council)
        "2PNR", #2. Pr\u00e4sidentIn des Nationalrates (Second President of the National Council)
        "3PNR", #3. Pr\u00e4sidentIn des Nationalrates (Third President of the National Council)
        "PRAES", #Pr\u00e4sidialkonferenz (Presidential Conference)
        "ZON", #Ordner des Nationalrates (Regulators of the National Council)
        "ZSN" #Schriftf\u00fchrerIn des Nationalrates (Secretary of the National Council)
    )
    checkmate::assert_subset(
        position,
        choices = choices_position,
        empty.ok = TRUE
    )
    #encode position
    if (!is.null(position) && position == "all") {
        position <- "ALLE"
    }

    #PARTY
    choices_party <- c(
        "all",
        "BP",
        "BZ\u00d6",
        "BAP",
        "CSP",
        "Gr\u00fcne",
        "FP\u00d6",
        "GdP",
        "HB",
        "KuL",
        "KP\u00d6",
        "LBd",
        "L",
        "LB",
        "PILZ",
        "NWB",
        "NEOS",
        "\u00d6VP",
        "SdP",
        "SP\u00d6",
        "STRONACH",
        "VO",
        "WdU"
    )

    checkmate::assert_subset(
        party,
        choices = choices_party,
        empty.ok = TRUE
    )

    checkmate::assert_scalar(
        party,
        null.ok = TRUE,
        .var.name = "Only one party provided."
    )

    #PARLIAMENTARY GROUP
    ##REVISE. parl_group only accepted if R_WF=="FR" (Fraktion)

    checkmate::assert_scalar(
        parl_group,
        null.ok = TRUE
    )

    choices_parl_group <- c(
        "all",
        "LBd",
        "CSP",
        "GR\u00dcNE",
        "SP\u00d6",
        "F-BZ\u00d6",
        "GdP",
        "F",
        "FP\u00d6",
        "KuL",
        "VO",
        "WdU",
        "LB",
        "NEOS-LIF",
        "PILZ",
        "NEOS",
        "OK",
        "HB",
        "KP\u00d6",
        "\u00d6VP",
        "BZ\u00d6",
        "JETZT",
        "L",
        "STRONACH",
        "NWB",
        "SdP"
    )
    checkmate::assert_subset(
        parl_group,
        choices = choices_parl_group,
        empty.ok = TRUE
    )

    #encode
    # parl_group <- match.arg(parl_group, several.ok = FALSE)
    if (!is.null(parl_group) && parl_group == "all") {
        parl_group <- "NULL"
    }

    #STATE
    checkmate::assert_scalar(
        state,
        null.ok = TRUE
    )

    #CHECK STATE BUNDESWAHLVORSCHLAG?
    choices_state <- c(
        "all", #Alle Bundesl\u00e4nder + Bundeswahlvorschlag (All Federal States + Federal Electoral Proposal)
        "all_states", #Alle Bundesl\u00e4nder (All Federal States)
        "B", #Burgenland
        "K", #K\u00e4rnten
        "N", #Nieder\u00f6sterreich
        "O", #Ober\u00f6sterreich
        "S", #Salzburg
        "St", #Steiermark
        "T", #Tirol
        "V", #Vorarlberg
        "W", #Wien
        "BWV" #Bundeswahlvorschlag (Federal Electoral Proposal)
    )

    checkmate::assert_subset(
        state,
        choices = choices_state,
        empty.ok = TRUE
    )

    #encode state
    if (!is.null(state) && state == "all") {
        state <- "ALLE"
    } else if (!is.null(state) && state == "all_states") {
        state <- "ALLE_BL"
    } else {
        state
    }

    #POSTAL CODE
    # checkmate::assert_scalar(
    #     postal_code,
    #     null.ok = TRUE
    # )

    #REVISE API returns additional rows
    # if (!is.na(postal_code) && !is.null(postal_code)) {
    #     postal_code <- as.character(postal_code)
    # }

    #ELECTORAL DISTRICT
    checkmate::assert_scalar(
        electoral_district,
        null.ok = TRUE
    )

    choices_electoral_district <- c(
        "ALLE", #Alle Wahlkreise (All Constituencies)
        "FB", #Bundeswahlvorschlag (Federal Electoral Proposal)
        "F1", #Burgenland
        "F1A", #Burgenland Nord
        "F1B", #Burgenland S\u00fcd
        "F5B", #Flachgau/Tennengau
        "F6A", #Graz und Umgebung
        "F4C", #Hausruckviertel
        "F7A", #Innsbruck
        "F7B", #Innsbruck-Land
        "F4B", #Innviertel
        "F2", #K\u00e4rnten
        "F2D", #K\u00e4rnten Ost
        "F2C", #K\u00e4rnten West
        "F2A", #Klagenfurt
        "F4A", #Linz und Umgebung
        "F5C", #Lungau/Pinzgau/Pongau
        "F3C", #Mostviertel
        "F4E", #M\u00fchlviertel
        "F3", #Nieder\u00f6sterreich
        "F3D", #Nieder\u00f6sterreich Mitte
        "F3G", #Nieder\u00f6sterreich Ost
        "F3E", #Nieder\u00f6sterreich S\u00fcd
        "F0", #noch offen (still open/pending)
        "F7D", #Oberland/Upper Country
        "F4", #Ober\u00f6sterreich
        "F6D", #Obersteiermark
        "F6B", #Oststeiermark
        "F7E", #Osttirol
        "F5", #Salzburg
        "F5A", #Salzburg Stadt
        "F6", #Steiermark
        "F3F", #Thermenregion (Thermal Region)
        "F7", #Tirol
        "F4D", #Traunviertel
        "F7C", #Unterland/Lower Country
        "F2B", #Villach
        "F8", #Vorarlberg
        "F8A", #Vorarlberg Nord
        "F8B", #Vorarlberg S\u00fcd
        "F3B", #Waldviertel
        "F3A", #Weinviertel
        "F6C", #Weststeiermark
        "F9", #Wien
        "F9C", #Wien Innen-Ost
        "F9A", #Wien Innen-S\u00fcd
        "F9B", #Wien Innen-West
        "F9G", #Wien Nord
        "F9F", #Wien Nord-West
        "F9D", #Wien S\u00fcd
        "F9E" #Wien S\u00fcd-West
    )
    checkmate::assert_subset(
        electoral_district,
        choices = choices_electoral_district,
        empty.ok = TRUE
    )

    # BODY PARAMS
    body_params <- list(
        M = M_input,
        W = W_input,
        # NRBR = institution,
        FUNK = position,
        WP = party,
        FR = parl_group,
        # PLZ = postal_code,
        BL = state,
        # R_PBW = R_PBW_input,
        WK = electoral_district
    ) %>%
        purrr::compact() %>%
        jsonlite::toJSON()

    # PERFORM REQUEST
    res <- get_mps_NR_current_api_request(body_params)

    vec_headings <- res %>%
        httr2::resp_body_json(simplifyVector = TRUE) %>%
        purrr::pluck("header", "label") %>%
        stringr::str_to_snake() %>%
        make.unique(sep = "_")

    # EXTRACT THE ACTUAL SUBSTANTIVE DATA
    df_res <- res %>%
        httr2::resp_body_json(simplifyVector = TRUE) %>%
        purrr::pluck("rows")

    if (length(df_res) == 0) {
        cli::cli_inform("No results found for the provided search criteria.")
        return(NULL)
    }
    colnames(df_res) <- vec_headings
    df_res <- as.data.frame(df_res)

    #ECHO
    if (echo == TRUE) {
        .parlat_echo_request(
            body_params,
            url_base = "https://www.parlament.gv.at/recherchieren/personen/nationalrat/index.html",
            param_prefix = "WFW_002",
            n_results = nrow(df_res)
        )
    }

    # #PARSE HTML STRINGS
    # df_res <- df_res %>%
    #     dplyr::mutate(across(
    #         # c("klub", "bundesland", "rss_description"),
    #         c("klub", "bundesland"),
    #         \(x) purrr::map_chr(x, aux_parse_html_text)
    # )) #%>% #REVISE, errors when position = "PRAES"
    # dplyr::mutate(
    #     parl_group = map_chr(rss_description, \(x) {
    #         x %>%
    #             rvest::read_html() %>%
    #             rvest::html_elements("span") %>%
    #             rvest::html_attr("title")
    #     })
    # )

    # SELECT RELEVANT COLUMNS #REVISE
    # df_res <- df_res %>%
    #     dplyr::mutate(pad_intern = stringr::str_extract(rss_pad, regex("\\+")))

    # cols_select <- c("pad_intern", "name", )

    return(df_res)
}


#' Fetch Current Members of Parliament Data
#'
#' This function sends a POST request to the Austrian Parliament's API endpoint to retrieve data related to current members of parliament.
#'
#' @param body_params A JSON-formatted string or raw vector containing the body parameters required by the API.
#'
#' @return An HTTP response object from the httr2 package containing the API's response.
#'
#' @noRd
get_mps_NR_current_api_request <- function(body_params) {
    httr2::request("https://www.parlament.gv.at/Filter/api/json/post") %>%
        httr2::req_method("POST") %>%
        httr2::req_url_query(
            jsMode = "EVAL",
            FBEZ = "WFW_002",
            listeId = "undefined",
            pageNumber = "1",
            pagesize = "200",
            feldRnr = "1",
            ascDesc = "ASC"
        ) %>%
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            # referer = "https://www.parlament.gv.at/recherchieren/personen/nationalrat",
            `sec-ch-ua` = '"Chromium";v="134", "Not:A-Brand";v="24", "Microsoft Edge";v="134"',
            `sec-ch-ua-mobile` = "?0",
            `sec-ch-ua-platform` = '"Windows"',
            `sec-fetch-dest` = "empty",
            `sec-fetch-mode` = "cors",
            `sec-fetch-site` = "same-origin",
            `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 Edg/134.0.0.0",
        ) %>%
        httr2::req_body_raw(body_params, type = "application/json") %>%
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") %>%
        httr2::req_retry(max_tries = 3) %>%
                httr2::req_perform()
}


#GET MPS BUNDESRAT/FEDERAL COUNCIL

#' Get Current Members of the Austrian Federal Council (Bundesrat)
#'
#' This function retrieves information about current members of the Austrian Federal Council
#' based on specified filtering criteria such as gender, position, party affiliation,
#' parliamentary group, and federal state.
#'
#' @param gender Character string specifying gender filter. Options are "all" (default),
#'   "female", or "male".
#' @param position Character string specifying position filter. Options include:
#'   \itemize{
#'     \item "all" - All Members of the Federal Council
#'     \item "PB" - President of the Federal Council
#'     \item "SPB" - Vice-President of the Federal Council
#'     \item "PRAES" - Presidential Conference
#'     \item "ZOB" - Usher/Sergeant-at-Arms of the Federal Council
#'     \item "ZSB" - Secretary/Scrutineer of the Federal Council
#'   }
#'   Default is NULL.
#' @param party Character string specifying party filter. Options include:
#'   \itemize{
#'     \item "all" - All Electoral Parties
#'     \item "GRÜNE" - The Greens
#'     \item "FPÖ" - Freedom Party of Austria
#'     \item "NEOS" - NEOS - The New Austria and Liberal Forum
#'     \item "ÖVP" - Austrian People's Party
#'     \item "SPÖ" - Social Democratic Party of Austria
#'   }
#'   Default is NULL.
#' @param parl_group Character string specifying parliamentary group filter. Options include:
#'   \itemize{
#'     \item "all" - All Parliamentary Groups
#'     \item "ÖVP" - ÖVP Parliamentary Group in the Federal Council
#'     \item "SPÖ" - SPÖ Parliamentary Group in the Federal Council
#'     \item "FPÖ" - Freedom Party Parliamentary Group in the Federal Council
#'     \item "GRÜNE" - Green Parliamentary Group in the Federal Council
#'     \item "OF" - #ohne Fraktionszugehörigkeit; Without Parliamentary Group Affiliation
#'   }
#'   Default is NULL.
#' @param state Character string specifying federal state filter. Options include:
#'   \itemize{
#'     \item "all" - All Federal States
#'     \item "B" - Burgenland
#'     \item "K" - Carinthia (Kärnten)
#'     \item "N" - Lower Austria (Niederösterreich)
#'     \item "O" - Upper Austria (Oberösterreich)
#'     \item "S" - Salzburg
#'     \item "St" - Styria (Steiermark)
#'     \item "T" - Tyrol (Tirol)
#'     \item "V" - Vorarlberg
#'     \item "W" - Vienna (Wien)
#'   }
#'   Default is NULL.
#'
#' @return A data frame containing information about Federal Council members matching
#'   the specified criteria. Returns NULL if no results are found, along with a message (internal helper).
#'
#' @examples
#' \donttest{
#' # Get all current Federal Council members
#' all_members <- get_mps_BR_current()
#'
#' # Get only female members
#' female_members <- get_mps_BR_current(gender = "female")
#'
#' # Get members from a specific party and state
#' ovp_vienna <- get_mps_BR_current(party = "ÖVP", state = "W")
#' }
#' @keywords internal
#' @noRd
# note: NULL input currently means "all" for the filter parameters below
get_mps_BR_current <- function(
    gender = "all",
    position = "all",
    party = NULL,
    parl_group = NULL,
    state = NULL,
    echo = TRUE
) {
    #GENDER
    choices_gender <- c("all", "female", "male")
    checkmate::assert_subset(
        gender,
        choices_gender,
        empty.ok = FALSE
    )
    ## encode

    if (gender == "all") {
        M_input <- "M"
        W_input <- "W"
    } else if (gender == "male") {
        M_input <- "M"
        W_input <- NULL
    } else {
        #exhaustive; must be female
        M_input <- NULL
        W_input <- "W"
    }

    #POSITION
    choices_position <- c(
        "all", #Alle Mitglieder des Bundesrates (All Members of the Federal Council)
        "PB", #Pr\u00e4sident des Bundesrates (President of the Federal Council)
        "SPB", #Vizepr\u00e4sident des Bundesrates (Vice-President of the Federal Council)
        "PRAES", #Pr\u00e4sidialkonferenz (Presidential Conference)
        "ZOB", #Ordner des Bundesrates (Usher/Sergeant-at-Arms of the Federal Council)
        "ZSB" #Schriftf\u00fchrer des Bundesrates (Secretary/Scrutineer of the Federal Council)
    )
    checkmate::assert_subset(
        position,
        choices = choices_position,
        empty.ok = TRUE
    )
    #encode position
    if (!is.null(position) && position == "all") {
        position <- "ALLE"
    }

    #PARTY
    choices_party <- c(
        "all", #(Alle Wahlparteien, All Electoral Parties)
        "GR\u00dcNE", #(Die Gr\u00fcnen, The Greens)
        "FP\u00d6", #(Freiheitliche Partei \u00d6sterreichs, Freedom Party of Austria)
        "NEOS", #(NEOS - Das neue \u00d6sterreich und Liberales Forum, NEOS - The New Austria and Liberal Forum)
        "\u00d6VP", #(\u00d6sterreichische Volkspartei, Austrian People's Party)
        "SP\u00d6" #(Sozialdemokratische Partei \u00d6sterreichs, Social Democratic Party of Austria))
    )

    checkmate::assert_scalar(
        party,
        null.ok = TRUE
    )

    checkmate::assert_subset(
        party,
        choices = choices_party,
        empty.ok = TRUE
    )

    #PARLGROUP
    choices_parl_group <- c(
        "all", #Alle Fraktionen (All Parliamentary Groups)
        "\u00d6VP", #Bundesratsfraktion der \u00d6VP (\u00d6VP Parliamentary Group in the Federal Council)
        "SP\u00d6", #Bundesratsfraktion der SP\u00d6 (SP\u00d6 Parliamentary Group in the Federal Council)
        "FP\u00d6", #Freiheitliche Bundesratsfraktion (Freedom Party Parliamentary Group in the Federal Council)
        "GR\u00dcNE", #Gr\u00fcne Fraktion im Bundesrat (Green Parliamentary Group in the Federal Council)
        "OF" #ohne Fraktionszugeh\u00f6rigkeit (Without Parliamentary Group Affiliation)
    )

    checkmate::assert_scalar(
        parl_group,
        null.ok = TRUE
    )

    checkmate::assert_subset(
        parl_group,
        choices = choices_parl_group,
        empty.ok = TRUE
    )

    #STATE
    choices_state <- c(
        "all", #(Alle Bundesl\u00e4nder, All Federal States)
        "B", # (Burgenland, Burgenland)
        "K", #(K\u00e4rnten, Carinthia)
        "N", # (Nieder\u00f6sterreich, Lower Austria)
        "O", # (Ober\u00f6sterreich, Upper Austria)
        "S", # (Salzburg, Salzburg)
        "St", # (Steiermark, Styria)
        "T", # (Tirol, Tyrol)
        "V", # (Vorarlberg, Vorarlberg)
        "W" # (Wien, Vienna)
    )

    checkmate::assert_scalar(
        state,
        null.ok = TRUE
    )
    checkmate::assert_subset(
        state,
        choices = choices_state,
        empty.ok = TRUE
    )

    # BODY PARAMS
    body_params <- list(
        M = M_input,
        W = W_input,
        FUNK = position,
        WP = party,
        FR = parl_group,
        BL = state
    ) %>%
        purrr::compact() %>%
        jsonlite::toJSON()

    # PERFORM REQUEST
    res <- get_mps_BR_current_api_request(body_params)

    vec_headings <- res %>%
        httr2::resp_body_json(simplifyVector = TRUE) %>%
        purrr::pluck("header", "label") %>%
        stringr::str_to_snake() %>%
        make.unique(sep = "_")

    # EXTRACT THE ACTUAL SUBSTANTIVE DATA
    df_res <- res %>%
        httr2::resp_body_json(simplifyVector = TRUE) %>%
        purrr::pluck("rows")

    if (length(df_res) == 0) {
        cli::cli_inform("No results found for the provided search criteria.")
        return(NULL)
    }
    colnames(df_res) <- vec_headings
    df_res <- as.data.frame(df_res)

    #ECHO
    if (echo == TRUE) {
        .parlat_echo_request(
            body_params,
            url_base = "https://www.parlament.gv.at/recherchieren/personen/bundesrat/index.html",
            param_prefix = "WFW_005",
            n_results = nrow(df_res)
        )
    }

    # #PARSE HTML STRINGS
    # df_res <- df_res %>%
    #     dplyr::mutate(across(
    #         # c("klub", "bundesland", "rss_description"),
    #         c("klub", "bundesland"),
    #         \(x) purrr::map_chr(x, aux_parse_html_text)
    # )) #%>% #REVISE, errors when position = "PRAES"
    # dplyr::mutate(
    #     parl_group = map_chr(rss_description, \(x) {
    #         x %>%
    #             rvest::read_html() %>%
    #             rvest::html_elements("span") %>%
    #             rvest::html_attr("title")
    #     })
    # )

    # SELECT RELEVANT COLUMNS #REVISE
    # df_res <- df_res %>%
    #     dplyr::mutate(pad_intern = stringr::str_extract(rss_pad, regex("\\+")))

    # cols_select <- c("pad_intern", "name", )

    return(df_res)
}


get_mps_BR_current_api_request <- function(body_params) {
    httr2::request("https://www.parlament.gv.at/Filter/api/json/post") %>%
        httr2::req_method("POST") %>%
        httr2::req_url_query(
            jsMode = "EVAL",
            FBEZ = "WFW_005",
            listeId = "undefined",
            pageNumber = "1",
            pagesize = "100",
            feldRnr = "2",
            ascDesc = "ASC"
        ) %>%
        httr2::req_headers(
            accept = "*/*",
            `accept-language` = "en-US,en;q=0.9,de-DE;q=0.8,de;q=0.7",
            origin = "https://www.parlament.gv.at",
            priority = "u=1, i",
            # referer = "https://www.parlament.gv.at/recherchieren/personen/bundesrat/index.html",
            `sec-ch-ua` = '"Chromium";v="136", "Microsoft Edge";v="136", "Not.A/Brand";v="99"',
            `sec-ch-ua-mobile` = "?0",
            `sec-ch-ua-platform` = '"Windows"',
            `sec-fetch-dest` = "empty",
            `sec-fetch-mode` = "cors",
            `sec-fetch-site` = "same-origin",
            `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36 Edg/136.0.0.0"
        ) %>%
        httr2::req_body_raw(
            body_params,
            type = "application/json"
        ) %>%
        httr2::req_body_raw(body_params, type = "application/json") %>%
        httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") %>%
        httr2::req_retry(max_tries = 3) %>%
                httr2::req_perform()
}

#auxiliary function to extract name from rss_description;
#assembles name in the format title name familyname, title
aux_extract_name <- function(string) {
    title <- stringr::str_extract(string, "(?<=Ak\\. Grad:\n)(.*?)(?=\n<br)")
    name <- stringr::str_extract(string, "(?<=Vorname:\n)(.*?)(?=\n<br)")
    name_family <- stringr::str_extract(
        string,
        "(?<=Nachname:\n)(.*?)(?=\n<br)"
    )
    title_trailing <- stringr::str_extract(
        string,
        "(?<=Ak\\. Grad nachg\\.:\n)(.*?)(?=\n<br)"
    )
    # print(name_family)
    # print(title_trailing)

    if (is.na(title_trailing) || !nzchar(title_trailing)) {
        stringr::str_flatten(
            c(title, name, name_family),
            na.rm = TRUE,
            collapse = " "
        )
    } else {
        stringr::str_flatten(
            c(title, name, name_family, title_trailing),
            na.rm = TRUE,
            collapse = " ",
            last = ", "
        )
    }
}


#' Zero-row tibble matching the documented columns of get_mps_current()
#' @noRd
.empty_mps_current_tibble <- function() {
    .parlat_empty_tibble(
        c(
            "time_stamp", "pad_intern", "name", "gender", "parl_group",
            "parl_group_code", "party_name", "party_code", "state",
            "electoral_district_region_code", "chamber"
        ),
        datetime_cols = "time_stamp"
    )
}
