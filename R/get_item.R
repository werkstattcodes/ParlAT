get_item <- function(institution = c("all", "Bundesrat", "Nationalrat")) {

  #INSTITUTION
  institution <- match.arg(institution)
  institution <- switch(
    institution,
    all = "ALLE",
    Nationalrat = "NR",
    Bundesrat = "BR"
  )

 #LEGIS PERIOD
  #allows for vector of length > 1
  legis_period <- c(15, 27, "Provisorische Nationalversammlung")

  fn_check_legis_period <- function(x) {

    if (!(is.numeric(x) ||
          x %in% c("all",
                              "Provisorische Nationalversammlung",
                              "Konstituierende Nationalversammlung"
          )
    )) {
      stop(
        "Invalid input for legis_period. Must be a numeric value or one of 'all', 'Provisorisch Nationalversammlung', or 'Konstituierende Nationalversammlung'."
      )
    }

    if (is.numeric(x)) {
      x <- as.character(as.roman(x))
    } else if (x == "all") {
      x <- "ALLE"
    } else {
      x
    }

  }

purrr::map_chr(legis_period, \(x) print(paste(x, "_")))


  body_params <- list(
    NRBR = institution
    # GP = legis_period,
    # WP = party,
    # FR = parl_group,
    # PR = presidents_only,
  ) |>
    purrr::compact() |>  #keep only non-empty elements
    jsonlite::toJSON()


  res <- httr2::request("https://www.parlament.gv.at/Filter/api/filter/data/101") |>
      httr2::req_url_query(
      js = "eval",
      # page = "1",
      # pagesize = "10",
      showAll=TRUE,
      sortrnr = "17",
      ascDesc = "DESC",
    ) |>
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      `content-type` = "application/json",
      cookie = "JSESSIONID=6SuuP4uN67Tzfy5YSSTebU_drcVJsXaonUCi2Ip2.appsrv05e; JSESSIONID=D5_fJZPk36M3KGFa5uvK-d3ze_hVKvOXxYHz-fZ2.appsrv04e; JSESSIONID=ed1JSdqiLIKgiFtm_wJhD78ib7UZWk3qfkL8Ayrl.appsrv04e; pddsgvo=j; _pk_id.1.26ca=7fce6f38a899aedc.1706609353.; _pk_ref.1.26ca=%5B%22%22%2C%22%22%2C1724424995%2C%22https%3A%2F%2Fwww.google.com%2F%22%5D; _pk_ses.1.26ca=1",
      dnt = "1",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i",
      `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0 Safari/537.36",
    ) |>
    httr2::req_body_raw(body_params, "application/json") |>
    httr2::req_perform()

  vec_headings <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("header", "label") |>
    janitor::make_clean_names()

  # extract the actual substantive data
  df_res <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("rows")

  colnames(df_res) <- vec_headings

  return(df_res)

}
