test_that("hy_sed_daily_suscon accepts single and multiple province arguments", {
  stns <- "05AA008"
  expect_identical(
    unique(
      hy_sed_daily_suscon(
        station_number = stns,
        hydat_path = hy_test_db()
      )$STATION_NUMBER
    ),
    stns
  )
  expect_identical(
    length(unique(
      hy_sed_daily_suscon(
        station_number = c("05AA008", "08MF005"),
        hydat_path = hy_test_db()
      )$STATION_NUMBER
    )),
    length(c("08NM083", "08NE102"))
  )
})


test_that("hy_sed_daily_suscon accepts single and multiple province arguments", {
  expect_true(
    nrow(
      hy_sed_daily_suscon(
        prov_terr_state_loc = "BC",
        hydat_path = hy_test_db()
      )
    ) >=
      1
  )
  expect_true(
    nrow(
      hy_sed_daily_suscon(
        prov_terr_state_loc = c("BC", "AB"),
        hydat_path = hy_test_db()
      )
    ) >=
      1
  )
})

## Too much data
# test_that("hy_sed_daily_suscon gather data when no arguments are supplied",{
#  expect_true(nrow(hy_sed_daily_suscon(hydat_path = hy_test_db())) >= 1)
# })

test_that("hy_sed_daily_suscon respects Date specification", {
  date_vector <- c("1965-06-01", "1966-03-01")
  temp_df <- hy_sed_daily_suscon(
    station_number = "08MF005",
    hydat_path = hy_test_db(),
    start_date = date_vector[1],
    end_date = date_vector[2]
  )
  expect_identical(
    c(min(temp_df$Date), max(temp_df$Date)),
    as.Date(date_vector)
  )
})

test_that("functions that accept a date argument return data when specifying only the start date or end date", {
  date_string <- "1965-05-01"

  open_date_start <- hy_sed_daily_suscon(
    station_number = "08MF005",
    hydat_path = hy_test_db(),
    start_date = date_string
  )
  expect_identical(min(open_date_start$Date), as.Date(date_string))

  open_date_end <- hy_sed_daily_suscon(
    station_number = "08MF005",
    hydat_path = hy_test_db(),
    end_date = date_string
  )
  expect_identical(max(open_date_end$Date), as.Date(date_string))
})

test_that("hy_sed_daily_suscon correctly parses leaps year", {
  expect_warning(
    hy_sed_daily_suscon(
      prov_terr_state_loc = "BC",
      hydat_path = hy_test_db(),
      start_date = "1976-02-29",
      end_date = "1976-02-29"
    ),
    regexp = NA
  )
})
