test_that("get_mps returns correct number of female MPs for 27th legislative period", {
  result <- run_api_call(
    {
      get_mps(legis_period = 27, institution = "NR", gender = "female")
    },
    fixture_subdir = "get_mps"
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 88)
})

# Test gender = "male"
test_that("get_mps accepts male gender filter", {
  result <- run_api_call(
    {
      get_mps(legis_period = 27, institution = "NR", gender = "male")
    },
    fixture_subdir = "get_mps"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  # Check that all returned MPs are male
  expect_true(all(result$gender == "male"))
})

# Test gender = "all" (default)
test_that("get_mps accepts 'all' gender filter", {
  result <- run_api_call(
    {
      get_mps(legis_period = 27, institution = "NR", gender = "all")
    },
    fixture_subdir = "get_mps"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  # Should include both male and female MPs
  expect_true(all(unique(result$gender) %in% c("male", "female")))
})

# Test invalid gender input
test_that("get_mps validates gender input", {
  expect_error(
    get_mps(legis_period = 27, institution = "NR", gender = "invalid"),
    "Must be a subset of"
  )
})

# Test gender filtering works correctly
test_that("get_mps gender filtering returns different results", {
  result_male <- run_api_call(
    {
      get_mps(legis_period = 27, institution = "NR", gender = "male")
    },
    fixture_subdir = "get_mps"
  )

  result_female <- run_api_call(
    {
      get_mps(
        legis_period = 27,
        institution = "NR",
        gender = "female"
      )
    },
    fixture_subdir = "get_mps"
  )

  result_all <- run_api_call(
    {
      get_mps(legis_period = 27, institution = "NR", gender = "all")
    },
    fixture_subdir = "get_mps"
  )

  # Male and female results should be different
  expect_false(identical(result_male, result_female))

  # All should have more rows than either male or female alone
  expect_true(nrow(result_all) >= nrow(result_male))
  expect_true(nrow(result_all) >= nrow(result_female))
})

# Test gender recoding works (W -> female, M -> male)
test_that("get_mps correctly recodes gender values", {
  result <- run_api_call(
    {
      get_mps(legis_period = 27, institution = "NR")
    },
    fixture_subdir = "get_mps"
  )

  # Check that no raw W or M values remain in output
  expect_false(any(result$gender %in% c("W", "M")))
  expect_true(all(result$gender %in% c("male", "female")))
})

# Test gender filtering with date parameter
test_that("get_mps accepts gender filter with date parameter", {
  result_female <- run_api_call(
    {
      get_mps(
        date = "01.01.2020",
        institution = "NR",
        gender = "female"
      )
    },
    fixture_subdir = "get_mps"
  )

  result_male <- run_api_call(
    {
      get_mps(
        date = "01.01.2020",
        institution = "NR",
        gender = "male"
      )
    },
    fixture_subdir = "get_mps"
  )

  result_all <- run_api_call(
    {
      get_mps(date = "01.01.2020", institution = "NR", gender = "all")
    },
    fixture_subdir = "get_mps"
  )

  expect_s3_class(result_female, "data.frame")
  expect_s3_class(result_male, "data.frame")
  expect_s3_class(result_all, "data.frame")
  expect_identical(names(result_all)[1], "date")
  expect_s3_class(result_all$date, "Date")
  expect_true(all(result_all$date == as.Date("2020-01-01")))

  # Check that gender filtering works with date
  expect_true(all(result_female$gender == "female"))
  expect_true(all(result_male$gender == "male"))
  expect_true(all(unique(result_all$gender) %in% c("male", "female")))
  expect_equal(nrow(result_all), 183)

  # Results should be different
  expect_false(identical(result_female, result_male))
})

test_that("get_mps returns a typed date-mode schema for empty API results", {
  local_mocked_bindings(
    get_legis_periods = function(...) {
      tibble::tibble(legis_period = "XXVII")
    }
  )
  local_mocked_bindings(
    req_perform = function(req) {
      httr2::response(
        headers = list(`content-type` = "application/json"),
        body = charToRaw('{"rows":[]}')
      )
    },
    .package = "httr2"
  )

  expect_message(
    result <- get_mps(
      date = "01.01.2020",
      institution = "NR",
      echo = FALSE
    ),
    "No results found"
  )

  expect_s3_class(result, "tbl_df")
  expect_identical(
    names(result),
    c(
      "date", "legis_period", "pad_intern", "link", "name", "gender",
      "mp_details"
    )
  )
  expect_s3_class(result$date, "Date")
  expect_type(result$legis_period, "character")
  expect_type(result$pad_intern, "character")
  expect_type(result$link, "character")
  expect_type(result$name, "character")
  expect_type(result$gender, "character")
  expect_type(result$mp_details, "list")
  expect_identical(nrow(result), 0L)
})

test_that("get_mps validates date length", {
  expect_error(
    get_mps(date = c("01.01.2020", "02.01.2020"), institution = "NR"),
    "Only date inputs of length 1 are allowed\\."
  )
})

# Tests for legis_period argument

test_that("get_mps accepts numeric legis_period", {
  result <- run_api_call(
    {
      get_mps(legis_period = 27, institution = "NR")
    },
    fixture_subdir = "get_mps"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps accepts Roman numeral legis_period", {
  result <- run_api_call(
    {
      get_mps(legis_period = "XXVII", institution = "NR")
    },
    fixture_subdir = "get_mps"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps accepts historical period abbreviations", {
  result <- run_api_call(
    {
      get_mps(legis_period = "PN", institution = "PN")
    },
    fixture_subdir = "get_mps"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps accepts multiple legis_periods", {
  result <- run_api_call(
    {
      get_mps(legis_period = c(26, 27), institution = "NR")
    },
    fixture_subdir = "get_mps"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps filters correctly by legis_period", {
  # Test that results are actually filtered by period
  result_27 <- run_api_call(
    {
      get_mps(legis_period = 27, institution = "NR")
    },
    fixture_subdir = "get_mps"
  )

  result_26 <- run_api_call(
    {
      get_mps(legis_period = 26, institution = "NR")
    },
    fixture_subdir = "get_mps"
  )

  expect_false(identical(result_27, result_26))
})

test_that("get_mps rejects legis_period for Bundesrat", {
  expect_error(
    get_mps(legis_period = 27, institution = "BR"),
    "Filtering the Federal Council \\(Bundesrat\\) by legislative period is not supported"
  )
})

test_that("get_mps validates legis_period input", {
  expect_error(
    get_mps(legis_period = 999, institution = "NR"),
    "Must be a subset of"
  )
})

test_that("get_mps handles mixed legis_period types", {
  result <- run_api_call(
    {
      get_mps(legis_period = c("26", "XXVII"), institution = "NR")
    },
    fixture_subdir = "get_mps"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps returns empty result for non-existent legis_period", {
  # This should not error but return empty results
  result <- run_api_call(
    {
      get_mps(legis_period = character(0), institution = "NR")
    },
    fixture_subdir = "get_mps"
  )

  expect_s3_class(result, "data.frame")
})

test_that("get_mps with legis_period requires institution to be NR or NULL", {
  expect_error(
    get_mps(legis_period = 27, institution = "something_else"),
    "Must be element of set"
  )
})

test_that("get_mps validates PN institution requires PN legis_period", {
  expect_error(
    get_mps(institution = "PN", legis_period = 27),
    "When institution is 'PN'"
  )
})

test_that("get_mps validates PN legis_period requires PN institution", {
  expect_error(
    get_mps(legis_period = "PN", institution = "NR"),
    "When legis_period is 'PN'"
  )
})

test_that("get_mps allows PN institution with PN legis_period", {
  result <- run_api_call(
    {
      get_mps(institution = "PN", legis_period = "PN")
    },
    fixture_subdir = "get_mps"
  )

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

# check specific number
test_that("Check specific number: get_mps returns correct number of KPÖ candidates in 5 legis period", {
  result <- run_api_call(
    {
      get_mps(institution = "NR", legis_period = "5", party = "KPÖ")
    },
    fixture_subdir = "get_mps"
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 4)
})

# check consequence of name change on row numbers
test_that("Check whether name changes lead to duplicate entries within the relevant legislative period", {
  # This is a complex integration test that requires live API
  skip_on_cran()
  skip_if_mocked("Complex integration test requires live API")
  skip_if_offline()

  df_name_changes_mps_legis_period <- tibble::tribble(
    ~pad_intern   ,
    ~legis_period ,
       41L        ,
       21         ,
       76L        ,
       21         ,
      118L        ,
       22         ,
      192L        ,
       15         ,
      547L        ,
       17         ,
      586L        ,
       16         ,
      715L        ,
       18         ,
      717L        ,
       17         ,
     1130L        ,
       17         ,
     1174L        ,
       22         ,
     1174L        ,
       18         ,
     1345L        ,
       16         ,
     1613L        ,
       22         ,
     1688L        ,
       19         ,
     1846L        ,
       12         ,
     2018L        ,
       23         ,
     2834L        ,
       21         ,
     2869L        ,
       18         ,
     2872L        ,
       22         ,
     2872L        ,
       20         ,
     3130L        ,
       19         ,
     3133L        ,
       27         ,
     3488L        ,
       27         ,
     3727L        ,
       28         ,
     3727L        ,
       27         ,
     5096L        ,
       21         ,
     5647L        ,
       27         ,
     7569L        ,
       27         ,
     8184L        ,
       21         ,
     8238L        ,
       21         ,
     8240L        ,
       22         ,
     8245L        ,
       22         ,
    14693L        ,
       26         ,
    14757L        ,
       24         ,
    20236L        ,
       27         ,
    21150L        ,
       24         ,
    30352L        ,
       24         ,
    35468L        ,
       25         ,
    35496L        ,
       23         ,
    44127L        ,
       27         ,
    51559L        ,
       25         ,
    59247L        ,
       24         ,
    78585L        ,
       25         ,
    83111L        ,
       25         ,
    83124L        ,
       25         ,
    87146L        ,
       26
  )

  vec_periods <- df_name_changes_mps_legis_period |>
    dplyr::pull(legis_period) |>
    unique() |>
    sort() # legis periods with MPs having name changes

  legis_periods_name_changes <- get_mps(
    institution = "NR",
    legis_period = vec_periods
  ) |>
    dplyr::mutate(
      legis_period_num = purrr::map_chr(legis_period, \(x) {
        aux_convert_legis_periods(x)
      })
    )

  # get mps and legis_period who changed names
  legis_periods_name_changes_mps <- legis_periods_name_changes |>
    dplyr::semi_join(
      df_name_changes_mps_legis_period |>
        dplyr::mutate(legis_period = as.character(legis_period)),
      by = c("pad_intern", "legis_period_num" = "legis_period")
    ) |>
    dplyr::distinct(legis_period, pad_intern, name) |>
    dplyr::count(pad_intern) |>
    dplyr::filter(n > 1)

  expect_equal(nrow(legis_periods_name_changes_mps), 0)
})
