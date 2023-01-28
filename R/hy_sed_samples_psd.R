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
#' particle size distribution.  `station_number` and `prov_terr_state_loc` can both be supplied. If both
#' are omitted all values from the [hy_stations()] table are returned. That is a large vector for `hy_sed_samples_psd`.
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
#'   \item{SED_DATA_TYPE}{Contains the type of sampling method used in collecting sediment for a station}
#'   \item{Date}{Contains the time to the nearest minute of when the sample was taken}
#'   \item{PARTICLE_SIZE}{Particle size (mm)}
#'   \item{PERCENT}{Contains the percentage values for indicated particle sizes for samples collected}
#' }
#'
#'
#' @examples
#' \dontrun{
#' hy_sed_samples_psd(station_number = "01CA004")
#' }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export



hy_sed_samples_psd <- function(station_number = NULL,
                               hydat_path = NULL,
                               prov_terr_state_loc = NULL,
                               start_date = NULL,
                               end_date = NULL) {
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
  sed_samples_psd <- dplyr::tbl(hydat_con, "SED_SAMPLES_PSD")
  sed_samples_psd <- dplyr::filter(sed_samples_psd, !!sym_STATION_NUMBER %in% stns)
  sed_samples_psd <- dplyr::left_join(sed_samples_psd, dplyr::tbl(hydat_con, "SED_DATA_TYPES"), by = c("SED_DATA_TYPE"))

  sed_samples_psd <- dplyr::collect(sed_samples_psd)

  if (is.data.frame(sed_samples_psd) && nrow(sed_samples_psd) == 0) stop("This station is not present in HYDAT")

  sed_samples_psd <- dplyr::mutate(sed_samples_psd, DATE = lubridate::ymd_hms(DATE), date_no_time = as.Date(DATE))

  ## SUBSET by date
  if (!dates_null[["start_is_null"]]) sed_samples_psd <- dplyr::filter(sed_samples_psd, !!sym("date_no_time") >= as.Date(start_date))
  if (!dates_null[["end_is_null"]]) sed_samples_psd <- dplyr::filter(sed_samples_psd, !!sym("date_no_time") <= as.Date(end_date))


  sed_samples_psd <- dplyr::select(sed_samples_psd, STATION_NUMBER,
    SED_DATA_TYPE = SED_DATA_TYPE_EN,
    Date = DATE, PARTICLE_SIZE, PERCENT
  )

  attr(sed_samples_psd, "missed_stns") <- setdiff(unique(stns), unique(sed_samples_psd$STATION_NUMBER))
  as.hy(sed_samples_psd)
}
