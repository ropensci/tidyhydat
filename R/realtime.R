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


#' Download a tibble of realtime river data from the last 30 days from the Meteorological Service of Canada datamart
#'
#' Download realtime river data from the last 30 days from the Meteorological Service of Canada (MSC) datamart. 
#' The function will prioritize downloading data collected at the highest resolution. In instances where data is 
#' not available at high (hourly or higher) resolution daily averages are used. Currently, if a station does not 
#' exist or is not found, no data is returned.
#'
#' @param station_number Water Survey of Canada station number. If this argument is omitted from the function call, the value of \code{prov_terr_state_loc}
#' is returned.
#' @param prov_terr_state_loc Province, state or territory. If this argument is omitted from the function call, the value of \code{station_number}
#' is returned.
#'
#' @return A tibble of water flow and level values. 
#' 
#' @format A tibble with 8 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{PROV_TERR_STATE_LOC}{The province, territory or state in which the station is located}
#'   \item{Date}{Observation date and time for last thirty days. Formatted as a POSIXct class as UTC for consistency.}
#'   \item{Parameter}{Parameter being measured. Only possible values are Flow and Level}
#'   \item{Value}{Value of the measurement. If Parameter equals Flow the units are m^3/s. 
#'   If Parameter equals Level the units are metres.}
#'   \item{Grade}{reserved for future use}
#'   \item{Symbol}{reserved for future use}
#'   \item{Code}{quality assurance/quality control flag for the discharge}
#' }
#'
#' @examples
#' \dontrun{
#' ## Download from multiple provinces
#' realtime_dd(station_number=c("01CD005","08MF005"))
#'
#' # To download all stations in Prince Edward Island:
#' realtime_dd(prov_terr_state_loc = "PE")
#' }
#' 
#' @family realtime functions
#' @export
realtime_dd <- function(station_number = NULL, prov_terr_state_loc = NULL) {

  ## TODO: HAve a warning message if not internet connection exists
  if (!is.null(station_number) && station_number == "ALL") {
    stop("Deprecated behaviour.Omit the station_number = \"ALL\" argument. See ?realtime_dd for examples.")
  }
  
  ## If station number isn't and user wants the province
  if (is.null(station_number)) {
    station_number <- realtime_stations(prov_terr_state_loc = prov_terr_state_loc)$STATION_NUMBER
  }
  
  list_o_stations <- lapply(station_number, single_realtime_station)
  
  dplyr::bind_rows(list_o_stations)



}


#' Download a tibble of active realtime stations
#'
#' An up to date dataframe of all stations in the Realtime Water Survey of Canada 
#'   hydrometric network operated by Environment and Climate Change Canada
#'
#' @param prov_terr_state_loc Province/State/Territory or Location. See examples for list of available options. 
#'   realtime_stations() for all stations.
#'
#' @family realtime functions
#' 
#' @format A tibble with 6 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{STATION_NAME}{Official name for station identification}
#'   \item{LATITUDE}{North-South Coordinates of the gauging station in decimal degrees}
#'   \item{LONGITUDE}{East-West Coordinates of the gauging station in decimal degrees}
#'   \item{PROV_TERR_STATE_LOC}{The province, territory or state in which the station is located}
#'   \item{TIMEZONE}{Timezone of the station}
#' }
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' ## Available inputs for prov_terr_state_loc argument:
#' unique(realtime_stations()$prov_terr_state_loc)
#'
#' realtime_stations(prov_terr_state_loc = "BC")
#' realtime_stations(prov_terr_state_loc = c("QC","PE"))
#' }


realtime_stations <- function(prov_terr_state_loc = NULL) {
  prov <- prov_terr_state_loc

  url_check <- httr::GET("http://dd.weather.gc.ca/hydrometric/doc/hydrometric_StationList.csv")
  
  ## Checking to make sure the link is valid
  if(httr::http_error(url_check) == "TRUE"){
    stop("http://dd.weather.gc.ca/hydrometric/doc/hydrometric_StationList.csv is not a valid url. Datamart may be
         down or the url has changed.")
  }
  
  net_tibble <- httr::content(url_check,
                              type = "text/csv",
                              encoding = "UTF-8",
                              skip = 1,
                              col_names = c(
                                "STATION_NUMBER",
                                "STATION_NAME",
                                "LATITUDE",
                                "LONGITUDE",
                                "PROV_TERR_STATE_LOC",
                                "TIMEZONE"
                              ),
                              col_types = readr::cols()
                          )
  
  if (is.null(prov)) {
    return(net_tibble)
  }
  

  net_tibble <- dplyr::filter(net_tibble, .data$PROV_TERR_STATE_LOC %in% prov)
  net_tibble
}

###############################################
## Get realtime station data - single station
single_realtime_station <- function(station_number){
  
  ## If station is provided
  if (!is.null(station_number)) {
    sym_STATION_NUMBER <- sym("STATION_NUMBER")
    
    if(any(tidyhydat::allstations$STATION_NUMBER %in% station_number)){ ## first check internal dataframe for station info
      choose_df <- dplyr::filter(tidyhydat::allstations, !!sym_STATION_NUMBER %in% station_number)
      choose_df <- dplyr::select(choose_df, .data$STATION_NUMBER, .data$PROV_TERR_STATE_LOC)
    } else{
      choose_df <- realtime_stations()
      choose_df <- dplyr::filter(choose_df, !!sym_STATION_NUMBER %in% station_number)
      choose_df <- dplyr::select(choose_df, .data$STATION_NUMBER, .data$PROV_TERR_STATE_LOC)
    }
    
  }
  
  ## Specify from choose_df
  STATION_NUMBER_SEL <- choose_df$STATION_NUMBER
  PROV_SEL <- choose_df$PROV_TERR_STATE_LOC
  
  
  base_url <- "http://dd.weather.gc.ca/hydrometric"
  
  # build URL
  type <- c("hourly", "daily")
  url <-
    sprintf("%s/csv/%s/%s", base_url, PROV_SEL, type)
  infile <-
    sprintf(
      "%s/%s_%s_%s_hydrometric.csv",
      url,
      PROV_SEL,
      STATION_NUMBER_SEL,
      type
    )
  
  # Define column names as the same as HYDAT
  colHeaders <-
    c(
      "STATION_NUMBER",
      "Date",
      "Level",
      "Level_GRADE",
      "Level_SYMBOL",
      "Level_CODE",
      "Flow",
      "Flow_GRADE",
      "Flow_SYMBOL",
      "Flow_CODE"
    )
  
  url_check <- httr::GET(infile[1])
  ## check if a valid url
  if(httr::http_error(url_check) == TRUE){
    info(paste0("No hourly data found for ",STATION_NUMBER_SEL))
    
    h <- dplyr::tibble(A = STATION_NUMBER_SEL, B = NA, C = NA, D = NA, E = NA,
                       F = NA, G = NA, H = NA, I = NA, J = NA)
    
    colnames(h) <- colHeaders
  } else{
    h <- httr::content(
      url_check,
      type = "text/csv",
      encoding = "UTF-8",
      skip = 1,
      col_names = colHeaders,
      col_types = readr::cols(
        STATION_NUMBER = readr::col_character(),
        Date = readr::col_datetime(),
        Level = readr::col_double(),
        Level_GRADE = readr::col_character(),
        Level_SYMBOL = readr::col_character(),
        Level_CODE = readr::col_integer(),
        Flow = readr::col_double(),
        Flow_GRADE = readr::col_character(),
        Flow_SYMBOL = readr::col_character(),
        Flow_CODE = readr::col_integer()
      )
    )
  }
  
  # download daily file
  url_check_d <- httr::GET(infile[2])
  ## check if a valid url
  if(httr::http_error(url_check_d) == TRUE){
    info(paste0("No daily data found for ",STATION_NUMBER_SEL))
    
    d <- dplyr::tibble(A = NA, B = NA, C = NA, D = NA, E = NA,
                       F = NA, G = NA, H = NA, I = NA, J = NA)
    colnames(d) <- colHeaders
  } else{
    d <- httr::content(
      url_check_d,
      type = "text/csv",
      encoding = "UTF-8",
      skip = 1,
      col_names = colHeaders,
      col_types = readr::cols(
        STATION_NUMBER = readr::col_character(),
        Date = readr::col_datetime(),
        Level = readr::col_double(),
        Level_GRADE = readr::col_character(),
        Level_SYMBOL = readr::col_character(),
        Level_CODE = readr::col_integer(),
        Flow = readr::col_double(),
        Flow_GRADE = readr::col_character(),
        Flow_SYMBOL = readr::col_character(),
        Flow_CODE = readr::col_integer()
      )
    )
  }
  
  
  
  # now merge the hourly + daily (hourly data overwrites daily where dates are the same)
  if(NROW(stats::na.omit(h)) == 0){
    output <- d
  } else{
    p <- which(d$Date < min(h$Date))
    output <- rbind(d[p, ], h)
  }
  
  ## Create symbols
  sym_temp <- sym("temp")
  sym_val <- sym("val")
  sym_key <- sym("key")
  
  ## Now tidy the data
  ## TODO: Find a better way to do this
  output <- dplyr::rename(output, `Level_` = .data$Level, `Flow_` = .data$Flow)
  output <- tidyr::gather(output, !!sym_temp, !!sym_val, -.data$STATION_NUMBER, -.data$Date)
  output <- tidyr::separate(output, !!sym_temp, c("Parameter", "key"), sep = "_", remove = TRUE)
  output <- dplyr::mutate(output, key = ifelse(.data$key == "", "Value", .data$key))
  output <- tidyr::spread(output, !!sym_key, !!sym_val)
  output <- dplyr::rename(output, Code = .data$CODE, Grade = .data$GRADE, Symbol = .data$SYMBOL)
  output <- dplyr::mutate(output, PROV_TERR_STATE_LOC = PROV_SEL)
  output <- dplyr::select(output, .data$STATION_NUMBER, .data$PROV_TERR_STATE_LOC, .data$Date, .data$Parameter, .data$Value,
                          .data$Grade, .data$Symbol, .data$Code)
  output <- dplyr::arrange(output, .data$Parameter, .data$STATION_NUMBER, .data$Date)
  output$Value <- as.numeric(output$Value)
  
  output
  
  
}
