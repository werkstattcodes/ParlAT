# test_that("get_mandates works correctly", {
#     # Mock API response using httr2::mock
#     httr2::mock(
#       get_mandates, # function to mock
#       list( # list of responses
#         list( # first response
#           body = jsonlite::toJSON(list(
#             pad_intern = 1174,
#             mandatVon = "2020-01-01",
#             mandatBis = "2024-01-01",
#             gremium = "NR"
#           ))
#         )
#       )
#     )

#     # Test basic functionality
#     pad_test <- 1174
#     result <- get_mandates(pad_test)
#     expect_s3_class(result, "data.frame")
#     expect_true(all(c("pad_intern", "mandatVon", "mandatBis", "gremium") %in% colnames(result)))

#   # Test multiple pad_intern with duplicates
#   pad_test_dup <- c(1174, 1174, 1234)
#   result_dup <- get_mandates(pad_test_dup)
#   expect_equal(length(unique(result_dup$pad_intern)), 2)

#   # Test date filtering
#   date_result <- get_mandates(pad_test, date="2023-01-01")
#   expect_true(all(date_result$mandatVon <= as.Date("2023-01-01")))

#   # Test institution filtering
#   nr_result <- get_mandates(pad_test, institution="Nationalrat")
#   expect_true(all(nr_result$gremium == "NR"))
#   br_result <- get_mandates(pad_test, institution="Bundesrat")
#   expect_true(all(br_result$gremium == "BR"))

#   # Test invalid pad_intern
#   expect_null(get_mandates(-999))

#   # Test invalid date format
#   expect_error(get_mandates(pad_test, date="invalid"))

#   # Test invalid institution
#   expect_error(get_mandates(pad_test, institution="invalid"))
# })
