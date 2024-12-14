test_that("historical_ws returns the correct data header", {
  skip_on_cran()

  ws_test <- historical_ws(
    station_number = "08MF005",
    parameters = "level"
  )

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

  empty = historical_ws(
    station_number = "08MF005",
    parameters = "level",
    start_date = Sys.Date() - 2
  )
  expect_true(nrow(empty) == 0)
})


