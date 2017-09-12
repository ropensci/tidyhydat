context("Testing STATIONS")

test_that("STATIONS accepts single and multiple province arguments", {
  stns <- "08NM083"
  expect_identical(unique(STATIONS(STATION_NUMBER = stns, hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER), stns)
  expect_identical(length(unique(STATIONS(STATION_NUMBER = c("08NM083", "08NE102"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("STATIONS accepts single and multiple province arguments", {
  prov <- c("BC")
  expect_identical(unique(STATIONS(PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$PROV_TERR_STATE_LOC), prov)
  expect_identical(unique(STATIONS(PROV_TERR_STATE_LOC = c("AB", "YT"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$PROV_TERR_STATE_LOC), c("AB", "YT"))
})

test_that("STATIONS produces an error when a province is not specified correctly", {
  expect_error(STATIONS(PROV_TERR_STATE_LOC = "BCD", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
  expect_error(STATIONS(PROV_TERR_STATE_LOC = c("AB", "BCD"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
})

test_that("STATIONS gather data when no arguments are supplied", {
  expect_true(nrow(STATIONS(hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("STATIONS can accept both arguments for backward compatability", {
  expect_true(nrow(STATIONS(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})
