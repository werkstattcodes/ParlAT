get_mps <- function(institution=c("all", "Bundesrat", "Nationalrat"),
                    gender=c("all", "female","male"),
                    legis_period="all",
                    parl_group=c("all",
                      "LBd", "CSP", "GRÜNE", "SPÖ", "F-BZÖ", "GdP", "F", "FPÖ",
                      "KuL", "VO", "WdU", "LB", "NEOS-LIF", "PILZ", "NEOS", "OK",
                      "HB", "KPÖ", "ÖVP", "BZÖ", "JETZT", "L", "STRONACH", "NWB",
                      "SdP")
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
  institution <- switch(institution,
                        all="ALLE",
                        Nationalrat="NR",
                        Bundesrat="BR")

  if (!(is.numeric(legis_period) || legis_period %in% c("all", "Provisorische Nationalversammlung", "Konstituierende Nationalversammlung"))) {
    stop("Invalid input for legis_period. Must be a numeric value or one of 'all', 'Provisorisch Nationalversammlung', or 'Konstituierende Nationalversammlung'.")
  }

  if (is.numeric(legis_period)) {
    legis_period <- as.character(as.roman(legis_period))
  } else if (legis_period=="all") {
    legis_period <- "ALLE"
  } else {
    legis_period
  }

  parl_group <- match.arg(parl_group)
  if (parl_group=="all") {
    parl_group <- "ALLE" }

  body_params <- list(
    M=M, #male MPs
    W=W, #female MPs
    NRBR=institution,
    GP=legis_period,
    FR=parl_group
  )|>
    purrr::compact() |>  #keep only non-empty elements
    jsonlite::toJSON()

  res <- httr2::request("https://www.parlament.gv.at/Filter/api/json/post") |>
    httr2::req_url_query(
      jsMode = "EVAL",
      FBEZ = "WFW_008",
      listeId = "undefined",
      # pageNumber = "1",
      # pagesize = "10",
      showAll="true",
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
    httr2::req_body_raw(body_params, "application/json") |>
    httr2::req_user_agent("ParlAT R package (http://werk.statt.codes)") |>
    httr2::req_verbose(body_req=T, header_req=F, header_resp = F) |>
    httr2::req_perform()

  # Extract headings; rename to make more informative
  vec_headings <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("header", "label") |>
    janitor::make_clean_names()

  # extract the actual substantive data
  df_res <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("rows") |>
    as.data.frame()

  if (nrow(df_res) == 0) {
    message("No results found for the given search criteria.")
    return(NULL)
  }

  colnames(df_res) <- vec_headings

  # df_res <- df_res |>
  #   dplyr::mutate(pad_intern = as.numeric(pad_intern))|>
  #   dplyr::select(pad_intern, name, wahlpartei, bundesland, link) |>
  #   dplyr::mutate(across(.cols=c(wahlpartei, bundesland), .fns=\(x) purrr::map_chr(x, \(y) y|> rvest::read_html() |> rvest::html_element("span") |> rvest::html_attr("title")))) |>
  #   dplyr::mutate(legis_period=legis_period, .before=1)

  # #rename to english and make names more informative
  # df_res <- df_res |>
  #   dplyr::rename(
  #     party=wahlpartei,
  #     electoral_district=bundesland
  #   )

  return(df_res)

}

