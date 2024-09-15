get_committee_membership <- function(name, institution) {

  # name="Krisper"
  # institution="Nationalrat"

  vec_pad_intern <- get_persons(name=name, institution=institution) |>
    dplyr::pull(pad_intern) |>
    unique()

  body_params <- list(
    PAD_INTERN=vec_pad_intern
  ) |>
    purrr::compact() |>  #keep only non-empty elements
    jsonlite::toJSON()

  print(body_params)

  res <- httr2::request("https://www.parlament.gv.at/Filter/api/filter/data/250") |>
    httr2::req_url_query(
      `1` = "1",
      showAll=TRUE,
      # page = "1",
      # pagesize = "20",
      sortrnr = "2",
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
    httr2::req_verbose(body_req = T,
                       header_req = F,
                       header_resp = F) |>
    httr2::req_perform()

  vec_headings <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("header", "label") |>
    janitor::make_clean_names()
  print(vec_headings)

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

  return(df_res)

}





