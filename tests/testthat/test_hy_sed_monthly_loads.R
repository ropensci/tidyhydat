context("Testing hy_sed_monthly_loads")

test_that("hy_sed_monthly_loads accepts single and multiple province arguments",
          {
            stns <- "08MF005"
            expect_identical(unique(
              hy_sed_monthly_loads(
                station_number = stns,
                hydat_path = hy_test_db()
              )$STATION_NUMBER
            ), stns)
            expect_identical(length(unique(
              hy_sed_monthly_loads(
                station_number = c("08MF005", "05AA008"),
                hydat_path = hy_test_db()
              )$STATION_NUMBER
            )), length(c("08NM083", "08NE102")))
          })


test_that("hy_sed_monthly_loads accepts single and multiple province arguments",
          {
            expect_true(nrow(
              hy_sed_monthly_loads(
                prov_terr_state_loc = "BC",
                hydat_path = hy_test_db()
              )
            ) >= 1)
            expect_true(nrow(
              hy_sed_monthly_loads(
                prov_terr_state_loc = c("BC", "AB"),
                hydat_path = hy_test_db()
              )
            ) >= 1)
          })

test_that("hy_sed_monthly_loads produces an error when a province is not specified correctly",
          {
            expect_error(hy_sed_monthly_loads(
              prov_terr_state_loc = "BCD",
              hydat_path = hy_test_db()
            ))
            expect_error(hy_sed_monthly_loads(
              prov_terr_state_loc = c("AB", "BCD"),
              hydat_path = hy_test_db()
            ))
          })


test_that("When hy_sed_monthly_loads is ALL there is an error", {
  expect_error(hy_sed_monthly_loads(station_number = "ALL"))
})
