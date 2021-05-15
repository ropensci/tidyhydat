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
#' A thin wrapper around `hy_daily_flows` and `hy_daily_levels`` that returns a data frames that 
#' contains both parameters. All arguments are passed directly to these functions. 
#' 
#' @inheritParams hy_stations 
#' @param ... See [hy_daily_flows()] arguments
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

hy_daily <- function(station_number = NULL, prov_terr_state_loc = NULL,  
                     hydat_path = NULL, ...){
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  ## Create an empty tibble
  daily <- dplyr::tibble()
  
  
  ## Query each parameter then check if it returned a tibble 
  
  ## flows
  flows <- handle_error(
    suppressMessages(hy_daily_flows(stns, hydat_path = hydat_con, ...))
  )
  
  
  
  if (inherits(flows, "tbl_df")) daily <- flows
  
  ## levels
  levels <- handle_error(
    suppressMessages(hy_daily_levels(stns, ...))
  )
  
  if (inherits(levels, "tbl_df")) daily <- dplyr::bind_rows(daily, levels)
  
  ##loads
  loads <- handle_error(
    suppressMessages(hy_sed_daily_loads(stns, ...))
  )
  
  if (inherits(loads, "tbl_df")) daily <- dplyr::bind_rows(daily, loads)
  
  ## suscon
  suscon <- handle_error(
    suppressMessages(hy_sed_daily_suscon(stns, ...))
  )
  
  if (inherits(suscon, "tbl_df")) daily <- dplyr::bind_rows(daily, suscon)
  
  
  if(nrow(daily) == 0){
    info(paste0("No data for ", station_number,". Did you correctly input station name or province?"))
  }
  
  attr(daily,'missed_stns') <- setdiff(unique(stns), unique(daily$STATION_NUMBER))
  as.hy(dplyr::arrange(daily, .data$STATION_NUMBER, .data$Date))

}
