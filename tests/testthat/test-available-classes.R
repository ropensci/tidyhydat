# Tests for available class

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

test_that("print.available displays metadata correctly", {
  df <- data.frame(
    STATION_NUMBER = c("08MF005", "08MF005", "08MF005"),
    Date = as.Date(c("2020-01-01", "2020-06-01", "2020-12-01")),
    Parameter = c("Flow", "Flow", "Flow"),
    Value = c(10.5, 11.2, 12.3),
    Symbol = c(NA_character_, NA_character_, NA_character_),
    Approval = c("final", "final", "provisional")
  )

  result <- as.available(df)
  attr(result, "historical_source") <- "HYDAT"
  attr(result, "missed_stns") <- character(0)

  # Capture the printed output
  output <- capture.output(print(result))

  # Check that key elements are present in the output
  expect_true(any(grepl("Queried on:", output)))
  expect_true(any(grepl("Historical data source: HYDAT", output)))
  expect_true(any(grepl("Final data range:", output)))
  expect_true(any(grepl("Provisional data range:", output)))
  expect_true(any(grepl("Records by approval status:", output)))
  expect_true(any(grepl("Station\\(s\\) returned:", output)))
})

test_that("print.available handles missing final data", {
  df <- data.frame(
    STATION_NUMBER = c("08MF005", "08MF005"),
    Date = as.Date(c("2020-12-01", "2020-12-02")),
    Parameter = c("Flow", "Flow"),
    Value = c(12.3, 13.1),
    Symbol = c(NA_character_, NA_character_),
    Approval = c("provisional", "provisional")
  )

  result <- as.available(df)
  attr(result, "historical_source") <- "Web Service"

  output <- capture.output(print(result))

  expect_true(any(grepl("No final data", output)))
  expect_true(any(grepl("Provisional data range:", output)))
})

test_that("print.available handles missing provisional data", {
  df <- data.frame(
    STATION_NUMBER = c("08MF005", "08MF005"),
    Date = as.Date(c("2020-01-01", "2020-01-02")),
    Parameter = c("Flow", "Flow"),
    Value = c(10.5, 11.2),
    Symbol = c(NA_character_, NA_character_),
    Approval = c("final", "final")
  )

  result <- as.available(df)
  attr(result, "historical_source") <- "HYDAT"

  output <- capture.output(print(result))

  expect_true(any(grepl("Final data range:", output)))
  expect_true(any(grepl("No provisional data", output)))
})

test_that("print.available shows missed stations", {
  df <- data.frame(
    STATION_NUMBER = c("08MF005", "08MF005"),
    Date = as.Date(c("2020-01-01", "2020-01-02")),
    Parameter = c("Flow", "Flow"),
    Value = c(10.5, 11.2),
    Symbol = c(NA_character_, NA_character_),
    Approval = c("final", "provisional")
  )

  result <- as.available(df)
  attr(result, "missed_stns") <- c("08NM116", "08NL071")

  output <- capture.output(print(result))

  expect_true(any(grepl("Stations requested but not returned:", output)))
  expect_true(any(grepl("08NM116", output)))
  expect_true(any(grepl("08NL071", output)))
})

test_that("print.available handles many missed stations", {
  df <- data.frame(
    STATION_NUMBER = c("08MF005"),
    Date = as.Date(c("2020-01-01")),
    Parameter = c("Flow"),
    Value = c(10.5),
    Symbol = c(NA_character_),
    Approval = c("final")
  )

  result <- as.available(df)
  # Create more than 10 missed stations
  attr(result, "missed_stns") <- paste0("STN", sprintf("%03d", 1:15))

  output <- capture.output(print(result))

  expect_true(any(grepl("More than 10 stations", output)))
})

test_that("available_flows handles 'No data exists' error from realtime_ws gracefully", {

  # This tests that when realtime_ws returns no data (empty CSV),
  # available_flows continues and returns only the final/validated data
  httptest2::with_mock_dir("fixtures", {
    result <- available_flows(
      station_number = "05AA008",  # Station with flow data in test database
      hydat_path = hy_test_db(),
      start_date = as.Date("1910-07-01"),
      end_date = as.Date("1910-07-05")
    )

    # Should have data from HYDAT (final)
    expect_s3_class(result, "available")
    expect_true(nrow(result) > 0)

    # All data should be "final" (no provisional data)
    expect_true(all(result$Approval == "final"))

    # Should not have any provisional data
    expect_false(any(result$Approval == "provisional"))
  })
})

