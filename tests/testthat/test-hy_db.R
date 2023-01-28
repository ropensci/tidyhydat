test_that("hy_*_db returns the correct locations", {
  expect_equal(basename(hy_downloaded_db()), "Hydat.sqlite3")
  expect_equal(basename(hy_test_db()), "tinyhydat.sqlite3")

  # create a temporary file
  tmp_file <- tempfile()
  file.create(tmp_file)

  prev_def <- hy_set_default_db(tmp_file)
  expect_equal(hy_default_db(), tmp_file)
  hy_set_default_db(prev_def)

  unlink(tmp_file)
})

test_that("hy_set_default_db() fails when the input is not valid", {
  def_value <- hy_default_db()

  expect_error(
    hy_set_default_db(character(0)),
    "length\\(hydat_path\\) == 1 is not TRUE"
  )

  expect_error(
    hy_set_default_db(factor(hy_test_db())),
    "is.character\\(hydat_path\\) is not TRUE"
  )

  expect_error(
    hy_set_default_db("not_a_file_anywhere.nope"),
    "file.exists\\(hydat_path\\) is not TRUE"
  )

  # make sure we didn't change the default value by accident
  hy_set_default_db(def_value)
})

test_that("default place to look for Hydat database can be get/set internally", {
  # get previous value so we can reset when done the test
  prev_val <- tidyhydat:::hy_set_default_db(NULL)

  # NULL should set back to original default
  expect_equal(tidyhydat:::hy_default_db(), file.path(hy_dir(), "Hydat.sqlite3"))

  # set_default_db should return previous value
  expect_equal(tidyhydat:::hy_set_default_db(hy_test_db()), file.path(hy_dir(), "Hydat.sqlite3"))

  # set back to value when we started
  tidyhydat:::hy_set_default_db(prev_val)
})

test_that("hy_src fails when hydat_path is not a file", {
  expect_error(
    hy_src("not_a_file_anywhere.nope"),
    "Run download_hydat\\(\\) to download the database."
  )
})

test_that("hy_src returns a dplyr src", {
  src <- hy_src(hydat_path = hy_test_db())
  expect_s3_class(src, "src_sql")
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

test_that("hy_src_disconnect errors when called on an unknown object", {
  expect_error(
    hy_src_disconnect(NULL),
    "hy_src_disconnect doesn't know how to deal with object of class"
  )
})

test_that("the test database always exists", {
  expect_true(file.exists(hy_test_db()))
})
