context("Testing ANNUAL_STATISTICS")

test_that("ANNUAL_STATISTICS accepts single and multiple province arguments", {
  stns <- "08NM083"
  expect_identical(unique(ANNUAL_STATISTICS(STATION_NUMBER = stns, hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER), stns)
  expect_identical(length(unique(ANNUAL_STATISTICS(STATION_NUMBER = c("08NM083", "08NE102"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("ANNUAL_STATISTICS accepts single and multiple province arguments", {
  expect_true(nrow(ANNUAL_STATISTICS(PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
  expect_true(nrow(ANNUAL_STATISTICS(PROV_TERR_STATE_LOC = c("BC", "YT"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("ANNUAL_STATISTICS produces an error when a province is not specified correctly", {
  expect_error(ANNUAL_STATISTICS(PROV_TERR_STATE_LOC = "BCD", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
  expect_error(ANNUAL_STATISTICS(PROV_TERR_STATE_LOC = c("AB", "BCD"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
})

test_that("ANNUAL_STATISTICS gather data when no arguments are supplied", {
  expect_true(nrow(ANNUAL_STATISTICS(hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("ANNUAL_STATISTICS can accept both arguments for backward compatability", {
  expect_true(nrow(ANNUAL_STATISTICS(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("ANNUAL_STATISTICS respects year inputs", {
  df <- ANNUAL_STATISTICS(STATION_NUMBER = c("08NM083", "08NE102"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"), start_year = 1981, end_year = 2007)
  expect_equal(2007, max(df$Year))
  expect_equal(1981, min(df$Year))
})
