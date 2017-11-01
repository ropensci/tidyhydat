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


#' @title Parameter ID
#'
#' @description A tibble of parameter id codes and their corresponding explanation/description specific to the ECCC webservice
#' 
#' @format A tibble with 8 rows and 7 variables:
#' \describe{
#'   \item{Parameter}{Numeric parameter code}
#'   \item{Code}{Letter parameter code}
#'   \item{Name_En}{Code name in English}
#'   \item{Name_En}{Code name in French}
#'   \item{Unit}{Parameter units}
#' }
#'
#' @source \url{http://collaboration.cmc.ec.gc.ca/cmc/hydrometric_additionalData/Document/WebService_Guidelines.pdf}
#'
#'
"param_id"


#' All Canadian stations 
#' 
#' A shorthand to avoid having always call \code{hy_stations} or \code{realtime_stations}. Only up to date as of 2017-10-26. Populated by both 
#' realtime and historical data from HYDAT. 
#' 
#' @format A tibble with 5 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{STATION_NAME}{Official name for station identification}
#'   \item{PROV_TERR_STATE_LOC}{The province, territory or state in which the station is located}
#'   \item{LATITUDE}{North-South Coordinates of the gauging station in decimal degrees}
#'   \item{LONGITUDE}{East-West Coordinates of the gauging station in decimal degrees}
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
