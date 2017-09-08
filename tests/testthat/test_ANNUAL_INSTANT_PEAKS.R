context("Testing ANNUAL_INSTANT_PEAKS")

test_that("ANNUAL_INSTANT_PEAKS accepts single and multiple province arguments", {
  stns <- "08NM083"
  expect_identical(unique(ANNUAL_INSTANT_PEAKS(STATION_NUMBER = stns, hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER), stns)
  expect_identical(length(unique(ANNUAL_INSTANT_PEAKS(STATION_NUMBER = c("08NM083", "08NE102"), hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("ANNUAL_INSTANT_PEAKS accepts single and multiple province arguments", {
  expect_true(nrow(ANNUAL_INSTANT_PEAKS(PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3")) >= 1)
  expect_true(nrow(ANNUAL_INSTANT_PEAKS(PROV_TERR_STATE_LOC = c("BC", "YT"), hydat_path = "H:/Hydat.sqlite3")) >= 1)
})

test_that("ANNUAL_INSTANT_PEAKS produces an error when a province is not specified correctly", {
  expect_error(ANNUAL_INSTANT_PEAKS(PROV_TERR_STATE_LOC = "BCD", hydat_path = "H:/Hydat.sqlite3"))
  expect_error(ANNUAL_INSTANT_PEAKS(PROV_TERR_STATE_LOC = c("AB", "BCD"), hydat_path = "H:/Hydat.sqlite3"))
})

test_that("ANNUAL_INSTANT_PEAKS gather data when no arguments are supplied", {
  expect_true(nrow(ANNUAL_INSTANT_PEAKS(hydat_path = "H:/Hydat.sqlite3")) >= 1)
})

test_that("ANNUAL_INSTANT_PEAKS can accept both arguments for backward compatability", {
  expect_true(nrow(ANNUAL_INSTANT_PEAKS(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = "H:/Hydat.sqlite3")) >= 1)
})


test_that("ANNUAL_INSTANT_PEAKS respects year inputs", {
  df <- ANNUAL_INSTANT_PEAKS(STATION_NUMBER = c("08NM083", "08NE102"), hydat_path = "H:/Hydat.sqlite3", start_year = 1981, end_year = 2007)
  expect_equal(2007, max(df$YEAR))
  expect_equal(1981, min(df$YEAR))
})
