context("Testing DLY_FLOWS")

test_that("DLY_FLOWS downloads one station", {
  data("bcstations")
  stns <- "08LG006"
  expect_identical( unique(DLY_FLOWS(STATION_NUMBER = stns, 
                              PROV_TERR_STATE_LOC = "BC", 
                              hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER),
                    stns)
  
})


test_that("DLY_FLOWS downloads multiple stations", {
  stns <- c("08MH012","08KH023")
  expect_identical( length(unique(DLY_FLOWS(STATION_NUMBER = stns, 
                                     PROV_TERR_STATE_LOC = "BC", 
                                     hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER)),
                    length(stns))
  
})
