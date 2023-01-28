test_that("hy_stn_remarks returns a dataframe", {
  expect_s3_class(
    hy_stn_remarks(
      station_number = "08MF005",
      hydat_path = hy_test_db()
    ),
    class = "tbl_df"
  )
})

test_that("hy_stn_datum_conv returns a dataframe", {
  expect_s3_class(
    hy_stn_datum_conv(
      station_number = "08MF005",
      hydat_path = hy_test_db()
    ),
    class = "tbl_df"
  )
})

## Not testing STN_DATUM_UNRELALTED because there are so few stations in the database

test_that("hy_stn_data_range returns a dataframe", {
  expect_s3_class(
    hy_stn_data_range(
      station_number = "08MF005",
      hydat_path = hy_test_db()
    ),
    class = "tbl_df"
  )
})

test_that("hy_stn_data_coll returns a dataframe", {
  expect_s3_class(
    hy_stn_data_coll(
      station_number = "08MF005",
      hydat_path = hy_test_db()
    ),
    class = "tbl_df"
  )
})

test_that("hy_stn_op_schedule returns a dataframe", {
  expect_s3_class(
    hy_stn_op_schedule(
      station_number = "08MF005",
      hydat_path = hy_test_db()
    ),
    class = "tbl_df"
  )
})


test_that("hy_stn_data_range contains properly coded NA's", {
  expect_true(is.na(hy_stn_data_range(hydat_path = hy_test_db())$SED_DATA_TYPE[1]))
})
