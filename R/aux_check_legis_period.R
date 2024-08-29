# use when legis_period allows for inpult longer than length 1
# function splits input into elements of lenght 1
# checks if potentially numeric
## => if so converts to roman number
## => if not: checks if character string is permissible option
# if all elements are ok => combine into one string and feed into httr body parameters
# if at least one element errors => error message

#' Check elements of vector 'legis_period'
#'
#' @param x a vector of length > 0;
#'
#' @return
#' @export
#'
#' @examples
fn_check_legis_period_elements <- function(x) {

  if (is.null(x)) {stop("`legis_period` is required.")}
  #print("check 2")

  if (!(stringr::str_detect(x, stringr::regex("\\D"), negate=T) || x %in% c("all","Provisorische Nationalversammlung","Konstituierende Nationalversammlung"))) {
    stop(
      "Invalid input for legis_period. Must be a numeric value or one of 'all', 'Provisorisch Nationalversammlung', or 'Konstituierende Nationalversammlung'."
    )
  }

  if (stringr::str_detect(x, stringr::regex("\\D"), negate=T)) {
    return(as.character(as.roman(x)))
  } else if (x == "all") {
    x <- "ALLE"
  } else {
    x
  }

}



get_padintern <- function(string) {





}
