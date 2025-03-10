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
#' Provides wrapper to turn the hy_sed_samples table in HYDAT into a tidy data frame of instantaneous sediment sample information.
#' `station_number` and `prov_terr_state_loc` can both be supplied. If both are omitted all values from the `hy_stations`
#' table are returned. That is a large vector for `hy_sed_samples`.
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
#'   \item{Date}{Contains the time to the nearest minute of when the sample was taken}
#'   \item{SAMPLE_REMARK_CODE}{Descriptive Sediment Sample Remark in English}
#'   \item{TIME_SYMBOL}{An "E" symbol means the time is an estimate only}
#'   \item{FLOW}{Contains the instantaneous discharge in cubic metres per second at the time the sample was taken}
#'   \item{SYMBOL_EN}{Indicates a condition where the daily mean has a larger than expected error}
#'   \item{SAMPLER_TYPE}{Contains the type of measurement device used to take the sample}
#'   \item{SAMPLING_VERTICAL_LOCATION}{The location on the cross-section of the river
#'         at which the single sediment samples are collected. If one of the standard
#'         locations is not used the distance in meters will be shown}
#'   \item{SAMPLING_VERTICAL_EN}{Indicates sample location relative to the
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
#' }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export

hy_sed_samples <- function(
  station_number = NULL,
  hydat_path = NULL,
  prov_terr_state_loc = NULL,
  start_date = NULL,
  end_date = NULL
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
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  sym_DATE <- sym("DATE")

  ## Data manipulations
  sed_samples <- dplyr::tbl(hydat_con, "SED_SAMPLES")
  sed_samples <- dplyr::filter(sed_samples, !!sym_STATION_NUMBER %in% stns)
  sed_samples <- dplyr::left_join(
    sed_samples,
    dplyr::tbl(hydat_con, "SED_DATA_TYPES"),
    by = c("SED_DATA_TYPE")
  )
  sed_samples <- dplyr::left_join(
    sed_samples,
    dplyr::tbl(hydat_con, "SAMPLE_REMARK_CODES"),
    by = c("SAMPLE_REMARK_CODE")
  )
  sed_samples <- dplyr::left_join(
    sed_samples,
    dplyr::tbl(hydat_con, "SED_VERTICAL_LOCATION"),
    by = c("SAMPLING_VERTICAL_LOCATION" = "SAMPLING_VERTICAL_LOCATION_ID")
  )
  sed_samples <- dplyr::left_join(
    sed_samples,
    dplyr::tbl(hydat_con, "SED_VERTICAL_SYMBOLS"),
    by = c("SAMPLING_VERTICAL_SYMBOL")
  )
  sed_samples <- dplyr::left_join(
    sed_samples,
    dplyr::tbl(hydat_con, "CONCENTRATION_SYMBOLS"),
    by = c("CONCENTRATION_SYMBOL")
  )

  sed_samples <- dplyr::collect(sed_samples)

  if (is.data.frame(sed_samples) && nrow(sed_samples) == 0)
    stop("This station is not present in HYDAT")

  sed_samples <- dplyr::left_join(
    sed_samples,
    tidyhydat::hy_data_symbols,
    by = c("FLOW_SYMBOL" = "SYMBOL_ID")
  )
  sed_samples <- dplyr::mutate(
    sed_samples,
    DATE = lubridate::ymd_hms(DATE),
    date_no_time = as.Date(DATE)
  )

  ## SUBSET by date
  if (!dates_null[["start_is_null"]])
    sed_samples <- dplyr::filter(
      sed_samples,
      !!sym("date_no_time") >= as.Date(start_date)
    )
  if (!dates_null[["end_is_null"]])
    sed_samples <- dplyr::filter(
      sed_samples,
      !!sym("date_no_time") <= as.Date(end_date)
    )

  sed_samples <- dplyr::select(
    sed_samples,
    STATION_NUMBER,
    SED_DATA_TYPE_EN,
    Date = DATE,
    SAMPLE_REMARK_EN,
    TIME_SYMBOL,
    FLOW,
    SYMBOL_EN,
    SAMPLER_TYPE,
    SAMPLING_VERTICAL_LOCATION,
    SAMPLING_VERTICAL_EN,
    TEMPERATURE,
    CONCENTRATION,
    CONCENTRATION_EN,
    SV_DEPTH2
  )

  attr(sed_samples, "missed_stns") <- setdiff(
    unique(stns),
    unique(sed_samples$STATION_NUMBER)
  )
  as.hy(sed_samples)
}
