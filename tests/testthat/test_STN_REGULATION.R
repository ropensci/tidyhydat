context("Testing STN_REGULATION")

test_that("STN_REGULATION downloads one station", {
  stns <- "08NM083"
  expect_identical( unique(STN_REGULATION(STATION_NUMBER = stns,
                              hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER),
                    stns)
  
})


test_that("STN_REGULATION downloads multiple stations", {
  stns <- c("08NM083","08NE102")
  expect_identical( length(unique(STN_REGULATION(STATION_NUMBER = stns, 
                                     hydat_path = "H:/Hydat.sqlite3")$STATION_NUMBER)),
                    length(stns))
  
})

