context("Testing minor lookup tables for STN_ functions")

test_that("STN_REMARKS returns a dataframe", {
  expect_is(STN_REMARKS(STATION_NUMBER = "08MF005", 
                        hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")), class = "tbl_df") 
})

test_that("STN__DATUM_CONVERSION returns a dataframe", {
  expect_is(STN_DATUM_CONVERSION(STATION_NUMBER = "08MF005", 
                                 hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")), class = "tbl_df")
})

test_that("STN_DATA_RANGE returns a dataframe", {
  expect_is(STN_DATA_RANGE(STATION_NUMBER = "08MF005", 
                           hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")), class = "tbl_df")
})

test_that("STN_DATA_COLLECTION returns a dataframe", {
  expect_is(STN_DATA_COLLECTION(STATION_NUMBER = "08MF005", 
                                hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")), class = "tbl_df")
})

test_that("STN_OPERATION_SCHEDULE returns a dataframe", {
  expect_is(STN_OPERATION_SCHEDULE(STATION_NUMBER = "08MF005", 
                                   hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")), class = "tbl_df")
})

##Not testing STN_DATUM_UNRELALTED because there are so few stations in the database
