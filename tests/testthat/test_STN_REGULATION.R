context("Testing STN_REGULATION")

test_that("STN_REGULATION accepts single and multiple province arguments", {
  stns <- "08NM083"
  expect_identical(unique(STN_REGULATION(STATION_NUMBER = stns, hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER), stns)
  expect_identical(length(unique(STN_REGULATION(STATION_NUMBER = c("08NM083", "08NE102"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("STN_REGULATION accepts single and multiple province arguments", {
  expect_true(nrow(STN_REGULATION(PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
  expect_true(nrow(STN_REGULATION(PROV_TERR_STATE_LOC = c("BC", "YT"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("STN_REGULATION produces an error when a province is not specified correctly", {
  expect_error(STN_REGULATION(PROV_TERR_STATE_LOC = "BCD", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
  expect_error(STN_REGULATION(PROV_TERR_STATE_LOC = c("AB", "BCD"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
})

test_that("STN_REGULATION gather data when no arguments are supplied", {
  expect_true(nrow(STN_REGULATION(hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("STN_REGULATION can accept both arguments for backward compatability", {
  expect_true(nrow(STN_REGULATION(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})
