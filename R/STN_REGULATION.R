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



#' @title Extract station regulation from the HYDAT database 
#' 
#' @description Provides wrapper to turn the STN_REGULATION table in HYDAT into a tidy data frame. \code{STATION_NUMBER} and 
#' \code{PROV_TERR_STATE_LOC} must both be supplied. When STATION_NUMBER="ALL" the PROV_TERR_STATE_LOC argument decides 
#' where those stations come from. 
#' 
#' @param hydat_path Directory to the hydat database. Can be set as "Hydat.sqlite3" which will look for Hydat in the working directory 
#' @param STATION_NUMBER Water Survey of Canada station number. No default. Can also take the "ALL" argument. 
#' 
#' @return A tibble of stations, years of regulation and the regulation status
#' 
#' @examples 
#' \donttest{
#' ## Two stations
#' STN_REGULATION(STATION_NUMBER = c("08CG001", "08CE001"), hydat_path = "H:/Hydat.sqlite3")
#' 
#' ## ALL stations from PEI
#' STN_REGULATION(STATION_NUMBER = "ALL", hydat_path = "H:/Hydat.sqlite3")
#' }
#' 

#' @export

STN_REGULATION <- function(hydat_path, STATION_NUMBER = "ALL") {

  if(missing(hydat_path))
    stop("No Hydat.sqlite3 set. Download the hydat database from here: http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/")
  
  
  stns = STATION_NUMBER
  
  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  

  if(stns[1] == "ALL"){
    df = dplyr::tbl(hydat_con, "STN_REGULATION") %>%
      dplyr::collect() %>%
      dplyr::mutate(
        REGULATED = dplyr::case_when(
          REGULATED == 0 ~ "Natural",
          REGULATED == 1 ~ "Regulated"
        )
        )
    DBI::dbDisconnect(hydat_con)
    return(df)
  } else{
    df <- dplyr::tbl(hydat_con, "STN_REGULATION") %>%
      dplyr::filter(STATION_NUMBER %in% stns) %>%
      dplyr::collect() %>%
      dplyr::mutate(
        REGULATED = dplyr::case_when(
          REGULATED == 0 ~ "Natural",
          REGULATED == 1 ~ "Regulated"
        )
      )
    DBI::dbDisconnect(hydat_con)
    
    return(df)
  }
  
}
