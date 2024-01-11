test_that("realtime_ws returns the correct data header", {
  skip_on_cran()

  ws_test <- realtime_ws(
    station_number = "08MF005",
    parameters = c(46), ## Water level
    start_date = Sys.Date(),
    end_date = Sys.Date()
  )

  expect_identical(
    colnames(ws_test),
    c(
      "STATION_NUMBER", "Date", "Name_En", "Value", "Unit", "Grade",
      "Symbol", "Approval", "Parameter", "Code"
    )
  )

  ## Turned #42 into a test
  expect_true(is.numeric(ws_test$Value))
})


test_that("realtime_ws fails with incorrectly specified date", {
  skip_on_cran()

  expect_error(realtime_ws(
    station_number = "08MF005",
    parameters = 46,
    start_date = "01-01-2017 00:00:00"
  ))
  expect_error(realtime_ws(
    station_number = "08MF005",
    parameters = 46,
    end_date = "01-01-2017 00:00:00"
  ))
})

test_that("realtime_ws succeed specifying only date; no time", {
  skip_on_cran()

  today <- as.Date(as.POSIXct(Sys.time(), tz = "UTC"))
  sdate <- today - 1
  edate <- today

  output <- realtime_ws(
    station_number = "08MF005",
    parameters = 46,
    start_date = sdate,
    end_date = edate
  )

  expect_equal(as.Date(max(output$Date)), edate)
  expect_equal(as.Date(min(output$Date)), sdate)
})

test_that("realtime_ws succeed specifying  time", {
  skip_on_cran()

  stime <- as.POSIXlt(Sys.time() - 1E5, tz = "UTC")
  etime <- as.POSIXlt(Sys.time(), tz = "UTC")

  output <- realtime_ws(
    station_number = "08MF005",
    parameters = 46,
    start_date = stime,
    end_date = etime
  )

  expect_true(max(output$Date) <= etime)
  expect_true(min(output$Date) >= stime)
})
