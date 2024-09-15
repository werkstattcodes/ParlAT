get_committee <- function(
    search_string=NULL, #Suchbegriff - SUCH
    institution=NULL, #Gremium - NBR
    legis_period=NULL, #Gesetzgebungsperiode - GP_CODE
    permanent=NULL, #Permanent tagende Ausschüsse - PERM
    include_subcommittees=NULL #auch Unterausschüsse - UA
    ) {

  #INSTITUTION
  checkmate::assert_subset(x=institution, choices = c("Bundesrat", "Nationalrat"), empty.ok=FALSE)
  ##encode
  institution_input <- switch(
    institution,
    Nationalrat = "NR",
    Bundesrat = "BR"
  )

  #LEGIS PERIOD
  legis_period <- purrr::map_chr(legis_period, \(x) fn_check_legis_period_elements(x))

  #PERMANENT
  checkmate::assert_logical(x=permanent, null.ok = TRUE)
  if (!is.null(permanent) && permanent==TRUE) {
    permanent_input <- "J"
    } else if (is.null(permanent)||permanent==FALSE) {
   permanent_input <- NULL
  }

  #INCLUDE SUBCOMMITTEES
  ## if `permanent`==T => searching for subcommittees is not possible

  if (permanent==TRUE && include_subcommittees==TRUE) {
    stop("Searching for subcommittees is only possible if `permanent` is not TRUE")
  }

  checkmate::assert_logical(x=include_subcommittees, null.ok = TRUE)
  if (!is.null(include_subcommittees) && include_subcommittees==TRUE) {
    include_subcommittees_input <- "J"
  } else if (is.null(include_subcommittees)||include_subcommittees==FALSE) {
    include_subcommittees_input <- NULL
  }

  #DEFINE PARAMETERS
  body_params <- list(
    NRBR = institution_input,
    GP_CODE = legis_period,
    PERM = permanent_input,
    UA = include_subcommittees_input,
    SUCH=search_string
  ) |>
    purrr::compact() |>  #keep only non-empty elements
    jsonlite::toJSON()

  res <- httr2::request("https://www.parlament.gv.at/Filter/api/json/post") |>
    httr2::req_url_query(
      jsMode = "EVAL",
      FBEZ = "WFP_009",
      listeId = "undefined",
      showAll=TRUE,
      # pageNumber = "1",
      # pagesize = "10",
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

  # extract the actual substantive data
  df_res <- res |>
    httr2::resp_body_json(simplifyVector = T) |>
    purrr::pluck("rows")
  #print(class(df_res))

  checkmate::check_data_frame(df_res, min.rows=1)

  if (length(df_res)==0) {
    message("No results found for the provided search criteria.")
    return(NULL)
  }

  colnames(df_res) <- vec_headings

  print(nrow(df_res))

  return(df_res)



}
