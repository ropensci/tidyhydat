context("Testing hy_annual_instant_peaks")

test_that("hy_annual_instant_peaks accepts single and multiple province arguments", {
  stns <- "08NM083"
  expect_identical(unique(hy_annual_instant_peaks(station_number = stns, hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER), stns)
  expect_identical(length(unique(hy_annual_instant_peaks(station_number = c("08NM083", "08NE102"), 
                                                         hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("hy_annual_instant_peaks accepts single and multiple province arguments", {
  expect_true(nrow(hy_annual_instant_peaks(prov_terr_state_loc = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
  expect_true(nrow(hy_annual_instant_peaks(prov_terr_state_loc = c("BC", "YT"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("hy_annual_instant_peaks produces an error when a province is not specified correctly", {
  expect_error(hy_annual_instant_peaks(prov_terr_state_loc = "BCD", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
  expect_error(hy_annual_instant_peaks(prov_terr_state_loc = c("AB", "BCD"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
})

test_that("hy_annual_instant_peaks gather data when no arguments are supplied", {
  expect_true(nrow(hy_annual_instant_peaks(hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("hy_annual_instant_peaks can accept both arguments for backward compatability", {
  expect_true(nrow(hy_annual_instant_peaks(prov_terr_state_loc = "BC", station_number = "08MF005", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})


test_that("hy_annual_instant_peaks respects year inputs", {
  df <- hy_annual_instant_peaks(station_number = c("08NM083", "08NE102"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"), start_year = 1981, end_year = 2007)
  expect_equal(2007, max(df$YEAR))
  expect_equal(1981, min(df$YEAR))
})
