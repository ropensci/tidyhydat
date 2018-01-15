context("Testing realtime functions")

 test_that("realtime_dd returns the correct data header", {
   #skip_on_travis()
   skip_on_cran()
   expect_identical(
     colnames(realtime_dd(station_number = "08MF005", prov_terr_state_loc = "BC")),
     c("STATION_NUMBER", "PROV_TERR_STATE_LOC", "Date", "Parameter", "Value", "Grade", "Symbol", "Code")
  )
})

test_that("realtime_dd can download stations from multiple provinces using prov_terr_state_loc", {
  #skip_on_travis()
  skip_on_cran()
  expected_columns <- c("STATION_NUMBER", "PROV_TERR_STATE_LOC", "Date", "Parameter", 
                        "Value", "Grade", "Symbol", "Code")
  rldf <- realtime_dd(prov_terr_state_loc = c("QC", "PE"))
  
  expect_true(identical(expected_columns,colnames(rldf)))
  expect_equal(length(unique(rldf$PROV_TERR_STATE_LOC)),2)
})


test_that("realtime_dd can download stations from multiple provinces using station_number", {
  #skip_on_travis()
  skip_on_cran()
  expect_error(realtime_dd(station_number = c("01CD005", "08MF005")), regexp = NA)
})

test_that("When station_number is ALL there is an error", {
  #skip_on_travis()
  skip_on_cran()
  expect_error(realtime_dd(station_number = "ALL"))
})
