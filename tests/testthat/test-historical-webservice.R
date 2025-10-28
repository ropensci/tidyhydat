test_that("ws_daily_flows returns the correct data header", {
  skip_on_cran()

  ws_test <- ws_daily_flows(
    station_number = "08MF005",
    start_date = Sys.Date() - 365,
    end_date = Sys.Date()
  )

  expect_identical(
    colnames(ws_test),
    c(
      "STATION_NUMBER", "Date", "Parameter", "Value", "Symbol"
    )
  )
  expect_true(is.numeric(ws_test$Value))
})


test_that("ws_daily_flows is empty with a nearish date", {
  skip_on_cran()

  expect_error(ws_daily_flows(
    station_number = "08MF005",
    start_date = Sys.Date() - 2,
    end_date = Sys.Date()
  ), "No data exists for this station query during the period chosen")
})

test_that("ws_daily_levels returns the correct data header", {
  skip_on_cran()

  ws_test <- ws_daily_levels(
    station_number = "08MF005",
    start_date = Sys.Date(),
    end_date = Sys.Date() - 365
  )

  expect_identical(
    colnames(ws_test),
    c(
      "STATION_NUMBER", "Date", "Parameter", "Value", "Symbol"
    )
  )
  expect_true(is.numeric(ws_test$Value))
})


test_that("ws_daily_levels is empty with a nearish date", {
  skip_on_cran()

  expect_error(ws_daily_levels(
    station_number = "08MF005",
    start_date = Sys.Date() - 2
  ), "No data exists for this station query during the period chosen")
})

test_that("get_historical_data error informatively with no dates given",{
  expect_error(
    get_historical_data(
      station_number = "08MF005"
    ),
    "please provide a valid date for the start_date argument"
  )

  expect_error(
    get_historical_data(
      station_number = "08MF005",
      start_date = Sys.Date(),
      end_date = NULL
    ),
    "please provide a valid date for the start_date argument"
  )
})

test_that("function can take a string for date", {

})