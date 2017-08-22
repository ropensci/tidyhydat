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

#' @title Extract daily levels information from the HYDAT database
#' 
#' @description Provides wrapper to turn the DLY_LEVELS table in HYDAT into a tidy data frame. \code{STATION_NUMBER} and 
#' \code{PROV_TERR_STATE_LOC} must both be supplied. When STATION_NUMBER="ALL" the PROV_TERR_STATE_LOC argument decides 
#' where those stations come from. 
#' 
#' @inheritParams DLY_FLOWS
#' 
#' @return A tibble of daily levels
#' 
#' @examples 
#' \donttest{
#' DLY_LEVELS(STATION_NUMBER = "08LA001", PROV_TERR_STATE_LOC = "BC", 
#'            hydat_path = "H:/Hydat.sqlite3")
#' DLY_LEVELS(STATION_NUMBER = c("08LA001","08LG048"), PROV_TERR_STATE_LOC = "BC", 
#'           hydat_path = "H:/Hydat.sqlite3",
#'           start_date = "1996-01-01", end_date = "2000-01-01")
#'
#' DLY_LEVELS(STATION_NUMBER = "ALL", PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")
#' 
#' DLY_LEVELS(STATION_NUMBER = "ALL", PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3",
#'           start_date = "1996-01-01", end_date = "2000-01-01")
#'           }
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



DLY_LEVELS <- function(hydat_path, STATION_NUMBER, PROV_TERR_STATE_LOC, start_date ="ALL", end_date = "ALL") {
  
  
  ## Argument checks
  if(missing(STATION_NUMBER) | missing(PROV_TERR_STATE_LOC))
    stop("STATION_NUMBER or PROV_TERR_STATE_LOC argument is missing. These arguments must match jurisdictions.")
  
  #if(missing(start_date) | missing(end_date))
  #  stop("Both the start date and the end date must be specified")
  
  if(missing(hydat_path))
    stop("No Hydat.sqlite3 set. Download the hydat database from here: http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/")
  
  if(start_date == "ALL" & end_date == "ALL"){
    message("No start and end dates specified. All dates available will be returned.")
  } else {
    ## When we want date contraints we need to break apart the dates because SQL has no native date format 
    ##Start
    start_year = lubridate::year(start_date)
    start_month = lubridate::month(start_date)
    start_day = lubridate::day(start_date)
    
    ##End
    end_year = lubridate::year(end_date)
    end_month = lubridate::month(end_date)
    end_day = lubridate::day(end_date)
  }
  
  ## Check date is in the right format
  if(start_date != "ALL" | end_date != "ALL"){
    if(is.na(as.Date(start_date, format = "%Y-%m-%d")) | is.na(as.Date(end_date, format = "%Y-%m-%d")) ){
      stop("Invalid date format. Dates need to be in YYYY-MM-DD format")
    }
    
    if(start_date >= end_date){
      stop("start_date is after end_date. Try swapping values.")
    }
  }
  
  
  prov = PROV_TERR_STATE_LOC
  stns = STATION_NUMBER
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  ## Get list of stations when stns is ALL
  if (stns[1] == "ALL") {
    stns = dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::filter(PROV_TERR_STATE_LOC == prov) %>%
      dplyr::pull(STATION_NUMBER)
  }
  
  
  dly_levels = dplyr::tbl(hydat_con, "DLY_LEVELS")
  dly_levels = dplyr::filter(dly_levels, STATION_NUMBER %in% stns)
  
  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too
  if (start_date != "ALL" | end_date != "ALL") {
    dly_levels = dplyr::filter(dly_levels, YEAR >= start_year &
                                YEAR <= end_year)
  }
  
  dly_levels = dplyr::select(dly_levels, STATION_NUMBER, YEAR, MONTH, NO_DAYS, dplyr::contains("LEVEL"))
  dly_levels = dplyr::collect(dly_levels)
  dly_levels = tidyr::gather(dly_levels, variable, temp,-(STATION_NUMBER:NO_DAYS))
  dly_levels = dplyr::mutate(dly_levels, DAY = as.numeric(gsub("LEVEL|LEVEL_SYMBOL", "", variable)))
  dly_levels = dplyr::mutate(dly_levels, variable = gsub("[0-9]+", "", variable) )
  dly_levels = tidyr::spread(dly_levels, variable, temp)
  dly_levels = dplyr::mutate(dly_levels, LEVEL = as.numeric(LEVEL))
  ## No days that exceed actual number of days in the month
  dly_levels = dplyr::filter(dly_levels, DAY <= NO_DAYS)
  
  ##convert into R date. 
  dly_levels = dplyr::mutate(dly_levels, Date = lubridate::ymd(paste0(YEAR, "-", MONTH, "-", DAY)))  
  
  ## Then when a date column exist fine tune the subset
  if (start_date != "ALL" | end_date != "ALL") {
    dly_levels = dplyr::filter(dly_levels, Date >= start_date &
                                Date <= end_date)
  }
  dly_levels = dplyr::left_join(dly_levels, DATA_SYMBOLS, by = c("LEVEL_SYMBOL" = "SYMBOL_ID"))
  dly_levels = dplyr::mutate(dly_levels, Parameter = "LEVEL")
  dly_levels = dplyr::select(dly_levels, STATION_NUMBER, Date, Parameter, LEVEL, SYMBOL_EN)
  dly_levels = dplyr::arrange(dly_levels, Date)
  
  colnames(dly_levels) = c("STATION_NUMBER", "Date","Parameter","Value","Symbol")
  
  DBI::dbDisconnect(hydat_con)
  
  ## What stations were missed?
  differ = setdiff(unique(stns), unique(dly_levels$STATION_NUMBER))
  if( length(differ) !=0 ){
    message("The following station(s) were not retrieved: ", paste0(differ, sep = " "))
    message("Check station number typos or if it is a valid station in the network")
  } else{
    message("All station successfully retrieved")
  }
  
  return(dly_levels)
  
  
}

