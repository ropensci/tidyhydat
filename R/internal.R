#' @title Function to chose a station based on consistent arguments for hydat functions.
#' 
#' @description A function to avoid duplication in HYDAT functions.  This function is not intended for external use. 
#' 
#' @inheritParams STATIONS
#' @param hydat_con A database connection
#' 
#' @keywords internal
#' 
#' 
station_choice = function(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC){
  
  
  ## Only possible values for PROV_TERR_STATE_LOC
  stn_option = dplyr::tbl(hydat_con, "STATIONS") %>%
    dplyr::distinct(PROV_TERR_STATE_LOC) %>%
    dplyr::pull(PROV_TERR_STATE_LOC)
  
  ## If not STATION_NUMBER arg is supplied then this controls how to handle the PROV arg
  if((is.null(STATION_NUMBER) & !is.null(PROV_TERR_STATE_LOC))){
    STATION_NUMBER = "ALL" ## All stations
    prov = PROV_TERR_STATE_LOC ## Prov info
    
    if(any(!prov %in% stn_option) == TRUE){
      DBI::dbDisconnect(hydat_con)
      stop("Invalid PROV_TERR_STATE_LOC value")
    }
  }
  
  ## If PROV arg is supplied then simply use the STATION_NUMBER independent of PROV
  if(is.null(PROV_TERR_STATE_LOC)){
    STATION_NUMBER = STATION_NUMBER
  }
  
  
  ## Steps to create the station vector
  stns = STATION_NUMBER
  
  ## Get all stations
  if(is.null(stns) == TRUE && is.null(PROV_TERR_STATE_LOC) == TRUE){
    stns = dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::collect() %>%
      dplyr::pull(STATION_NUMBER)
  }
  
  if(stns[1] == "ALL"){
    stns = dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::filter(PROV_TERR_STATE_LOC %in% prov) %>%
      dplyr::pull(STATION_NUMBER)
  }
  return(stns)
}
