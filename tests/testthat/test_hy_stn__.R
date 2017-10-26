context("Testing minor lookup tables for STN_* functions")

test_that("hy_stn_remarks returns a dataframe", {
  expect_is(hy_stn_remarks(
    station_number = "08MF005",
    hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
  ),
  class = "tbl_df")
})

test_that("hy_stn_datum_conv returns a dataframe", {
  expect_is(hy_stn_datum_conv(
    station_number = "08MF005",
    hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
  ),
  class = "tbl_df")
})

##Not testing STN_DATUM_UNRELALTED because there are so few stations in the database

test_that("hy_stn_data_range returns a dataframe", {
  expect_is(hy_stn_data_range(
    station_number = "08MF005",
    hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
  ),
  class = "tbl_df")
})

test_that("hy_stn_data_coll returns a dataframe", {
  expect_is(hy_stn_data_coll(
    station_number = "08MF005",
    hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
  ),
  class = "tbl_df")
})

test_that("hy_stn_op_schedule returns a dataframe", {
  expect_is(hy_stn_op_schedule(
    station_number = "08MF005",
    hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
  ),
  class = "tbl_df")
})

##Not testing STN_DATUM_UNRELALTED because there are so few stations in the database
