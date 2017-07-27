context("Testing STATIONS")

test_that("STATIONS downloads one station", {
  stns <- "08NM083"
  expect_identical( unique(STATIONS(STATION_NUMBER = stns, 
                              PROV_TERR_STATE_LOC = "BC", 
                              hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER),
                    stns)
  
})


test_that("STATIONS downloads multiple stations", {
  stns <- c("08NM083","08NE102")
  expect_identical( length(unique(STATIONS(STATION_NUMBER = stns, 
                                     PROV_TERR_STATE_LOC = "BC", 
                                     hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER)),
                    length(stns))
  
})
