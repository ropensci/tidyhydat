test_that("daily_mean takes a range of values for yesterday and reduces it to one value per parameter",{
  skip_on_cran()
  df <- realtime_dd("08MF005")
  df_yesterday <- df[as.Date(df$Date) == Sys.Date() - 1,]
    expect_equal(nrow(realtime_daily_mean(df_yesterday, na.rm = FALSE)), 2)
})
