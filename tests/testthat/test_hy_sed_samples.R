test_that("hy_sed_samples accepts single and multiple province arguments", {
  stns <- "05AA008"
  expect_identical(unique(
    hy_sed_samples(
      station_number = stns,
      hydat_path = hy_test_db()
    )$STATION_NUMBER
  ), stns)
  expect_identical(length(unique(
    hy_sed_samples(
      station_number = c("05AA008", "08MF005"),
      hydat_path = hy_test_db()
    )$STATION_NUMBER
  )), length(c("08NM083", "08NE102")))
})


test_that("hy_sed_samples accepts single and multiple province arguments", {
  expect_true(nrow(
    hy_sed_samples(
      prov_terr_state_loc = "BC",
      hydat_path = hy_test_db()
    )
  ) >= 1)
  expect_true(nrow(
    hy_sed_samples(
      prov_terr_state_loc = c("BC", "AB"),
      hydat_path = hy_test_db()
    )
  ) >= 1)
})

test_that("hy_sed_samples produces an error when a province is not specified correctly", {
  expect_error(hy_sed_samples(
    prov_terr_state_loc = "BCD",
    hydat_path = hy_test_db()
  ))
  expect_error(hy_sed_samples(
    prov_terr_state_loc = c("BC", "BCD"),
    hydat_path = hy_test_db()
  ))
})

## Too much data
# test_that("hy_sed_samples gather data when no arguments are supplied",{
#  expect_true(nrow(hy_sed_samples(hydat_path = hy_test_db())) >= 1)
# })


test_that("hy_sed_samples respects Date specification", {
  date_vector <- c("1966-01-01", "1977-01-01")
  temp_df <- hy_sed_samples(
    station_number = "08MF005",
    hydat_path = hy_test_db(),
    start_date = date_vector[1],
    end_date = date_vector[2]
  )
  expect_true(min(temp_df$Date) >= as.Date(date_vector[1]))
  expect_true(max(temp_df$Date) <= as.Date(date_vector[2]))
})

test_that("functions that accept a date argument return data when specifying only the start date or end date", {
  date_string <- "1969-04-17"

  open_date_start <- hy_sed_samples(station_number = "08MF005", hydat_path = hy_test_db(), start_date = date_string)
  expect_identical(min(as.Date(open_date_start$Date)), as.Date(date_string))

  open_date_end <- hy_sed_samples(station_number = "08MF005", hydat_path = hy_test_db(), end_date = date_string)
  expect_identical(max(as.Date(open_date_end$Date)), as.Date(date_string))
})

test_that("hy_sed_samples correctly parses leaps year", {
  expect_warning(
    hy_sed_samples(
      prov_terr_state_loc = "BC",
      hydat_path = hy_test_db(),
      start_date = "1976-02-29",
      end_date = "1976-02-29"
    ),
    regexp = NA
  )
})
