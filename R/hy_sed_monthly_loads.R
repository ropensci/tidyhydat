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

#' Extract monthly flows information from the HYDAT database
#'
#' Tidy data of monthly loads information from the SED_DLY_LOADS HYDAT table. \code{station_number} and
#'   \code{prov_terr_state_loc} can both be supplied. If both are omitted all values from the \code{hy_stations} table are returned.
#'   That is a large vector for \code{hy_sed_monthly_loads}.
#'
#' @inheritParams hy_stations
#' @param start_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param end_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#'
#' @return A tibble of monthly sediment loads. 
#'   
#' @format A tibble with 8 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{YEAR}{Year of record.}
#'   \item{MONTH}{Numeric month value}
#'   \item{FULL_MONTH}{Logical value is there is full record from MONTH}
#'   \item{NO_DAYS}{Number of days in that month}
#'   \item{Sum_stat}{Summary statistic being used.} 
#'   \item{Value}{Value of the measurement in tonnes.}
#'   \item{Date_occurred}{Observation date. Formatted as a Date class. MEAN is a annual summary 
#'   and therefore has an NA value for Date.}
#' }
#'
#' @examples
#' \dontrun{
#' hy_sed_monthly_loads(station_number = "01CE003")
#'           }
#'           
#' @family HYDAT functions
#' @source HYDAT
#' @export



hy_sed_monthly_loads <- function(station_number = NULL,
                              hydat_path = NULL, 
                              prov_terr_state_loc = NULL, start_date ="ALL", end_date = "ALL") {
  
  if(is.null(hydat_path)){
    hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  
  if (!is.null(station_number) && station_number == "ALL") {
    stop("Deprecated behaviour.Omit the station_number = \"ALL\" argument. See ?hy_sed_monthly_loads for examples.")
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
  

  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  on.exit(DBI::dbDisconnect(hydat_con))
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  
  ## Data manipulations to make it "tidy"
  sed_monthly_loads <- dplyr::tbl(hydat_con, "SED_DLY_LOADS")
  sed_monthly_loads <- dplyr::filter(sed_monthly_loads, STATION_NUMBER %in% stns)
  
  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too
  if (start_date != "ALL" | end_date != "ALL") {
    sed_monthly_loads <- dplyr::filter(sed_monthly_loads, YEAR >= start_year &
                                         YEAR <= end_year)
    
    #sed_monthly_loads <- dplyr::filter(sed_monthly_loads, MONTH >= start_month &
    #                             MONTH <= end_month)
  }
  
  sed_monthly_loads <- dplyr::select(sed_monthly_loads, STATION_NUMBER:MAX)
  sed_monthly_loads <- dplyr::collect(sed_monthly_loads)
  
  if(is.data.frame(sed_monthly_loads) && nrow(sed_monthly_loads)==0)
  {stop("This station is not present in HYDAT")}
  
  ## Need to rename columns for gather
  colnames(sed_monthly_loads) <- c("STATION_NUMBER","YEAR","MONTH", "FULL_MONTH", "NO_DAYS","MEAN_Value",
                           "TOTAL_Value", "MIN_DAY","MIN_Value", "MAX_DAY","MAX_Value")
  
  

  sed_monthly_loads <- tidyr::gather(sed_monthly_loads, variable, temp, -(STATION_NUMBER:NO_DAYS))
  sed_monthly_loads <- tidyr::separate(sed_monthly_loads, variable, into = c("Sum_stat","temp2"), sep = "_")

  sed_monthly_loads <- tidyr::spread(sed_monthly_loads, temp2, temp)

  ## convert into R date for date of occurence.
  sed_monthly_loads <- dplyr::mutate(sed_monthly_loads, Date_occurred = lubridate::ymd(paste0(YEAR, "-", MONTH, "-", DAY), quiet = TRUE))

  sed_monthly_loads <- dplyr::select(sed_monthly_loads, -DAY)
  sed_monthly_loads <- dplyr::mutate(sed_monthly_loads, FULL_MONTH = FULL_MONTH == 1)

  ## What stations were missed?
  differ <- setdiff(unique(stns), unique(sed_monthly_loads$STATION_NUMBER))
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


  sed_monthly_loads
}
