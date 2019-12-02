context("Testing realtime_plot")

test_that("realtime_plot will plot a lake only station", {
  skip_if_net_down()
  skip_on_cran()
  expect_message(realtime_plot("08NM083"))
})

test_that("realtime_plot will be silent is Parameter is set to Level",{
  skip_if_net_down()
  skip_on_cran()
  expect_silent(realtime_plot("08NM083", Parameter = "Level"))
})

test_that("realtime_plot will be silent when a river station is called",{
  skip_if_net_down()
  skip_on_cran()
  expect_silent(realtime_plot("08MF005", Parameter = "Level"))
})

test_that("realtime_plot will throw an error when try to plot more than one station", {
  skip_if_net_down()
  skip_on_cran()
  expect_error(realtime_plot(c("08NM083","08MF005")))
})

test_that("throw an error when plotting a lake level station with Flow specified",{
  l <- realtime_dd('08KH011')
  expect_error(plot(l, Parameter = "Flow"))
  expect_silent(plot(l, Parameter = "Level"))
})
