context("Testing DLY_FLOWS")

test_that("DLY_FLOWS accepts single and multiple station arguments", {
  stns <- "08MF005"
  expect_identical(unique(DLY_FLOWS(STATION_NUMBER = stns, 
                                    hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER), stns)
  expect_identical(length(unique(DLY_FLOWS(STATION_NUMBER = c("08MF005", "05AA008"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("DLY_FLOWS accepts single and multiple province arguments", {
  expect_true(nrow(DLY_FLOWS(PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
  expect_true(nrow(DLY_FLOWS(PROV_TERR_STATE_LOC = c("BC", "YT"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("DLY_FLOWS produces an error when a province is not specified correctly", {
  expect_error(DLY_FLOWS(PROV_TERR_STATE_LOC = "BCD", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
  expect_error(DLY_FLOWS(PROV_TERR_STATE_LOC = c("YT", "BCD"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
})

## Too much data
# test_that("DLY_FLOWS gather data when no arguments are supplied",{
#  expect_true(nrow(DLY_FLOWS(hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
# })

test_that("DLY_FLOWS can accept both arguments for backward compatability", {
  expect_true(nrow(DLY_FLOWS(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})


test_that("DLY_FLOWS respects Date specification", {
  date_vector <- c("2013-01-01", "2014-01-01")
  temp_df <- DLY_FLOWS(
    STATION_NUMBER = "08MF005", PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"),
    start_date = date_vector[1],
    end_date = date_vector[2]
  )
  expect_identical(c(min(temp_df$Date), max(temp_df$Date)), as.Date(date_vector))
})

test_that("DLY_FLOWS correctly parses leaps year", {
  expect_warning(DLY_FLOWS(
    PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"),
    start_date = "1988-02-29",
    end_date = "1988-02-29"
  ), regexp = NA)
})


test_that("When DLY_FLOWS is ALL there is an error", {
  expect_error(DLY_FLOWS(STATION_NUMBER = "ALL"))
})
