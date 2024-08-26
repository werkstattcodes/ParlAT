fn_check_legis_period <- function(x) {

  if (!(str_detect(x, regex("\\D"), negate=T) || x %in% c("all","Provisorische Nationalversammlung","Konstituierende Nationalversammlung"))) {
    stop(
      "Invalid input for legis_period. Must be a numeric value or one of 'all', 'Provisorisch Nationalversammlung', or 'Konstituierende Nationalversammlung'."
    )
  }

  if (str_detect(x, regex("\\D"), negate=T)) {
    return(as.character(as.roman(x)))
  } else if (x == "all") {
    x <- "ALLE"
  } else {
    x
  }

}
