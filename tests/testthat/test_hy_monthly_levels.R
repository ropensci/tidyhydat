context("Testing hy_monthly_levels")

test_that("hy_monthly_levels accepts single and multiple province arguments",
          {
            stns <- "08MF005"
            expect_identical(unique(
              hy_monthly_levels(
                station_number = stns,
                hydat_path = hy_test_db()
              )$STATION_NUMBER
            ), stns)
            expect_identical(length(unique(
              hy_monthly_levels(
                station_number = c("08MF005", "05AA008"),
                hydat_path = hy_test_db()
              )$STATION_NUMBER
            )), length(c("08NM083", "08NE102")))
          })


test_that("hy_monthly_levels accepts single and multiple province arguments",
          {
            expect_true(nrow(
              hy_monthly_levels(
                prov_terr_state_loc = "BC",
                hydat_path = hy_test_db()
              )
            ) >= 1)
            expect_true(nrow(
              hy_monthly_levels(
                prov_terr_state_loc = c("YT", "BC"),
                hydat_path = hy_test_db()
              )
            ) >= 1)
          })

test_that("hy_monthly_levels produces an error when a province is not specified correctly",
          {
            expect_error(hy_monthly_levels(
              prov_terr_state_loc = "BCD",
              hydat_path = hy_test_db()
            ))
            expect_error(hy_monthly_levels(
              prov_terr_state_loc = c("AB", "BCD"),
              hydat_path = hy_test_db()
            ))
          })


test_that("hy_monthly_levels respects Year specification", {
  date_vector <- c("2013-01-01", "2014-01-01")
  temp_df <- hy_monthly_levels(
    station_number = "08MF005",
    prov_terr_state_loc = "BC",
    hydat_path = hy_test_db(),
    start_date = date_vector[1],
    end_date = date_vector[2]
  )
  expect_equal(c(min(temp_df$YEAR), max(temp_df$YEAR)), c(2013, 2014))
})

test_that("When hy_monthly_levels is ALL there is an error", {
  expect_error(hy_monthly_levels(station_number = "ALL"))
})
