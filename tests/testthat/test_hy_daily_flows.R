context("Testing hy_daily_flows")

test_that("hy_daily_flows accepts single and multiple station arguments", {
  stns <- "08MF005"
  expect_identical(unique(
    hy_daily_flows(
      station_number = stns,
      hydat_path = hy_test_db()
    )$STATION_NUMBER
  ), stns)
  expect_identical(length(unique(
    hy_daily_flows(
      station_number = c("08MF005", "05AA008"),
      hydat_path = hy_test_db()
    )$STATION_NUMBER
  )), length(c("08NM083", "08NE102")))
})


test_that("hy_daily_flows accepts single and multiple province arguments",
          {
            expect_true(nrow(
              hy_daily_flows(
                prov_terr_state_loc = "BC",
                hydat_path = hy_test_db()
              )
            ) >= 1)
            expect_true(nrow(
              hy_daily_flows(
                prov_terr_state_loc = c("BC", "YT"),
                hydat_path = hy_test_db()
              )
            ) >= 1)
          })

test_that("hy_daily_flows produces an error when a province is not specified correctly",
          {
            expect_error(hy_daily_flows(
              prov_terr_state_loc = "BCD",
              hydat_path = hy_test_db()
            ))
            expect_error(hy_daily_flows(
              prov_terr_state_loc = c("YT", "BCD"),
              hydat_path = hy_test_db()
            ))
          })

## Too much data
# test_that("hy_daily_flows gather data when no arguments are supplied",{
#  expect_true(nrow(hy_daily_flows(hydat_path = hy_test_db())) >= 1)
# })

test_that("hy_daily_flows respects Date specification", {
  date_vector <- c("2013-01-01", "2014-01-01")
  temp_df <- hy_daily_flows(
    station_number = "08MF005",
    hydat_path = hy_test_db(),
    start_date = date_vector[1],
    end_date = date_vector[2]
  )
  expect_identical(c(min(temp_df$Date), max(temp_df$Date)), as.Date(date_vector))
})

test_that("functions that accept a date argument return data when specifying only the start date or end date",{
  date_string <- "1961-01-01"
  
  open_date_start <- hy_daily_flows(station_number = "08MF005", hydat_path = hy_test_db(), start_date = date_string)
  expect_identical(min(open_date_start$Date), as.Date(date_string))
  
  open_date_end <- hy_daily_flows(station_number = "08MF005", hydat_path = hy_test_db(), end_date = date_string)
  expect_identical(max(open_date_end$Date), as.Date(date_string))
})


test_that("hy_daily_flows correctly parses leaps year", {
  expect_warning(
    hy_daily_flows(
      prov_terr_state_loc = "BC",
      hydat_path = hy_test_db(),
      start_date = "1988-02-29",
      end_date = "1988-02-29"
    ),
    regexp = NA
  )
})


test_that("When hy_daily_flows is ALL there is an error", {
  expect_error(hy_daily_flows(station_number = "ALL"))
})
