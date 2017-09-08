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



#' @title Extract station regulation from the HYDAT database
#'
#' @description Provides wrapper to turn the STN_REGULATION table in HYDAT into a tidy data frame. \code{STATION_NUMBER} and
#' \code{PROV_TERR_STATE_LOC} can both be supplied. If both are omitted all values from the \code{STATIONS} table are returned
#'
#' @inheritParams STATIONS
#'
#' @return A tibble of stations, years of regulation and the regulation status
#'
#' @examples
#' \donttest{
#' ## Multiple stations province not specified
#' STN_REGULATION(STATION_NUMBER = c("08NM083","08NE102"), hydat_path = "H:/Hydat.sqlite3")
#'
#' ## Multiple province, station number not specified
#' STN_REGULATION(PROV_TERR_STATE_LOC = c("AB","YT"), hydat_path = "H:/Hydat.sqlite3")
#' }
#'

#' @export

STN_REGULATION <- function(hydat_path=NULL, STATION_NUMBER = NULL, PROV_TERR_STATE_LOC = NULL) {
  if (is.null(hydat_path)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
  }


  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)

  ## data manipulations to make it "tidy"
  df <- dplyr::tbl(hydat_con, "STN_REGULATION") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect() %>%
    dplyr::mutate(
      REGULATED = dplyr::case_when(
        REGULATED == 0 ~ "Natural",
        REGULATED == 1 ~ "Regulated"
      )
    )

  df
}
