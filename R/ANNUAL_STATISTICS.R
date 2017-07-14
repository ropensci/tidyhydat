#' @title Get a tidy tibble of daily flows
#' @export
#' 
#' @description Provides wrapper to turn the ANNUAL_STATISTICS table into a tidy data frame
#' 
#' @param hydat_path Directory to the hydat database
#' @param STATION_NUMBER Water Survey of Canada station number. No default. Can also take the "ALL" argument if all stations in BC are requested.
#' 
#' @return A tibble of ANNUAL_STATISTICS
#' 
#' @examples 
#' ANNUAL_STATISTICS(STATION_NUMBER = "08LA001")
#'
#' ANNUAL_STATISTICS(STATION_NUMBER = c("08LA001","08LG006"))



ANNUAL_STATISTICS <- function(hydat_path = "H:/Hydat.sqlite3", STATION_NUMBER) {
  stn = STATION_NUMBER
  STATION_NUMBER = NULL
  
  dbname <- hydat_path
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), dbname)
  
  if(stn[1] == "ALL"){
    stn = dplyr::tbl(hydat_con, "STATIONS") %>%
      filter(PROV_TERR_STATE_LOC == "BC") %>%
      pull(STATION_NUMBER)
  }
  ## Because of a bug in dbplyr: https://github.com/tidyverse/dplyr/issues/2898
  if (length(stn) == 1 & stns[1] != "ALL") {
    annual_statistics = dplyr::tbl(hydat_con, "ANNUAL_STATISTICS") %>%
      dplyr::filter(STATION_NUMBER == stn) %>%
      dplyr::collect() 
    return(annual_statistics)
  } else {
    annual_statistics = tbl(hydat_con, "ANNUAL_STATISTICS") %>%
      dplyr::filter(STATION_NUMBER %in% stn) %>%
      dplyr::collect() 
    
    return(annual_statistics)
  }
  
  DBI::dbDisconnect(hydat_con)
}

