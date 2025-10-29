# Tests for historical webservice functions
# These tests use httptest2 to mock HTTP responses
# To re-record fixtures, see tests/testthat/record_fixtures.R

httptest2::with_mock_dir("fixtures", {
  test_that("ws_daily_flows returns the correct data header", {
    ws_test <- ws_daily_flows(
      station_number = "08MF005",
      start_date = as.Date("2023-01-01"),
      end_date = as.Date("2023-12-31")
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
    expect_error(ws_daily_flows(
      station_number = "08MF005",
      start_date = Sys.Date() - 2,
      end_date = Sys.Date()
    ), "No data exists for this station query during the period chosen")
  })

  test_that("ws_daily_levels returns the correct data header", {
    ws_test <- ws_daily_levels(
      station_number = "08MF005",
      start_date = as.Date("2023-01-01"),
      end_date = as.Date("2023-12-31")
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
    expect_error(ws_daily_levels(
      station_number = "08MF005",
      start_date = Sys.Date() - 2,
      end_date = Sys.Date()
    ), "No data exists for this station query during the period chosen")
  })
})

test_that("get_historical_data error informatively with no dates given", {
  expect_error(
    get_historical_data(
      station_number = "08MF005"
    ),
    "please provide a valid date for the start_date argument"
  )

  expect_error(
    get_historical_data(
      station_number = "08MF005",
      start_date = Sys.Date()
    ),
    "please provide a valid date for the end_date argument"
  )
})

test_that("get_historical_data errors when end_date is before start_date", {
  expect_error(
    get_historical_data(
      station_number = "08MF005",
      start_date = Sys.Date(),
      end_date = Sys.Date() - 10
    ),
    "end_date must be after start_date"
  )
})

test_that("ws_daily_flows accepts Date objects", {
  skip_if_not_installed("httptest2")

  httptest2::with_mock_dir("fixtures", {
    result <- ws_daily_flows(
      station_number = "08MF005",
      start_date = as.Date("2023-01-01"),
      end_date = as.Date("2023-12-31")
    )

    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
  })
})
