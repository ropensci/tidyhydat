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



#' Extract station regulation from the HYDAT database
#'
#' Provides wrapper to turn the hy_stn_regulation table in HYDAT into a tidy data frame. \code{station_number} and
#' \code{prov_terr_state_loc} can both be supplied. If both are omitted all values from the \code{hy_stations} table are returned
#'
#' @inheritParams hy_stations
#'
#' @return A tibble of stations, years of regulation and the regulation status
#'
#' @examples
#' \donttest{
#' ## Multiple stations province not specified
#' hy_stn_regulation(station_number = c("08NM083","08NE102"))
#'
#' ## Multiple province, station number not specified
#' hy_stn_regulation(prov_terr_state_loc = c("AB","YT"))
#' }
#'

#' @family HYDAT functions
#' @source HYDAT
#' @export

hy_stn_regulation <- function(station_number = NULL, 
                           hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"), 
                           prov_terr_state_loc = NULL) {
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }


  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)

  ## data manipulations to make it "tidy"
  dplyr::tbl(hydat_con, "STN_REGULATION") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect() %>%
    dplyr::mutate(
      REGULATED = dplyr::case_when(
        REGULATED == 0 ~ "Natural",
        REGULATED == 1 ~ "Regulated"
      )
    )

}
