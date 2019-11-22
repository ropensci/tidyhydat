context("testing plot methods for tidyhydat")

test_that("plot fails with more than four stations",{
  skip_on_cran()
  skip_on_travis()
  skip_on_actions()
  stns <-  c("01AA002", "01AD001", "01AD002", "01AD003", "01AD004")
  four_stns <- hy_daily_flows(stns)
  expect_error(plot(four_stns))
})

test_that("plot fails with non daily value",{
  month <- hy_monthly_flows("05AA008", hydat_path = hy_test_db())
  expect_error(plot(month))
})

test_that("plot succeeds with daily values",{
  skip_on_travis()
  dd <- hy_daily_flows("05AA008", hydat_path = hy_test_db())
  plot_dd <- plot(dd)
  expect_true(plot_dd)
})
