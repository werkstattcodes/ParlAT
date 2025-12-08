test_that("get_mps returns correct number of female MPs for 27th legislative period", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = 27, institution = "NR", gender = "female")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 88)
})

# Test gender = "male"
test_that("get_mps accepts male gender filter", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = 27, institution = "NR", gender = "male")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  # Check that all returned MPs are male
  expect_true(all(result$gender == "male"))
})

# Test gender = "all" (default)
test_that("get_mps accepts 'all' gender filter", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = 27, institution = "NR", gender = "all")

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
  skip_on_cran()
  skip_if_offline()

  result_male <- get_mps(legis_period = 27, institution = "NR", gender = "male")
  result_female <- get_mps(
    legis_period = 27,
    institution = "NR",
    gender = "female"
  )
  result_all <- get_mps(legis_period = 27, institution = "NR", gender = "all")

  # Male and female results should be different
  expect_false(identical(result_male, result_female))

  # All should have more rows than either male or female alone
  expect_true(nrow(result_all) >= nrow(result_male))
  expect_true(nrow(result_all) >= nrow(result_female))
})

# Test gender recoding works (W -> female, M -> male)
test_that("get_mps correctly recodes gender values", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = 27, institution = "NR")

  # Check that no raw W or M values remain in output
  expect_false(any(result$gender %in% c("W", "M")))
  expect_true(all(result$gender %in% c("male", "female")))
})

# Test gender filtering with date parameter
test_that("get_mps accepts gender filter with date parameter", {
  skip_on_cran()
  skip_if_offline()

  result_female <- get_mps(
    date = "01.01.2020",
    institution = "NR",
    gender = "female"
  )
  result_male <- get_mps(
    date = "01.01.2020",
    institution = "NR",
    gender = "male"
  )
  result_all <- get_mps(date = "01.01.2020", institution = "NR", gender = "all")

  expect_s3_class(result_female, "data.frame")
  expect_s3_class(result_male, "data.frame")
  expect_s3_class(result_all, "data.frame")

  # Check that gender filtering works with date
  expect_true(all(result_female$gender == "female"))
  expect_true(all(result_male$gender == "male"))
  expect_true(all(unique(result_all$gender) %in% c("male", "female")))
  expect_true(nrow(result_all) == 183)

  # Results should be different
  expect_false(identical(result_female, result_male))
})

# Tests for legis_period argument

test_that("get_mps accepts numeric legis_period", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = 27, institution = "NR")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps accepts Roman numeral legis_period", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = "XXVII", institution = "NR")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps accepts historical period abbreviations", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = "PN", institution = "PN")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps accepts multiple legis_periods", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = c(26, 27), institution = "NR")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps filters correctly by legis_period", {
  skip_on_cran()
  skip_if_offline()

  # Test that results are actually filtered by period
  result_27 <- get_mps(legis_period = 27, institution = "NR")
  result_26 <- get_mps(legis_period = 26, institution = "NR")

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
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(legis_period = c("26", "XXVII"), institution = "NR")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("get_mps returns empty result for non-existent legis_period", {
  skip_on_cran()
  skip_if_offline()

  # This should not error but return empty results
  result <- get_mps(legis_period = character(0), institution = "NR")

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
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(institution = "PN", legis_period = "PN")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

#check specific number
test_that("Check specific number: get_mps returns correct number of KPÖ candidates in 5 legis period", {
  skip_on_cran()
  skip_if_offline()

  result <- get_mps(institution = "NR", legis_period = "5", party = "KPÖ")

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) == 4)
})

#check consequence of name change on row numbers
test_that("Check whether name changes lead to duplicate entries within the relevant legislative period", {
  #1) get pad_intern of all MPs ever
  #2) feed their pad_interns into get_names and check whether they have more than 1 row => name changes
  #3) for each MP with a name change, get the legisative period in which the name change took place
  #4) with get_mps get alls mps of the legislative periods identified above (in which some name changes
  #took place)
  #5) check whether those mps which had a name change appear more than once within this legislative periods;
  #if there an MP appars multiple time nrow > 1

  # df_all <- get_mps() #get all mps ever
  # vec_pad_intern <- unique(df_all$pad_intern)

  # df_all_names <- get_names(pad_intern = vec_pad_intern) #get pad_interns of all mps who had name changes
  # pad_intern_name_changes <- df_all_names %>% #pad_interns of al MPs who changed their names at one point
  #   dplyr::filter(index > 1) %>%
  #   dplyr::pull(pad_intern)

  # # get entry of mps in the legislative period where they changed their name
  # df_name_changes_mps_legis_period <- df_all_names %>%
  #   dplyr::filter(pad_intern %in% pad_intern_name_changes) %>%
  #   dplyr::mutate(
  #     date_name_change = stringr::str_extract(
  #       #extract year of name change
  #       value,
  #       stringr::regex("\\d+\\.\\d+\\.\\d+")
  #     )
  #   ) %>%
  #   dplyr::filter(!is.na(date_name_change)) %>%
  #   #get legis period of name change based on year
  #   dplyr::mutate(
  #     legis_period_name_change = purrr::map(
  #       date_name_change,
  #       \(x) {
  #         get_legis_periods(date = x)
  #       },
  #       .progress = TRUE
  #     )
  #   ) %>%
  #   #extract the legis period
  #   dplyr::mutate(
  #     legis_period = map_dbl(legis_period_name_change, \(x) {
  #       pluck(x, "legis_period", .default = NA_real_)
  #     })
  #   )

  df_name_changes_mps_legis_period <- tibble::tribble(
    ~pad_intern,
    ~legis_period,
    41L,
    21,
    76L,
    21,
    118L,
    22,
    192L,
    15,
    547L,
    17,
    586L,
    16,
    715L,
    18,
    717L,
    17,
    1130L,
    17,
    1174L,
    22,
    1174L,
    18,
    1345L,
    16,
    1613L,
    22,
    1688L,
    19,
    1846L,
    12,
    2018L,
    23,
    2834L,
    21,
    2869L,
    18,
    2872L,
    22,
    2872L,
    20,
    3130L,
    19,
    3133L,
    27,
    3488L,
    27,
    3727L,
    28,
    3727L,
    27,
    5096L,
    21,
    5647L,
    27,
    7569L,
    27,
    8184L,
    21,
    8238L,
    21,
    8240L,
    22,
    8245L,
    22,
    14693L,
    26,
    14757L,
    24,
    20236L,
    27,
    21150L,
    24,
    30352L,
    24,
    35468L,
    25,
    35496L,
    23,
    44127L,
    27,
    51559L,
    25,
    59247L,
    24,
    78585L,
    25,
    83111L,
    25,
    83124L,
    25,
    87146L,
    26
  )

  vec_periods <- df_name_changes_mps_legis_period %>%
    dplyr::pull(legis_period) %>%
    unique() %>%
    sort() # legis periods with MPs having name changes

  legis_periods_name_changes <- get_mps(
    institution = "NR",
    legis_period = vec_periods
  ) %>%
    dplyr::mutate(
      legis_period_num = purrr::map_chr(legis_period, \(x) {
        aux_convert_legis_periods(x)
      })
    )

  # get mps and legis_period who changed names
  legis_periods_name_changes_mps <- legis_periods_name_changes %>%
    dplyr::semi_join(
      df_name_changes_mps_legis_period %>%
        dplyr::mutate(legis_period = as.character(legis_period)),
      by = c("pad_intern", "legis_period_num" = "legis_period")
    ) %>%
    dplyr::distinct(legis_period, pad_intern, name) %>%
    dplyr::count(pad_intern) %>%
    dplyr::filter(n > 1)

  expect_equal(nrow(legis_periods_name_changes_mps), 0)
})


1
