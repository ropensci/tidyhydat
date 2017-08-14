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


#' @title Download a tibble of realtime discharge data from the MSC datamart
#' 
#' @description Download realtime discharge data from the Meteorological Service of Canada (MSC) datamart. The function will prioritize 
#' downloading data collected at the highest resolution. In instances where data is not available at high (hourly or higher) resolution 
#' daily averages are used. Currently, if a station does not exist or is not found, no data is returned. Both the province and the station number 
#' should be specified. 
#' 
#' @param STATION_NUMBER Water Survey of Canada station number. No default. Can also take the "ALL" argument. 
#' @param PROV_TERR_STATE_LOC Province, state or territory. See also for argument options.
#' 
#' @return A tibble of water flow and level values
#' 
#' @seealso 
#' \code{download_network()}.
#' 
#' 
#' @examples
#' download_realtime2(STATION_NUMBER="08MF005", PROV_TERR_STATE_LOC="BC")
#' 
#' # To download all stations in Prince Edward Island:
#' download_realtime2(STATION_NUMBER = "ALL", PROV_TERR_STATE_LOC = "PE")
#' 
#' @export
download_realtime2 <- function(STATION_NUMBER, PROV_TERR_STATE_LOC) {
  
  if(missing(STATION_NUMBER) | missing(PROV_TERR_STATE_LOC)) 
    stop("STATION_NUMBER or PROV_TERR_STATE_LOC argument is missing. These arguments must match jurisdictions.")
  
  ## TODO: HAve a warning message if not internet connection exists
  
  prov = PROV_TERR_STATE_LOC
  
  if(STATION_NUMBER[1] == "ALL"){
    STATION_NUMBER = download_network(PROV_TERR_STATE_LOC = prov)$STATION_NUMBER
  }
  
  output_c <- c()
  for (i in 1:length(STATION_NUMBER) ){
    STATION_NUMBER_SEL = STATION_NUMBER[i]
  
  base_url = "http://dd.weather.gc.ca/hydrometric"
  
  # build URL
  type <- c("hourly", "daily")
  url <- sprintf("%s/csv/%s/%s", base_url, PROV_TERR_STATE_LOC, type)
  infile <- sprintf("%s/%s_%s_%s_hydrometric.csv", url, PROV_TERR_STATE_LOC, STATION_NUMBER_SEL, type)
  
  # Define column names as the same as HYDAT
  colHeaders <- c("STATION_NUMBER", "Date", "LEVEL", "LEVEL_GRADE", "LEVEL_SYMBOL", "LEVEL_CODE",
                  "FLOW", "FLOW_GRADE", "FLOW_SYMBOL", "FLOW_CODE")
  
  
  h <- tryCatch(
      readr::read_csv(
        infile[1],
        skip = 1,
        col_names = colHeaders,
        col_types = readr::cols(
          STATION_NUMBER = readr::col_character(),
          Date = readr::col_datetime(),
          LEVEL = readr::col_double(),
          LEVEL_GRADE = readr::col_character(),
          LEVEL_SYMBOL = readr::col_character(),
          LEVEL_CODE = readr::col_integer(),
          FLOW = readr::col_double(),
          FLOW_GRADE = readr::col_character(),
          FLOW_SYMBOL = readr::col_character(),
          FLOW_CODE = readr::col_integer()
        )
      ),
      error = function(c) {
        c$message <- paste0(STATION_NUMBER_SEL, " cannot be found")
        stop(c)
      }
    )
  
  
  # download daily file
  d <- tryCatch(
      readr::read_csv(
        infile[2],
        skip = 1,
        col_names = colHeaders,
        col_types = readr::cols(
          STATION_NUMBER = readr::col_character(),
          Date = readr::col_datetime(),
          LEVEL = readr::col_double(),
          LEVEL_GRADE = readr::col_character(),
          LEVEL_SYMBOL = readr::col_character(),
          LEVEL_CODE = readr::col_integer(),
          FLOW = readr::col_double(),
          FLOW_GRADE = readr::col_character(),
          FLOW_SYMBOL = readr::col_character(),
          FLOW_CODE = readr::col_integer()
        )
      ),
      error = function(c) {
        c$message <- paste0(STATION_NUMBER_SEL, " cannot be found")
        stop(c)
      }
    )


  # now merge the hourly + daily (hourly data overwrites daily where dates are the same)
  p <- which(d$Date < min(h$Date))
  output <- rbind(d[p,], h)
  
  ## Now tidy the data
  ## TODO: Find a better way to do this
  output = dplyr::rename(output, `LEVEL_` = LEVEL, `FLOW_` = FLOW) 
  output = tidyr::gather(output, temp, val, -STATION_NUMBER, -Date)
  output = tidyr::separate(output, temp, c("Parameter", "key"), sep = "_", remove = TRUE)
  output = dplyr::mutate(output, key = ifelse(key=="","Value", key)) 
  output = tidyr::spread(output,key, val) 
  output = dplyr::rename(output,Code = CODE, Grade = GRADE, Symbol = SYMBOL)
  output = dplyr::select(output, STATION_NUMBER, Date, Parameter, Value, Grade, Symbol, Code)
  output = dplyr::arrange(output, Parameter, STATION_NUMBER, Date)
  output$Value = as.numeric(output$Value)
 

  
  output_c <- dplyr::bind_rows(output, output_c)
  



  }
  
  ## Now tidy the data
  ## TODO: Find a better way to do this
  #output_c = dplyr::rename(output_c, `LEVEL_` = LEVEL, `FLOW_` = FLOW) 
  #output_c = tidyr::gather(output_c, temp, val, -STATION_NUMBER, -Date)
  #output_c = tidyr::separate(output_c, temp, c("Parameter", "key"), sep = "_", remove = TRUE)
  #output_c = dplyr::mutate(output_c, key = ifelse(key=="","Value", key)) 
  #output_c = tidyr::spread(output_c,key, val) 
  #output_c = dplyr::rename(output_c,Code = CODE, Grade = GRADE, Symbol = SYMBOL)
  #output_c = dplyr::select(output_c, STATION_NUMBER, Date, Parameter, Value, Grade, Symbol, Code)
  #output_c$Value = as.numeric(output_c$Value)
  return(output_c)
}


#' @title download a tibble of active realtime stations
#' 
#' @description Returns all stations in the Realtime Water Survey of Canada hydrometric network operated by Environment and Cliamte Change Canada
#' 
#' @param PROV_TERR_STATE_LOC Province/State/Territory or Location. See examples for list of available options. Use "ALL" for all stations. 
#' 
#' @export
#' 
#' @examples
#' ## Available inputs for PROV_TERR_STATE_LOC argument:
#' unique(download_network(PROV_TERR_STATE_LOC = "ALL")$PROV_TERR_STATE_LOC)
#' 
#' download_network(PROV_TERR_STATE_LOC = "BC")
#' ## Not respecting only BC

download_network <- function(PROV_TERR_STATE_LOC){
  prov = PROV_TERR_STATE_LOC
  ## Need to implement a search by station
  #try((if(hasArg(PROV_TERR_STATE_LOC_SEL) == FALSE) stop("Stopppppte")))
  
  net_tibble <- readr::read_csv(
      "http://dd.weather.gc.ca/hydrometric/doc/hydrometric_StationList.csv",
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
  
  if((prov == "ALL")[1]){
    return(net_tibble)
  } 
  
  net_tibble = dplyr::filter(net_tibble, PROV_TERR_STATE_LOC %in% prov)
  return(net_tibble)
}

#' @title Request a token from the Environment and Climate Change Canada  
#' @param username Supplied by ECCC
#' @param password Supplied by ECCC
#' @description Request a token from the ECCC webservice using the POST method. This token expires after 10 minutes. 
#' You can only have 5 tokens out at once. 
#' 
#' @details The \code{username} and \code{password} should be treated carefully and should never be entered directly into an r script or console. 
#' Rather these credentials should be stored in your \code{.Renviron} file. The .Renviron file can edited using \code{file.edit("~/.Renviron")}. 
#' In that file, which is only stored locally and is only available to you, you can assign your \code{username} and \code{password} to variables 
#' and then call those environmental variables in your R session. See \code{?download_ws} for examples.
#' 
#' @return The token as a string that should be supplied the \code{download_ws_realtime} function.
#' 
#' @export
#' 


get_ws_token <- function(username, password){
  login <- list(
    username = username,
    password = password
  )
  r = httr::POST("https://wateroffice.ec.gc.ca/services/auth", body = login)
  
  ## If the POST request was not a successful, print out why.
  ## Possibly could provide errors as per Webservice guidelines
  httr::stop_for_status(r)
  
  message(paste0("This token will expire at ",format(Sys.time() + 10*60, "%H:%M:%S")))
  
  ## Extract token from POST
  token = httr::content(r, "text", encoding = "ISO-8859-1")
  
  return(token)
  
  
}

#' @title Download realtime data from the ECCC web service
#' @description Function to actually retrieve data from ECCC webservice. Before using this function, 
#' a token from \code{get_ws_token()} is needed.
#' @param STATION_NUMBER Water Survey of Canada station number.
#' @param parameters parameter ID. Can take multiple entries. Parameter is a numeric code. See \code{param_id} for options. Defaults to all parameters. 
#' @param start_date Need to be in YYYY-MM-DD. Defaults to 30 days before current date 
#' @param end_date Need to be in YYYY-MM-DD. Defaults to current date
#' @param token generate by \code{get_ws_token()}
#' 
#' @examples
#' \donttest{
#' token_out <- get_ws_token(username = Sys.getenv("WS_USRNM"), password = Sys.getenv("WS_PWD"))
#' 
#' ws_08 <- download_realtime(STATION_NUMBER = c("08NL071","08NM174"),
#'                          parameters = c(47, 5),
#'                          token = token_out)
#'                           
#' fivedays <- download_realtime(STATION_NUMBER = c("08NL071","08NM174"),
#'                          parameters = c(47, 5),
#'                          end_date = Sys.Date(), #today
#'                          start_date = Sys.Date() - 5, #five days ago
#'                          token = token_out)                         
#' }
#' @export


download_realtime <- function(STATION_NUMBER, parameters = c(46,16,52,47,8,5,41,18), 
                              start_date = Sys.Date()-30, end_date = Sys.Date(), token){
  if(length(STATION_NUMBER) >= 300){
    stop("Only 300 stations are supported for one request. If more stations are required, 
         a separate request should be issued to include the excess stations. This second request will 
         require an additional token.")
  }
  
  ## Check date is in the right format
  if(is.na(as.Date(start_date, format = "%Y-%m-%d"))  | is.na(as.Date(end_date, format = "%Y-%m-%d")) ){
    stop("Invalid date format. Dates need to be in YYYY-MM-DD format")
  }
  
  if(as.Date(end_date) - as.Date(start_date) > 60){
    stop("The time period of data being requested should not exceed 2 months. 
         If more data is required, then a separate request should be issued to include a different time period.")
  }
  ## English parameter names
  
  ## Is it a valid parameter name?
  
  ## Is it a valid Station name? 
  
  
  ##Build link for GET
  baseurl = "https://wateroffice.ec.gc.ca/services/real_time_data/csv/inline?"
  station_string = paste0("stations[]=", STATION_NUMBER, collapse = "&")
  parameters_string = paste0("parameters[]=", parameters, collapse = "&")
  date_string = paste0("start_date=", start_date, "%2000:00:00&end_date=", end_date,"%2023:59:59")
  token_string = paste0("token=",token)
  
  ## paste them all together
  url_for_GET = paste0(baseurl,
                       station_string,"&",
                       parameters_string,"&",
                       date_string,"&",
                       token_string)
  
  ## Get data
  get_ws = httr::GET(url_for_GET)
  
  ## Check the GET status
  httr::stop_for_status(get_ws)
  
  if (httr::headers(get_ws)$`content-type` != "text/csv; charset=utf-8"){
    stop("GET response is not a csv file")
  }
  
  ## Turn it into a tibble
  csv_df = httr::content(get_ws)
  ## Rename columns to reflect tidyhydat naming
  csv_df = dplyr::rename(csv_df, STATION_NUMBER = ID)
  csv_df = dplyr::left_join(csv_df, 
                            select(param_id, -Name_Fr),
                            by = c("Parameter")
                            )
  csv_df = dplyr::select(csv_df, STATION_NUMBER, Date, Name_En, Value, Unit, Grade, Symbol, Approval, Parameter, Code)
  
  ## What stations were missed?
  differ = setdiff(unique(STATION_NUMBER), unique(csv_df$STATION_NUMBER))
  if( length(differ) !=0 ){
    message("The following station(s) were not retrieved: ", paste0(differ, sep = " "))
    message("See ?download_realtime for possible reasons why.")
  } else{
    message("All station successfully retrieved")
  }
  
  ##Return it
  return(csv_df)
  
  ## Need to output a warning to see if any stations weren't retrieved
  }



#download_hydat <- function() {
#  url <- 'http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/'
#
#  date_string <- substr(gsub("^.*\\Hydat_sqlite3_","",
#                             RCurl::getURL(url)), 1,8)
#  
#  to_get_hydat <-paste0(url, "Hydat_sqlite3_", date_string,".zip")
#  
#  message(paste0("Proceed to this link to download a zip file of hydat", to_get_hydat))
#  
#
#  
#}
