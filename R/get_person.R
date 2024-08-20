get_person <- function(search_string) {

  # search_string <- "Krisper"

  res <- httr2::request("https://www.parlament.gv.at/Filter/api/filter/data/10400") |>
    httr2::req_url_query(
      js = "eval",
      page = "1",
      pagesize = "20",
      search = search_string,
      ascDesc = "ASC",
    ) |>
    httr2::req_headers(
      accept = "*/*",
      `accept-language` = "en-US,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-AT;q=0.6",
      `content-type` = "application/json",
      cookie = "JSESSIONID=6SuuP4uN67Tzfy5YSSTebU_drcVJsXaonUCi2Ip2.appsrv05e; JSESSIONID=D5_fJZPk36M3KGFa5uvK-d3ze_hVKvOXxYHz-fZ2.appsrv04e; JSESSIONID=a8RmonS5xoSPjzey8ovDCAsEBsyl5Ua7YpXVQjF0.appsrv06e; pddsgvo=j; _pk_id.1.26ca=7fce6f38a899aedc.1706609353.; _pk_ref.1.26ca=%5B%22%22%2C%22%22%2C1724182412%2C%22https%3A%2F%2Fwww.google.com%2F%22%5D; _pk_ses.1.26ca=1",
      dnt = "1",
      origin = "https://www.parlament.gv.at",
      priority = "u=1, i",
      `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/127.0.0.0
Safari/537.36",
    ) |>
    httr2::req_body_raw("{}", "application/json") |>
    httr2::req_perform()

  # vec_headings
  vec_headings <- res |> httr2::resp_body_json(simplifyVector = T) |> purrr::pluck("header", "label") |> janitor::make_clean_names()

  df_res <- res |> httr2::resp_body_json(simplifyVector = T) |> purrr::pluck("rows")  |> as.data.frame()
  # nrow(df_res)

  colnames(df_res) <- vec_headings

  df_res  <- df_res |>
    dplyr:::select(
      name,
      geschl,
      pad_intern,
      funktion,
      link
    )

  df_res <- df_res |>
    dplyr::mutate(funktion=stringr::str_remove(funktion, pattern=stringr::regex("<.*$")))

  return(df_res)

}
