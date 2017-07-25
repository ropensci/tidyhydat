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
#' @param hydat_path Directory to the hydat database. Can be set as "Hydat.sqlite3" which will look for Hydat in the working directory. 
#' @param STATION_NUMBER Water Survey of Canada station number. No default. Can also take the "ALL" argument. 
#' @param PROV_TERR_STATE_LOC Province, state or territory. See also for argument options.
#' @param start_date Leave blank in all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param end_date Leave blank in all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' 
#' @return A tibble of daily levels
#' 
#' @examples 
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
  }
  
  
  prov = PROV_TERR_STATE_LOC
  stns = STATION_NUMBER
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  ## Get list of stations when stns is ALL
  if(stns[1] == "ALL"){
    stns = dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::filter(PROV_TERR_STATE_LOC == prov) %>%
      dplyr::pull(STATION_NUMBER)
  }
  
  ## Because of a bug in dbplyr: https://github.com/tidyverse/dplyr/issues/2898
  if (length(stns) == 1 & stns[1] != "ALL") {
    dly_levels = dplyr::tbl(hydat_con, "DLY_LEVELS") 
    dly_levels = dplyr::filter(dly_levels, STATION_NUMBER == stns) 
    
    ## If a date is supplied...
    if(start_date != "ALL" | end_date != "ALL"){
      dly_levels = dplyr::filter(dly_levels, YEAR >= start_year & YEAR <= end_year)
    }
    
    dly_levels = dplyr::group_by(dly_levels, STATION_NUMBER) 
    dly_levels = dplyr::select_if(dly_levels, is.numeric)  ## select only numeric data
    dly_levels = dplyr::select(dly_levels, -(PRECISION_CODE:MAX)) %>% ## Only columns we need
      dplyr::collect() ## the end of the road for sqlite in this pipe
    dly_levels = tidyr::gather(dly_levels, DAY, LEVEL, -(STATION_NUMBER:MONTH)) 
    dly_levels = dplyr::mutate(dly_levels, DAY = as.numeric(gsub("LEVEL","", DAY)))  ##Extract day number
    dly_levels = dplyr::mutate(dly_levels, Date = lubridate::ymd(paste0(YEAR,"-",MONTH,"-",DAY)))  ##convert into R date. Failure to parse from invalid #days/motnh
    
    ## If a date is supplied...
    if(start_date != "ALL" | end_date != "ALL"){
      dly_levels = dplyr::filter(dly_levels, Date >= start_date & Date <= end_date)
    }
    dly_levels = dplyr::select(dly_levels, STATION_NUMBER, LEVEL, Date) 
    dly_levels = dplyr::filter(dly_levels, !is.na(Date)) 
    
    DBI::dbDisconnect(hydat_con)
    
    return(dly_levels)
  } else {
    dly_levels = dplyr::tbl(hydat_con, "DLY_LEVELS") 
    dly_levels = dplyr::filter(dly_levels, STATION_NUMBER %in% stns) 
    
    ## If a date is supplied...
    if(start_date != "ALL" | end_date != "ALL"){
      dly_levels = dplyr::filter(dly_levels, YEAR >= start_year & YEAR <= end_year)
    }
    
    dly_levels = dplyr::group_by(dly_levels, STATION_NUMBER) 
    dly_levels = dplyr::select_if(dly_levels, is.numeric)  ## select only numeric data
    dly_levels = dplyr::select(dly_levels, -(PRECISION_CODE:MAX)) %>% ## Only columns we need
      dplyr::collect() ## the end of the road for sqlite in this pipe
    dly_levels = tidyr::gather(dly_levels, DAY, LEVEL, -(STATION_NUMBER:MONTH)) 
    dly_levels = dplyr::mutate(dly_levels, DAY = as.numeric(gsub("LEVEL","", DAY)))  ##Extract day number
    dly_levels = dplyr::mutate(dly_levels, Date = lubridate::ymd(paste0(YEAR,"-",MONTH,"-",DAY)))  ##convert into R date. Failure to parse from invalid #days/motnh
    
    ## If a date is supplied...
    if(start_date != "ALL" | end_date != "ALL"){
      dly_levels = dplyr::filter(dly_levels, Date >= start_date & Date <= end_date)
    }
    dly_levels = dplyr::select(dly_levels, STATION_NUMBER, LEVEL, Date) 
    dly_levels = dplyr::filter(dly_levels, !is.na(Date)) 
    
    DBI::dbDisconnect(hydat_con)
    return(dly_levels)
  }
  
  
}

