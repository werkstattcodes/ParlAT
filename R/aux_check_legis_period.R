# use when legis_period allows for input longer than length 1
# function splits input into elements of length 1
# checks if potentially numeric
## => if so converts to roman number
## => if not: checks if character string is permissible option
# if all elements are ok => combine into one string and feed into httr body parameters
# if at least one element errors => error message

#' Check elements of vector 'legis_period'
#'
#' @param x a vector of length > 0;
#'
#' @return a vector of length 1
#' 
#' @keywords internal
#' @noRd
#'
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
  html |>
    rvest::read_html() |>
    rvest::html_element("span") |>
    rvest::html_attr("title")
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
