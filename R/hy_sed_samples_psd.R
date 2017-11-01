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

#' Extract instantaneous sediment sample particle size distribution information from the HYDAT database
#'
#' Provides wrapper to turn the hy_sed_samples_psd table in HYDAT into a tidy data frame of instantaneous sediment sample 
#' particle size distribution.  \code{station_number} and \code{prov_terr_state_loc} can both be supplied. If both 
#' are omitted all values from the \code{hy_stations} table are returned. That is a large vector for \code{hy_sed_samples_psd}.
#'
#' @inheritParams hy_stations
#' @param start_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param end_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#'
#' @return A tibble of sediment sample particle size data
#' 
#' @format A tibble with 5 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{SED_DATA_TYPE_EN}{Contains the type of sampling method used in collecting sediment for a station}
#'   \item{DATE}{Contains the time to the nearest minute of when the sample was taken}
#'   \item{PARTICLE_SIZE}{Particle size (mm)}
#'   \item{PERCENT}{Contains the percentage values for indicated particle sizes for samples collected}
#' }
#'
#'
#' @examples
#' \dontrun{
#' hy_sed_samples_psd(station_number = "01CA004")
#'           }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export



hy_sed_samples_psd <- function(station_number = NULL,
                            hydat_path = NULL, 
                            prov_terr_state_loc = NULL, start_date ="ALL", end_date = "ALL") {
  
  if(is.null(hydat_path)){
    hydat_path <- paste0(hy_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",hy_dir(),". Run download_hydat() to download the database."))
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
  sed_samples_psd <- dplyr::tbl(hydat_con, "SED_SAMPLES_PSD")
  sed_samples_psd <- dplyr::filter(sed_samples_psd, STATION_NUMBER %in% stns)
  sed_samples_psd <- dplyr::left_join(sed_samples_psd, dplyr::tbl(hydat_con, "SED_DATA_TYPES"), by = c("SED_DATA_TYPE"))

  sed_samples_psd <- dplyr::collect(sed_samples_psd)
  
  if(is.data.frame(sed_samples_psd) && nrow(sed_samples_psd)==0)
  {stop("This station is not present in HYDAT")}
  
  sed_samples_psd <- dplyr::mutate(sed_samples_psd, DATE = lubridate::ymd_hms(DATE))

  ## SUBSET by date
  if (start_date != "ALL" | end_date != "ALL") {
    sed_samples_psd <- dplyr::filter(sed_samples_psd, DATE >= start_date &
      DATE <= end_date)
  }
  
  
  sed_samples_psd <- dplyr::select(sed_samples_psd, STATION_NUMBER, SED_DATA_TYPE_EN, DATE, PARTICLE_SIZE, PERCENT)
  
  
  ## What stations were missed?
  differ <- setdiff(unique(stns), unique(sed_samples_psd$STATION_NUMBER))
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
  
  sed_samples_psd
}
