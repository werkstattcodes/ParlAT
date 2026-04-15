test_that("get_voting_results parses plenary voting text", {
  x <- "3. Sitzung des Nationalrates: Abstimmung: Antrag, den ablehnenden Ausschussbericht zur Kenntnis zu nehmen: angenommen Dafür: ÖVP, SPÖ, NEOS, GRÜNE, dagegen: FPÖ"

  res <- get_voting_results(x)

  expect_true(res$is_vote_result[[1]])
  expect_equal(res$decision[[1]], "angenommen")
  expect_match(res$vote_subject[[1]], "Antrag")
  expect_equal(res$in_favor[[1]], c("ÖVP", "SPÖ", "NEOS", "GRÜNE"))
  expect_equal(res$against[[1]], "FPÖ")
  expect_equal(length(res$abstained[[1]]), 0)
})

test_that("get_voting_results handles missing vote markers", {
  x <- "Ausschuss für Petitionen und Bürgerinitiativen: auf Tagesordnung in der 4. Sitzung des Ausschusses"

  res <- get_voting_results(x)

  expect_false(res$is_vote_result[[1]])
  expect_true(is.na(res$decision[[1]]))
  expect_true(is.na(res$vote_subject[[1]]) || res$vote_subject[[1]] == "")
  expect_equal(length(res$in_favor[[1]]), 0)
  expect_equal(length(res$against[[1]]), 0)
})
