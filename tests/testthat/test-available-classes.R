# Tests for available class
# These tests use httptest2 to mock HTTP responses

test_that("as.available creates available class", {
  df <- data.frame(
    STATION_NUMBER = c("08MF005", "08MF005"),
    Date = as.Date(c("2020-01-01", "2020-01-02")),
    Parameter = c("Flow", "Flow"),
    Value = c(10.5, 11.2),
    Symbol = c(NA_character_, NA_character_),
    Approval = c("final", "provisional")
  )

  result <- as.available(df)

  expect_s3_class(result, "available")
  expect_true(!is.null(attr(result, "query_time")))
  expect_s3_class(attr(result, "query_time"), "POSIXct")
})

test_that("available_flows returns correct structure with HYDAT", {
  httptest2::with_mock_dir("fixtures", {
    result <- available_flows(
      station_number = "05AA008",
      hydat_path = hy_test_db(),
      start_date = as.Date("1910-07-01"),
      end_date = as.Date("1910-07-05")
    )

    expect_s3_class(result, "available")
    expect_true(nrow(result) > 0)
    expect_identical(
      colnames(result),
      c("STATION_NUMBER", "Date", "Parameter", "Value", "Symbol", "Approval")
    )
    expect_equal(attr(result, "historical_source"), "HYDAT")
  })
})

test_that("available_flows handles final-only data gracefully", {
  # When realtime_ws returns no data, should return only final data
  httptest2::with_mock_dir("fixtures", {
    result <- available_flows(
      station_number = "05AA008",
      hydat_path = hy_test_db(),
      start_date = as.Date("1910-07-01"),
      end_date = as.Date("1910-07-05")
    )

    expect_s3_class(result, "available")
    expect_true(all(result$Approval == "final"))
    expect_false(any(result$Approval == "provisional"))
  })
})

test_that("print.available displays expected content", {
  httptest2::with_mock_dir("fixtures", {
    result <- available_flows(
      station_number = "05AA008",
      hydat_path = hy_test_db(),
      start_date = as.Date("1910-07-01"),
      end_date = as.Date("1910-07-05")
    )

    output <- capture.output(print(result))

    expect_true(any(grepl("Queried on:", output)))
    expect_true(any(grepl("Historical data source: HYDAT", output)))
    expect_true(any(grepl("Overall date range:", output)))
    expect_true(any(grepl("Flow records by approval status:", output)))
    expect_true(any(grepl("Station\\(s\\) returned:", output)))
    expect_true(any(grepl("Use summary\\(\\)", output)))
  })
})

test_that("summary.available returns correct structure", {
  httptest2::with_mock_dir("fixtures", {
    result <- available_flows(
      station_number = "05AA008",
      hydat_path = hy_test_db(),
      start_date = as.Date("1910-07-01"),
      end_date = as.Date("1910-07-05")
    )

    summ <- summary(result)
    expect_s3_class(summ, "tbl_df")
    expect_true("STATION_NUMBER" %in% names(summ))
    expect_true("final_start" %in% names(summ) || "provisional_start" %in% names(summ))
  })
})

