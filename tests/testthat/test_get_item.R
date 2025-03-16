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
    expect_error(get_item(date_start = "2025-01-01"))
})
