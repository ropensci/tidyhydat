test_that("hy_sed_monthly_suscon accepts single and multiple province arguments", {
  stns <- "08MF005"
  expect_identical(
    unique(
      hy_sed_monthly_suscon(
        station_number = stns,
        hydat_path = hy_test_db()
      )$STATION_NUMBER
    ),
    stns
  )
  expect_identical(
    length(unique(
      hy_sed_monthly_suscon(
        station_number = c("08MF005", "05AA008"),
        hydat_path = hy_test_db()
      )$STATION_NUMBER
    )),
    length(c("08NM083", "08NE102"))
  )
})


test_that("hy_sed_monthly_suscon accepts single and multiple province arguments", {
  expect_true(
    nrow(
      hy_sed_monthly_suscon(
        prov_terr_state_loc = "BC",
        hydat_path = hy_test_db()
      )
    ) >=
      1
  )
  expect_true(
    nrow(
      hy_sed_monthly_suscon(
        prov_terr_state_loc = c("BC", "AB"),
        hydat_path = hy_test_db()
      )
    ) >=
      1
  )
})

test_that("hy_sed_monthly_suscon produces an error when a province is not specified correctly", {
  expect_error(hy_sed_monthly_suscon(
    prov_terr_state_loc = "BCD",
    hydat_path = hy_test_db()
  ))
  expect_error(hy_sed_monthly_suscon(
    prov_terr_state_loc = c("AB", "BCD"),
    hydat_path = hy_test_db()
  ))
})

test_that("hy_sed_monthly_suscon respects Date specification", {
  date_vector <- c("1965-05-31", "1965-07-12 ")
  temp_df <- hy_sed_monthly_suscon(
    station_number = "08MF005",
    hydat_path = hy_test_db(),
    start_date = date_vector[1],
    end_date = date_vector[2]
  )
  expect_true(min(temp_df$Date_occurred) >= as.Date(date_vector[1]))
  expect_true(max(temp_df$Date_occurred) <= as.Date(date_vector[2]))
})

test_that("functions that accept a date argument return data when specifying only the start date or end date", {
  date_string <- "1965-07-12"

  open_date_start <- hy_sed_monthly_suscon(
    station_number = "08MF005",
    hydat_path = hy_test_db(),
    start_date = date_string
  )
  expect_true(min(open_date_start$Date_occurred) >= as.Date(date_string))

  open_date_end <- hy_sed_monthly_suscon(
    station_number = "08MF005",
    hydat_path = hy_test_db(),
    end_date = date_string
  )
  expect_true(max(open_date_end$Date_occurred) <= as.Date(date_string))
})


test_that("When hy_sed_monthly_suscon is ALL there is an error", {
  expect_error(hy_sed_monthly_suscon(station_number = "ALL"))
})
