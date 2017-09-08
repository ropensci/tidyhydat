context("Testing SED_DLY_SUSCON")

test_that("SED_DLY_SUSCON accepts single and multiple province arguments", {
  stns <- "08MH024"
  expect_identical(unique(SED_DLY_SUSCON(STATION_NUMBER = stns, hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER), stns)
  expect_identical(length(unique(SED_DLY_SUSCON(STATION_NUMBER = c("08MH024", "08MH001"), hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("SED_DLY_SUSCON accepts single and multiple province arguments", {
  expect_true(nrow(SED_DLY_SUSCON(PROV_TERR_STATE_LOC = "ID", hydat_path = "H:/Hydat.sqlite3")) >= 1)
  expect_true(nrow(SED_DLY_SUSCON(PROV_TERR_STATE_LOC = c("ID", "PE"), hydat_path = "H:/Hydat.sqlite3")) >= 1)
})

test_that("SED_DLY_SUSCON produces an error when a province is not specified correctly", {
  expect_error(SED_DLY_SUSCON(PROV_TERR_STATE_LOC = "BCD", hydat_path = "H:/Hydat.sqlite3"))
  expect_error(SED_DLY_SUSCON(PROV_TERR_STATE_LOC = c("ID", "BCD"), hydat_path = "H:/Hydat.sqlite3"))
})

## Too much data
# test_that("SED_DLY_SUSCON gather data when no arguments are supplied",{
#  expect_true(nrow(SED_DLY_SUSCON(hydat_path = "H:/Hydat.sqlite3")) >= 1)
# })

test_that("SED_DLY_SUSCON can accept both arguments for backward compatability", {
  expect_true(nrow(SED_DLY_SUSCON(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = "H:/Hydat.sqlite3")) >= 1)
})


test_that("SED_DLY_SUSCON respects Date specification", {
  date_vector <- c("1965-06-01", "1966-03-01")
  temp_df <- SED_DLY_SUSCON(
    STATION_NUMBER = "08MH024", hydat_path = "H:/Hydat.sqlite3",
    start_date = date_vector[1],
    end_date = date_vector[2]
  )
  expect_identical(c(min(temp_df$Date), max(temp_df$Date)), as.Date(date_vector))
})

test_that("SED_DLY_SUSCON correctly parses leaps year", {
  expect_warning(SED_DLY_SUSCON(
    PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3",
    start_date = "1988-02-29",
    end_date = "1988-02-29"
  ), regexp = NA)
})
