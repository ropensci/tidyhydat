test_that("Outputs that same station that is inputted in outputted when province is missing", {
  hydat_path <- hy_test_db()
  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  stns <- c("08NM083", "08NE102")
  on.exit(DBI::dbDisconnect(hydat_con), add = TRUE)
  stns_out <- tidyhydat:::station_choice(hydat_con, station_number = stns, prov_terr_state_loc = NULL)
  expect_identical(stns, stns_out)
})

test_that("Test that all stations are outputted when just a province is supplied", {
  hydat_path <- hy_test_db()
  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  ## All BC stations in test db
  dplyr::tbl(hydat_con, "STATIONS") |>
    dplyr::filter(PROV_TERR_STATE_LOC == "BC") |>
    dplyr::collect() |>
    dplyr::pull(STATION_NUMBER) -> stns
  on.exit(DBI::dbDisconnect(hydat_con), add = TRUE)
  stns_out <- tidyhydat:::station_choice(hydat_con, station_number = NULL, prov_terr_state_loc = "BC")
  expect_identical(stns, stns_out)
})


test_that("station name in any case is accepted", {
  hydat_path <- hy_test_db()
  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  stns <- c("08nm083", "08nE102")
  on.exit(DBI::dbDisconnect(hydat_con), add = TRUE)
  expect_silent(out_stns <- tidyhydat:::station_choice(hydat_con, station_number = stns, prov_terr_state_loc = NULL))
  expect_identical(toupper(stns), out_stns)
})


test_that("province in any case is accepted", {
  hydat_path <- hy_test_db()
  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  prov <- c("Ab", "bC")
  on.exit(DBI::dbDisconnect(hydat_con), add = TRUE)
  expect_silent(stns <- tidyhydat:::station_choice(hydat_con, station_number = NULL, prov_terr_state_loc = prov))
  expect_identical(toupper(prov), unique(hy_stations(hydat_path, station_number = stns)$PROV_TERR_STATE_LOC))
})

test_that("'CA' to prov_terr_state_loc argument returns only Canadian stations", {
  only_canada <- unique(hy_stations(prov_terr_state_loc = "CA", hydat_path = hy_test_db())$PROV_TERR_STATE_LOC)
  expect_equal(c("AB", "SK", "BC"), only_canada)
})
