context("Testing DLY_LEVELS")

test_that("DLY_LEVELS downloads one station", {
  data("bcstations")
  stns <- "08NM083"
  expect_identical( unique(DLY_LEVELS(STATION_NUMBER = stns, 
                              PROV_TERR_STATE_LOC = "BC", 
                              hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER),
                    stns)
  
})


test_that("DLY_LEVELS downloads multiple stations", {
  stns <- c("08NM083","08NE102")
  expect_identical( length(unique(DLY_LEVELS(STATION_NUMBER = stns, 
                                     PROV_TERR_STATE_LOC = "BC", 
                                     hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER)),
                    length(stns))
  
})
