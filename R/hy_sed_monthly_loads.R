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
#' Tidy data of monthly loads information from the SED_DLY_LOADS HYDAT table. `station_number` and
#'   `prov_terr_state_loc` can both be supplied. If both are omitted all values from the `hy_stations` table are returned.
#'   That is a large vector for `hy_sed_monthly_loads`.
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
#'   \item{Year}{Year of record.}
#'   \item{Month}{Numeric month value}
#'   \item{Full_Month}{Logical value is there is full record from Month}
#'   \item{No_days}{Number of days in that month}
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
  sed_monthly_loads <- dplyr::tbl(hydat_con, "SED_DLY_LOADS")
  sed_monthly_loads <- dplyr::filter(sed_monthly_loads, !!sym_STATION_NUMBER %in% stns)
  
  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too
  
  ## by year
  if (!dates_null[["start_is_null"]]) sed_monthly_loads <- dplyr::filter(sed_monthly_loads, !!sym_YEAR >= lubridate::year(start_date))
  if (!dates_null[["end_is_null"]]) sed_monthly_loads <- dplyr::filter(sed_monthly_loads, !!sym_YEAR <= lubridate::year(end_date))
  
  sed_monthly_loads <- dplyr::select(sed_monthly_loads, .data$STATION_NUMBER:.data$MAX)
  sed_monthly_loads <- dplyr::collect(sed_monthly_loads)
  
  if(is.data.frame(sed_monthly_loads) && nrow(sed_monthly_loads)==0)
  {stop("This station is not present in HYDAT")}
  
  ## Need to rename columns for gather
  colnames(sed_monthly_loads) <- c("STATION_NUMBER","Year","Month", "Full_Month", "No_days","MEAN_Value",
                           "TOTAL_Value", "MIN_DAY","MIN_Value", "MAX_DAY","MAX_Value")
  
  

  sed_monthly_loads <- tidyr::gather(sed_monthly_loads, !!sym_variable, !!sym_temp, -(.data$STATION_NUMBER:.data$No_days))
  sed_monthly_loads <- tidyr::separate(sed_monthly_loads, !!sym_variable, into = c("Sum_stat","temp2"), sep = "_")

  sed_monthly_loads <- tidyr::spread(sed_monthly_loads, !!sym_temp2, !!sym_temp)

  ## convert into R date for date of occurence.
  sed_monthly_loads <- dplyr::mutate(sed_monthly_loads, Date_occurred = paste0(.data$Year, "-", .data$Month, "-", .data$DAY))
  
  ## Check if DAY is NA and if so give it an NA value so the date parse correctly.
  sed_monthly_loads <- dplyr::mutate(sed_monthly_loads, Date_occurred = ifelse(is.na(.data$DAY), NA, .data$Date_occurred))
  sed_monthly_loads <- dplyr::mutate(sed_monthly_loads, Date_occurred = lubridate::ymd(.data$Date_occurred, quiet = TRUE))
  
  ## Then when a date column exist fine tune the subset
  if (!dates_null[["start_is_null"]]) sed_monthly_loads <- dplyr::filter(sed_monthly_loads, .data$Date_occurred >= start_date)
  if (!dates_null[["end_is_null"]]) sed_monthly_loads <- dplyr::filter(sed_monthly_loads, .data$Date_occurred <= end_date)

  sed_monthly_loads <- dplyr::select(sed_monthly_loads, -.data$DAY)
  sed_monthly_loads <- dplyr::mutate(sed_monthly_loads, Full_Month = .data$Full_Month == 1)
  
  attr(sed_monthly_loads,'missed_stns') <- setdiff(unique(stns), unique(sed_monthly_loads$STATION_NUMBER))
  as.hy(sed_monthly_loads)
}
