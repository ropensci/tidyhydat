test_that("historical_ws returns the correct data header", {
  skip_on_cran()

  ws_test <- ws_daily_flows(station_number = "08MF005")

  expect_identical(
    colnames(ws_test),
    c(
      "STATION_NUMBER", "Date", "Parameter", "Value", "Symbol"
    )
  )

  ## Turned #42 into a test
  expect_true(is.numeric(ws_test$Value))
})


test_that("historical_ws is empty is a nearish date", {
  skip_on_cran()

  expect_error(ws_daily_flows(
    station_number = "08MF005",
    start_date = Sys.Date() - 2
  ), "No data exists for this station query during the period chosen")
  
})


