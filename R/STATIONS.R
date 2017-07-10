#' @title Station Hydat wrapper
#' @export
#' 
#' @description Provides wrapper to turn the STATIONS table into a tidy data frame
#' 
#' @param hydat_path Directory to the hydat database
#' @param STATION_NUMBER_SEL Water Survey of Canada station number
#' 
#' @examples 
#' 
#' ## One station
#' STATIONS(STATION_NUMBER = "08CG001")
#' ## Two stations
#' STATIONS(STATION_NUMBER = c("08CG001", "08CE001"))

STATIONS <-
  function(hydat_path = "H:/Hydat.sqlite3", STATION_NUMBER_SEL = STATION_NUMBER) {
    dbname <- hydat_path
    
    ## Read on database

    hydat_con <- DBI::dbConnect(RSQLite::SQLite(), dbname)
    
    ## Because of a bug in dbplyr: https://github.com/tidyverse/dplyr/issues/2898
    if (length(STATION_NUMBER_SEL) == 1) {
      df <- dplyr::tbl(hydat_con, "STATIONS") %>%
        dplyr::filter(STATION_NUMBER == STATION_NUMBER_SEL) %>%
        dplyr::collect()
      
      return(df)
    } else{
      df <- dplyr::tbl(hydat_con, "STATIONS") %>%
        dplyr::filter(STATION_NUMBER %in% STATION_NUMBER_SEL) %>%
        dplyr::collect() 
      
      return(df)
    }
    
    DBI::dbDisconnect(hydat_con)
    
  }
