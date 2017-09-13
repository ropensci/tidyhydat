context("Testing SED_SAMPLES")

test_that("SED_SAMPLES accepts single and multiple province arguments", {
  stns <- "05AA008"
  expect_identical(unique(SED_SAMPLES(STATION_NUMBER = stns, 
                                          hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER), stns)
  expect_identical(length(unique(SED_SAMPLES(STATION_NUMBER = c("05AA008", "08MF005"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("SED_SAMPLES accepts single and multiple province arguments", {
  expect_true(nrow(SED_SAMPLES(PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
  expect_true(nrow(SED_SAMPLES(PROV_TERR_STATE_LOC = c("BC", "AB"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("SED_SAMPLES produces an error when a province is not specified correctly", {
  expect_error(SED_SAMPLES(PROV_TERR_STATE_LOC = "BCD", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
  expect_error(SED_SAMPLES(PROV_TERR_STATE_LOC = c("BC", "BCD"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
})

## Too much data
# test_that("SED_SAMPLES gather data when no arguments are supplied",{
#  expect_true(nrow(SED_SAMPLES(hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
# })

test_that("SED_SAMPLES can accept both arguments for backward compatability", {
  expect_true(nrow(SED_SAMPLES(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})


test_that("SED_SAMPLES respects Date specification", {
  date_vector <- c("1965-06-01", "1966-03-01")
  expect_error(SED_SAMPLES(
    STATION_NUMBER = "08MF005", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"),
    start_date = date_vector[1],
    end_date = date_vector[2]
  ), regexp = NA)
})

test_that("SED_SAMPLES correctly parses leaps year", {
  expect_warning(SED_SAMPLES(
    PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"),
    start_date = "1976-02-29",
    end_date = "1976-02-29"
  ), regexp = NA)
})
