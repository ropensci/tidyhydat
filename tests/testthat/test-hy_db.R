context("hy_db")

test_that("hy_db returns the default location of the Hydat.sqlite3 database", {
  expect_equal(basename(hy_db(check_exists = FALSE)), "Hydat.sqlite3")
  expect_equal(basename(hy_db(hydat_path = hy_test_db())), "tinyhydat.sqlite3")
})

test_that("hy_db fails when there is no hydat_path", {
  expect_error(hy_db("not_a_file_anywhere.nope", check_exists = TRUE), "hydat_path does not exist")
  expect_silent(hy_db("not_a_file_anywhere.nope", check_exists = FALSE))
  expect_equal(hy_db("not_a_file_anywhere.nope", check_exists = FALSE), "not_a_file_anywhere.nope")
})

test_that("hy_src returns a dplyr src", {
  expect_is(hy_src(hydat_path = hy_test_db()), "src_sql")
})

test_that("the test database always exists", {
  expect_true(file.exists(hy_test_db()))
})
