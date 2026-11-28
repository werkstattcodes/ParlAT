# failed extractions are distinct from successful empty replies

    Code
      analyse_fixture(data, "openai/test", text_column = "full_text")
    Condition
      Error in `value[[3L]]()`:
      ! Argument extraction failed for submission "s1". Check provider access, structured output support and input size.

# verbatim quotes and well-formed extraction records are required

    Code
      .parlat_validate_arguments(list(list(direction = "contra", argument = "A claim",
        quotes = list("invented quote"))), "source", "s1")
    Condition
      Error in `FUN()`:
      ! The model returned a quote absent from the submission text.

---

    Code
      .parlat_validate_arguments(list(list(direction = "contra", argument = "A claim",
        quotes = list())), "source", "s1")
    Condition
      Error in `FUN()`:
      ! The model returned a quote absent from the submission text.

---

    Code
      .parlat_argument_records(list(list(group_id = NA_character_)), "group_id")
    Condition
      Error in `FUN()`:
      ! The model returned a record with missing or invalid fields.

# invalid codebooks and assignments cannot produce frequencies

    Code
      analyse_fixture(data, "openai/test")
    Condition
      Error in `FUN()`:
      ! The model returned missing, repeated or unknown argument/group IDs.

---

    Code
      analyse_fixture(data, "openai/test")
    Condition
      Error in `FUN()`:
      ! The model returned missing, repeated or unknown argument/group IDs.

---

    Code
      analyse_fixture(data, "openai/test")
    Condition
      Error in `FUN()`:
      ! The model returned missing, repeated or unknown argument/group IDs.

---

    Code
      analyse_fixture(data, "openai/test")
    Condition
      Error in `FUN()`:
      ! The model returned missing, repeated or unknown argument/group IDs.

---

    Code
      analyse_fixture(data, "openai/test")
    Condition
      Error in `group_submission_arguments()`:
      ! The model returned an empty, oversized or duplicated group codebook.

---

    Code
      analyse_fixture(data, "openai/test", n_groups = 1)
    Condition
      Error in `group_submission_arguments()`:
      ! The model returned an empty, oversized or duplicated group codebook.

# inputs and request size are validated before network calls

    Code
      analyse_fixture(data, "openai")
    Condition
      Error in `get_submission_arguments()`:
      ! `model` must be an explicit "provider/model" name.

---

    Code
      group_submission_arguments(empty, "openai/test", n_groups = 0)
    Condition
      Error in `group_submission_arguments()`:
      ! Assertion on 'n_groups' failed: Must be >= 1.

---

    Code
      analyse_fixture(data[c(1, 1), ], "openai/test")
    Condition
      Error in `get_submission_arguments()`:
      ! Assertion on 'data$submission_id' failed: Contains duplicated values, position 2.

---

    Code
      analyse_fixture(data, "openai/test", max_input_chars = 2)
    Condition
      Error in `get_submission_arguments()`:
      ! Submission text exceeds `max_input_chars`; prepare smaller inputs or raise the limit.

---

    Code
      .parlat_argument_json(data, 2)
    Condition
      Error in `.parlat_argument_json()`:
      ! Argument registry exceeds `max_input_chars`; reduce the corpus or raise the limit.

