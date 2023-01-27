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
#' Provides wrapper to turn the hy_stn_regulation table in HYDAT into a tidy data frame of station regulation.
#' `station_number` and `prov_terr_state_loc` can both be supplied. If both are omitted all values
#' from the `hy_stations` table are returned.
#'
#' @inheritParams hy_stations
#'
#' @return A tibble of stations, years of regulation and the regulation status
#'
#' @format A tibble with 4 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Year_from}{First year of use}
#'   \item{Year_to}{Last year of use}
#'   \item{REGULATED}{logical}
#' }
#'
#' @examples
#' \dontrun{
#' ## Multiple stations province not specified
#' hy_stn_regulation(station_number = c("08NM083", "08NE102"))
#'
#' ## Multiple province, station number not specified
#' hy_stn_regulation(prov_terr_state_loc = c("AB", "YT"))
#' }
#'

#' @family HYDAT functions
#' @source HYDAT
#' @export

hy_stn_regulation <- function(station_number = NULL,
                              hydat_path = NULL,
                              prov_terr_state_loc = NULL) {
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)

  ## Creating rlang symbols
  sym_STATION_NUMBER <- sym("STATION_NUMBER")

  ## data manipulations to make it "tidy"
  stn_reg <- dplyr::tbl(hydat_con, "STN_REGULATION")
  stn_reg <- dplyr::filter(stn_reg, !!sym_STATION_NUMBER %in% stns)
  stn_reg <- dplyr::collect(stn_reg)
  stn_reg <- dplyr::mutate(stn_reg, REGULATED = REGULATED == 1)

  colnames(stn_reg) <- c("STATION_NUMBER", "Year_from", "Year_to", "REGULATED")

  attr(stn_reg, "missed_stns") <- setdiff(unique(stns), unique(stn_reg$STATION_NUMBER))
  as.hy(stn_reg)
}
