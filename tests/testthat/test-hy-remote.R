test_that("hy_remote returns a string", {
  skip_on_cran()
  expect_true(
    is.character(hy_remote())
  )
})
