# Tests for realtime webservice functions
# These tests use httptest2 to mock HTTP responses

httptest2::with_mock_dir("fixtures", {
  test_that("realtime_ws returns the correct data header", {
    ws_test <- realtime_ws(
      station_number = "08MF005",
      parameters = c(46), ## Water level
      start_date = as.Date("2025-10-22"),
      end_date = as.Date("2025-10-22")
    )

    expect_identical(
      colnames(ws_test),
      c(
        "STATION_NUMBER",
        "Date",
        "Name_En",
        "Value",
        "Unit",
        "Grade",
        "Symbol",
        "Approval",
        "Parameter",
        "Code",
        "Qualifier",
        "Qualifiers"
      )
    )

    ## Turned #42 into a test
    expect_true(is.numeric(ws_test$Value))
  })

  test_that("realtime_ws succeed specifying only date; no time", {
    output <- realtime_ws(
      station_number = "08MF005",
      parameters = 46,
      start_date = as.Date("2025-10-21"),
      end_date = as.Date("2025-10-22")
    )

    expect_s3_class(output, "tbl_df")
    expect_true(nrow(output) > 0)
    expect_equal(unique(output$STATION_NUMBER), "08MF005")
  })
})

# Date validation tests don't make HTTP calls, so they're outside the mock context
test_that("realtime_ws fails with incorrectly specified date", {
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

test_that("realtime_ws handles Date objects", {
  skip_if_not_installed("httptest2")

  httptest2::with_mock_dir("fixtures", {
    # Date objects should work (converted to strings internally)
    output <- realtime_ws(
      station_number = "08MF005",
      parameters = 46,
      start_date = as.Date("2025-10-21"),
      end_date = as.Date("2025-10-22")
    )

    expect_s3_class(output, "tbl_df")
    expect_true(nrow(output) > 0)
    expect_equal(unique(output$Parameter), 46)
  })
})
