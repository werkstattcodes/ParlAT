analyse_fixture <- function(data, model, n_groups = 5L, batch_size = 50L, ...) {
  extracted <- get_submission_arguments(data, model, ...)
  group_submission_arguments(extracted, model,
    n_groups = n_groups,
    batch_size = batch_size
  )
}

test_that("frequencies count submissions once and retain zero-argument cases", {
  skip_if_not_installed("ellmer", "0.4.0")
  data <- tibble::tibble(
    submission_id = c("s1", "s2", "s3", "s4"),
    submission_text = c("cost and delay", "cost", "no objections", NA_character_)
  )
  local_mocked_bindings(.parlat_argument_request = function(model, prompt, input, stage) {
    switch(stage,
      extract = switch(input,
        "cost and delay" = list(
          list(direction = "contra", argument = "High cost", quotes = list("cost")),
          list(direction = "contra", argument = "Delay", quotes = list("delay"))
        ),
        "cost" = list(list(direction = "contra", argument = "High cost", quotes = list("cost"))),
        "no objections" = list()
      ),
      groups = list(list(group_id = "g1", group_name = "Resources", definition = "Cost and time")),
      assign = {
        batch <- jsonlite::fromJSON(input)
        lapply(batch$argument_id, function(id) list(argument_id = id, group_id = "g1"))
      }
    )
  })
  result <- analyse_fixture(data, "openai/test", n_groups = 2, batch_size = 1)
  expect_equal(result$submissions$n_arguments, c(2L, 1L, 0L, NA_integer_))
  expect_equal(result$submissions$status, c(rep("analysed", 3), "missing_text"))
  expect_equal(result$frequencies$n_arguments, 3L)
  expect_equal(result$frequencies$n_submissions, 2L)
  expect_equal(result$frequencies$proportion, 2 / 3)
  expect_equal(result$metadata$n_analysed, 3L)
  expect_equal(length(unique(result$arguments$argument_id)), 3L)
  expect_equal(result$arguments$quotes, list("cost", "delay", "cost"))
})

test_that("missing and empty input returns typed tables without requests", {
  local_mocked_bindings(.parlat_argument_request = function(...) stop("Unexpected request"))
  for (text in list(character(), c(NA_character_, "", "  "))) {
    data <- tibble::tibble(submission_id = as.character(seq_along(text)), submission_text = text)
    result <- analyse_fixture(data, "openai/test")
    expect_equal(nrow(result$arguments), 0L)
    expect_equal(nrow(result$frequencies), 0L)
    expect_type(result$arguments$quotes, "list")
    expect_type(result$submissions$n_arguments, "integer")
    expect_type(result$submissions$status, "character")
    expect_equal(result$metadata$n_analysed, 0L)
  }
})

test_that("failed extractions are distinct from successful empty replies", {
  skip_if_not_installed("ellmer", "0.4.0")
  data <- tibble::tibble(submission_id = c("s1", "s2"), full_text = c("failure", "empty"))
  local_mocked_bindings(.parlat_argument_request = function(model, prompt, input, stage) {
    if (input == "failure") stop("Simulated provider error")
    list()
  })
  result <- analyse_fixture(data, "openai/test", text_column = "full_text", on_error = "continue")
  expect_equal(result$submissions$status, c("failed", "analysed"))
  expect_equal(result$submissions$n_arguments, c(NA_integer_, 0L))
  expect_equal(result$metadata$n_analysed, 1L)
  expect_snapshot(error = TRUE, analyse_fixture(data, "openai/test", text_column = "full_text"))
})

test_that("verbatim quotes and well-formed extraction records are required", {
  expect_snapshot(error = TRUE, .parlat_validate_arguments(
    list(list(direction = "contra", argument = "A claim", quotes = list("invented quote"))), "source", "s1"
  ))
  expect_snapshot(error = TRUE, .parlat_validate_arguments(
    list(list(direction = "contra", argument = "A claim", quotes = list())), "source", "s1"
  ))
  expect_snapshot(error = TRUE, .parlat_argument_records(list(list(group_id = NA_character_)), "group_id"))
})

test_that("invalid codebooks and assignments cannot produce frequencies", {
  skip_if_not_installed("ellmer", "0.4.0")
  data <- tibble::tibble(submission_id = "s1", submission_text = "source")
  codebook <- list(list(group_id = "g1", group_name = "Group", definition = "Meaning"))
  assignment <- list()
  local_mocked_bindings(.parlat_argument_request = function(model, prompt, input, stage) {
    switch(stage,
      extract = list(list(direction = "contra", argument = "A claim", quotes = list("source"))),
      groups = codebook,
      assign = assignment
    )
  })
  expect_snapshot(error = TRUE, analyse_fixture(data, "openai/test"))
  assignment <- list(list(argument_id = "invented", group_id = "g1"))
  expect_snapshot(error = TRUE, analyse_fixture(data, "openai/test"))
  assignment <- list(list(argument_id = "a1", group_id = "unknown"))
  expect_snapshot(error = TRUE, analyse_fixture(data, "openai/test"))
  assignment <- rep(list(list(argument_id = "a1", group_id = "g1")), 2)
  expect_snapshot(error = TRUE, analyse_fixture(data, "openai/test"))
  codebook <- rep(codebook, 2)
  expect_snapshot(error = TRUE, analyse_fixture(data, "openai/test"))
  codebook[[2]]$group_id <- "g2"
  expect_snapshot(error = TRUE, analyse_fixture(data, "openai/test", n_groups = 1))
})

test_that("inputs and request size are validated before network calls", {
  local_mocked_bindings(.parlat_argument_request = function(...) stop("Unexpected request"))
  data <- tibble::tibble(submission_id = "s1", submission_text = "source")
  expect_snapshot(error = TRUE, analyse_fixture(data, "openai"))
  empty <- get_submission_arguments(data[0, ], "openai/test")
  expect_snapshot(error = TRUE, group_submission_arguments(empty, "openai/test", n_groups = 0))
  expect_snapshot(error = TRUE, analyse_fixture(data[c(1, 1), ], "openai/test"))
  expect_snapshot(error = TRUE, analyse_fixture(data, "openai/test", max_input_chars = 2))
  expect_snapshot(error = TRUE, .parlat_argument_json(data, 2))
})

test_that("backend uses fresh structured chats and does not echo text", {
  skip_if_not_installed("ellmer", "0.4.0")
  calls <- list()
  local_mocked_bindings(chat = function(name, system_prompt, echo) {
    calls[[length(calls) + 1L]] <<- list(model = name, prompt = system_prompt, echo = echo)
    list(chat_structured = function(input, type, convert) {
      expect_identical(convert, FALSE)
      expect_identical(class(type), class(ellmer::type_array(ellmer::type_string())))
      list()
    })
  }, .package = "ellmer")
  for (stage in c("extract", "groups", "assign")) {
    expect_equal(.parlat_argument_request("openai/test", "instructions", "source", stage), list())
  }
  expect_length(calls, 3L)
  expect_equal(vapply(calls, `[[`, character(1), "echo"), rep("none", 3))
})
