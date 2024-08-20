#' Get MPs of a specific legislative period
#'
#' The function returns a dataframe containing data all members of the National
#' Council (Nationalrat) of a specific legislative period.
#' Data comprises MPs' unique identification number (pad_intern), name (family name, first name, and academic titles), party affiliation during the
#' legislative period in question (_party_), the legislative period
#'
#'
#' @param legis_period legislative period (numeric), required, scalar.
#'
#' @return x A dataframe.
#' @export
#'
#' @examples
#'get_mps(27)

get_mps <- function(legis_period) {

legis_period <- 25

# if (is.null(legis_period)) {
#   legis_period_roman <- NULL
# } else {
#   legis_period_roman <- as.character(as.roman(legis_period))
# }

body_params <- list(
    GP=as.character(as.roman(legis_period)),
    M="M", #male MPs
    R_BW="BL", #BL=Bundesland, WK Wahlkreis
    R_WF="WP", #WP=Wahlpartei, FR=Fraktion
    W="W", #female MPs
    WP="ALLE" #Wahlparteien
  )|>
 purrr::compact() |>  #keep only non-empty elements
 jsonlite::toJSON()

resp_mps <- httr2::request("https://www.parlament.gv.at/Filter/api/json/post") |>
  httr2::req_url_query(
    jsMode = "EVAL",
    FBEZ = "WFW_004",
    listeId = "undefined",
    showAll = "True",
    ascDesc = "ASC",
  ) |>
  httr2::req_headers(
    authority = "www.parlament.gv.at",
    accept = "*/*",
    `accept-language` = "en-AT,en;q=0.9,de-AT;q=0.8,de;q=0.7,en-GB;q=0.6,en-US;q=0.5",
    `content-type` = "application/json",
    cookie = "JSESSIONID=OXVn_Rnh2uhhLyeuWdwxcO9xTTr5YsHbH0xRa3-S.appsrv04e; JSESSIONID=6SuuP4uN67Tzfy5YSSTebU_drcVJsXaonUCi2Ip2.appsrv04e; pddsgvo=j; _pk_id.1.26ca=7fce6f38a899aedc.1706609353.; _pk_ref.1.26ca=%5B%22%22%2C%22%22%2C1707683917%2C%22https%3A%2F%2Fwww.google.com%2F%22%5D; _pk_ses.1.26ca=1",
    dnt = "1",
    origin = "https://www.parlament.gv.at",
    `user-agent` = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
  ) |>
  httr2::req_body_raw(body_params, "application/json") |>
  httr2::req_perform()

# Extract headings; rename to make more informative
vec_headings <- resp_mps |>
  httr2::resp_body_json(simplifyVector = T) |>
  purrr::pluck("header", "label") |>
  janitor::make_clean_names()

# extract the actual substantive data
df_mps <- resp_mps |>
  httr2::resp_body_json(simplifyVector = T) |>
  purrr::pluck("rows") |>
  as.data.frame()

colnames(df_mps) <- vec_headings

df_mps <- df_mps |>
  dplyr::mutate(pad_intern = as.numeric(pad_intern))|>
  dplyr::select(pad_intern, name, wahlpartei, bundesland, link) |>
  dplyr::mutate(across(.cols=c(wahlpartei, bundesland), .fns=\(x) purrr::map_chr(x, \(y) y|> rvest::read_html() |> rvest::html_element("span") |> rvest::html_attr("title")))) |>
  dplyr::mutate(legis_period=legis_period, .before=1)

#rename to english and make names more informative
df_mps <- df_mps |>
  dplyr::rename(
    party=wahlpartei,
    electoral_district=bundesland
  )

return(df_mps)

}
