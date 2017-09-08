context("Testing MONTHLY_LEVELS")

test_that("MONTHLY_LEVELS accepts single and multiple province arguments", {
  stns <- "08MF005"
  expect_identical(unique(MONTHLY_LEVELS(STATION_NUMBER = stns, hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER), stns)
  expect_identical(length(unique(MONTHLY_LEVELS(STATION_NUMBER = c("08MF005", "08KH001"), hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER)), length(c("08NM083", "08NE102")))
})


test_that("MONTHLY_LEVELS accepts single and multiple province arguments", {
  expect_true(nrow(MONTHLY_LEVELS(PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")) >= 1)
  expect_true(nrow(MONTHLY_LEVELS(PROV_TERR_STATE_LOC = c("NU", "PE"), hydat_path = "H:/Hydat.sqlite3")) >= 1)
})

test_that("MONTHLY_LEVELS produces an error when a province is not specified correctly", {
  expect_error(MONTHLY_LEVELS(PROV_TERR_STATE_LOC = "BCD", hydat_path = "H:/Hydat.sqlite3"))
  expect_error(MONTHLY_LEVELS(PROV_TERR_STATE_LOC = c("ID", "BCD"), hydat_path = "H:/Hydat.sqlite3"))
})

test_that("MONTHLY_LEVELS can accept both arguments for backward compatability", {
  expect_true(nrow(MONTHLY_LEVELS(PROV_TERR_STATE_LOC = "BC", STATION_NUMBER = "08MF005", hydat_path = "H:/Hydat.sqlite3")) >= 1)
})


test_that("MONTHLY_LEVELS respects Year specification", {
  date_vector <- c("2013-01-01", "2014-01-01")
  temp_df <- MONTHLY_LEVELS(
    STATION_NUMBER = "08MF005", PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3",
    start_date = date_vector[1],
    end_date = date_vector[2]
  )
  expect_equal(c(min(temp_df$YEAR), max(temp_df$YEAR)), c(2013,2014))
})

test_that("When MONTHLY_LEVELS is ALL there is an error", {
  expect_error(MONTHLY_LEVELS(STATION_NUMBER = "ALL"))
})
