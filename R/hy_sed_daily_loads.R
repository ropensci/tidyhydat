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

#' Extract daily sediment load information from the HYDAT database
#'
#' Provides wrapper to turn the SED_DLY_LOADS table in HYDAT into a tidy data frame of daily sediment load information.
#' \code{station_number} and \code{prov_terr_state_loc} can both be supplied. If both are omitted all values from the 
#' \code{hy_stations} table are returned. That is a large vector for \code{hy_sed_daily_loads}.
#'
#' @inheritParams hy_stations
#' @param start_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param end_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#'
#' @return A tibble of daily suspended sediment loads
#'
#' @format A tibble with 4 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Date}{Observation date. Formatted as a Date class.}
#'   \item{Parameter}{Parameter being measured. Only possible value is LOAD}
#'   \item{Value}{Discharge value. The units are tonnes.}
#' }
#'
#' @examples
#' \dontrun{
#' hy_sed_daily_loads(prov_terr_state_loc = "PE")
#'           }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export



hy_sed_daily_loads <- function(station_number = NULL, 
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
  sed_dly_loads <- dplyr::tbl(hydat_con, "SED_DLY_LOADS")
  sed_dly_loads <- dplyr::filter(sed_dly_loads, STATION_NUMBER %in% stns)

  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too
  if (start_date != "ALL" | end_date != "ALL") {
    sed_dly_loads <- dplyr::filter(sed_dly_loads, YEAR >= start_year &
      YEAR <= end_year)
  }

  sed_dly_loads <- dplyr::select(sed_dly_loads, STATION_NUMBER, YEAR, MONTH, NO_DAYS, dplyr::contains("LOAD"))
  sed_dly_loads <- dplyr::collect(sed_dly_loads)
  
  if(is.data.frame(sed_dly_loads) && nrow(sed_dly_loads)==0)
  {stop("This station is not present in HYDAT")}
  
  sed_dly_loads <- tidyr::gather(sed_dly_loads, variable, temp, -(STATION_NUMBER:NO_DAYS))
  sed_dly_loads <- dplyr::mutate(sed_dly_loads, DAY = as.numeric(gsub("LOAD", "", variable)))
  sed_dly_loads <- dplyr::mutate(sed_dly_loads, variable = gsub("[0-9]+", "", variable))
  sed_dly_loads <- tidyr::spread(sed_dly_loads, variable, temp)
  sed_dly_loads <- dplyr::mutate(sed_dly_loads, LOAD = as.numeric(LOAD))
  ## No days that exceed actual number of days in the month
  sed_dly_loads <- dplyr::filter(sed_dly_loads, DAY <= NO_DAYS)

  ## convert into R date.
  sed_dly_loads <- dplyr::mutate(sed_dly_loads, Date = lubridate::ymd(paste0(YEAR, "-", MONTH, "-", DAY)))

  ## Then when a date column exist fine tune the subset
  if (start_date != "ALL" | end_date != "ALL") {
    sed_dly_loads <- dplyr::filter(sed_dly_loads, Date >= start_date &
      Date <= end_date)
  }

  sed_dly_loads <- dplyr::mutate(sed_dly_loads, Parameter = "LOAD")
  sed_dly_loads <- dplyr::select(sed_dly_loads, STATION_NUMBER, Date, Parameter, LOAD)
  sed_dly_loads <- dplyr::arrange(sed_dly_loads, Date)

  colnames(sed_dly_loads) <- c("STATION_NUMBER", "Date", "Parameter", "Value")


  ## What stations were missed?
  differ <- setdiff(unique(stns), unique(sed_dly_loads$STATION_NUMBER))
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

  
  sed_dly_loads
}
