# invalid directions and changed submission provenance are rejected

    Code
      .parlat_validate_arguments(list(list(argument = "Claim", direction = "neutral",
        quotes = list("source"))), "source", "s1")
    Condition
      Error in `.parlat_validate_arguments()`:
      ! The model returned an invalid argument direction.

---

    Code
      get_submission_arguments(data, "openai/test", direction = "other")
    Condition
      Error in `match.arg()`:
      ! 'arg' should be one of "both", "pro", "contra"

---

    Code
      group_submission_arguments(extracted, "openai/test")
    Condition
      Error in `group_submission_arguments()`:
      ! Assertion on 'extracted$submission_id' failed: Must be a subset of the empty set, i.e. also empty.

