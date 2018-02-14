context("Testing hy_daily")

test_that("hy_daily accepts a level only station argument", {
  stns <- "08NM083"
 expect_silent(hy_daily(stns))
})

test_that("hy_daily accepts multiple station arguments", {
  stns <- c("08NM083","08MF005")
  expect_silent(multi_stn_data <- hy_daily(stns))
  expect_identical(length(stns), length(unique(multi_stn_data$STATION_NUMBER)))
})

