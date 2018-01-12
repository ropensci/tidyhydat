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

#' Extract monthly levels information from the HYDAT database
#'
#' Tidy data of monthly river or lake levels information from the DLY_LEVELS HYDAT table. \code{station_number} and
#'   \code{prov_terr_state_loc} can both be supplied. If both are omitted all values from the \code{hy_stations} table are returned.
#'   That is a large vector for \code{hy_monthly_levels}.
#'
#' @inheritParams hy_stations
#' @param start_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param end_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#'
#' @return A tibble of monthly levels. 
#'
#' @format A tibble with 8 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{YEAR}{Year of record.}
#'   \item{MONTH}{Numeric month value}
#'   \item{FULL_MONTH}{Logical value is there is full record from MONTH}
#'   \item{NO_DAYS}{Number of days in that month}
#'   \item{Sum_stat}{Summary statistic being used.} 
#'   \item{Value}{Value of the measurement in metres.}
#'   \item{Date_occurred}{Observation date. Formatted as a Date class. MEAN is a annual summary 
#'   and therefore has an NA value for Date.}
#' }
#'
#' @examples
#' \dontrun{
#' hy_monthly_levels(station_number = c("02JE013","08MF005"), 
#'   start_date = "1996-01-01", end_date = "2000-01-01")
#'
#' hy_monthly_levels(prov_terr_state_loc = "PE")
#'           }
#' @family HYDAT functions
#' @source HYDAT
#' @export



hy_monthly_levels <- function(station_number = NULL,
                           hydat_path = NULL,
                           prov_terr_state_loc = NULL, start_date ="ALL", end_date = "ALL") {
  if (!is.null(station_number) && station_number == "ALL") {
    stop("Deprecated behaviour.Omit the station_number = \"ALL\" argument. See ?hy_monthly_levels for examples.")
  }
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con))
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

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)


  ## Data manipulations to make it "tidy"
  monthly_levels <- dplyr::tbl(hydat_con, "DLY_LEVELS")
  monthly_levels <- dplyr::filter(monthly_levels, STATION_NUMBER %in% stns)

  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too
  if (start_date != "ALL" | end_date != "ALL") {
    monthly_levels <- dplyr::filter(monthly_levels, YEAR >= start_year &
      YEAR <= end_year)
    
    #monthly_levels <- dplyr::filter(monthly_levels, MONTH >= start_month &
    #                             MONTH <= end_month)
  }

  monthly_levels <- dplyr::select(monthly_levels, STATION_NUMBER:MAX)
  monthly_levels <- dplyr::collect(monthly_levels)
  
  if(is.data.frame(monthly_levels) && nrow(monthly_levels)==0)
  {stop("This station is not present in HYDAT")}
  
  ## Need to rename columns for gather
  colnames(monthly_levels) <- c("STATION_NUMBER","YEAR","MONTH", "PRECISION_CODE", "FULL_MONTH", "NO_DAYS", "MEAN_Value",
                           "TOTAL_Value", "MIN_DAY","MIN_Value", "MAX_DAY","MAX_Value")
  
  

  monthly_levels <- tidyr::gather(monthly_levels, variable, temp, -(STATION_NUMBER:NO_DAYS))
  monthly_levels <- tidyr::separate(monthly_levels, variable, into = c("Sum_stat","temp2"), sep = "_")

  monthly_levels <- tidyr::spread(monthly_levels, temp2, temp)

  ## convert into R date for date of occurence.
  monthly_levels <- dplyr::mutate(monthly_levels, Date_occurred = lubridate::ymd(paste0(YEAR, "-", MONTH, "-", DAY), quiet = TRUE))
  ## TODO: convert dates incorrectly. Make sure NA DAYs aren't converted into dates

  monthly_levels <- dplyr::select(monthly_levels, -DAY)
  monthly_levels <- dplyr::mutate(monthly_levels, FULL_MONTH = FULL_MONTH == 1)

  ## What stations were missed?
  differ_msg(unique(stns), unique(monthly_levels$STATION_NUMBER))


  monthly_levels
}
