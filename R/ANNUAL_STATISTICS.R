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


#' @title Extract daily flows information from the HYDAT database
#' 
#' @description Provides wrapper to turn the ANNUAL_STATISTICS table in HYDAT into a tidy data frame. \code{STATION_NUMBER} and 
#' \code{PROV_TERR_STATE_LOC} must both be supplied. When STATION_NUMBER="ALL" the PROV_TERR_STATE_LOC argument decides 
#' where those stations come from. 
#' 
#' @inheritParams STATIONS
#' @param start_year First year of the returned record
#' @param end_year Last year of the returned record
#' 
#' @return A tibble of ANNUAL_STATISTICS
#' 
#' @examples 
#' \donttest{
#' ANNUAL_STATISTICS(STATION_NUMBER = "08LA001",
#'                   PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3")
#'
#' ANNUAL_STATISTICS(STATION_NUMBER = "ALL", PROV_TERR_STATE_LOC = "PE", 
#'                   hydat_path = "H:/Hydat.sqlite3")
#' 
#' ANNUAL_STATISTICS(STATION_NUMBER = "ALL", PROV_TERR_STATE_LOC = "PE", 
#'                   hydat_path = "H:/Hydat.sqlite3",
#'                   start_year = 1972,
#'                   end_year = 1975)
#'}
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
#' @export

ANNUAL_STATISTICS <- function(hydat_path = "H:/Hydat.sqlite3", STATION_NUMBER, PROV_TERR_STATE_LOC, 
                              start_year = "ALL", end_year = "ALL") {
  
  ## Argument checks
  if(missing(STATION_NUMBER) | missing(PROV_TERR_STATE_LOC))
    stop("STATION_NUMBER or PROV_TERR_STATE_LOC argument is missing. These arguments must match jurisdictions.")
  
  #if(missing(start_year) | missing(end_year))
  #  stop("Both the start date and the end date must be specified")
  
  if(start_year == "ALL" & end_year == "ALL"){
    message("No start and end dates specified. All dates available will be returned.")
  } 
  
  prov = PROV_TERR_STATE_LOC
  stns = STATION_NUMBER
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  if(stns[1] == "ALL"){
    stns = dplyr::tbl(hydat_con, "STATIONS") %>%
      filter(PROV_TERR_STATE_LOC == prov) %>%
      pull(STATION_NUMBER)
  }
  
 
  annual_statistics = dplyr::tbl(hydat_con, "ANNUAL_STATISTICS")
  
  ## If a yearis supplied...
  if(start_year != "ALL" | end_year != "ALL"){
    annual_statistics = dplyr::filter(annual_statistics, YEAR >= start_year & YEAR <= end_year)
  }
  
  annual_statistics =  dplyr::filter(annual_statistics, STATION_NUMBER %in% stns) %>%
    dplyr::collect() 
  
  DBI::dbDisconnect(hydat_con)
  
  ## What stations were missed?
  differ = setdiff(unique(stns), unique(annual_statistics$STATION_NUMBER))
  if( length(differ) !=0 ){
    message("The following station(s) were not retrieved: ", paste0(differ, sep = " "))
    message("Check station number typos or if it is a valid station in the network")
  } else{
    message("All station successfully retrieved")
  }
  
  return(annual_statistics)
  

}

