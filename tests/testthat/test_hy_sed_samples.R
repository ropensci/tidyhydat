context("Testing hy_sed_samples")

test_that("hy_sed_samples accepts single and multiple province arguments",
          {
            stns <- "05AA008"
            expect_identical(unique(
              hy_sed_samples(
                station_number = stns,
                hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
              )$STATION_NUMBER
            ), stns)
            expect_identical(length(unique(
              hy_sed_samples(
                station_number = c("05AA008", "08MF005"),
                hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
              )$STATION_NUMBER
            )), length(c("08NM083", "08NE102")))
          })


test_that("hy_sed_samples accepts single and multiple province arguments",
          {
            expect_true(nrow(
              hy_sed_samples(
                prov_terr_state_loc = "BC",
                hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
              )
            ) >= 1)
            expect_true(nrow(
              hy_sed_samples(
                prov_terr_state_loc = c("BC", "AB"),
                hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
              )
            ) >= 1)
          })

test_that("hy_sed_samples produces an error when a province is not specified correctly",
          {
            expect_error(hy_sed_samples(
              prov_terr_state_loc = "BCD",
              hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
            ))
            expect_error(hy_sed_samples(
              prov_terr_state_loc = c("BC", "BCD"),
              hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
            ))
          })

## Too much data
# test_that("hy_sed_samples gather data when no arguments are supplied",{
#  expect_true(nrow(hy_sed_samples(hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"))) >= 1)
# })

test_that("hy_sed_samples can accept both arguments for backward compatability",
          {
            expect_true(nrow(
              hy_sed_samples(
                prov_terr_state_loc = "BC",
                station_number = "08MF005",
                hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
              )
            ) >= 1)
          })


test_that("hy_sed_samples respects Date specification", {
  date_vector <- c("1965-06-01", "1966-03-01")
  expect_error(
    hy_sed_samples(
      station_number = "08MF005",
      hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"),
      start_date = date_vector[1],
      end_date = date_vector[2]
    ),
    regexp = NA
  )
})

test_that("hy_sed_samples correctly parses leaps year", {
  expect_warning(
    hy_sed_samples(
      prov_terr_state_loc = "BC",
      hydat_path = system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat"),
      start_date = "1976-02-29",
      end_date = "1976-02-29"
    ),
    regexp = NA
  )
})
