# Tests for historical webservice functions
# These tests use httptest2 to mock HTTP responses
# To re-record fixtures, see tests/testthat/record_fixtures.R

httptest2::with_mock_dir("fixtures", {
  test_that("hy_daily_flows with hydat_path = FALSE returns the correct data header", {
    ws_test <- hy_daily_flows(
      station_number = "08MF005",
      hydat_path = FALSE,
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


  test_that("hy_daily_flows with hydat_path = FALSE is empty with a nearish date", {
    # using a fixed date that was empty on the date of fixture creation
    expect_error(hy_daily_flows(
      station_number = "08MF005",
      hydat_path = FALSE,
      start_date = as.Date("2025-10-27"),
      end_date = as.Date("2025-10-29")
    ), "No data exists for this station query during the period chosen")
  })

  test_that("hy_daily_levels with hydat_path = FALSE returns the correct data header", {
    ws_test <- hy_daily_levels(
      station_number = "08MF005",
      hydat_path = FALSE,
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


  test_that("hy_daily_levels with hydat_path = FALSE is empty with a nearish date", {
    # using a fixed date that was empty on the date of fixture creation
    expect_error(hy_daily_levels(
      station_number = "08MF005",
      hydat_path = FALSE,
      start_date = as.Date("2025-10-27"),
      end_date = as.Date("2025-10-29")
    ), "No data exists for this station query during the period chosen")
  })
})

test_that("hy_daily_flows with hydat_path = FALSE errors informatively with no dates given", {
  expect_error(
    hy_daily_flows(
      station_number = "08MF005",
      hydat_path = FALSE
    ),
    "start_date is required when using web service"
  )

  expect_error(
    hy_daily_flows(
      station_number = "08MF005",
      hydat_path = FALSE,
      start_date = Sys.Date()
    ),
    "end_date is required when using web service"
  )
})

test_that("hy_daily_flows with hydat_path = FALSE errors when end_date is before start_date", {
  expect_error(
    hy_daily_flows(
      station_number = "08MF005",
      hydat_path = FALSE,
      start_date = Sys.Date(),
      end_date = Sys.Date() - 10
    ),
    "end_date must be after start_date"
  )
})

test_that("hy_daily_flows with hydat_path = FALSE accepts Date objects", {
  skip_if_not_installed("httptest2")

  httptest2::with_mock_dir("fixtures", {
    result <- hy_daily_flows(
      station_number = "08MF005",
      hydat_path = FALSE,
      start_date = as.Date("2023-01-01"),
      end_date = as.Date("2023-12-31")
    )

    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
  })
})
