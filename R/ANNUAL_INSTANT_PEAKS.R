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


#' @title Annual maximum/minimum instantaneous flows and water levels
#' 
#' @description Provides wrapper to turn the ANNUAL_INSTANT_PEAKS table in HYDAT into a tidy data frame. \code{STATION_NUMBER} and 
#' \code{PROV_TERR_STATE_LOC} can both be supplied. If both are omitted all values from the \code{STATIONS} table are returned.
#' 
#' @inheritParams STATIONS
#' @param start_year First year of the returned record
#' @param end_year Last year of the returned record
#' 
#' @return A tibble of ANNUAL_INSTANT_PEAKS
#' 
#' @examples 
#' \donttest{
#' ## Multiple stations province not specified 
#' ANNUAL_INSTANT_PEAKS(STATION_NUMBER = c("08NM083","08NE102"), hydat_path = "H:/Hydat.sqlite3")
#' 
#' ## Multiple province, station number not specified
#' ANNUAL_INSTANT_PEAKS(PROV_TERR_STATE_LOC = c("AB","YT"), hydat_path = "H:/Hydat.sqlite3")
#'}
#'
#' @export
#' 
ANNUAL_INSTANT_PEAKS <- function(hydat_path, STATION_NUMBER = NULL, PROV_TERR_STATE_LOC = NULL, 
                              start_year = "ALL", end_year = "ALL") {
  
  if(missing(hydat_path))
    stop("No Hydat.sqlite3 set. Download the hydat database from here: http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/")
  
  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  ## Only possible values for PROV_TERR_STATE_LOC
  stn_option = dplyr::tbl(hydat_con, "STATIONS") %>%
    dplyr::distinct(PROV_TERR_STATE_LOC) %>%
    dplyr::pull(PROV_TERR_STATE_LOC)
  
  ## If not STATION_NUMBER arg is supplied then this controls how to handle the PROV arg
  if((is.null(STATION_NUMBER) & !is.null(PROV_TERR_STATE_LOC))){
    STATION_NUMBER = "ALL" ## All stations
    prov = PROV_TERR_STATE_LOC ## Prov info
    
    if(any(!prov %in% stn_option) == TRUE){
      stop("Invalid PROV_TERR_STATE_LOC value")
      DBI::dbDisconnect(hydat_con)
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
  
  aip = dplyr::tbl(hydat_con, "ANNUAL_INSTANT_PEAKS") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect()
  
  ## Add in english data type
  aip = dplyr::left_join(aip, DATA_TYPES, by = c("DATA_TYPE"))
  
  ## Add in Symbol
  aip = dplyr::left_join(aip, DATA_SYMBOLS, by = c("SYMBOL"= "SYMBOL_ID"))
  
  ## If a yearis supplied...
  if(start_year != "ALL" | end_year != "ALL"){
    aip = dplyr::filter(aip, YEAR >= start_year & YEAR <= end_year)
  }
  
  ## Parse PEAK_CODE manually - there are only 2
  aip = dplyr::mutate(aip, PEAK_CODE = ifelse(PEAK_CODE == "H", "MAX","MIN"))
  
  ## Parse PRECISION_CODE manually - there are only 2
  aip = dplyr::mutate(aip, PRECISION_CODE = ifelse(PRECISION_CODE == 8, "in m (to mm)","in m (to cm)"))
  
  ## TODO: Convert to dttm
  #aip = dplyr::mutate(aip, Datetime = lubridate::ymd_hm(paste0(YEAR,"-",MONTH,"-",DAY," ",HOUR,":",MINUTE)))
  
  ## Clean up and select only columns we need
  aip = dplyr::select(aip, STATION_NUMBER, DATA_TYPE_EN, YEAR, PEAK_CODE, PRECISION_CODE, MONTH, DAY, HOUR, MINUTE, TIME_ZONE, PEAK, SYMBOL_EN) %>%
    dplyr::rename(Parameter = DATA_TYPE_EN, Symbol = SYMBOL_EN, Value = PEAK) 
  
  DBI::dbDisconnect(hydat_con)
  
  return(aip)
  
}
  
