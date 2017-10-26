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

#' Extract instantaneous sediment sample information from the HYDAT database
#'
#' Provides wrapper to turn the hy_sed_samples table in HYDAT into a tidy data frame.  \code{station_number} and
#' \code{prov_terr_state_loc} can both be supplied. If both are omitted all values from the \code{hy_stations} table are returned.
#' That is a large vector for \code{hy_sed_samples}.
#'
#' @inheritParams hy_stations
#' @param start_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param end_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#'
#' @return A tibble of instantaneous sediment samples data
#' 
#' @format A tibble with 19 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{SED_DATA_TYPE}{Contains the type of sampling method used in collecting sediment for a station}
#'   \item{DATE}{Contains the time to the nearest minute of when the sample was taken}
#'   \item{SAMPLE_REMARK_CODE}{Descriptive Sediment Sample Remark in English}
#'   \item{TIME_SYMBOL}{An "E" symbol means the time is an estimate only}
#'   \item{FLOW}{Contains the instantaneous discharge in cubic metres per second at the time the sample was taken}
#'   \item{SYMBOL_EN}{Indicates a condition where the daily mean has a larger than expected error}
#'   \item{SAMPLER_TYPE}{Contains the type of measurement device used to take the sample}
#'   \item{SAMPLING_VERTICAL_LOCATION}{The location on the cross-section of the river 
#'         at which the single sediment samples are collected. If one of the standard 
#'         locations is not used the distance in meters will be shown}
#'   \item{SAMPLING_VERTICAL_EN}{ndicates sample location relative to the 
#'         regular measurement cross-section or the regular sampling site}
#'   \item{TEMPERATURE}{Contains the instantaneous water temperature
#'         in Celsius at the time the sample was taken}
#'   \item{CONCENTRATION_EN}{Contains the instantaneous concentration sampled in milligrams per litre}
#'   \item{SV_DEPTH2}{Depth 2 for split vertical depth integrating (m)}
#' }
#'
#' @examples
#' \dontrun{
#' hy_sed_samples(station_number = "01CA004")
#'           }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export



hy_sed_samples <- function(station_number = NULL, 
                        hydat_path = NULL, 
                        prov_terr_state_loc = NULL, start_date ="ALL", end_date = "ALL") {
  
  if(is.null(hydat_path)){
    hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
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

  ## Data manipulations
  sed_samples <- dplyr::tbl(hydat_con, "SED_SAMPLES")
  sed_samples <- dplyr::filter(sed_samples, STATION_NUMBER %in% stns)
  sed_samples <- dplyr::left_join(sed_samples, dplyr::tbl(hydat_con, "SED_DATA_TYPES"), by = c("SED_DATA_TYPE"))
  sed_samples <- dplyr::left_join(sed_samples, dplyr::tbl(hydat_con, "SAMPLE_REMARK_CODES"), by = c("SAMPLE_REMARK_CODE"))
  sed_samples <- dplyr::left_join(
    sed_samples, dplyr::tbl(hydat_con, "SED_VERTICAL_LOCATION"),
    by = c("SAMPLING_VERTICAL_LOCATION" = "SAMPLING_VERTICAL_LOCATION_ID")
  )
  sed_samples <- dplyr::left_join(sed_samples, dplyr::tbl(hydat_con, "SED_VERTICAL_SYMBOLS"), by = c("SAMPLING_VERTICAL_SYMBOL"))
  sed_samples <- dplyr::left_join(sed_samples, dplyr::tbl(hydat_con, "CONCENTRATION_SYMBOLS"), by = c("CONCENTRATION_SYMBOL"))

  sed_samples <- dplyr::collect(sed_samples)
  
  if(is.data.frame(sed_samples) && nrow(sed_samples)==0)
  {stop("This station is not present in HYDAT")}
  
  sed_samples <- dplyr::left_join(sed_samples, tidyhydat::data_symbols, by = c("FLOW_SYMBOL" = "SYMBOL_ID"))
  sed_samples <- dplyr::mutate(sed_samples, DATE = lubridate::ymd_hms(DATE))

  ## SUBSET by date
  if (start_date != "ALL" | end_date != "ALL") {
    sed_samples <- dplyr::filter(sed_samples, DATE >= start_date &
                                   DATE <= end_date)
  }
  
  
  sed_samples <- dplyr::select(
    sed_samples, STATION_NUMBER, SED_DATA_TYPE_EN, DATE, SAMPLE_REMARK_EN, TIME_SYMBOL,
    FLOW, SYMBOL_EN, SAMPLER_TYPE, SAMPLING_VERTICAL_LOCATION, SAMPLING_VERTICAL_EN,
    TEMPERATURE, CONCENTRATION, CONCENTRATION_EN, SV_DEPTH2
  )
  
  
  ## What stations were missed?
  differ <- setdiff(unique(stns), unique(sed_samples$STATION_NUMBER))
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
  
  sed_samples
}
