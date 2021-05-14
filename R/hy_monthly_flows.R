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
#' Tidy data of monthly flows information from the monthly_flows HYDAT table. `station_number` and
#' `prov_terr_state_loc` can both be supplied. If both are omitted all values from the `hy_stations` table are returned.
#' That is a large vector for `hy_monthly_flows`.
#'
#' @inheritParams hy_stations
#' @param start_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param end_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#'
#' @return A tibble of monthly flows.
#'
#' @format A tibble with 8 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Year}{Year of record.}
#'   \item{Month}{Numeric month value}
#'   \item{Full_Month}{Logical value is there is full record from Month}
#'   \item{No_days}{Number of days in that month}
#'   \item{Sum_stat}{Summary statistic being used.}
#'   \item{Value}{Value of the measurement in m^3/s.}
#'   \item{Date_occurred}{Observation date. Formatted as a Date class. MEAN is a annual summary
#'   and therefore has an NA value for Date.}
#' }
#'
#' @examples
#' \dontrun{
#' hy_monthly_flows(station_number = c("02JE013","08MF005"),
#'   start_date = "1996-01-01", end_date = "2000-01-01")
#'
#' hy_monthly_flows(prov_terr_state_loc = "PE")
#'           }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export



hy_monthly_flows <- function(station_number = NULL,
                             hydat_path = NULL,
                             prov_terr_state_loc = NULL, 
                             start_date =NULL, 
                             end_date = NULL) {
  
  ## Determine which dates should be queried
  dates_null <- date_check(start_date, end_date)

  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)

  ## Creating rlang symbols
  sym_YEAR <- sym("Year")
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  sym_variable <- sym("variable")
  sym_temp <- sym("temp")
  sym_temp2 <- sym("temp2")

  ## Data manipulations to make it "tidy"
  monthly_flows <- dplyr::tbl(hydat_con, "DLY_FLOWS")
  monthly_flows <- dplyr::filter(monthly_flows, !!sym_STATION_NUMBER %in% stns)

  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too
  
  ## by year
  if (!dates_null[["start_is_null"]]) monthly_flows <- dplyr::filter(monthly_flows, !!sym_YEAR >= lubridate::year(start_date))
  if (!dates_null[["end_is_null"]]) monthly_flows <- dplyr::filter(monthly_flows, !!sym_YEAR <= lubridate::year(end_date))

  monthly_flows <- dplyr::select(monthly_flows, .data$STATION_NUMBER:.data$MAX)
  monthly_flows <- dplyr::collect(monthly_flows)

  if (is.data.frame(monthly_flows) && nrow(monthly_flows) == 0) stop("This station is not present in HYDAT")


  ## Need to rename columns for gather
  colnames(monthly_flows) <- c(
    "STATION_NUMBER", "Year", "Month", "Full_Month", "No_days", "MEAN_Value",
    "TOTAL_Value", "MIN_DAY", "MIN_Value", "MAX_DAY", "MAX_Value"
  )



  monthly_flows <- tidyr::gather(monthly_flows, !!sym_variable, !!sym_temp, -(.data$STATION_NUMBER:.data$No_days))
  monthly_flows <- tidyr::separate(monthly_flows, !!sym_variable, into = c("Sum_stat", "temp2"), sep = "_")

  monthly_flows <- tidyr::spread(monthly_flows, !!sym_temp2, !!sym_temp)

  ## convert into R date for date of occurence.
  monthly_flows <- dplyr::mutate(monthly_flows, Date_occurred = paste0(.data$Year, "-", .data$Month, "-", .data$DAY))
  
  ## Check if DAY is NA and if so give it an NA value so the date parse correctly.
  monthly_flows <- dplyr::mutate(monthly_flows, Date_occurred = ifelse(is.na(.data$DAY), NA, .data$Date_occurred))
  monthly_flows <- dplyr::mutate(monthly_flows, Date_occurred = lubridate::ymd(.data$Date_occurred, quiet = TRUE))
  
  ## Then when a date column exist fine tune the subset
  if (!dates_null[["start_is_null"]]) monthly_flows <- dplyr::filter(monthly_flows, .data$Date_occurred >= start_date)
  if (!dates_null[["end_is_null"]]) monthly_flows <- dplyr::filter(monthly_flows, .data$Date_occurred <= end_date)

  monthly_flows <- dplyr::select(monthly_flows, -.data$DAY)
  monthly_flows <- dplyr::mutate(monthly_flows, Full_Month = .data$Full_Month == 1)

  attr(monthly_flows,'missed_stns') <- setdiff(unique(stns), unique(monthly_flows$STATION_NUMBER))
  as.hy(monthly_flows)
}
