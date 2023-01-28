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


#' All Canadian stations
#'
#' A shorthand to avoid having always call `hy_stations` or `realtime_stations`.
#' Populated by both realtime and historical data from HYDAT.
#'
#'
#' @format A tibble with 5 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{STATION_NAME}{Official name for station identification}
#'   \item{PROV_TERR_STATE_LOC}{The province, territory or state in which the station is located}
#'   \item{HYD_STATUS}{Current status of discharge or level monitoring in the hydrometric network}
#'   \item{REAL_TIME}{Logical. Indicates if a station has the capacity to deliver data in
#'   real-time or near real-time}
#'   \item{LATITUDE}{North-South Coordinates of the gauging station in decimal degrees}
#'   \item{LONGITUDE}{East-West Coordinates of the gauging station in decimal degrees}
#'   \item{station_tz}{Timezone of station calculated using the lutz package based on LAT/LONG of stations}
#'   \item{standard_offset}{Offset from UTC of local standard time}
#' }
#'
#' @source HYDAT, Meteorological Service of Canada datamart
"allstations"

#' DATA SYMBOLS look-up table
#'
#' A look table for data symbols
#'
#' @format A tibble with 5 rows and 3 variables:
#' \describe{
#'   \item{SYMBOL_ID}{Symbol code}
#'   \item{SYMBOL_EN}{Description of Symbol (English)}
#'   \item{SYMBOL_FR}{Description of Symbol (French)}
#' }
#' @family HYDAT functions
#' @source HYDAT
"hy_data_symbols"

#' DATA TYPES look-up table
#'
#' A look table for data types
#'
#' @format A tibble with 5 rows and 3 variables:
#' \describe{
#'   \item{DATA_TYPE}{Data type code}
#'   \item{DATA_TYPE_EN}{Descriptive data type (English)}
#'   \item{DATA_TYPE_FR}{Descriptive data type (French)}
#' }
#' @family HYDAT functions
#'
#' @source HYDAT
"hy_data_types"
