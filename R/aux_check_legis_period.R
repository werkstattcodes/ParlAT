# use when legis_period allows for input longer than length 1
# function splits input into elements of length 1
# checks if potentially numeric
## => if so converts to roman number
## => if not: checks if character string is permissible option
# if all elements are ok => combine into one string and feed into httr body parameters
# if at least one element errors => error message

fn_check_legis_period_elements <- function(x) {
  if (is.null(x)) {
    stop("`legis_period` is required.")
  }
  #print("check 2")

  if (
    !(stringr::str_detect(x, stringr::regex("\\D"), negate = TRUE) ||
      x %in%
        c(
          "all",
          "Provisorische Nationalversammlung",
          "Konstituierende Nationalversammlung"
        ))
  ) {
    stop(
      "Invalid input for legis_period. Must be a numeric value or one of 'all', 'Provisorisch Nationalversammlung', or 'Konstituierende Nationalversammlung'."
    )
  }

  if (stringr::str_detect(x, stringr::regex("\\D"), negate = T)) {
    return(as.character(as.roman(x)))
  } else if (x == "all") {
    x <- "ALLE"
  } else {
    x
  }
}


aux_parse_html_title <- function(html) {
  result <- tryCatch(
    {
      rvest::read_html(html) |>
        rvest::html_element("span") |>
        rvest::html_attr("title")
    },
    error = function(e) {
      html
    }
  )
  result
}

aux_parse_html_text <- function(html) {
  html |>
    rvest::read_html() |>
    rvest::html_elements("span") |>
    rvest::html_text()
}


#' Expand and standardize parliamentary group names
#'
#' This internal auxiliary function expands parliamentary group names to include related
#' or historical variations of the same group. Currently only implemented for FPÖ (Freedom Party).
#'
#' @param parl_group Character vector containing parliamentary group names to be expanded
#'
#' @return A character vector with expanded and deduplicated parliamentary group names
#'
#' @keywords internal
#' @noRd
aux_parl_group_names_standard <- function(parl_group) {
  group_FPÖ <- c("F", "FPÖ", "F-BZÖ")
  group_BZÖ <- c("BZÖ", "F-BZÖ")
  group_NEOS <- c("NEOS", "NEOS-LIF")
  group_JETZT <- c("JETZT", "PILZ")

  #combine & make unique
  for (i in seq_along(parl_group)) {
    if (parl_group[i] %in% group_FPÖ) {
      parl_group <- c(parl_group, group_FPÖ)
    }
    if (parl_group[i] %in% group_BZÖ) {
      parl_group <- c(parl_group, group_BZÖ)
    }
    if (parl_group[i] %in% group_NEOS) {
      parl_group <- c(parl_group, group_NEOS)
    }
    if (parl_group[i] %in% group_JETZT) {
      parl_group <- c(parl_group, group_JETZT)
    }
  }
  return(parl_group %>% unique())
}

#auxiliar function converting list to tibble, e.g. for extarcting mandates
fn_make_tibble <- function(x) {
  tibble::tibble(
    !!!purrr::imap(x, function(value, name) {
      if (is.list(value) && !is.atomic(value)) {
        list(value) # bleibe list-column
      } else {
        value
      }
    })
  )
}


aux_check_pad_intern_exists <- function(pad_intern) {
  if (!is.null(pad_intern) && length(pad_intern) > 1) {
    return(
      pad_intern %>%
        purrr::map_lgl(aux_check_pad_intern_exists)
    )
  }

  url_check <- glue::glue("https://www.parlament.gv.at/person/{pad_intern}")
  resp <- tryCatch(
    httr2::request(url_check) |>
      httr2::req_method("HEAD") |>
      httr2::req_perform(),
    error = function(e) return(NULL)
  )

  # if request failed or gave an HTTP error, return FALSE
  if (is.null(resp) || httr2::resp_is_error(resp)) {
    # print(glue::glue("Pad intern {pad_intern} does not exist or is invalid."))
    return(FALSE)
  }

  TRUE
}
