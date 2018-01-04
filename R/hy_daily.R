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
#' @inheritParams hy_stations 
#' @param quiet Geneerate output of parameters successfully queried? Defaults to TRUE. 
#' The output can be overly verbose when querying multiple stations but is useful when
#' only querying a few stations.
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

hy_daily <- function(station_number = NULL, prov_terr_state_loc = NULL, quiet = TRUE, ...){
  
  hydat_path <- file.path(hy_dir(),"Hydat.sqlite3")
  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  ## Query each parameter then check if it returned a tibble 
  
  ## flows
  flows <- handle_error(
    suppressMessages(hy_daily_flows(stns, ...))
  )
  
  if(any(class(flows) == "tbl_df")) daily <- flows
  
  ## levels
  levels <- handle_error(
    suppressMessages(hy_daily_levels(stns, ...))
  )
  
  if(any(class(levels) == "tbl_df")) daily <- dplyr::bind_rows(daily, levels)
  
  ##loads
  loads <- handle_error(
    suppressMessages(hy_sed_daily_loads(stns, ...))
  )
  
  if(any(class(loads) == "tbl_df")) daily <- dplyr::bind_rows(daily, loads)
  
  ## suscon
  suscon <- handle_error(
    suppressMessages(hy_sed_daily_suscon(stns, ...))
  )
  
  if(any(class(suscon) == "tbl_df")) daily <- dplyr::bind_rows(daily, suscon)
  
  if(quiet == FALSE){
    multi_param_msg(flows, stns, "Flow")
    multi_param_msg(levels, stns,  "Level")
    multi_param_msg(loads, stns, "Load")
    multi_param_msg(suscon, stns, "Suscon")
    
  }
  
  dplyr::arrange(daily, STATION_NUMBER, Date)

}
