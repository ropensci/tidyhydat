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
#' Provides wrapper to turn the SED_DLY_SUSCON table in HYDAT into a tidy data frame of daily suspended sediment concentration information.
#' \code{station_number} and \code{prov_terr_state_loc} can both be supplied. If both are omitted all values from the \code{hy_stations}
#' table are returned. That is a large vector for \code{hy_sed_daily_suscon}.
#'
#' @inheritParams hy_daily_flows
#'
#' @return A tibble of daily suspended sediment concentration
#'
#' @format A tibble with 5 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Date}{Observation date. Formatted as a Date class.}
#'   \item{Parameter}{Parameter being measured. Only possible value is Suscon}
#'   \item{Value}{Discharge value. The units are mg/l.}
#'   \item{Symbol}{Measurement/river conditions}
#' }
#'
#' @examples
#' \dontrun{
#' hy_sed_daily_suscon(station_number = "01CE003")
#' }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export

hy_sed_daily_suscon <- function(
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
  sed_dly_suscon <- dplyr::tbl(hydat_con, "SED_DLY_SUSCON")
  sed_dly_suscon <- dplyr::filter(
    sed_dly_suscon,
    !!sym_STATION_NUMBER %in% stns
  )

  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too

  ## by year
  if (!dates_null[["start_is_null"]])
    sed_dly_suscon <- dplyr::filter(
      sed_dly_suscon,
      !!sym_YEAR >= lubridate::year(start_date)
    )
  if (!dates_null[["end_is_null"]])
    sed_dly_suscon <- dplyr::filter(
      sed_dly_suscon,
      !!sym_YEAR <= lubridate::year(end_date)
    )

  sed_dly_suscon <- dplyr::select(
    sed_dly_suscon,
    STATION_NUMBER,
    YEAR,
    MONTH,
    NO_DAYS,
    dplyr::contains("SUSCON")
  )
  sed_dly_suscon <- dplyr::collect(sed_dly_suscon)

  if (is.data.frame(sed_dly_suscon) && nrow(sed_dly_suscon) == 0) {
    stop("No suspended sediment data for this station in HYDAT")
  }

  sed_dly_suscon <- tidyr::gather(
    sed_dly_suscon,
    !!sym_variable,
    !!sym_temp,
    -(STATION_NUMBER:NO_DAYS)
  )
  sed_dly_suscon <- dplyr::mutate(
    sed_dly_suscon,
    DAY = as.numeric(gsub("SUSCON|SUSCON_SYMBOL", "", variable))
  )
  sed_dly_suscon <- dplyr::mutate(
    sed_dly_suscon,
    variable = gsub("[0-9]+", "", variable)
  )
  sed_dly_suscon <- tidyr::spread(sed_dly_suscon, !!sym_variable, !!sym_temp)
  sed_dly_suscon <- dplyr::mutate(sed_dly_suscon, SUSCON = as.numeric(SUSCON))
  ## No days that exceed actual number of days in the month
  sed_dly_suscon <- dplyr::filter(sed_dly_suscon, DAY <= NO_DAYS)

  ## convert into R date.
  sed_dly_suscon <- dplyr::mutate(
    sed_dly_suscon,
    Date = lubridate::ymd(
      paste0(YEAR, "-", MONTH, "-", DAY)
    )
  )

  ## Then when a date column exist fine tune the subset
  if (!dates_null[["start_is_null"]])
    sed_dly_suscon <- dplyr::filter(sed_dly_suscon, !!sym_Date >= start_date)
  if (!dates_null[["end_is_null"]])
    sed_dly_suscon <- dplyr::filter(sed_dly_suscon, !!sym_Date <= end_date)

  sed_dly_suscon <- dplyr::left_join(
    sed_dly_suscon,
    tidyhydat::hy_data_symbols,
    by = c("SUSCON_SYMBOL" = "SYMBOL_ID")
  )
  sed_dly_suscon <- dplyr::mutate(sed_dly_suscon, Parameter = "Suscon")

  ## Control for symbol ouput
  if (symbol_output == "code") {
    sed_dly_suscon <- dplyr::select(
      sed_dly_suscon,
      STATION_NUMBER,
      Date,
      Parameter,
      SUSCON,
      SUSCON_SYMBOL
    )
  }

  if (symbol_output == "english") {
    sed_dly_suscon <- dplyr::select(
      sed_dly_suscon,
      STATION_NUMBER,
      Date,
      Parameter,
      SUSCON,
      SYMBOL_EN
    )
  }

  if (symbol_output == "french") {
    sed_dly_suscon <- dplyr::select(
      sed_dly_suscon,
      STATION_NUMBER,
      Date,
      Parameter,
      SUSCON,
      SYMBOL_FR
    )
  }

  sed_dly_suscon <- dplyr::arrange(sed_dly_suscon, Date)

  colnames(sed_dly_suscon) <- c(
    "STATION_NUMBER",
    "Date",
    "Parameter",
    "Value",
    "Symbol"
  )

  attr(sed_dly_suscon, "missed_stns") <- setdiff(
    unique(stns),
    unique(sed_dly_suscon$STATION_NUMBER)
  )
  as.hy(sed_dly_suscon)
}
