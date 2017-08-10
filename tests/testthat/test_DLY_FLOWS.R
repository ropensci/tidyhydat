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


test_that("DLY_FLOWS respects Date specification", {
  date_vector = c("2013-01-01","2014-01-01")
  temp_df <- DLY_FLOWS(STATION_NUMBER = "08MF005", PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3",
            start_date = date_vector[1] ,
            end_date = date_vector[2])
  expect_identical(c(min(temp_df$Date), max(temp_df$Date)), as.Date(date_vector) )
  
})

test_that("DLY_FLOWS correctly parses leaps year",{
  DLY_FLOWS(STATION_NUMBER = c("08HB074", "10BE009", "08FB005"), PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3",
            start_date = "1988-02-29" ,
            end_date = "1988-02-29")
})
