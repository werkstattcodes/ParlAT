test_that("shared topics retain both directions without double-counting submissions", {
  skip_if_not_installed("ellmer", "0.4.0")
  data <- tibble::tibble(
    submission_id = c("s1", "s2", "s3"),
    submission_text = c("saving cost delay", "cost", "empty")
  )
  stages <- character()
  local_mocked_bindings(.parlat_argument_request = function(model, prompt, input, stage) {
    stages <<- c(stages, stage)
    switch(stage,
      extract = switch(input,
        "saving cost delay" = list(
          list(argument = "Saves money", direction = "pro", quotes = list("saving")),
          list(argument = "Costs money", direction = "contra", quotes = list("cost")),
          list(argument = "Takes time", direction = "contra", quotes = list("delay"))
        ),
        "cost" = list(list(argument = "Costs money", direction = "contra", quotes = list("cost"))),
        "empty" = list()
      ),
      groups = list(list(group_id = "g1", group_name = "Resources", definition = "Cost and time")),
      assign = lapply(
        jsonlite::fromJSON(input)$argument_id,
        function(id) list(argument_id = id, group_id = "g1")
      )
    )
  })
  extracted <- get_submission_arguments(data, "openai/test")
  expect_equal(stages, rep("extract", 3))
  expect_named(
    extracted$arguments,
    c("submission_id", "argument_id", "argument", "direction", "quotes")
  )
  expect_equal(extracted$arguments$direction, c("pro", "contra", "contra", "contra"))
  stages <- character()
  result <- group_submission_arguments(extracted, "openai/other", n_groups = 2)
  expect_equal(stages, c("groups", "assign"))
  expect_equal(result$frequencies$n_arguments, 4L)
  expect_equal(result$frequencies$n_submissions, 2L)
  expect_equal(result$frequencies$proportion, 2 / 3)
  expect_equal(result$direction_frequencies$direction, c("pro", "contra"))
  expect_equal(result$direction_frequencies$n_arguments, c(1L, 3L))
  expect_equal(result$direction_frequencies$n_submissions, c(1L, 2L))
  expect_equal(result$direction_frequencies$proportion, c(1 / 3, 2 / 3))
  expect_identical(result$arguments$argument_id, extracted$arguments$argument_id)
  expect_equal(result$metadata$extraction$model, "openai/test")
  stages <- character()
  group_submission_arguments(extracted, "openai/other", n_groups = 1)
  expect_equal(stages, c("groups", "assign"))
  pro <- get_submission_arguments(data, "openai/test", direction = "pro")
  expect_equal(pro$arguments$direction, "pro")
  expect_equal(pro$submissions$n_arguments, c(1L, 0L, 0L))
  contra <- get_submission_arguments(data, "openai/test", direction = "contra")
  expect_equal(contra$arguments$direction, rep("contra", 3))
  expect_equal(contra$submissions$n_arguments, c(2L, 1L, 0L))
})

test_that("invalid directions and changed submission provenance are rejected", {
  expect_snapshot(error = TRUE, .parlat_validate_arguments(
    list(list(argument = "Claim", direction = "neutral", quotes = list("source"))),
    "source", "s1"
  ))
  data <- tibble::tibble(submission_id = "s1", submission_text = NA_character_)
  expect_snapshot(error = TRUE, get_submission_arguments(data, "openai/test", direction = "other"))
  extracted <- get_submission_arguments(data, "openai/test")
  extracted$arguments <- tibble::tibble(
    submission_id = "invented",
    argument_id = "a1", argument = "Claim", direction = "pro", quotes = list("source")
  )
  expect_snapshot(error = TRUE, group_submission_arguments(extracted, "openai/test"))
})
