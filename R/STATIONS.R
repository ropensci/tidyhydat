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



#' @title Extract station information from the HYDAT database 
#' 
#' @description Provides wrapper to turn the STATIONS table in HYDAT into a tidy data frame. \code{STATION_NUMBER} and 
#' \code{PROV_TERR_STATE_LOC} must both be supplied. When STATION_NUMBER="ALL" the PROV_TERR_STATE_LOC argument decides 
#' where those stations come from. 
#' 
#' @param hydat_path Directory to the hydat database. Can be set as "Hydat.sqlite3" which will look for Hydat in the working directory 
#' @param STATION_NUMBER Water Survey of Canada station number. No default. Can also take the "ALL" argument. 
#' @param PROV_TERR_STATE_LOC Province, state or territory. See also for argument options.
#' 
#' @return A tibble of stations and associated metadata
#' 
#' @examples 
#' ## Two stations
#' STATIONS(STATION_NUMBER = c("08CG001", "08CE001"), 
#'    PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3")
#' ## ALL stations from PEI
#' STATIONS(STATION_NUMBER = "ALL", PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")
#' 
#' @seealso 
#' Possible arguments for \code{PROV_TERR_STATE_LOC}
#' \itemize{
#' \item "QC" 
#' \item "ME" 
#' \item "NB" 
#' \item "PE" 
#' \item "NS" 
#' \item "MN" 
#' \item "ON" 
#' \item "MI" 
#' \item "NL" 
#' \item "MB" 
#' \item "AB" 
#' \item "MT" 
#' \item "SK" 
#' \item "ND" 
#' \item "NU" 
#' \item "NT" 
#' \item "BC" 
#' \item "YT" 
#' \item "AK" 
#' \item "WA" 
#' \item "ID"
#' }
#' 
#' @export

STATIONS <- function(hydat_path, STATION_NUMBER, PROV_TERR_STATE_LOC) {
  if(missing(STATION_NUMBER) | missing(PROV_TERR_STATE_LOC))
    stop("STATION_NUMBER or PROV_TERR_STATE_LOC argument is missing. These arguments must match jurisdictions.")
  
  if(missing(hydat_path))
    stop("No Hydat.sqlite3 set. Download the hydat database from here: http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/")
  

  ## TODO: Have a conditional that restricts and throw a warning when PROV_TERR_STATE_LOC isn't allowed
  
    prov = PROV_TERR_STATE_LOC
    stns = STATION_NUMBER
    
    ## Read in database
    hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
    
    ## Out all stations in the network
    if(stns == "ALL" &&  prov == "ALL"){
      df = dplyr::tbl(hydat_con, "STATIONS") %>%
        dplyr::collect()
      DBI::dbDisconnect(hydat_con)
      return(df)
    }
    
    if(stns[1] == "ALL"){
      stns = dplyr::tbl(hydat_con, "STATIONS") %>%
        filter(PROV_TERR_STATE_LOC == prov) %>%
        pull(STATION_NUMBER)
    }
    
    df <- dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::filter(STATION_NUMBER %in% stns) %>%
      dplyr::collect() 
    DBI::dbDisconnect(hydat_con)
    
    return(df)

    
    
    
  }
