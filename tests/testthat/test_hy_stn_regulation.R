test_that("hy_stn_regulation accepts single and multiple province arguments",
          {
            stns <- "08NM083"
            expect_identical(unique(
              hy_stn_regulation(
                station_number = stns,
                hydat_path = hy_test_db()
              )$STATION_NUMBER
            ), stns)
            expect_identical(length(unique(
              hy_stn_regulation(
                station_number = c("08NM083", "08NE102"),
                hydat_path = hy_test_db()
              )$STATION_NUMBER
            )), length(c("08NM083", "08NE102")))
          })


test_that("hy_stn_regulation accepts single and multiple province arguments",
          {
            expect_true(nrow(
              hy_stn_regulation(
                prov_terr_state_loc = "BC",
                hydat_path = hy_test_db()
              )
            ) >= 1)
            expect_true(nrow(
              hy_stn_regulation(
                prov_terr_state_loc = c("BC", "YT"),
                hydat_path = hy_test_db()
              )
            ) >= 1)
          })

test_that("hy_stn_regulation produces an error when a province is not specified correctly",
          {
            expect_error(hy_stn_regulation(
              prov_terr_state_loc = "BCD",
              hydat_path = hy_test_db()
            ))
            expect_error(hy_stn_regulation(
              prov_terr_state_loc = c("AB", "BCD"),
              hydat_path = hy_test_db()
            ))
          })

test_that("hy_stn_regulation gather data when no arguments are supplied", {
  expect_true(nrow(hy_stn_regulation(
    hydat_path = hy_test_db()
  )) >= 1)
})
