# Copyright 2017 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.



#' @title Station Hydat wrapper
#' @export
#' 
#' @description Provides wrapper to turn the STATIONS table into a tidy data frame
#' 
#' @param hydat_path Directory to the hydat database
#' @param STATION_NUMBER Water Survey of Canada station number. No default. Can also take the "ALL" argument at which point you need 
#' to specify \code{PROV_TERR_STATE_LOC}. 
#' 
#' @examples 
#' 
#' ## One station
#' STATIONS(STATION_NUMBER = "08CG001")
#' ## Two stations
#' STATIONS(STATION_NUMBER = c("08CG001", "08CE001"))

STATIONS <-
  function(hydat_path = "H:/Hydat.sqlite3", STATION_NUMBER, PROV_TERR_STATE_LOC) {
    if(missing(STATION_NUMBER) | missing(PROV_TERR_STATE_LOC)) 
      stop("STATION_NUMBER or PROV_TERR_STATE_LOC argument is missing. These arguments must match jurisdictions.")
    
    prov = PROV_TERR_STATE_LOC
    stns = STATION_NUMBER
    #STATION_NUMBER = NULL
    
    dbname <- hydat_path
    
    ## Read on database

    hydat_con <- DBI::dbConnect(RSQLite::SQLite(), dbname)
    
    if(stns == "ALL"){
      stns = dplyr::tbl(hydat_con, "STATIONS") %>%
        filter(PROV_TERR_STATE_LOC == prov) %>%
        pull(STATION_NUMBER)
    }
    
    ## Because of a bug in dbplyr: https://github.com/tidyverse/dplyr/issues/2898
    if (length(stns) == 1 & stns[1] != "ALL") {
      df <- dplyr::tbl(hydat_con, "STATIONS") %>%
        filter(PROV_TERR_STATE_LOC == prov) %>%
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
