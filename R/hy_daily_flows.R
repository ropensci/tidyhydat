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

#' @title Extract daily flows information from the HYDAT database
#'
#' @description Provides wrapper to turn the DLY_FLOWS table in HYDAT into a tidy data frame of daily flows.
#' `station_number` and `prov_terr_state_loc` can both be supplied. If both are omitted all
#' values from the `hy_stations` table are returned. That is a large tibble for `hy_daily_flows`.
#'
#' @inheritParams hy_stations
#' @param start_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param end_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param symbol_output Set whether the raw code, or the `english` or the `french` translations are outputted. Default
#'   value is `code`.
#'
#' @return A tibble of daily flows
#'
#' @format A tibble with 5 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Date}{Observation date. Formatted as a Date class.}
#'   \item{Parameter}{Parameter being measured. Only possible value is Flow}
#'   \item{Value}{Discharge value. The units are m^3/s.}
#'   \item{Symbol}{Measurement/river conditions}
#' }
#'
#' @examples
#' \dontrun{
#' # download_hydat()
#' hy_daily_flows(
#'   station_number = c("08MF005"),
#'   start_date = "1996-01-01", end_date = "2000-01-01"
#' )
#'
#' hy_daily_flows(prov_terr_state_loc = "PE")
#' }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export

hy_daily_flows <- function(
  station_number = NULL,
  hydat_path = NULL,
  prov_terr_state_loc = NULL,
  start_date = NULL,
  end_date = NULL,
  symbol_output = "code"
) {
  ## Determine which dates should be queried
  dates_null <- date_check(start_date, end_date)

  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)

  ## Creating rlang symbols
  sym_YEAR <- sym("YEAR")
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  sym_variable <- sym("variable")
  sym_temp <- sym("temp")
  sym_Date <- sym("Date")

  ## Data manipulations to make it "tidy"
  dly_flows <- dplyr::tbl(hydat_con, "DLY_FLOWS")
  dly_flows <- dplyr::filter(dly_flows, !!sym_STATION_NUMBER %in% stns)

  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too

  ## by year
  if (!dates_null[["start_is_null"]])
    dly_flows <- dplyr::filter(
      dly_flows,
      !!sym_YEAR >= lubridate::year(start_date)
    )
  if (!dates_null[["end_is_null"]])
    dly_flows <- dplyr::filter(
      dly_flows,
      !!sym_YEAR <= lubridate::year(end_date)
    )

  dly_flows <- dplyr::select(
    dly_flows,
    STATION_NUMBER,
    YEAR,
    MONTH,
    NO_DAYS,
    dplyr::contains("FLOW")
  )
  dly_flows <- dplyr::collect(dly_flows)

  if (is.data.frame(dly_flows) && nrow(dly_flows) == 0)
    stop("No flow data for this station in HYDAT")

  dly_flows <- tidyr::gather(
    dly_flows,
    !!sym_variable,
    !!sym_temp,
    -(STATION_NUMBER:NO_DAYS)
  )
  dly_flows <- dplyr::mutate(
    dly_flows,
    DAY = as.numeric(gsub("FLOW|FLOW_SYMBOL", "", variable))
  )
  dly_flows <- dplyr::mutate(dly_flows, variable = gsub("[0-9]+", "", variable))
  dly_flows <- tidyr::spread(dly_flows, variable, temp)
  dly_flows <- dplyr::mutate(dly_flows, FLOW = as.numeric(FLOW))
  ## No days that exceed actual number of days in the month
  dly_flows <- dplyr::filter(dly_flows, DAY <= NO_DAYS)

  ## convert into R date.
  dly_flows <- dplyr::mutate(
    dly_flows,
    Date = lubridate::ymd(paste0(YEAR, "-", MONTH, "-", DAY))
  )

  ## Then when a date column exist fine tune the subset
  if (!dates_null[["start_is_null"]])
    dly_flows <- dplyr::filter(dly_flows, !!sym_Date >= start_date)
  if (!dates_null[["end_is_null"]])
    dly_flows <- dplyr::filter(dly_flows, !!sym_Date <= end_date)

  dly_flows <- dplyr::left_join(
    dly_flows,
    tidyhydat::hy_data_symbols,
    by = c("FLOW_SYMBOL" = "SYMBOL_ID")
  )
  dly_flows <- dplyr::mutate(dly_flows, Parameter = "Flow")

  ## Control for symbol ouput
  if (symbol_output == "code") {
    dly_flows <- dplyr::select(
      dly_flows,
      STATION_NUMBER,
      Date,
      Parameter,
      FLOW,
      FLOW_SYMBOL
    )
  }

  if (symbol_output == "english") {
    dly_flows <- dplyr::select(
      dly_flows,
      STATION_NUMBER,
      Date,
      Parameter,
      FLOW,
      SYMBOL_EN
    )
  }

  if (symbol_output == "french") {
    dly_flows <- dplyr::select(
      dly_flows,
      STATION_NUMBER,
      Date,
      Parameter,
      FLOW,
      SYMBOL_FR
    )
  }

  dly_flows <- dplyr::arrange(dly_flows, Date)

  colnames(dly_flows) <- c(
    "STATION_NUMBER",
    "Date",
    "Parameter",
    "Value",
    "Symbol"
  )

  attr(dly_flows, "missed_stns") <- setdiff(
    unique(stns),
    unique(dly_flows$STATION_NUMBER)
  )
  as.hy(dly_flows)
}
