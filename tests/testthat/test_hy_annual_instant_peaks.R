test_that("hy_annual_instant_peaks accepts single and multiple province arguments", {
  stns <- "08NM083"
  expect_identical(
    unique(
      hy_annual_instant_peaks(
        station_number = stns,
        hydat_path = hy_test_db()
      )$STATION_NUMBER
    ),
    stns
  )
  expect_identical(
    length(unique(
      hy_annual_instant_peaks(
        station_number = c("08NM083", "08NE102"),
        hydat_path = hy_test_db()
      )$STATION_NUMBER
    )),
    length(c("08NM083", "08NE102"))
  )
})


test_that("hy_annual_instant_peaks accepts single and multiple province arguments", {
  expect_true(
    nrow(
      hy_annual_instant_peaks(
        prov_terr_state_loc = "BC",
        hydat_path = hy_test_db()
      )
    ) >=
      1
  )
  expect_true(
    nrow(
      hy_annual_instant_peaks(
        prov_terr_state_loc = c("BC", "YT"),
        hydat_path = hy_test_db()
      )
    ) >=
      1
  )
})

test_that("hy_annual_instant_peaks produces an error when a province is not specified correctly", {
  expect_error(hy_annual_instant_peaks(
    prov_terr_state_loc = "BCD",
    hydat_path = hy_test_db()
  ))
  expect_error(hy_annual_instant_peaks(
    prov_terr_state_loc = c("AB", "BCD"),
    hydat_path = hy_test_db()
  ))
})

## TODO add test for CA

test_that("hy_annual_instant_peaks gather data when no arguments are supplied", {
  expect_true(
    nrow(hy_annual_instant_peaks(
      hydat_path = hy_test_db()
    )) >=
      1
  )
})


test_that("hy_annual_instant_peaks respects year inputs", {
  s_year <- 1981
  e_year <- 2007
  df <-
    hy_annual_instant_peaks(
      station_number = c("08NM083", "08NE102"),
      hydat_path = hy_test_db(),
      start_year = s_year,
      end_year = e_year
    )
  expect_equal(s_year, min(lubridate::year(df$Datetime)))
  expect_equal(e_year, max(lubridate::year(df$Datetime)))
})
