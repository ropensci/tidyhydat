context("Testing hy_sed_monthly_suscon")

test_that("hy_sed_monthly_suscon accepts single and multiple province arguments",
          {
            stns <- "08MF005"
            expect_identical(unique(
              hy_sed_monthly_suscon(
                station_number = stns,
                hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
              )$STATION_NUMBER
            ), stns)
            expect_identical(length(unique(
              hy_sed_monthly_suscon(
                station_number = c("08MF005", "05AA008"),
                hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
              )$STATION_NUMBER
            )), length(c("08NM083", "08NE102")))
          })


test_that("hy_sed_monthly_suscon accepts single and multiple province arguments",
          {
            expect_true(nrow(
              hy_sed_monthly_suscon(
                prov_terr_state_loc = "BC",
                hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
              )
            ) >= 1)
            expect_true(nrow(
              hy_sed_monthly_suscon(
                prov_terr_state_loc = c("BC", "AB"),
                hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
              )
            ) >= 1)
          })

test_that("hy_sed_monthly_suscon produces an error when a province is not specified correctly",
          {
            expect_error(hy_sed_monthly_suscon(
              prov_terr_state_loc = "BCD",
              hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
            ))
            expect_error(hy_sed_monthly_suscon(
              prov_terr_state_loc = c("AB", "BCD"),
              hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
            ))
          })

test_that("hy_sed_monthly_suscon can accept both arguments for backward compatability",
          {
            expect_true(nrow(
              hy_sed_monthly_suscon(
                prov_terr_state_loc = "BC",
                station_number = "08MF005",
                hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
              )
            ) >= 1)
          })


test_that("When hy_sed_monthly_suscon is ALL there is an error", {
  expect_error(hy_sed_monthly_suscon(station_number = "ALL"))
})
