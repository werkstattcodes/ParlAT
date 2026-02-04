# Test aux_check_pad_intern_exists function

# Test basic functionality -----------------------------------------------

test_that("aux_check_pad_intern_exists returns logical for valid inputs", {
  skip_on_cran()

  # Test with a known valid pad_intern (Doris Bures)
  result <- run_api_call({
    aux_check_pad_intern_exists("145")
  }, fixture_subdir = "aux_check_pad_intern_exists")

  expect_type(result, "logical")
  expect_length(result, 1)
  expect_true(result)
})

test_that("aux_check_pad_intern_exists allows for inputs > length==1", {
  skip_on_cran()

  # Test with a known valid pad_intern (Doris Bures)
  result <- run_api_call({
    aux_check_pad_intern_exists(c("145", "2345"))
  }, fixture_subdir = "aux_check_pad_intern_exists")

  expect_type(result, "logical")
  expect_length(result, 2)
  expect_true(all(result))
})


# Test edge cases for pad_intern parameter --------------------------------

test_that("aux_check_pad_intern_exists handles boundary values", {
  skip_on_cran()

  # Test with zero
  result_zero <- run_api_call({
    aux_check_pad_intern_exists("0")
  }, fixture_subdir = "aux_check_pad_intern_exists")
  expect_false(result_zero)

  # Test with negative values - should error due to non-numeric characters
  expect_error(
    aux_check_pad_intern_exists("-1"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("-999"),
    "`pad_intern` can only contain numeric characters"
  )
})

test_that("aux_check_pad_intern_exists handles non-integer numeric strings", {
  # Test with decimal values - should error due to non-numeric characters (decimal point)
  expect_error(
    aux_check_pad_intern_exists("145.5"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("12.34"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("0.1"),
    "`pad_intern` can only contain numeric characters"
  )
})

test_that("aux_check_pad_intern_exists handles non-numeric strings", {
  # Test with alphabetic strings - should error
  expect_error(
    aux_check_pad_intern_exists("abc"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("test"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("MP145"),
    "`pad_intern` can only contain numeric characters"
  )

  # Test with mixed alphanumeric - should error
  expect_error(
    aux_check_pad_intern_exists("145abc"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("a145"),
    "`pad_intern` can only contain numeric characters"
  )
})

test_that("aux_check_pad_intern_exists handles special characters", {
  # Test with special characters - should error
  expect_error(
    aux_check_pad_intern_exists("145@"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("145!"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("145#"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("145%"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("145&"),
    "`pad_intern` can only contain numeric characters"
  )

  # Test with URL-like strings - should error
  expect_error(
    aux_check_pad_intern_exists("145/"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("145?"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("145="),
    "`pad_intern` can only contain numeric characters"
  )
})

# Test vectorized functionality ------------------------------------------

test_that("aux_check_pad_intern_exists is vectorized", {
  skip_on_cran()

  # Test with vector of valid numeric inputs
  inputs <- c("145", "999999")
  results <- run_api_call({
    aux_check_pad_intern_exists(inputs)
  }, fixture_subdir = "aux_check_pad_intern_exists")

  expect_type(results, "logical")
  expect_length(results, 2)
  expect_true(results[1]) # 145 should be valid
  expect_false(results[2]) # 999999 should be invalid (doesn't exist)

  # Test with vector containing invalid input - should error on first invalid element
  expect_error(
    aux_check_pad_intern_exists(c("145", "abc")),
    "`pad_intern` can only contain numeric characters"
  )
})

test_that("aux_check_pad_intern_exists handles multiple inputs with validation errors", {
  skip_on_cran()

  # Test with vector of numeric inputs that don't exist
  inputs <- c("999999", "1000000")
  results <- run_api_call({
    aux_check_pad_intern_exists(inputs)
  }, fixture_subdir = "aux_check_pad_intern_exists")

  expect_type(results, "logical")
  expect_length(results, 2)
  expect_true(all(!results)) # All should be FALSE (don't exist)

  # Test with vector containing validation errors - should error
  expect_error(
    aux_check_pad_intern_exists(c("999999", "abc")),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists(c("-1", "145.5")),
    "`pad_intern` can only contain numeric characters"
  )
})

test_that("aux_check_pad_intern_exists handles empty vector", {
  # Test with empty vector - should return FALSE
  result <- aux_check_pad_intern_exists(character(0))
  expect_false(result)
})

# Test NULL handling ------------------------------------------------------

test_that("aux_check_pad_intern_exists handles NULL input", {
  # Test with NULL - should return FALSE
  expect_false(aux_check_pad_intern_exists(NULL))
})

test_that("aux_check_pad_intern_exists handles NA input", {
  # Test with NA - should return FALSE
  expect_false(aux_check_pad_intern_exists(NA_character_))
  expect_false(aux_check_pad_intern_exists(NA))
})

test_that("aux_check_pad_intern_exists handles empty and whitespace strings", {
  # Test with empty string - should return FALSE
  expect_false(aux_check_pad_intern_exists(""))

  # Test with whitespace only - should return FALSE (after trimming becomes empty)
  expect_error(aux_check_pad_intern_exists(" "))
  expect_error(aux_check_pad_intern_exists("  "))
  expect_error(aux_check_pad_intern_exists("\t"))
  expect_error(aux_check_pad_intern_exists("\n"))

  # Test with padded valid values - should work (trimmed to "145")
  skip_on_cran()

  result1 <- run_api_call({
    aux_check_pad_intern_exists(" 145")
  }, fixture_subdir = "aux_check_pad_intern_exists")
  expect_true(result1)

  result2 <- run_api_call({
    aux_check_pad_intern_exists("145 ")
  }, fixture_subdir = "aux_check_pad_intern_exists")
  expect_true(result2)

  result3 <- run_api_call({
    aux_check_pad_intern_exists(" 145 ")
  }, fixture_subdir = "aux_check_pad_intern_exists")
  expect_true(result3)
})


# Test network error handling --------------------------------------------

test_that("aux_check_pad_intern_exists validates input before network calls", {
  # Test with input that contains invalid characters - should error before network call
  expect_error(
    aux_check_pad_intern_exists("invalid/url"),
    "`pad_intern` can only contain numeric characters"
  )
  expect_error(
    aux_check_pad_intern_exists("test with spaces"),
    "`pad_intern` can only contain numeric characters"
  )

  # Test with input containing URL encoding characters - should error
  expect_error(
    aux_check_pad_intern_exists("145%20test"),
    "`pad_intern` can only contain numeric characters"
  )
})

# Test input type validation ---------------------------------------------

test_that("aux_check_pad_intern_exists converts input types appropriately", {
  skip_on_cran()

  # The function should handle numeric input by converting to character
  result_numeric <- run_api_call({
    aux_check_pad_intern_exists(145)
  }, fixture_subdir = "aux_check_pad_intern_exists")

  result_character <- run_api_call({
    aux_check_pad_intern_exists("145")
  }, fixture_subdir = "aux_check_pad_intern_exists")

  expect_type(result_numeric, "logical")
  expect_type(result_character, "logical")
  expect_equal(result_numeric, result_character)
})

# Performance considerations ------------------------------------------

test_that("aux_check_pad_intern_exists performance with multiple requests", {
  skip_on_cran()

  # Test that function doesn't hang with multiple valid requests
  # Using known valid pad_intern values, limiting to prevent excessive API calls
  inputs <- c("145", "88641") # Keep small for testing

  start_time <- Sys.time()
  results <- run_api_call({
    aux_check_pad_intern_exists(inputs)
  }, fixture_subdir = "aux_check_pad_intern_exists")
  end_time <- Sys.time()

  expect_type(results, "logical")
  expect_length(results, 2)

  # Basic performance check - should complete within reasonable time
  # (Adjust threshold based on network conditions)
  time_diff <- as.numeric(difftime(end_time, start_time, units = "secs"))
  expect_true(time_diff < 30) # Should complete within 30 seconds
})
