options(httptest2.verbose = TRUE)

with_mock_dir("test get item", {
    system.time(
        antr_24 <- get_item(
            institution = "Nationalrat",
            item = "ANTR",
            date_start = "01-02-2024",
            date_end = "29-02-2024"
        )
    )

    expect_s3_class(antr_24, "data.frame")
    expect_equal(ncol(antr_24), 31)
    expect_equal(nrow(antr_24), 97)
})


with_mock_dir("test_get_item-invalid_date", {
    res_wrong_format <- get_item(date_start = "2025-01-01")
    expect_error(res_wrong_format)
})

#         # Test institution parameter
#         expect_no_error(get_item(institution = "Nationalrat"))
#         expect_no_error(get_item(institution = "Bundesrat"))
#         expect_error(get_item(institution = "Invalid"))

#         # Test topic parameter
#         expect_no_error(get_item(topic = "Europäische Union"))
#         expect_error(get_item(topic = "Invalid Topic"))

#         # Test date parameters
#         expect_no_error(get_item(
#             date_start = "01-01-2023",
#             date_end = "31-12-2023"
#         ))
#         expect_error(get_item(date_start = "2023-01-01")) # wrong format
#         expect_error(get_item(date_end = "invalid-date"))

#         # Test item parameter
#         expect_no_error(get_item(item = "ANTR"))
#         expect_error(get_item(item = "INVALID"))

#         # Test doc_type parameter
#         expect_error(get_item(doc_type = "A")) # doc_type without item should error
#         expect_no_error(get_item(
#             item = "ANTR",
#             doc_type = "A",
#             institution = "Nationalrat"
#         ))
#         expect_error(get_item(item = "ANTR", doc_type = "INVALID"))
#     })

#     # Test edge case - empty results
#     mock_empty_response <- list(
#         status_code = 200,
#         headers = list(`content-type` = "application/json"),
#         body = jsonlite::toJSON(list(
#             header = list(label = c()),
#             rows = data.frame()
#         ))
#     )

#     httr2::with_mocked_responses({
#         httr2::mock_endpoint("", mock_empty_response)
#         expect_message(
#             get_item(topic = "Europäische Union"),
#             "No results found"
#         )
#         expect_null(get_item(topic = "Europäische Union"))
#     })
# })
