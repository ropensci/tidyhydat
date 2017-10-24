context("Testing hy_sed_monthly_suscon")

test_that("hy_sed_monthly_suscon accepts single and multiple province arguments", {
  stns <- "08MF005"
  expect_identical(unique(hy_sed_monthly_suscon(STATION_NUMBER = stns, 
                                             hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER), stns)
  expect_identical(length(unique(hy_sed_monthly_suscon(STATION_NUMBER = c("08MF005", "05AA008"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("hy_sed_monthly_suscon accepts single and multiple province arguments", {
  expect_true(nrow(hy_sed_monthly_suscon(PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
  expect_true(nrow(hy_sed_monthly_suscon(PROV_TERR_STATE_LOC = c("BC", "AB"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("hy_sed_monthly_suscon produces an error when a province is not specified correctly", {
  expect_error(hy_sed_monthly_suscon(PROV_TERR_STATE_LOC = "BCD", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
  expect_error(hy_sed_monthly_suscon(PROV_TERR_STATE_LOC = c("AB", "BCD"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
})

test_that("hy_sed_monthly_suscon can accept both arguments for backward compatability", {
  expect_true(nrow(hy_sed_monthly_suscon(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})


test_that("When hy_sed_monthly_suscon is ALL there is an error", {
  expect_error(hy_sed_monthly_suscon(STATION_NUMBER = "ALL"))
})
