#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom cli cli_progress_bar cli_progress_update
#' @importFrom dplyr across any_of contains everything starts_with desc between
#' @importFrom jsonlite fromJSON
#' @importFrom jsonlite read_json
#' @importFrom jsonlite toJSON
#' @importFrom lifecycle deprecated
#' @importFrom magrittr %>%
#' @importFrom purrr map2
#' @importFrom rlang .data %||%
#' @importFrom stats setNames
#' @importFrom utils as.roman URLencode
## usethis namespace: end
NULL

# NSE pronouns: `x`/`y` are dplyr::join_by() pronouns, `.` is the magrittr
# placeholder. Declared so R CMD check does not flag them as undefined globals.
utils::globalVariables(c(".", "x", "y"))
