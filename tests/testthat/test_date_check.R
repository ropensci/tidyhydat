test_that("an error is thrown when the date format is incorrect", {
  expect_error(tidyhydat:::date_check(start_date = "01-01-1961"))
  expect_error(tidyhydat:::date_check(end_date = "01-01-1961"))
  expect_error(tidyhydat:::date_check(start_date = "1961-31-12"))
  expect_error(tidyhydat:::date_check(start_date = "1961-99-99"))
  ## Silent when date is correct
  expect_silent(tidyhydat:::date_check(start_date = "1961-12-31"))
})

test_that("correct logicals are returned when date params are left null", {
  false_start <- tidyhydat:::date_check(start_date = "1961-12-31")
  expect_false(false_start$start_is_null)
  expect_true(false_start$end_is_null)
  false_end <- tidyhydat:::date_check(end_date = "1961-12-31")
  expect_false(false_end$end_is_null)
  expect_true(false_end$start_is_null)
  both_null <- tidyhydat:::date_check()
  expect_true(both_null$end_is_null)
  expect_true(both_null$start_is_null)
})


test_that("date_check errors when start_date is after end_date", {
  expect_error(tidyhydat::date_check(
    start_date = "2010-01-01",
    end_date = "2009-01-01"
  ))
  expect_silent(tidyhydat:::date_check(
    start_date = "2009-01-01",
    end_date = "2010-01-01"
  ))
})
