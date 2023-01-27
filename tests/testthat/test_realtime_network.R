test_that("realtime_network_meta returns a data frame", {
  skip_if_net_down()
  skip_on_cran()
  expect_silent(realtime_stations(prov_terr_state_loc = "BC"))
})
