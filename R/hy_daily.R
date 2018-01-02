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

#' Extract all daily water level and flow measurements
#' 
#' A thin wrapper around \code{hy_daily_flows} and \code{hy_daily_levels} that returns a data frames that 
#' contains both parameters. All arguments are passed directly to these functions. 
#' 
#' @param ... See \code{\link{hy_daily_flows}} arguments
#' 
#' @return A tibble of daily flows and levels
#' 
#' @format A tibble with 5 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Date}{Observation date. Formatted as a Date class.}
#'   \item{Parameter}{Parameter being measured.}
#'   \item{Value}{Discharge value. The units are m^3/s.}
#'   \item{Symbol}{Measurement/river conditions}
#' }
#' 
#' @export
#' @family HYDAT functions
#' @source HYDAT
#' @examples 
#' \dontrun{
#' hy_daily(station_number = c("02JE013","08MF005"))
#' }

hy_daily <- function(station_number = NULL, ...){
  flows <- suppressMessages(hy_daily_flows(station_number = NULL, ...))
  
  levels <- suppressMessages(hy_daily_levels(station_number = NULL, ...))
  
  loads <- suppressMessages(hy_sed_daily_loads(station_number = NULL, ...))
  
  suscon <- suppressMessages(hy_sed_daily_suscon(station_number = NULL, ...))
  
  daily <- dplyr::bind_rows(flows, levels, loads, suscon)
  
  
  
  dplyr::arrange(daily, STATION_NUMBER, Date)

}


#tryCatch(
#  tidyhydat::realtime_dd(station_number = loop_stations[i]),
#  error = function(e)
#    data.frame(Status = e$message)
#)
#
#hy_daily_flows()
#
#station_number_val <- "08MF005"
#
#flows <- tryCatch(
#  suppressMessages(hy_daily_flows(station_number = station_number_val, ...)),
#  error = function(e)
#)
