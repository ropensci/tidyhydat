test_that("realtime_add_local_datetime add applies correct timezone",{
  skip_on_cran()
  skip_if_net_down()
  col_added <- realtime_dd("08MF005") %>% realtime_add_local_datetime()
  expect_equal(lubridate::tz(col_added$local_datetime), unique(col_added$station_tz))
})


test_that("realtime_add_local_datetime add applies first timezone when multiple timezones exist and generates a warning",{
  skip_on_cran()
  skip_if_net_down()
  expect_warning(col_added <- realtime_dd(c("08MF005","02LA004", "02AB006")) %>% realtime_add_local_datetime())
  expect_equal(lubridate::tz(col_added$local_datetime), "America/Toronto")
})


test_that("when set_tz is supplied, it is respected",{
  skip_on_cran()
  skip_if_net_down()
  expect_warning(col_added <- realtime_dd(c("08MF005","02LA004")) %>% realtime_add_local_datetime(set_tz = "America/Moncton"))
  expect_equal(lubridate::tz(col_added$local_datetime), unique(col_added$tz_used))
  expect_equal(lubridate::tz(col_added$local_datetime), "America/Moncton")
  expect_equal(unique(col_added$tz_used), "America/Moncton")
})


