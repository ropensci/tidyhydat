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

#' Extract monthly flows information from the HYDAT database
#'
#' Tidy data of monthly flows information from the DLY_FLOWS HYDAT table. \code{station_number} and
#' \code{prov_terr_state_loc} can both be supplied. If both are omitted all values from the \code{hy_stations} table are returned.
#' That is a large vector for \code{hy_monthly_flows}.
#'
#' @inheritParams hy_stations
#' @param start_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param end_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#'
#' @return A tibble of monthly flows.
#'
#' @format A tibble with 8 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{YEAR}{Year of record.}
#'   \item{MONTH}{Numeric month value}
#'   \item{FULL_MONTH}{Logical value is there is full record from MONTH}
#'   \item{NO_DAYS}{Number of days in that month}
#'   \item{Sum_stat}{Summary statistic being used.}
#'   \item{Value}{Value of the measurement in m^3/s.}
#'   \item{Date_occurred}{Observation date. Formatted as a Date class. MEAN is a annual summary
#'   and therefore has an NA value for Date.}
#' }
#'
#' @examples
#' \dontrun{
#' hy_monthly_flows(station_number = c("02JE013","08MF005"),
#'   start_date = "1996-01-01", end_date = "2000-01-01")
#'
#' hy_monthly_flows(prov_terr_state_loc = "PE")
#'           }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export



hy_monthly_flows <- function(station_number = NULL,
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

  ## Creating rlang symbols
  sym_YEAR <- sym("YEAR")
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  sym_variable <- sym("variable")
  sym_temp <- sym("temp")
  sym_temp2 <- sym("temp2")

  ## Data manipulations to make it "tidy"
  monthly_flows <- dplyr::tbl(hydat_con, "DLY_FLOWS")
  monthly_flows <- dplyr::filter(monthly_flows, !!sym_STATION_NUMBER %in% stns)

  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too
  if (start_date != "ALL" | end_date != "ALL") {
    monthly_flows <- dplyr::filter(monthly_flows, !!sym_YEAR >= start_year &
      !!sym_YEAR <= end_year)

    # monthly_flows <- dplyr::filter(monthly_flows, MONTH >= start_month &
    #                             MONTH <= end_month)
  }

  monthly_flows <- dplyr::select(monthly_flows, .data$STATION_NUMBER:.data$MAX)
  monthly_flows <- dplyr::collect(monthly_flows)

  if (is.data.frame(monthly_flows) && nrow(monthly_flows) == 0) {
    stop("This station is not present in HYDAT")
  }

  ## Need to rename columns for gather
  colnames(monthly_flows) <- c(
    "STATION_NUMBER", "YEAR", "MONTH", "FULL_MONTH", "NO_DAYS", "MEAN_Value",
    "TOTAL_Value", "MIN_DAY", "MIN_Value", "MAX_DAY", "MAX_Value"
  )



  monthly_flows <- tidyr::gather(monthly_flows, !!sym_variable, !!sym_temp, -(.data$STATION_NUMBER:.data$NO_DAYS))
  monthly_flows <- tidyr::separate(monthly_flows, !!sym_variable, into = c("Sum_stat", "temp2"), sep = "_")

  monthly_flows <- tidyr::spread(monthly_flows, !!sym_temp2, !!sym_temp)

  ## convert into R date for date of occurence.
  monthly_flows <- dplyr::mutate(monthly_flows, Date_occurred = lubridate::ymd(paste0(.data$YEAR, "-", .data$MONTH, "-", .data$DAY), quiet = TRUE))

  monthly_flows <- dplyr::select(monthly_flows, -.data$DAY)
  monthly_flows <- dplyr::mutate(monthly_flows, FULL_MONTH = .data$FULL_MONTH == 1)

  ## What stations were missed?
  differ_msg(unique(stns), unique(monthly_flows$STATION_NUMBER))


  monthly_flows
}
