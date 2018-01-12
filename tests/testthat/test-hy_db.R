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
  src <- hy_src(hydat_path = hy_test_db())
  expect_is(src, "src_sql")
  hy_src_disconnect(src)
})

test_that("hy_src returns its input if hydat_path is already a hy_src", {
  src <- hy_src(hydat_path = hy_test_db())
  expect_identical(hy_src(hydat_path = src), src)
  hy_src_disconnect(src)
})

test_that("hy_src_disconnect disconnects the database", {
  src <- hy_src(hydat_path = hy_test_db())
  expect_true(DBI::dbIsValid(src$con))
  hy_src_disconnect(src)
  expect_false(DBI::dbIsValid(src$con))
})

test_that("hy_src_disconnect produces warnings when database is already connected", {
  src <- hy_src(hydat_path = hy_test_db())
  expect_true(DBI::dbIsValid(src$con))
  expect_silent(hy_src_disconnect(src))
  expect_warning(hy_src_disconnect(src), "Already disconnected")
})

test_that("hy_src_disconnect also works on database connections", {
  src <- hy_src(hydat_path = hy_test_db())
  expect_true(DBI::dbIsValid(src$con))
  hy_src_disconnect(src$con)
  expect_false(DBI::dbIsValid(src$con))
})

test_that("hy_src_disconnect errors when called on an unknown object", {
  expect_error(
    hy_src_disconnect(NULL), 
    "hy_src_disconnect doesn't know how to deal with object of class"
  )
})

test_that("the test database always exists", {
  expect_true(file.exists(hy_test_db()))
})
