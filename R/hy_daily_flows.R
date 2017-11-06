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
#' @description Provides wrapper to turn the DLY_FLOWS table in HYDAT into a tidy data frame of daily flows. 
#' \code{station_number} and \code{prov_terr_state_loc} can both be supplied. If both are omitted all 
#' values from the \code{hy_stations} table are returned. That is a large tibble for \code{hy_daily_flows}.
#'
#' @inheritParams hy_stations
#' @param start_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param end_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param symbol_output Set whether the raw code, or the \code{english} or the \code{french} translations are outputted. Default 
#'   value is \code{code}. 
#'
#' @return A tibble of daily flows
#' 
#' @format A tibble with 5 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Date}{Observation date. Formatted as a Date class.}
#'   \item{Parameter}{Parameter being measured. Only possible value is FLOW}
#'   \item{Value}{Discharge value. The units are m^3/s.}
#'   \item{Symbol}{Measurement/river conditions}
#' }
#'
#' @examples
#' \dontrun{
#' #download_hydat()
#' hy_daily_flows(station_number = c("02JE013","08MF005"), 
#'   start_date = "1996-01-01", end_date = "2000-01-01")
#'
#' hy_daily_flows(prov_terr_state_loc = "PE")
#'           }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export



hy_daily_flows <- function(station_number = NULL,
                      hydat_path = NULL, 
                      prov_terr_state_loc = NULL, start_date = "ALL", end_date = "ALL",
                      symbol_output = "code") {
  
  if (!is.null(station_number) && station_number == "ALL") {
    stop("Deprecated behaviour.Omit the station_number = \"ALL\" argument. See ?hy_daily_flows for examples.")
  }
  
  if (start_date == "ALL" & end_date == "ALL") {
    message("No start and end dates specified. All dates available will be returned.")
  } else {
    ## When we want date contraints we need to break apart the dates because SQL has no native date format
    ## Start
    start_year <- lubridate::year(start_date)
    start_month <- lubridate::month(start_date)
    start_day <- lubridate::day(start_date)
    
    ## End
    end_year <- lubridate::year(end_date)
    end_month <- lubridate::month(end_date)
    end_day <- lubridate::day(end_date)
  }
  
  ## Check date is in the right format
  if (start_date != "ALL" | end_date != "ALL") {
    if (is.na(as.Date(start_date, format = "%Y-%m-%d")) | is.na(as.Date(end_date, format = "%Y-%m-%d"))) {
      stop("Invalid date format. Dates need to be in YYYY-MM-DD format")
    }
    
    if (start_date > end_date) {
      stop("start_date is after end_date. Try swapping values.")
    }
  }
  
  if(is.null(hydat_path)){
    hydat_path <- file.path(hy_dir(),"Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",hy_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  
  ## Data manipulations to make it "tidy"
  dly_flows <- dplyr::tbl(hydat_con, "DLY_FLOWS")
  dly_flows <- dplyr::filter(dly_flows, STATION_NUMBER %in% stns)
  
  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too
  if (start_date != "ALL" | end_date != "ALL") {
    dly_flows <- dplyr::filter(dly_flows, YEAR >= start_year &
                                 YEAR <= end_year)
  }
  
  dly_flows <- dplyr::select(dly_flows, STATION_NUMBER, YEAR, MONTH, NO_DAYS, dplyr::contains("FLOW"))
  dly_flows <- dplyr::collect(dly_flows)
  
  if(is.data.frame(dly_flows) && nrow(dly_flows)==0)
    {stop("This station is not present in HYDAT")}
  
  dly_flows <- tidyr::gather(dly_flows, variable, temp, -(STATION_NUMBER:NO_DAYS))
  dly_flows <- dplyr::mutate(dly_flows, DAY = as.numeric(gsub("FLOW|FLOW_SYMBOL", "", variable)))
  dly_flows <- dplyr::mutate(dly_flows, variable = gsub("[0-9]+", "", variable))
  dly_flows <- tidyr::spread(dly_flows, variable, temp)
  dly_flows <- dplyr::mutate(dly_flows, FLOW = as.numeric(FLOW))
  ## No days that exceed actual number of days in the month
  dly_flows <- dplyr::filter(dly_flows, DAY <= NO_DAYS)
  
  ## convert into R date.
  dly_flows <- dplyr::mutate(dly_flows, Date = lubridate::ymd(paste0(YEAR, "-", MONTH, "-", DAY)))
  
  ## Then when a date column exist fine tune the subset
  if (start_date != "ALL" | end_date != "ALL") {
    dly_flows <- dplyr::filter(dly_flows, Date >= start_date &
                                 Date <= end_date)
  }
  
  dly_flows <- dplyr::left_join(dly_flows, tidyhydat::hy_data_symbols, by = c("FLOW_SYMBOL" = "SYMBOL_ID"))
  dly_flows <- dplyr::mutate(dly_flows, Parameter = "FLOW")
  
  ## Control for symbol ouput
  if(symbol_output == "code"){
    dly_flows <- dplyr::select(dly_flows, STATION_NUMBER, Date, Parameter, FLOW, FLOW_SYMBOL)
  }
  
  if(symbol_output == "english"){
    dly_flows <- dplyr::select(dly_flows, STATION_NUMBER, Date, Parameter, FLOW, SYMBOL_EN)
  }
  
  if(symbol_output == "french"){
    dly_flows <- dplyr::select(dly_flows, STATION_NUMBER, Date, Parameter, FLOW, SYMBOL_FR)
  }
  
  
  dly_flows <- dplyr::arrange(dly_flows, Date)
  
  colnames(dly_flows) <- c("STATION_NUMBER", "Date", "Parameter", "Value", "Symbol")
  
  
  ## What stations were missed?
  differ <- setdiff(unique(stns), unique(dly_flows$STATION_NUMBER))
  if (length(differ) != 0) {
    if (length(differ) <= 10) {
      message("The following station(s) were not retrieved: ", paste0(differ, sep = " "))
      message("Check station number typos or if it is a valid station in the network")
    }
    else {
      message("More than 10 stations from the initial query were not returned. Ensure realtime and active status are correctly specified.")
    }
  } else {
    message("All station successfully retrieved")
  }


  dly_flows
}
