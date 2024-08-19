  #' Say hello
#'
#' @param your_name Your name.
#'
#' @return A greeting with your name.
#' @export
#'
#' @examples
#' your_name <- "Thomas"?
#' say_hello(your_name)
say_hello <- function(your_name) {

  glue::glue("Hello, this is {your_name} printed with glue")

}
