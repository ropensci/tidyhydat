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

#' @title Extract daily levels information from the HYDAT database
#'
#' @description Provides wrapper to turn the hy_daily_levels table in HYDAT into a tidy data frame.  \code{station_number} and
#' \code{prov_terr_state_loc} can both be supplied. If both are omitted all values from the \code{hy_stations} table are returned.
#' That is a large vector for \code{hy_daily_levels}.
#'
#' @inheritParams hy_daily_flows
#'
#' @return A tibble of daily levels
#'
#' @examples
#' \donttest{
#' hy_daily_levels(station_number = c("02JE013","08MF005"), 
#'   start_date = "1996-01-01", end_date = "2000-01-01")
#'
#' hy_daily_levels(prov_terr_state_loc = "PE", hydat_path = "H:/Hydat.sqlite3")
#'
#'           }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export



hy_daily_levels <- function(station_number = NULL, 
                       hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"),
                       prov_terr_state_loc = NULL, 
                       start_date ="ALL", end_date = "ALL", symbol_output = "code") {
  if (!is.null(station_number) && station_number == "ALL") {
    stop("Deprecated behaviour.Omit the station_number = \"ALL\" argument. See ?hy_daily_levels for examples.")
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
  dly_levels <- dplyr::tbl(hydat_con, "DLY_LEVELS")
  dly_levels <- dplyr::filter(dly_levels, STATION_NUMBER %in% stns)

  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too
  if (start_date != "ALL" | end_date != "ALL") {
    dly_levels <- dplyr::filter(dly_levels, YEAR >= start_year &
      YEAR <= end_year)
  }

  dly_levels <- dplyr::select(dly_levels, STATION_NUMBER, YEAR, MONTH, NO_DAYS, dplyr::contains("LEVEL"))
  dly_levels <- dplyr::collect(dly_levels)
  
  if(is.data.frame(dly_levels) && nrow(dly_levels)==0)
  {stop("This station is not present in HYDAT.")}
  
  dly_levels <- tidyr::gather(dly_levels, variable, temp, -(STATION_NUMBER:NO_DAYS))
  dly_levels <- dplyr::mutate(dly_levels, DAY = as.numeric(gsub("LEVEL|LEVEL_SYMBOL", "", variable)))
  dly_levels <- dplyr::mutate(dly_levels, variable = gsub("[0-9]+", "", variable))
  dly_levels <- tidyr::spread(dly_levels, variable, temp)
  dly_levels <- dplyr::mutate(dly_levels, LEVEL = as.numeric(LEVEL))
  ## No days that exceed actual number of days in the month
  dly_levels <- dplyr::filter(dly_levels, DAY <= NO_DAYS)

  ## convert into R date.
  dly_levels <- dplyr::mutate(dly_levels, Date = lubridate::ymd(paste0(YEAR, "-", MONTH, "-", DAY)))

  ## Then when a date column exist fine tune the subset
  if (start_date != "ALL" | end_date != "ALL") {
    dly_levels <- dplyr::filter(dly_levels, Date >= start_date &
      Date <= end_date)
  }
  dly_levels <- dplyr::left_join(dly_levels, tidyhydat::data_symbols, by = c("LEVEL_SYMBOL" = "SYMBOL_ID"))
  dly_levels <- dplyr::mutate(dly_levels, Parameter = "LEVEL")
  
  ## Control for symbol ouput
  if(symbol_output == "code"){
    dly_levels <- dplyr::select(dly_levels, STATION_NUMBER, Date, Parameter, LEVEL, LEVEL_SYMBOL)
  }
  
  if(symbol_output == "english"){
    dly_levels <- dplyr::select(dly_levels, STATION_NUMBER, Date, Parameter, LEVEL, SYMBOL_EN)
  }
  
  if(symbol_output == "french"){
    dly_levels <- dplyr::select(dly_levels, STATION_NUMBER, Date, Parameter, LEVEL, SYMBOL_FR)
  }
  
  dly_levels <- dplyr::arrange(dly_levels, Date)
  
  colnames(dly_levels) <- c("STATION_NUMBER", "Date", "Parameter", "Value", "Symbol")
  
  
  ## What stations were missed?
  differ <- setdiff(unique(stns), unique(dly_levels$STATION_NUMBER))
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

  dly_levels
}
