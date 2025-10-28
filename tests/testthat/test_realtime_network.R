test_that("realtime_network_meta returns a data frame", {
  skip_if_net_down()
  skip_on_cran()
  expect_s3_class(realtime_stations(prov_terr_state_loc = "BC"), "tbl_df")
})

test_that("realtime_stations handles 404 gracefully", {
  skip_on_cran()
  local_mocked_bindings(
    realtime_parser = function(file) NA_character_
  )

  result <- realtime_stations(prov_terr_state_loc = "BC")
  expect_s3_class(result, "tbl_df")
  expect_true(all(is.na(result$STATION_NUMBER)))
  expect_true(all(is.na(result$STATION_NAME)))
})
