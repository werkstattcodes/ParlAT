# Test file for get_pad_intern function

test_that("get_pad_intern validates input parameter", {
  expect_error(get_pad_intern(123), "Assertion on 'name' failed")
  expect_error(
    get_pad_intern(c("Name1", "Name2")),
    "Assertion on 'name' failed"
  )
  expect_error(get_pad_intern(NULL), "Assertion on 'name' failed")
  expect_error(get_pad_intern(character(0)), "Assertion on 'name' failed")
})

test_that("get_pad_intern returns correct structure with valid name", {
  skip_on_cran()

  result <- run_api_call({
    get_pad_intern("Kurz")
  }, fixture_subdir = "get_pad_intern")

  expect_s3_class(result, "data.frame")
  expect_true(all(c("pad_intern", "names_variants") %in% colnames(result)))
  expect_type(result$pad_intern, "character")
  expect_type(result$names_variants, "character")
})

test_that("get_pad_intern handles names with special characters", {
  skip_on_cran()

  result <- run_api_call({
    get_pad_intern("Müller")
  }, fixture_subdir = "get_pad_intern")

  expect_s3_class(result, "data.frame")
  expect_true(all(c("pad_intern", "names_variants") %in% colnames(result)))
})

test_that("get_pad_intern returns unique pad_intern values", {
  skip_on_cran()

  result <- run_api_call({
    get_pad_intern("Schmidt")
  }, fixture_subdir = "get_pad_intern")

  expect_equal(length(result$pad_intern), length(unique(result$pad_intern)))
})

test_that("get_pad_intern handles non-existent names gracefully", {
  skip_on_cran()

  result <- run_api_call({
    get_pad_intern("XyZaNonExistentName123")
  }, fixture_subdir = "get_pad_intern")

  expect_true(is.null(result) || nrow(result) == 0)
})

test_that("get_pad_intern performs case-sensitive name matching", {
  skip_on_cran()

  result_lower <- run_api_call({
    get_pad_intern("kurz")
  }, fixture_subdir = "get_pad_intern")

  result_upper <- run_api_call({
    get_pad_intern("KURZ")
  }, fixture_subdir = "get_pad_intern")

  result_proper <- run_api_call({
    get_pad_intern("Kurz")
  }, fixture_subdir = "get_pad_intern")

  expect_false(identical(result_lower, result_proper))
  expect_false(identical(result_upper, result_proper))
})

test_that("get_pad_intern returns names_variants as comma-separated string", {
  skip_on_cran()

  result <- run_api_call({
    get_pad_intern("Michael Pock")
  }, fixture_subdir = "get_pad_intern")

  expect_true(all(
    grepl(",\\s*", result$names_variants) | !grepl(",", result$names_variants)
  ))
})

test_that("get_pad_intern returns same pad_intern for persons who changed their name", {
  skip_on_cran()

  result_bernhard <- run_api_call({
    get_pad_intern("Michael Bernhard")
  }, fixture_subdir = "get_pad_intern")

  result_pock <- run_api_call({
    get_pad_intern("Michael Pock")
  }, fixture_subdir = "get_pad_intern")

  expect_equal(
    result_bernhard$pad_intern,
    result_pock$pad_intern,
    info = "Michael Bernhard and Michael Pock should have the same pad_intern"
  )

  expect_true(
    grepl("Michael Bernhard", result_pock$names_variants) ||
      grepl("Michael Pock", result_bernhard$names_variants),
    info = "Name variants should include both names"
  )
})

test_that("get_pad_intern returns expected pad_intern values for specific persons", {
  skip_on_cran()

  result_goetze <- run_api_call({
    get_pad_intern("Elisabeth Götze")
  }, fixture_subdir = "get_pad_intern")

  result_krisper <- run_api_call({
    get_pad_intern("Stephanie Krisper")
  }, fixture_subdir = "get_pad_intern")

  expect_equal(
    result_goetze$pad_intern,
    "5654",
    info = "Elisabeth Götze should have pad_intern 5654"
  )

  expect_equal(
    result_krisper$pad_intern,
    "2344",
    info = "Stephanie Krisper should have pad_intern 2344"
  )
})
