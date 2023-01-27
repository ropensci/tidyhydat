test_that("hy_stations accepts single and multiple province arguments", {
  stns <- "08NM083"
  expect_identical(unique(hy_stations(
    station_number = stns,
    hydat_path = hy_test_db()
  )$STATION_NUMBER), stns)
  expect_identical(
    length(unique(hy_stations(
      station_number = c("08NM083", "08NE102"),
      hydat_path = hy_test_db()
    )$STATION_NUMBER)),
    length(c("08NM083", "08NE102"))
  )
})


test_that("hy_stations accepts single and multiple province arguments", {
  prov <- c("BC")
  expect_identical(unique(hy_stations(
    prov_terr_state_loc = "BC",
    hydat_path = hy_test_db()
  )$PROV_TERR_STATE_LOC), prov)
  expect_identical(unique(hy_stations(
    prov_terr_state_loc = c("AB", "BC"),
    hydat_path = hy_test_db()
  )$PROV_TERR_STATE_LOC), c("AB", "BC"))
})

test_that("hy_stations produces an error when a province is not specified correctly", {
  expect_error(hy_stations(prov_terr_state_loc = "BCD", hydat_path = hy_test_db()))
  expect_error(hy_stations(prov_terr_state_loc = c("AB", "BCD"), hydat_path = hy_test_db()))
})

test_that("hy_stations gather data when no arguments are supplied", {
  expect_true(nrow(hy_stations(hydat_path = hy_test_db())) >= 1)
})

test_that("hy_stations outputs actual NA's", {
  stns <- hy_stations(hydat_path = hy_test_db())
  expect_gt(nrow(stns[is.na(stns$SED_STATUS), ]), 0L)
})
