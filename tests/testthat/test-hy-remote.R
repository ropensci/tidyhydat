test_that("hy_remote returns a string", {
  expect_snapshot_output(hy_remote())
})
