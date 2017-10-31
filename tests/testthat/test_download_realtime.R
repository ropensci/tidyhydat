context("Testing realtime functions")

 test_that("realtime_ws returns the correct data header", {
  skip_on_cran()
  skip_on_travis()
  token_out <- token_ws()

  ws_test <- realtime_ws(station_number = "08MF005",
                               parameters = c(46),  ## Water level and temperature
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
     colnames(realtime_dd(station_number = "08MF005", prov_terr_state_loc = "BC")),
     c("STATION_NUMBER", "PROV_TERR_STATE_LOC", "Date", "Parameter", "Value", "Grade", "Symbol", "Code")
  )
})

test_that("realtime_dd can download stations from multiple provinces using prov_terr_state_loc", {
  skip_on_cran()
  expect_silent(realtime_dd(prov_terr_state_loc = c("QC", "PE")))
})


test_that("realtime_dd can download stations from multiple provinces using station_number", {
  skip_on_cran()
  expect_error(realtime_dd(station_number = c("01CD005", "08MF005")), regexp = NA)
})

test_that("When station_number is ALL there is an error", {
  skip_on_cran()
  expect_error(realtime_dd(station_number = "ALL"))
})
