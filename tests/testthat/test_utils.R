test_that("hy_dir returns a path", {
  expect_silent(hy_dir())
})

test_that("hy_agency_list returns a dataframe and works", {
  expect_s3_class(hy_agency_list(hydat_path = hy_test_db()), "data.frame")
  expect_silent(hy_agency_list(hydat_path = hy_test_db()))
})

test_that("hy_reg_office_list returns a dataframe and works", {
  expect_s3_class(hy_reg_office_list(hydat_path = hy_test_db()), "data.frame")
  expect_silent(hy_reg_office_list(hydat_path = hy_test_db()))
})

test_that("hy_datum_list returns a dataframe and works", {
  expect_s3_class(hy_datum_list(hydat_path = hy_test_db()), "data.frame")
  expect_silent(hy_datum_list(hydat_path = hy_test_db()))
})

test_that("hy_version returns a dataframe and works", {
  expect_s3_class(hy_version(hydat_path = hy_test_db()), "data.frame")
  expect_silent(hy_version(hydat_path = hy_test_db()))
})


test_that("downloading hydat fails behind a proxy server with informative error message", {
  skip_on_cran()
  skip_on_ci()
  base_url_cmc <- "http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/"
  expect_snapshot_error(
    tidyhydat:::network_check(base_url_cmc, "64.251.21.73", 8080)
  )
})


test_that("pull_station_number fails when a dataframe doesn't contain a STATION_NUMBER column", {
  data(iris)
  expect_error(iris |> pull_station_number())
})


test_that("pull_station_number grabs station number successfully", {
  stns <- c("08NM083", "08NE102")
  pulled_stns <- hy_annual_stats(stns, hydat_path = hy_test_db()) |>
    pull_station_number()
  expect_identical(stns, unique(pulled_stns))
})

test_that("pull_station_number returns only unique values", {
  many_repeats <- hy_sed_samples(hydat_path = hy_test_db())
  expect_length(pull_station_number(many_repeats), 2)
})
