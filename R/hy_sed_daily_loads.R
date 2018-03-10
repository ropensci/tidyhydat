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
#'   \item{Parameter}{Parameter being measured. Only possible value is Load}
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
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con))
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

  sed_dly_loads <- dplyr::select(sed_dly_loads, .data$STATION_NUMBER, .data$YEAR, .data$MONTH,
                                 .data$NO_DAYS, dplyr::contains("LOAD"))
  sed_dly_loads <- dplyr::collect(sed_dly_loads)
  
  if(is.data.frame(sed_dly_loads) && nrow(sed_dly_loads)==0)
  {stop("No sediment load data for this station in HYDAT")}
  
  sed_dly_loads <- tidyr::gather(sed_dly_loads, variable, temp, -(.data$STATION_NUMBER:.data$NO_DAYS))
  sed_dly_loads <- dplyr::mutate(sed_dly_loads, DAY = as.numeric(gsub("LOAD", "", .data$variable)))
  sed_dly_loads <- dplyr::mutate(sed_dly_loads, variable = gsub("[0-9]+", "", .data$variable))
  sed_dly_loads <- tidyr::spread(sed_dly_loads, variable, temp)
  sed_dly_loads <- dplyr::mutate(sed_dly_loads, LOAD = as.numeric(.data$LOAD))
  ## No days that exceed actual number of days in the month
  sed_dly_loads <- dplyr::filter(sed_dly_loads, .data$DAY <= .data$NO_DAYS)

  ## convert into R date.
  sed_dly_loads <- dplyr::mutate(sed_dly_loads, Date = lubridate::ymd(
    paste0(.data$YEAR, "-", .data$MONTH, "-", .data$DAY)))

  ## Then when a date column exist fine tune the subset
  if (start_date != "ALL" | end_date != "ALL") {
    sed_dly_loads <- dplyr::filter(sed_dly_loads, Date >= start_date &
      Date <= end_date)
  }

  sed_dly_loads <- dplyr::mutate(sed_dly_loads, Parameter = "Load")
  sed_dly_loads <- dplyr::select(sed_dly_loads, .data$STATION_NUMBER, .data$Date, .data$Parameter, .data$LOAD)
  sed_dly_loads <- dplyr::arrange(sed_dly_loads, .data$Date)

  colnames(sed_dly_loads) <- c("STATION_NUMBER", "Date", "Parameter", "Value")


  ## What stations were missed?
  differ_msg(unique(stns), unique(sed_dly_loads$STATION_NUMBER))

  
  sed_dly_loads
}
