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
#' @description Provides wrapper to turn the DLY_LEVELS table in HYDAT into a tidy data frame.  The primary value returned by this
#' function is discharge. `station_number` and `prov_terr_state_loc` can both be supplied. If both are omitted all
#' values from the `hy_stations` table are returned. That is a large vector for `hy_daily_levels`.
#'
#' @inheritParams hy_daily_flows
#'
#' @return A tibble of daily levels
#'
#' @format A tibble with 5 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Date}{Observation date. Formatted as a Date class.}
#'   \item{Parameter}{Parameter being measured. Only possible value is Level}
#'   \item{Value}{Level value. The units are metres.}
#'   \item{Symbol}{Measurement/river conditions}
#' }
#'
#' @examples
#' \dontrun{
#' hy_daily_levels(
#'   station_number = c("02JE013", "08MF005"),
#'   start_date = "1996-01-01", end_date = "2000-01-01"
#' )
#'
#' hy_daily_levels(prov_terr_state_loc = "PE")
#' }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export

hy_daily_levels <- function(
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

  ## Data manipulations
  dly_levels <- dplyr::tbl(hydat_con, "DLY_LEVELS")
  dly_levels <- dplyr::filter(dly_levels, !!sym_STATION_NUMBER %in% stns)

  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too

  ## by year
  if (!dates_null[["start_is_null"]])
    dly_levels <- dplyr::filter(
      dly_levels,
      !!sym_YEAR >= lubridate::year(start_date)
    )
  if (!dates_null[["end_is_null"]])
    dly_levels <- dplyr::filter(
      dly_levels,
      !!sym_YEAR <= lubridate::year(end_date)
    )

  dly_levels <- dplyr::select(
    dly_levels,
    STATION_NUMBER,
    YEAR,
    MONTH,
    NO_DAYS,
    dplyr::contains("LEVEL")
  )
  dly_levels <- dplyr::collect(dly_levels)

  if (is.data.frame(dly_levels) && nrow(dly_levels) == 0) {
    stop("No level data for this station in HYDAT")
  }

  dly_levels <- tidyr::gather(
    dly_levels,
    !!sym_variable,
    !!sym_temp,
    -(STATION_NUMBER:NO_DAYS)
  )
  dly_levels <- dplyr::mutate(
    dly_levels,
    DAY = as.numeric(gsub("LEVEL|LEVEL_SYMBOL", "", variable))
  )
  dly_levels <- dplyr::mutate(
    dly_levels,
    variable = gsub("[0-9]+", "", variable)
  )
  dly_levels <- tidyr::spread(dly_levels, variable, temp)
  dly_levels <- dplyr::mutate(dly_levels, LEVEL = as.numeric(LEVEL))
  ## No days that exceed actual number of days in the month
  dly_levels <- dplyr::filter(dly_levels, DAY <= NO_DAYS)

  ## convert into R date.
  dly_levels <- dplyr::mutate(
    dly_levels,
    Date = lubridate::ymd(paste0(YEAR, "-", MONTH, "-", DAY))
  )

  ## Then when a date column exist fine tune the subset
  if (!dates_null[["start_is_null"]])
    dly_levels <- dplyr::filter(dly_levels, !!sym_Date >= start_date)
  if (!dates_null[["end_is_null"]])
    dly_levels <- dplyr::filter(dly_levels, !!sym_Date <= end_date)

  dly_levels <- dplyr::left_join(
    dly_levels,
    tidyhydat::hy_data_symbols,
    by = c("LEVEL_SYMBOL" = "SYMBOL_ID")
  )
  dly_levels <- dplyr::mutate(dly_levels, Parameter = "Level")

  ## Control for symbol ouput
  if (symbol_output == "code") {
    dly_levels <- dplyr::select(
      dly_levels,
      STATION_NUMBER,
      Date,
      Parameter,
      LEVEL,
      LEVEL_SYMBOL
    )
  }

  if (symbol_output == "english") {
    dly_levels <- dplyr::select(
      dly_levels,
      STATION_NUMBER,
      Date,
      Parameter,
      LEVEL,
      SYMBOL_EN
    )
  }

  if (symbol_output == "french") {
    dly_levels <- dplyr::select(
      dly_levels,
      STATION_NUMBER,
      Date,
      Parameter,
      LEVEL,
      SYMBOL_FR
    )
  }

  dly_levels <- dplyr::arrange(dly_levels, Date)

  colnames(dly_levels) <- c(
    "STATION_NUMBER",
    "Date",
    "Parameter",
    "Value",
    "Symbol"
  )

  attr(dly_levels, "missed_stns") <- setdiff(
    unique(stns),
    unique(dly_levels$STATION_NUMBER)
  )

  as.hy(dly_levels)
}
