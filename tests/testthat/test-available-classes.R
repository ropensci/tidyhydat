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

test_that("trim_provisional_overlap keeps provisional data for stations lacking final coverage", {
  ## Regression: a station with complete final coverage previously pushed the
  ## global realtime start past end_date, starving provisional data for every
  ## station, including those with no final record at all.

  sym_STATION_NUMBER <- rlang::sym("STATION_NUMBER")
  sym_Date <- rlang::sym("Date")

  ## Station A is fully covered by final data through 2025-12-31.
  final_data <- dplyr::tibble(
    STATION_NUMBER = "A",
    Date = as.Date(c("2025-12-30", "2025-12-31")),
    Parameter = "Flow",
    Value = c(1, 2),
    Symbol = NA_character_,
    Approval = "final"
  )

  ## Provisional data exists for both A (overlapping final) and B (no final).
  provisional <- dplyr::tibble(
    STATION_NUMBER = c("A", "A", "B", "B"),
    Date = as.Date(c("2025-12-31", "2026-01-01", "2025-06-01", "2025-06-02")),
    Parameter = "Flow",
    Value = c(2.1, 3, 10, 11),
    Symbol = NA_character_,
    Approval = "provisional"
  )

  result <- trim_provisional_overlap(
    provisional,
    final_data,
    sym_STATION_NUMBER,
    sym_Date
  )

  ## Station B's provisional data must survive despite A's complete coverage.
  expect_true(all(
    c("2025-06-01", "2025-06-02") %in%
      as.character(result$Date[result$STATION_NUMBER == "B"])
  ))
  expect_equal(sum(result$STATION_NUMBER == "B"), 2L)

  ## Station A keeps only provisional records beyond its last final date.
  a_dates <- as.character(result$Date[result$STATION_NUMBER == "A"])
  expect_equal(a_dates, "2026-01-01")
})

test_that("trim_provisional_overlap is a no-op when no final data exists", {
  sym_STATION_NUMBER <- rlang::sym("STATION_NUMBER")
  sym_Date <- rlang::sym("Date")

  provisional <- dplyr::tibble(
    STATION_NUMBER = c("B", "B"),
    Date = as.Date(c("2025-06-01", "2025-06-02")),
    Parameter = "Flow",
    Value = c(10, 11),
    Symbol = NA_character_,
    Approval = "provisional"
  )

  expect_identical(
    trim_provisional_overlap(provisional, NULL, sym_STATION_NUMBER, sym_Date),
    provisional
  )
  expect_identical(
    trim_provisional_overlap(
      provisional,
      provisional[0, ],
      sym_STATION_NUMBER,
      sym_Date
    ),
    provisional
  )
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
    expect_true(
      "final_start" %in% names(summ) || "provisional_start" %in% names(summ)
    )
  })
})
