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

#' Extract daily suspended sediment concentration information from the HYDAT database
#'
#' Provides wrapper to turn the hy_sed_daily_suscon table in HYDAT into a tidy data frame.  \code{station_number} and
#' \code{prov_terr_state_loc} can both be supplied. If both are omitted all values from the \code{hy_stations} table are returned.
#' That is a large vector for \code{hy_sed_daily_suscon}.
#'
#' @inheritParams hy_daily_flows
#'
#' @return A tibble of daily suspended sediment concentration
#'
#' @format A tibble with 5 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Date}{Observation date. Formatted as a Date class.}
#'   \item{Parameter}{Parameter being measured. Only possible value is SUSCON}
#'   \item{Value}{Discharge value. The units are mg/l.}
#'   \item{Symbol}{Measurement/river conditions}
#' }
#'
#' @examples
#' \dontrun{
#' hy_sed_daily_suscon(station_number = "01CE003")
#'           }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export



hy_sed_daily_suscon <- function(station_number = NULL,
                           hydat_path = NULL, 
                           prov_terr_state_loc = NULL, 
                           start_date ="ALL", end_date = "ALL", symbol_output = "code") {
  
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
  sed_dly_suscon <- dplyr::tbl(hydat_con, "SED_DLY_SUSCON")
  sed_dly_suscon <- dplyr::filter(sed_dly_suscon, STATION_NUMBER %in% stns)

  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too
  if (start_date != "ALL" | end_date != "ALL") {
    sed_dly_suscon <- dplyr::filter(sed_dly_suscon, YEAR >= start_year &
      YEAR <= end_year)
  }

  sed_dly_suscon <- dplyr::select(sed_dly_suscon, STATION_NUMBER, YEAR, MONTH, NO_DAYS, dplyr::contains("SUSCON"))
  sed_dly_suscon <- dplyr::collect(sed_dly_suscon)
  
  if(is.data.frame(sed_dly_suscon) && nrow(sed_dly_suscon)==0)
  {stop("This station is not present in HYDAT")}
  
  sed_dly_suscon <- tidyr::gather(sed_dly_suscon, variable, temp, -(STATION_NUMBER:NO_DAYS))
  sed_dly_suscon <- dplyr::mutate(sed_dly_suscon, DAY = as.numeric(gsub("SUSCON|SUSCON_SYMBOL", "", variable)))
  sed_dly_suscon <- dplyr::mutate(sed_dly_suscon, variable = gsub("[0-9]+", "", variable))
  sed_dly_suscon <- tidyr::spread(sed_dly_suscon, variable, temp)
  sed_dly_suscon <- dplyr::mutate(sed_dly_suscon, SUSCON = as.numeric(SUSCON))
  ## No days that exceed actual number of days in the month
  sed_dly_suscon <- dplyr::filter(sed_dly_suscon, DAY <= NO_DAYS)

  ## convert into R date.
  sed_dly_suscon <- dplyr::mutate(sed_dly_suscon, Date = lubridate::ymd(paste0(YEAR, "-", MONTH, "-", DAY)))

  ## Then when a date column exist fine tune the subset
  if (start_date != "ALL" | end_date != "ALL") {
    sed_dly_suscon <- dplyr::filter(sed_dly_suscon, Date >= start_date &
      Date <= end_date)
  }
  
  
  sed_dly_suscon <- dplyr::left_join(sed_dly_suscon, data_symbols, by = c("SUSCON_SYMBOL" = "SYMBOL_ID"))
  sed_dly_suscon <- dplyr::mutate(sed_dly_suscon, Parameter = "SUSCON")
  
  ## Control for symbol ouput
  if(symbol_output == "code"){
    sed_dly_suscon <- dplyr::select(sed_dly_suscon, STATION_NUMBER, Date, Parameter, SUSCON, SUSCON_SYMBOL)
  }
  
  if(symbol_output == "english"){
    sed_dly_suscon <- dplyr::select(sed_dly_suscon, STATION_NUMBER, Date, Parameter, SUSCON, SYMBOL_EN)
  }
  
  if(symbol_output == "french"){
    sed_dly_suscon <- dplyr::select(sed_dly_suscon, STATION_NUMBER, Date, Parameter, SUSCON, SYMBOL_FR)
  }
  
  sed_dly_suscon <- dplyr::arrange(sed_dly_suscon, Date)

  colnames(sed_dly_suscon) <- c("STATION_NUMBER", "Date", "Parameter", "Value", "Symbol")

  ## What stations were missed?
  differ <- setdiff(unique(stns), unique(sed_dly_suscon$STATION_NUMBER))
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

  sed_dly_suscon
}
