context("Testing realtime_network_meta ")

 test_that("realtime_network_meta returns a data frame", {
   expect_silent(realtime_network_meta(PROV_TERR_STATE_LOC = "BC"))
 })

 
