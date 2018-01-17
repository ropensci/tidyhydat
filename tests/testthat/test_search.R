context("search function testing")

test_that("search_stn_number returns a dataframe", {
  expect_is(search_stn_number("08HF", hydat_path = hy_test_db()), "data.frame")
})


test_that("search_stn_name returns a dataframe", {
  expect_is(search_stn_name("Saskatchewan", hydat_path = hy_test_db()), "data.frame")
})
