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
#' @description Provides wrapper to turn the DLY_FLOWS table in HYDAT into a tidy data frame. \code{STATION_NUMBER} and 
#' \code{PROV_TERR_STATE_LOC} must both be supplied. When STATION_NUMBER="ALL" the PROV_TERR_STATE_LOC argument decides 
#' where those stations come from. 
#' 
#' @param hydat_path Directory to the hydat database. Can be set as "Hydat.sqlite3" which will look for Hydat in the working directory. 
#' @param STATION_NUMBER Water Survey of Canada station number. No default. Can also take the "ALL" argument. 
#' @param PROV_TERR_STATE_LOC Province, state or territory. See also for argument options.
#' 
#' @return A tibble of daily flows
#' 
#' @examples 
#' DLY_FLOWS(STATION_NUMBER = "08LA001", PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3")
#'
#' DLY_FLOWS(STATION_NUMBER = "ALL", PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")
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



DLY_FLOWS <- function(hydat_path, STATION_NUMBER, PROV_TERR_STATE_LOC) {
  
  if(missing(STATION_NUMBER) | missing(PROV_TERR_STATE_LOC))
    stop("STATION_NUMBER or PROV_TERR_STATE_LOC argument is missing. These arguments must match jurisdictions.")
  
  if(missing(hydat_path))
    stop("No Hydat.sqlite3 set. Download the hydat database from here: http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/")
  
  prov = PROV_TERR_STATE_LOC
  stns = STATION_NUMBER

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  if(stns[1] == "ALL"){
    stns = dplyr::tbl(hydat_con, "STATIONS") %>%
      filter(PROV_TERR_STATE_LOC == prov) %>%
      pull(STATION_NUMBER)
  }
  
  ## Because of a bug in dbplyr: https://github.com/tidyverse/dplyr/issues/2898
  if (length(stns) == 1 & stns[1] != "ALL") {
    dly_flows = dplyr::tbl(hydat_con, "DLY_FLOWS") %>%
      dplyr::filter(STATION_NUMBER == stns) %>%
      dplyr::group_by(STATION_NUMBER) %>%
      dplyr::select_if(is.numeric) %>% ## select only numeric data
      dplyr::select(-(FULL_MONTH:MAX)) %>% ## Only columns we need
      dplyr::collect() %>% ## the end of the road for sqlite in this pipe
      tidyr::gather(DAY, FLOW, -(STATION_NUMBER:MONTH)) %>%
      dplyr::mutate(DAY = as.numeric(gsub("FLOW","", DAY))) %>% ##Extract day number
      dplyr::mutate(Date = lubridate::ymd(paste0(YEAR,"-",MONTH,"-",DAY))) %>% ##convert into R date. Failure to parse from invalid #days/motnh
      dplyr::select(STATION_NUMBER, FLOW, Date) %>%
      dplyr::filter(!is.na(Date)) %>%
      tibble::as_tibble()
    
    DBI::dbDisconnect(hydat_con)
    
    return(dly_flows)
  } else {
    dly_flows = dplyr::tbl(hydat_con, "DLY_FLOWS") %>%
      dplyr::filter(STATION_NUMBER %in% stns) %>%
      dplyr::group_by(STATION_NUMBER) %>%
      dplyr::select_if(is.numeric) %>% ## select only numeric data
      dplyr::select(-(FULL_MONTH:MAX)) %>% ## Only columns we need
      dplyr::collect() %>% ## the end of the road for sqlite in this pipe
      tidyr::gather(DAY, FLOW, -(STATION_NUMBER:MONTH)) %>%
      dplyr::mutate(DAY = as.numeric(gsub("FLOW","", DAY))) %>% ##Extract day number
      dplyr::mutate(Date = lubridate::ymd(paste0(YEAR,"-",MONTH,"-",DAY))) %>% ##convert into R date. Failure to parse from invalid #days/motnh
      dplyr::select(STATION_NUMBER, FLOW, Date) %>%
      dplyr::filter(!is.na(Date)) %>%
      tibble::as_tibble()
    
    DBI::dbDisconnect(hydat_con)
    return(dly_flows)
  }
  
  
}

