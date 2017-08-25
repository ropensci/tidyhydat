context("Testing DLY_LEVELS")

test_that("DLY_LEVELS accepts single and multiple province arguments", {
  stns <- "08MF005"
  expect_identical( unique(DLY_LEVELS(STATION_NUMBER = stns, hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER), stns)
  expect_identical( length(unique(DLY_LEVELS(STATION_NUMBER = c("08MF005","08KH001"), hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER)),length(c("08NM083","08NE102")))
})


test_that("DLY_LEVELS accepts single and multiple province arguments", {
  expect_true( nrow(DLY_LEVELS(PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")) >= 1)
  expect_true( nrow(DLY_LEVELS(PROV_TERR_STATE_LOC = c("ID","PE"), hydat_path = "H:/Hydat.sqlite3")) >= 1)
})

test_that("DLY_LEVELS produces an error when a province is not specified correctly",{
  expect_error(DLY_LEVELS(PROV_TERR_STATE_LOC = "BCD", hydat_path = "H:/Hydat.sqlite3"))
  expect_error(DLY_LEVELS(PROV_TERR_STATE_LOC = c("ID","BCD"), hydat_path = "H:/Hydat.sqlite3"))
})

## Too much data 
#test_that("DLY_LEVELS gather data when no arguments are supplied",{
#  expect_true(nrow(DLY_LEVELS(hydat_path = "H:/Hydat.sqlite3")) >= 1)
#})

test_that("DLY_LEVELS can accept both arguments for backward compatability",{
  expect_true(nrow(DLY_LEVELS(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = "H:/Hydat.sqlite3")) >= 1)
})


test_that("DLY_LEVELS respects Date specification", {
  date_vector = c("2013-01-01","2014-01-01")
  temp_df <- DLY_LEVELS(STATION_NUMBER = "08MF005", PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3",
                       start_date = date_vector[1] ,
                       end_date = date_vector[2])
  expect_identical(c(min(temp_df$Date), max(temp_df$Date)), as.Date(date_vector) )
  
})

test_that("DLY_LEVELS correctly parses leaps year",{
  expect_warning(DLY_LEVELS(PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3",
                            start_date = "1988-02-29" ,
                            end_date = "1988-02-29"), regexp = NA)
})
