# Tests for webservice class functionality

test_that("as.ws adds ws class to tibble", {
  df <- dplyr::tibble(
    STATION_NUMBER = "08MF005",
    Date = as.Date("2023-01-01"),
    Value = 1.5
  )

  ws_df <- as.ws(df)

  expect_s3_class(ws_df, "ws")
  expect_s3_class(ws_df, "tbl_df")
})

test_that("as.ws adds query_time attribute in UTC", {
  df <- dplyr::tibble(
    STATION_NUMBER = "08MF005",
    Date = as.Date("2023-01-01"),
    Value = 1.5
  )

  ws_df <- as.ws(df)

  expect_true(!is.null(attr(ws_df, "query_time")))
  expect_s3_class(attr(ws_df, "query_time"), "POSIXct")
  expect_equal(attr(attr(ws_df, "query_time"), "tzone"), "UTC")
})

test_that("print.ws displays query time and date range", {
  df <- dplyr::tibble(
    STATION_NUMBER = "08MF005",
    Date = as.Date(c("2023-01-01", "2023-12-31")),
    Value = c(1.5, 2.0)
  )

  ws_df <- as.ws(df)

  output <- capture.output(print(ws_df))

  expect_true(any(grepl("Queried on:", output)))
  expect_true(any(grepl("Date range:", output)))
  expect_true(any(grepl("2023-01-01 to 2023-12-31", output)))
})

test_that("print.ws displays station count", {
  df <- dplyr::tibble(
    STATION_NUMBER = c("08MF005", "08MF005", "08NM116"),
    Date = as.Date(c("2023-01-01", "2023-01-02", "2023-01-01")),
    Value = c(1.5, 2.0, 3.0)
  )

  ws_df <- as.ws(df)

  output <- capture.output(print(ws_df))

  expect_true(any(grepl("Station\\(s\\) returned:", output)))
  expect_true(any(grepl("2", output)))
})

test_that("print.ws displays missed stations when present", {
  df <- dplyr::tibble(
    STATION_NUMBER = "08MF005",
    Date = as.Date("2023-01-01"),
    Value = 1.5
  )

  ws_df <- as.ws(df)
  attr(ws_df, "missed_stns") <- c("08NM116", "08NL071")

  output <- capture.output(print(ws_df))

  expect_true(any(grepl("Stations requested but not returned:", output)))
  expect_true(any(grepl("08NM116", output)))
  expect_true(any(grepl("08NL071", output)))
})

test_that("print.ws displays success message when no stations missed", {
  df <- dplyr::tibble(
    STATION_NUMBER = "08MF005",
    Date = as.Date("2023-01-01"),
    Value = 1.5
  )

  ws_df <- as.ws(df)
  attr(ws_df, "missed_stns") <- character(0)

  output <- capture.output(print(ws_df))

  expect_true(any(grepl("All stations successfully retrieved", output)))
})

test_that("print.ws displays missed parameters when present", {
  df <- dplyr::tibble(
    STATION_NUMBER = "08MF005",
    Date = as.Date("2023-01-01"),
    Parameter = 46,
    Value = 1.5
  )

  ws_df <- as.ws(df)
  attr(ws_df, "missed_params") <- c(47, 48)

  output <- capture.output(print(ws_df))

  expect_true(any(grepl("Parameter\\(s\\) not retrieved:", output)))
  expect_true(any(grepl("47", output)))
  expect_true(any(grepl("48", output)))
})

test_that("print.ws displays success message when no parameters missed", {
  df <- dplyr::tibble(
    STATION_NUMBER = "08MF005",
    Date = as.Date("2023-01-01"),
    Parameter = 46,
    Value = 1.5
  )

  ws_df <- as.ws(df)
  attr(ws_df, "missed_params") <- numeric(0)

  output <- capture.output(print(ws_df))

  expect_true(any(grepl("All parameters successfully retrieved", output)))
})

test_that("print.ws handles data with no Date column", {
  df <- dplyr::tibble(
    STATION_NUMBER = "08MF005",
    Value = 1.5
  )

  ws_df <- as.ws(df)

  # Should not error and should display query time
  output <- capture.output(print(ws_df))
  expect_true(any(grepl("Queried on:", output)))
})

httptest2::with_mock_dir("fixtures", {
  test_that("ws_daily_flows returns ws class", {
    result <- ws_daily_flows(
      station_number = "08MF005",
      start_date = as.Date("2023-01-01"),
      end_date = as.Date("2023-12-31")
    )

    expect_s3_class(result, "ws")
    expect_true(!is.null(attr(result, "query_time")))
    expect_true(!is.null(attr(result, "missed_stns")))
  })

  test_that("ws_daily_levels returns ws class", {
    result <- ws_daily_levels(
      station_number = "08MF005",
      start_date = as.Date("2023-01-01"),
      end_date = as.Date("2023-12-31")
    )

    expect_s3_class(result, "ws")
    expect_true(!is.null(attr(result, "query_time")))
    expect_true(!is.null(attr(result, "missed_stns")))
  })

  test_that("realtime_ws returns ws class", {
    result <- realtime_ws(
      station_number = "08MF005",
      parameters = 46,
      start_date = Sys.Date() - 7,
      end_date = Sys.Date() - 7
    )

    expect_s3_class(result, "ws")
    expect_true(!is.null(attr(result, "query_time")))
    expect_true(!is.null(attr(result, "missed_stns")))
    expect_true(!is.null(attr(result, "missed_params")))
  })
})
