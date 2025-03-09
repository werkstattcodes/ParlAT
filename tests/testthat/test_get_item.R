test_that("get_item works correctly", {
    # Mock API response
    mock_response <- list(
        status_code = 200,
        headers = list(`content-type` = "application/json"),
        body = jsonlite::toJSON(list(
            header = list(label = c("ID", "Topic", "Date", "Status")),
            rows = data.frame(
                ID = c("1", "2"),
                Topic = c("Europäische Union", "Budget und Finanzen"),
                Date = c("2023-01-01", "2023-02-01"),
                Status = c("Active", "Completed")
            )
        ))
    )

    my_mock <- function(req) {
        response(mock_response)
    }



    # httr2::with_mocked_responses({
    #     # Register mock response
    #     httr2::mock_endpoint("", mock_response)

        # Test basic functionality
        result <- get_item(topic = "Europäische Union")
        expect_s3_class(result, "data.frame")
        expect_equal(ncol(result), 4)
        expect_equal(nrow(result), 2)

        # Test institution parameter
        expect_no_error(get_item(institution = "Nationalrat"))
        expect_no_error(get_item(institution = "Bundesrat"))
        expect_error(get_item(institution = "Invalid"))

        # Test topic parameter
        expect_no_error(get_item(topic = "Europäische Union"))
        expect_error(get_item(topic = "Invalid Topic"))

        # Test date parameters
        expect_no_error(get_item(
            date_start = "01-01-2023",
            date_end = "31-12-2023"
        ))
        expect_error(get_item(date_start = "2023-01-01")) # wrong format
        expect_error(get_item(date_end = "invalid-date"))

        # Test item parameter
        expect_no_error(get_item(item = "ANTR"))
        expect_error(get_item(item = "INVALID"))

        # Test doc_type parameter
        expect_error(get_item(doc_type = "A")) # doc_type without item should error
        expect_no_error(get_item(
            item = "ANTR",
            doc_type = "A",
            institution = "Nationalrat"
        ))
        expect_error(get_item(item = "ANTR", doc_type = "INVALID"))
    })

    # Test edge case - empty results
    mock_empty_response <- list(
        status_code = 200,
        headers = list(`content-type` = "application/json"),
        body = jsonlite::toJSON(list(
            header = list(label = c()),
            rows = data.frame()
        ))
    )

    httr2::with_mocked_responses({
        httr2::mock_endpoint("", mock_empty_response)
        expect_message(
            get_item(topic = "Europäische Union"),
            "No results found"
        )
        expect_null(get_item(topic = "Europäische Union"))
    })
})
