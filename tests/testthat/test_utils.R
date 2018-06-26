context("Testing function in utils.R")

test_that("hy_dir returns a path",{
  expect_silent(hy_dir())
})

test_that("hy_agency_list returns a dataframe and works",{
  expect_is(hy_agency_list(hydat_path = hy_test_db()), "data.frame")
  expect_silent(hy_agency_list(hydat_path = hy_test_db()))
})

test_that("hy_reg_office_list returns a dataframe and works",{
  expect_is(hy_reg_office_list(hydat_path = hy_test_db()), "data.frame")
  expect_silent(hy_reg_office_list(hydat_path = hy_test_db()))
})

test_that("hy_datum_list returns a dataframe and works",{
  expect_is(hy_datum_list(hydat_path = hy_test_db()), "data.frame")
  expect_silent(hy_datum_list(hydat_path = hy_test_db()))
})

test_that("hy_version returns a dataframe and works",{
  expect_is(hy_version(hydat_path = hy_test_db()), "data.frame")
  expect_silent(hy_version(hydat_path = hy_test_db()))
})


test_that("pull_station_number fails when a dataframe doesn't contain a STATION_NUMBER column",{
  data(iris)
  expect_error(iris %>% pull_station_number())
})


test_that("pull_station_number grabs station number successfully",{
  stns <- c("08NM083", "08NE102")
  pulled_stns <- hy_annual_stats(stns, hydat_path = hy_test_db()) %>% pull_station_number()
  expect_identical(stns, unique(pulled_stns))
})
