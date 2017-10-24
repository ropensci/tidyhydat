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
#' Provides wrapper to turn the STATIONS table in HYDAT into a tidy data frame. \code{STATION_NUMBER} and
#' \code{PROV_TERR_STATE_LOC} can both be supplied. If both are omitted all values from the \code{STATIONS} table are returned
#'
#' @inheritParams AGENCY_LIST
#' @param STATION_NUMBER Water Survey of Canada station number. If this argument is omitted, the value of \code{PROV_TERR_STATE_LOC}
#' is returned.
#' @param PROV_TERR_STATE_LOC Province, state or territory. If this argument is omitted, the value of \code{STATION_NUMBER}
#' is returned. See \code{unique(allstations$PROV_TERR_STATE_LOC)}
#'
#' @return A tibble of stations and associated metadata
#'
#' @examples
#' \donttest{
#' ## Multiple stations province not specified
#' STATIONS(STATION_NUMBER = c("08NM083","08NE102"))
#'
#' ## Multiple province, station number not specified
#' STATIONS(PROV_TERR_STATE_LOC = c("AB","YT"))
#' }
#'
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export

STATIONS <- function(STATION_NUMBER = NULL, 
                     hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"),
                     PROV_TERR_STATE_LOC = NULL) {
  if (!is.null(STATION_NUMBER) && STATION_NUMBER == "ALL") {
    stop("Deprecated behaviour.Omit the STATION_NUMBER = \"ALL\" argument. See ?download_realtime_dd for examples.")
  }

  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  


  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)

  ## Create the dataframe to return
  df <- dplyr::tbl(hydat_con, "STATIONS") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect() %>%
    dplyr::mutate(REGIONAL_OFFICE_ID = as.numeric(REGIONAL_OFFICE_ID)) %>%
    dplyr::mutate(
      HYD_STATUS = dplyr::case_when(
        HYD_STATUS == "D" ~ "DISCONTINUED",
        HYD_STATUS == "A" ~ "ACTIVE",
        TRUE ~ "NA"
      ),
      SED_STATUS = dplyr::case_when(
        SED_STATUS == "D" ~ "DISCONTINUED",
        SED_STATUS == "A" ~ "ACTIVE",
        TRUE ~ "NA"
      ),
      RHBN = dplyr::case_when(
        RHBN == "1" ~ "Yes",
        RHBN == "0" ~ "No",
        TRUE ~ "NA"
      ),
      REAL_TIME = dplyr::case_when(
        REAL_TIME == "1" ~ "Yes",
        REAL_TIME == "0" ~ "No",
        TRUE ~ "NA"
      )
    )

  ## What stations were missed?
  differ <- setdiff(unique(stns), unique(df$STATION_NUMBER))
  if (length(differ) != 0) {
    if (length(differ) <= 10) {
      message("The following station(s) were not retrieved: ", paste0(differ, sep = " "))
      message("Check station number typos or if it is a valid station in the network")
    }
    else {
      message("More than 10 stations from the initial query were not returned. Ensure realtime and active status are correctly specified.")
    }
  } else {
    message("All station successfully retrieved")
  }

  df
}
