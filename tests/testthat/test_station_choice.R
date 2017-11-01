context("Make sure that station choice chooses the correct station")

test_that("Outputs that same station that is inputted",{
  hydat_path <- system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  stns <- c("08NM083", "08NE102")
  stns_out <- tidyhydat:::station_choice(hydat_con, station_number = stns, prov_terr_state_loc = "BC")
  DBI::dbDisconnect(hydat_con)
  expect_identical(stns, stns_out)
})
