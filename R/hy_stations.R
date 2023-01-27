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



#' Extract station information from the HYDAT database
#'
#' Provides wrapper to turn the hy_stations table in HYDAT into a tidy data frame of station information. `station_number` and
#' `prov_terr_state_loc` can both be supplied. If both are omitted all values from the `hy_stations` table are returned. This
#' is the entry point for most analyses is tidyhydat as establish the stations for consideration is likely the first step in many
#' instances.
#'
#' @inheritParams hy_agency_list
#' @param station_number A seven digit Water Survey of Canada station number. If this argument is omitted, the value of `prov_terr_state_loc`
#' is returned.
#' @param prov_terr_state_loc Province, state or territory. If this argument is omitted, the value of `station_number`
#' is returned. See `unique(allstations$prov_terr_state_loc)`. Will also accept `CA` to return only Canadian stations.
#'
#' @return A tibble of stations and associated metadata
#'
#' @format A tibble with 15 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{STATION_NAME}{Official name for station identification}
#'   \item{PROV_TERR_STATE_LOC}{The province, territory or state in which the station is located}
#'   \item{REGIONAL_OFFICE_ID}{The identifier of the regional office responsible for the station.
#'   Links to \link[tidyhydat]{hy_reg_office_list}}
#'   \item{HYD_STATUS}{Current status of discharge or level monitoring in the hydrometric network}
#'   \item{SED_STATUS}{Current status of sediment monitoring in the hydrometric network}
#'   \item{LATITUDE}{North-South Coordinates of the gauging station in decimal degrees}
#'   \item{LONGITUDE}{East-West Coordinates of the gauging station in decimal degrees}
#'   \item{DRAINAGE_AREA_GROSS}{The total surface area that drains to the gauge site (km^2)}
#'   \item{DRAINAGE_AREA_EFFECT}{The portion of the drainage basin that contributes runoff to
#'   the gauge site, calculated by subtracting any noncontributing portion from the
#'   gross drainage area (km^2)}
#'   \item{RHBN}{Logical. Reference Hydrometric Basin Network station. The Reference Hydrometric
#'   Basin Network (RHBN) is a sub-set of the national network that has been identified
#'   for use in the detection, monitoring, and assessment of climate change.}
#'   \item{REAL_TIME}{Logical. Indicates if a station has the capacity to deliver data in
#'   real-time or near real-time}
#'   \item{CONTRIBUTOR_ID}{Unique ID of an agency that contributes data to the
#'   HYDAT database. The agency is non-WSC and non WSC funded}
#'   \item{OPERATOR_ID}{Unique ID of an agency that operates a hydrometric station}
#'   \item{DATUM_ID}{Unique ID for a datum}
#' }
#'
#' @examples
#' \dontrun{
#' ## Multiple stations province not specified
#' hy_stations(station_number = c("08NM083", "08NE102"))
#'
#' ## Multiple province, station number not specified
#' hy_stations(prov_terr_state_loc = c("AB", "YT"))
#' }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export

hy_stations <- function(station_number = NULL,
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

  ## Create the dataframe to return
  df <- dplyr::tbl(hydat_con, "STATIONS") %>%
    dplyr::filter(!!sym_STATION_NUMBER %in% stns) %>%
    dplyr::collect() %>%
    dplyr::mutate(REGIONAL_OFFICE_ID = as.numeric(REGIONAL_OFFICE_ID)) %>%
    dplyr::mutate(
      HYD_STATUS = dplyr::case_when(
        HYD_STATUS == "D" ~ "DISCONTINUED",
        HYD_STATUS == "A" ~ "ACTIVE",
        TRUE ~ NA_character_
      ),
      SED_STATUS = dplyr::case_when(
        SED_STATUS == "D" ~ "DISCONTINUED",
        SED_STATUS == "A" ~ "ACTIVE",
        TRUE ~ NA_character_
      ),
      RHBN = RHBN == 1,
      REAL_TIME = REAL_TIME == 1
    )


  attr(df, "missed_stns") <- setdiff(unique(stns), unique(df$STATION_NUMBER))
  as.hy(df)
}
