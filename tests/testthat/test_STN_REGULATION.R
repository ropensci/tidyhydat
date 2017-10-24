context("Testing hy_stn_regulation")

test_that("hy_stn_regulation accepts single and multiple province arguments", {
  stns <- "08NM083"
  expect_identical(unique(hy_stn_regulation(STATION_NUMBER = stns, hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER), stns)
  expect_identical(length(unique(hy_stn_regulation(STATION_NUMBER = c("08NM083", "08NE102"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("hy_stn_regulation accepts single and multiple province arguments", {
  expect_true(nrow(hy_stn_regulation(PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
  expect_true(nrow(hy_stn_regulation(PROV_TERR_STATE_LOC = c("BC", "YT"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("hy_stn_regulation produces an error when a province is not specified correctly", {
  expect_error(hy_stn_regulation(PROV_TERR_STATE_LOC = "BCD", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
  expect_error(hy_stn_regulation(PROV_TERR_STATE_LOC = c("AB", "BCD"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
})

test_that("hy_stn_regulation gather data when no arguments are supplied", {
  expect_true(nrow(hy_stn_regulation(hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("hy_stn_regulation can accept both arguments for backward compatability", {
  expect_true(nrow(hy_stn_regulation(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})
