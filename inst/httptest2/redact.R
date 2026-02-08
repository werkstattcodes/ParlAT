# Package-level redactor for httptest2
#
# This function is automatically called by httptest2 whenever the package is
# loaded (during tests, vignette building, and fixture recording). It shortens
# the URL paths used for fixture file storage to keep paths under the 100-byte
# portable limit required by CRAN.
#
# Three URL patterns are shortened:
#   www.parlament.gv.at/Filter/api/filter/data/ -> api/data/
#   www.parlament.gv.at/Filter/api/json/        -> api/json/
#   www.parlament.gv.at/person/                  -> api/person/

function(response) {
  response |>
    gsub_response(
      "www.parlament.gv.at/Filter/api/filter/data/",
      "api/data/",
      fixed = TRUE
    ) |>
    gsub_response(
      "www.parlament.gv.at/Filter/api/json/",
      "api/json/",
      fixed = TRUE
    ) |>
    gsub_response("www.parlament.gv.at/person/", "api/person/", fixed = TRUE)
}
