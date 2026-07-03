test_that("get_party_colors returns the default plotting palette", {
  colors <- get_party_colors()

  expect_type(colors, "character")
  expect_named(colors)
  expect_equal(unname(colors["SP\u00d6"]), "#CE000C")
  expect_equal(unname(colors["\u00d6VP"]), "#63C3D0")
  expect_equal(unname(colors["FP\u00d6"]), "#0056A2")
  expect_equal(unname(colors["GR\u00dcNE"]), "#88B626")
  expect_equal(unname(colors["NEOS"]), "#E3257B")
  expect_equal(unname(colors["FRANK"]), "#F47100")
  expect_equal(unname(colors["STRONACH"]), "#F47100")
  expect_equal(unname(colors["OK"]), "grey")
})

test_that("get_party_colors matches common aliases", {
  colors <- get_party_colors(c(
    "S",
    "V",
    "F",
    "G",
    "N",
    "Sozialdemokratische Partei \u00d6sterreichs",
    "\u00d6sterreichische Volkspartei",
    "Die Gr\u00fcnen",
    "Liste Peter Pilz"
  ))

  expect_equal(unname(colors), c(
    "#CE000C",
    "#63C3D0",
    "#0056A2",
    "#88B626",
    "#E3257B",
    "#CE000C",
    "#63C3D0",
    "#88B626",
    "lightgrey"
  ))
  expect_named(colors, names(colors))
})

test_that("get_party_colors handles historical ÖVP color by legislative period", {
  colors <- get_party_colors(
    c("\u00d6VP", "\u00d6VP", "SP\u00d6"),
    legis_period = c(25, 26, 25)
  )

  expect_equal(unname(colors), c("black", "#63C3D0", "#CE000C"))
  expect_equal(
    get_party_colors("\u00d6VP", legis_period = "XXV"),
    c("\u00d6VP" = "black")
  )
})

test_that("get_party_colors returns tibble output", {
  colors <- get_party_colors(c("S", "unknown", NA), output = "tibble")

  expect_s3_class(colors, "tbl_df")
  expect_named(colors, c("party", "canonical_party", "color"))
  expect_equal(colors$party, c("S", "unknown", NA_character_))
  expect_equal(colors$canonical_party, c("SP\u00d6", NA_character_, NA_character_))
  expect_equal(colors$color, c("#CE000C", NA_character_, NA_character_))
})

test_that("get_party_colors can error on unmatched input", {
  err <- rlang::catch_cnd(
    get_party_colors("unknown", unmatched = "error"),
    classes = "error"
  )

  expect_s3_class(err, "error")
  expect_match(conditionMessage(err), "Could not match party input: .unknown.")
})
