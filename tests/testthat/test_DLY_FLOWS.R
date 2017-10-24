context("Testing hy_daily_flows")

test_that("hy_daily_flows accepts single and multiple station arguments", {
  stns <- "08MF005"
  expect_identical(unique(hy_daily_flows(STATION_NUMBER = stns, 
                                    hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER), stns)
  expect_identical(length(unique(hy_daily_flows(STATION_NUMBER = c("08MF005", "05AA008"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("hy_daily_flows accepts single and multiple province arguments", {
  expect_true(nrow(hy_daily_flows(PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
  expect_true(nrow(hy_daily_flows(PROV_TERR_STATE_LOC = c("BC", "YT"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("hy_daily_flows produces an error when a province is not specified correctly", {
  expect_error(hy_daily_flows(PROV_TERR_STATE_LOC = "BCD", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
  expect_error(hy_daily_flows(PROV_TERR_STATE_LOC = c("YT", "BCD"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
})

## Too much data
# test_that("hy_daily_flows gather data when no arguments are supplied",{
#  expect_true(nrow(hy_daily_flows(hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
# })

test_that("hy_daily_flows can accept both arguments for backward compatability", {
  expect_true(nrow(hy_daily_flows(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})


test_that("hy_daily_flows respects Date specification", {
  date_vector <- c("2013-01-01", "2014-01-01")
  temp_df <- hy_daily_flows(
    STATION_NUMBER = "08MF005", PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"),
    start_date = date_vector[1],
    end_date = date_vector[2]
  )
  expect_identical(c(min(temp_df$Date), max(temp_df$Date)), as.Date(date_vector))
})

test_that("hy_daily_flows correctly parses leaps year", {
  expect_warning(hy_daily_flows(
    PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"),
    start_date = "1988-02-29",
    end_date = "1988-02-29"
  ), regexp = NA)
})


test_that("When hy_daily_flows is ALL there is an error", {
  expect_error(hy_daily_flows(STATION_NUMBER = "ALL"))
})
