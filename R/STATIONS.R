#' @title Station Hydat wrapper
#' @export
#' 
#' @description Provides wrapper to turn the STATIONS table into a tidy data frame
#' 
#' @param hydat_path Directory to the hydat database
#' @param STATION_NUMBER Water Survey of Canada station number. No default. Can also take the "ALL" argument if all stations in BC are requested.
#' 
#' @examples 
#' 
#' ## One station
#' STATIONS(STATION_NUMBER = "08CG001")
#' ## Two stations
#' STATIONS(STATION_NUMBER = c("08CG001", "08CE001"))

STATIONS <-
  function(hydat_path = "H:/Hydat.sqlite3", STATION_NUMBER) {
    stns = STATION_NUMBER
    STATION_NUMBER = NULL
    
    dbname <- hydat_path
    
    ## Read on database

    hydat_con <- DBI::dbConnect(RSQLite::SQLite(), dbname)
    
    if(stns == "ALL"){
      stns = dplyr::tbl(hydat_con, "STATIONS") %>%
        filter(PROV_TERR_STATE_LOC == "BC") %>%
        pull(STATION_NUMBER)
    }
    
    ## Because of a bug in dbplyr: https://github.com/tidyverse/dplyr/issues/2898
    if (length(stns) == 1 & stns[1] != "ALL") {
      df <- dplyr::tbl(hydat_con, "STATIONS") %>%
        dplyr::filter(STATION_NUMBER == stns) %>%
        dplyr::collect()
      
      return(df)
    } else{
      df <- dplyr::tbl(hydat_con, "STATIONS") %>%
        dplyr::filter(STATION_NUMBER %in% stns) %>%
        dplyr::collect() 
      
      return(df)
    }
    
    DBI::dbDisconnect(hydat_con)
    
  }
