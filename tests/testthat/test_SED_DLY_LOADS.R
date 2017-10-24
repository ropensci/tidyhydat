context("Testing hy_sed_daily_loads")

test_that("hy_sed_daily_loads accepts single and multiple province arguments", {
  stns <- "05AA008"
  expect_identical(unique(hy_sed_daily_loads(STATION_NUMBER = stns, 
                                        hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER), stns)
  expect_identical(length(unique(hy_sed_daily_loads(STATION_NUMBER = c("05AA008", "08MF005"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("hy_sed_daily_loads accepts single and multiple province arguments", {
  expect_true(nrow(hy_sed_daily_loads(PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
  expect_true(nrow(hy_sed_daily_loads(PROV_TERR_STATE_LOC = c("BC", "AB"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})

test_that("hy_sed_daily_loads produces an error when a province is not specified correctly", {
  expect_error(hy_sed_daily_loads(PROV_TERR_STATE_LOC = "BCD", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
  expect_error(hy_sed_daily_loads(PROV_TERR_STATE_LOC = c("AB", "BCD"), hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")))
})

## Too much data
# test_that("hy_sed_daily_loads gather data when no arguments are supplied",{
#  expect_true(nrow(hy_sed_daily_loads(hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
# })

test_that("hy_sed_daily_loads can accept both arguments for backward compatability", {
  expect_true(nrow(hy_sed_daily_loads(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
})


test_that("hy_sed_daily_loads respects Date specification", {
  date_vector <- c("1965-06-01", "1966-03-01")
  temp_df <- hy_sed_daily_loads(
    STATION_NUMBER = "08MF005", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"),
    start_date = date_vector[1],
    end_date = date_vector[2]
  )
  expect_identical(c(min(temp_df$Date), max(temp_df$Date)), as.Date(date_vector))
})

test_that("hy_sed_daily_loads correctly parses leaps year", {
  expect_warning(hy_sed_daily_loads(
    PROV_TERR_STATE_LOC = "BC", hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"),
    start_date = "1976-02-29",
    end_date = "1976-02-29"
  ), regexp = NA)
})
