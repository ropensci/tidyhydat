test_that("hy_daily accepts a level only station argument", {
  skip_on_travis()
  skip_on_cran()
  skip_on_actions()
  stns <- "08NM083"
 expect_silent(hy_daily(stns,hydat_path = hy_test_db()))
})

test_that("hy_daily accepts multiple station arguments", {
  skip_on_cran()
  skip_on_travis()
  skip_on_actions()
  stns <- c("08NM083","08MF005")
  expect_silent(multi_stn_data <- hy_daily(stns,hydat_path = hy_test_db()))
  
  expect_identical(length(stns), length(unique(multi_stn_data$STATION_NUMBER)))
})

test_that("hy_daily generates right column names",{
  skip_on_cran()
  hy_daily_out <- hy_daily("08MF005",hydat_path = hy_test_db())
  
  expect_identical(colnames(hy_daily_out), c("STATION_NUMBER", "Date", "Parameter", "Value", "Symbol"))
  
})


