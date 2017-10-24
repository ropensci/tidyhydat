context("Testing realtime_stations ")

 test_that("realtime_network_meta returns a data frame", {
   expect_silent(realtime_stations(PROV_TERR_STATE_LOC = "BC"))
 })

 
