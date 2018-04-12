context("Testing hy_sed_samples_psd")

test_that("hy_sed_samples_psd accepts single and multiple province arguments",
          {
            stns <- "05AA008"
            expect_identical(unique(
              hy_sed_samples_psd(
                station_number = stns,
                hydat_path = hy_test_db()
              )$STATION_NUMBER
            ), stns)
            expect_identical(length(unique(
              hy_sed_samples_psd(
                station_number = c("05AA008", "08MF005"),
                hydat_path = hy_test_db()
              )$STATION_NUMBER
            )), length(c("08NM083", "08NE102")))
          })


test_that("hy_sed_samples_psd accepts single and multiple province arguments",
          {
            expect_true(nrow(
              hy_sed_samples_psd(
                prov_terr_state_loc = "BC",
                hydat_path = hy_test_db()
              )
            ) >= 1)
            expect_true(nrow(
              hy_sed_samples_psd(
                prov_terr_state_loc = c("BC", "AB"),
                hydat_path = hy_test_db()
              )
            ) >= 1)
          })

test_that("hy_sed_samples_psd produces an error when a province is not specified correctly",
          {
            expect_error(hy_sed_samples_psd(
              prov_terr_state_loc = "BCD",
              hydat_path = hy_test_db()
            ))
            expect_error(hy_sed_samples_psd(
              prov_terr_state_loc = c("BC", "BCD"),
              hydat_path = hy_test_db()
            ))
          })

## Too much data
# test_that("hy_sed_samples_psd gather data when no arguments are supplied",{
#  expect_true(nrow(hy_sed_samples_psd(hydat_path = hy_test_db())) >= 1)
# })


test_that("hy_sed_samples_psd respects Date specification", {
  date_vector <- c("1965-06-01", "1966-03-01")
  expect_error(
    hy_sed_samples_psd(
      station_number = "08MF005",
      hydat_path = hy_test_db(),
      start_date = date_vector[1],
      end_date = date_vector[2]
    ),
    regexp = NA
  )
})

test_that("hy_sed_samples_psd correctly parses leaps year", {
  expect_warning(
    hy_sed_samples_psd(
      prov_terr_state_loc = "BC",
      hydat_path = hy_test_db(),
      start_date = "1976-02-29",
      end_date = "1976-02-29"
    ),
    regexp = NA
  )
})
