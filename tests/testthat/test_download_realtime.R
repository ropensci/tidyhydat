test_that("realtime_dd returns the correct data header", {
  skip_on_cran()
  expect_identical(
    colnames(realtime_dd(
      station_number = "08MF005",
      prov_terr_state_loc = "BC"
    )),
    c(
      "STATION_NUMBER",
      "PROV_TERR_STATE_LOC",
      "Date",
      "Parameter",
      "Value",
      "Grade",
      "Symbol",
      "Code"
    )
  )
})

test_that("realtime_dd can download stations from a whole province using prov_terr_state_loc and stores query time", {
  skip_on_cran()
  expected_columns <- c(
    "STATION_NUMBER",
    "PROV_TERR_STATE_LOC",
    "Date",
    "Parameter",
    "Value",
    "Grade",
    "Symbol",
    "Code"
  )
  rldf <- realtime_dd(prov_terr_state_loc = "PE")

  expect_true(identical(expected_columns, colnames(rldf)))
  expect_s3_class(attributes(rldf)$query_time, "POSIXct")
})


test_that("realtime_dd can download stations from multiple provinces using station_number", {
  skip_on_cran()
  expect_error(
    realtime_dd(station_number = c("01CD005", "08MF005")),
    regexp = NA
  )
})

test_that("When station_number is ALL there is an error", {
  skip_on_cran()
  expect_error(realtime_dd(station_number = "ALL"))
})

test_that("realtime_dd works when station is not realtime", {
  skip_on_cran()
  stns <- hy_stations(hydat_path = hy_test_db())
  stn <- sample(
    stns$STATION_NUMBER[!stns$REAL_TIME & stns$HYD_STATUS == "DISCONTINUED"],
    1
  )
  expect_s3_class(realtime_dd(stn), "realtime")
})
