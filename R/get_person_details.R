get_person_details <- function(link) {


link <- "/person/2822"
link_file_json <- glue::glue("https://www.parlament.gv.at/{link}?json=TRUE")
file_json <- jsonlite::read_json(link_file_json)

content <- file_json$content

biography <- file_json$content$biografie
df_biography <- biography |>  tibble::enframe()
df_biography_wide <- df_biography |> tidyr::pivot_wider()
df_biography_wide <- df_biography_wide |> tidyr::unnest_wider(mandatefunktionen)




}
