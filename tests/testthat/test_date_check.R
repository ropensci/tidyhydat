context("Testing the date parsing and checks")

test_that("an error is thrown when the date format is incorrect",{
  expect_error(tidyhydat:::date_check(start_date = "01-01-1961"))
  expect_error(tidyhydat:::date_check(end_date = "01-01-1961"))
  expect_error(tidyhydat:::date_check(start_date = "1961-31-12"))
  ## Silent when date is correct
  expect_silent(tidyhydat:::date_check(start_date = "1961-12-31"))
})

test_that("date_check returns true when start_date and end_date are left NULL",{
  expect_true(tidyhydat:::date_check())
})

test_that("date_check errors when start_date is after end_date",{
  expect_error(tidyhydat::date_check(start_date = "2010-01-01", end_date = "2009-01-01"))
  expect_silent(tidyhydat:::date_check(start_date = "2009-01-01", end_date = "2010-01-01"))
})
