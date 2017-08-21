context("Testing download_realtime functions")

test_that("download_realtime2 returns the correct data header", {
  token_out <- get_ws_token(username = Sys.getenv("WS_USRNM"), password = Sys.getenv("WS_PWD"))
  
  ws_test <- download_realtime_ws(STATION_NUMBER = "08MF005",
                               parameters = c(46), ## Water level and temperature
                               start_date = Sys.Date(),
                               end_date = Sys.Date(),
                               token = token_out)
  
  expect_identical(colnames(ws_test), 
                   c("STATION_NUMBER", "Date", "Name_En", "Value", "Unit", "Grade", 
                     "Symbol", "Approval", "Parameter", "Code"))
})


test_that("download_realtime2 returns the correct data header", {
  
  expect_identical(colnames(download_realtime_dd(STATION_NUMBER = "08MF005", PROV_TERR_STATE_LOC = "BC")), 
                   c("STATION_NUMBER", "Date", "Parameter","Value","Grade", "Symbol","Code"))
})
