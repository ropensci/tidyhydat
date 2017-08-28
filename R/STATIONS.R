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



#' @title Extract station information from the HYDAT database 
#' 
#' @description Provides wrapper to turn the STATIONS table in HYDAT into a tidy data frame. \code{STATION_NUMBER} and 
#' \code{PROV_TERR_STATE_LOC} can both be supplied. If both are omitted all values from the \code{STATIONS} table are returned
#' 
#' @param hydat_path Directory to the hydat database. Can be set as "Hydat.sqlite3" which will look for Hydat in the working directory. 
#' The hydat path can also be set in the \code{.Renviron} file so that it doesn't have to specified every function call. The path should 
#' set as the variable \code{hydat}. Open the \code{.Renviron} file using this command: \code{file.edit("~/.Renviron")}.
#' @param STATION_NUMBER Water Survey of Canada station number. If this argument is omitted from the function call, the value of \code{PROV_TERR_STATE_LOC} 
#' is returned. 
#' @param PROV_TERR_STATE_LOC Province, state or territory. If this argument is omitted from the function call, the value of \code{STATION_NUMBER} 
#' is returned. See \code{unique(STATIONS(hydat_path = "H:/Hydat.sqlite3")$PROV_TERR_STATE_LOC)}
#' 
#' @return A tibble of stations and associated metadata
#' 
#' @examples 
#' \donttest{
#' ## Multiple stations province not specified 
#' STATIONS(STATION_NUMBER = c("08NM083","08NE102"), hydat_path = "H:/Hydat.sqlite3")
#' 
#' ## Multiple province, station number not specified
#' STATIONS(PROV_TERR_STATE_LOC = c("AB","YT"), hydat_path = "H:/Hydat.sqlite3")
#' }
#' 
#' 
#' @export

STATIONS <- function(hydat_path=NULL, STATION_NUMBER = NULL, PROV_TERR_STATE_LOC = NULL) {
  
  #if(STATION_NUMBER == "ALL" | PROV_TERR_STATE_LOC == "ALL"){
  #  stop("Specifying ALL for STATION_NUMBER OR PROV_TERR_STATE_LOC is deprecrated. See examples for usage.")
  #}
  
  if(is.null(hydat_path)){
    hydat_path = Sys.getenv("hydat")
    if(is.na(hydat_path)){
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
  }
  
  
  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  ## Determine which stations we are querying 
  stns = station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)
    
  ## Create the dataframe to return
  df = dplyr::tbl(hydat_con, "STATIONS") %>%
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
  DBI::dbDisconnect(hydat_con)
  
  ## What stations were missed?
  differ = setdiff(unique(stns), unique(df$STATION_NUMBER))
  if( length(differ) !=0 ){
    message("The following station(s) were not retrieved: ", paste0(differ, sep = " "))
    message("Check station number typos or if it is a valid station in the network")
  } else{
    message("All station successfully retrieved")
  }
  
  return(df)
  
    
  }
