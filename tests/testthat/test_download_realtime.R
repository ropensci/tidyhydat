context("Testing download_realtime2")

test_that("download_realtime2 returns the correct data header", {
  
  expect_identical(colnames(download_realtime2(STATION_NUMBER = "08MF005", PROV_TERR_STATE_LOC = "BC")), 
                   c("STATION_NUMBER", "Date", "LEVEL", "LEVEL_GRADE", "LEVEL_SYMBOL", 
                     "LEVEL_CODE", "FLOW", "FLOW_GRADE", "FLOW_SYMBOL", "FLOW_CODE"))
})
