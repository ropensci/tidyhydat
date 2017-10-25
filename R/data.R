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
#' @description A tibble of parameter id codes and their corresponding explanation/description
#'
#' @source \url{http://collaboration.cmc.ec.gc.ca/cmc/hydrometric_additionalData/Document/WebService_Guidelines.pdf}
#'
#'
"param_id"

## To add to list
# bcstations <- download_network(prov_terr_state_loc = "BC") %>%
#  anti_join(hy_stations(hydat_path = "H:/Hydat.sqlite3",
#                     prov_terr_state_loc = "BC", station_number = "ALL"),
#            by = c("station_number", "STATION_NAME")) %>%
#  select(station_number, STATION_NAME) %>%
#  bind_rows(bcstations)

#' A tibble of BC stations and their names
#'
#' A shorthand to avoid having always call \code{hy_stations}. Only up to date as of 2017-07-18.
#'
#' @source HYDAT
"bcstations"


#' A tibble of all Canadian Stations stations and their names.
#'
#' A shorthand to avoid having always call \code{hy_stations}. Only up to date as of 2017-07-18.
#'
#' @source HYDAT
"allstations"


#' DATA SYMBOLS look-up table
#'
#' A look table for data symbols
#'
#' @source HYDAT
"DATA_SYMBOLS"

#' DATA TYPES look-up table
#'
#' A look table for data types
#'
#' @source HYDAT
"DATA_TYPES"
