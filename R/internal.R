#' @title Function to chose a station based on consistent arguments for hydat functions.
#'
#' @description A function to avoid duplication in HYDAT functions.  This function is not intended for external use.
#'
#' @inheritParams hy_stations
#' @param hydat_con A database connection
#'
#' @keywords internal
#'
#'
station_choice <- function(hydat_con, station_number, prov_terr_state_loc) {


  ## Only possible values for prov_terr_state_loc
  stn_option <- dplyr::tbl(hydat_con, "STATIONS") %>%
    dplyr::distinct(PROV_TERR_STATE_LOC) %>%
    dplyr::pull(PROV_TERR_STATE_LOC)

  ## If not station_number arg is supplied then this controls how to handle the PROV arg
  if ((is.null(station_number) & !is.null(prov_terr_state_loc))) {
    station_number <- "ALL" ## All stations
    prov <- prov_terr_state_loc ## Prov info

    if (any(!prov %in% stn_option) == TRUE) {
      stop("Invalid prov_terr_state_loc value")
    }
  }

  ## If PROV arg is supplied then simply use the station_number independent of PROV
  if (is.null(prov_terr_state_loc)) {
    station_number <- station_number
  }


  ## Steps to create the station vector
  stns <- station_number

  ## Get all stations
  if (is.null(stns) == TRUE && is.null(prov_terr_state_loc) == TRUE) {
    stns <- dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::collect() %>%
      dplyr::pull(STATION_NUMBER)
  }

  if (stns[1] == "ALL") {
    stns <- dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::filter(PROV_TERR_STATE_LOC %in% prov) %>%
      dplyr::pull(STATION_NUMBER)
  }
  stns
}
