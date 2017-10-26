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


#' Annual maximum/minimum instantaneous flows and water levels
#'
#' Provides wrapper to turn the hy_annual_instant_peaks table in HYDAT into a tidy data frame. \code{station_number} and
#' \code{prov_terr_state_loc} can both be supplied. 
#' 
#' @inheritParams hy_stations
#' @param start_year First year of the returned record
#' @param end_year Last year of the returned record
#'
#' @return A tibble of hy_annual_instant_peaks
#' 
#'
#' @examples
#' \dontrun{
#' ## Multiple stations province not specified
#' hy_annual_instant_peaks(station_number = c("08NM083","08NE102"))
#'
#' ## Multiple province, station number not specified
#' hy_annual_instant_peaks(prov_terr_state_loc = c("AB","YT"))
#' }
#' 
#' @family HYDAT functions
#' @source HYDAT
#' @export
#'
hy_annual_instant_peaks <- function(station_number = NULL, 
                                 hydat_path = NULL, 
                                 prov_terr_state_loc = NULL,
                                 start_year = "ALL", end_year = "ALL") {
  

  if (!is.null(station_number) && station_number == "ALL") {
    stop("Deprecated behaviour.Omit the station_number = 
         \"ALL\" argument. See ?hy_annual_stats for examples.")
  }
  
  if(is.null(hydat_path)){
    hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)

  ## Data manipulations
  aip <- dplyr::tbl(hydat_con, "ANNUAL_INSTANT_PEAKS") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect()

  ## Add in english data type
  aip <- dplyr::left_join(aip, tidyhydat::data_types, by = c("DATA_TYPE"))

  ## Add in Symbol
  aip <- dplyr::left_join(aip, tidyhydat::data_symbols, by = c("SYMBOL" = "SYMBOL_ID"))

  ## If a yearis supplied...
  if (start_year != "ALL" | end_year != "ALL") {
    aip <- dplyr::filter(aip, YEAR >= start_year & YEAR <= end_year)
  }

  ## Parse PEAK_CODE manually - there are only 2
  aip <- dplyr::mutate(aip, PEAK_CODE = ifelse(PEAK_CODE == "H", "MAX", "MIN"))

  ## Parse PRECISION_CODE manually - there are only 2
  aip <- dplyr::mutate(aip, PRECISION_CODE = ifelse(PRECISION_CODE == 8, "in m (to mm)", "in m (to cm)"))

  ## TODO: Convert to dttm
  # aip = dplyr::mutate(aip, Datetime = lubridate::ymd_hm(paste0(YEAR,"-",MONTH,"-",DAY," ",HOUR,":",MINUTE)))

  ## Clean up and select only columns we need
  aip <- dplyr::select(aip, STATION_NUMBER, DATA_TYPE_EN, YEAR, PEAK_CODE, PRECISION_CODE, MONTH, DAY, HOUR, MINUTE, TIME_ZONE, PEAK, SYMBOL_EN) %>%
    dplyr::rename(Parameter = DATA_TYPE_EN, Symbol = SYMBOL_EN, Value = PEAK)

  ## What stations were missed?
  differ <- setdiff(unique(stns), unique(aip$STATION_NUMBER))
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
  
  aip
}
