context("Testing realtime functions")

 test_that("realtime_ws returns the correct data header", {
  skip_on_cran()
  skip_on_travis()
  token_out <- token_ws(username = Sys.getenv("WS_USRNM"), password = Sys.getenv("WS_PWD"))

  ws_test <- realtime_ws(STATION_NUMBER = "08MF005",
                               parameters = c(46), ## Water level and temperature
                               start_date = Sys.Date(),
                               end_date = Sys.Date(),
                               token = token_out)

  expect_identical(colnames(ws_test),
                   c("STATION_NUMBER", "Date", "Name_En", "Value", "Unit", "Grade",
                     "Symbol", "Approval", "Parameter", "Code"))
  
  ## Turned #42 into a test
  expect_is(ws_08$Value, "numeric")
 })
 
 
 test_that("realtime_dd returns the correct data header", {
   skip_on_cran()
   expect_identical(
     colnames(realtime_dd(STATION_NUMBER = "08MF005", PROV_TERR_STATE_LOC = "BC")),
     c("STATION_NUMBER", "PROV_TERR_STATE_LOC", "Date", "Parameter", "Value", "Grade", "Symbol", "Code")
  )
})

test_that("realtime_dd can download stations from multiple provinces using PROV_TERR_STATE_LOC", {
  skip_on_cran()
  realtime_dd(PROV_TERR_STATE_LOC = c("QC", "PE"))
})


test_that("realtime_dd can download stations from multiple provinces using STATION_NUMBER", {
  skip_on_cran()
  expect_error(realtime_dd(STATION_NUMBER = c("01CD005", "08MF005")), regexp = NA)
})

test_that("When STATION_NUMBER is ALL there is an error", {
  skip_on_cran()
  expect_error(realtime_dd(STATION_NUMBER = "ALL"))
})
