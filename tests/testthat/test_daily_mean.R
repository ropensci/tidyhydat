test_that("daily_mean takes a range of values for yesterday and reduces it to one value per parameter", {
  skip_on_cran()

  date_utc <- as.Date(as.POSIXct(Sys.time(), tz = "UTC"))
  df <- realtime_dd("08MF005")
  df_yesterday <- df[as.Date(df$Date) == date_utc - 1, ]
  expect_equal(nrow(realtime_daily_mean(df_yesterday, na.rm = FALSE)), 2)
})
