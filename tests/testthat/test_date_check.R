context("Testing the date parsing and checks")

test_that("an error is thrown when the date format is incorrect",{
  expect_error(tidyhydat:::date_check(start_date = "01-01-1961", end_date = "ALL"))
  expect_error(tidyhydat:::date_check(start_date = "ALL", end_date = "01-01-1961"))
})
