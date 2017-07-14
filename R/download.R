#' @title Download a tibble of realtime network
#' 
#' @description A function to download realtime discharge data from the Water Survey of Canada datamart. Multiple stations will
#' be used. Currently, if a station does not exist or is not found, no data is returned.
#' 
#' @param STATION_NUMBER Water Survey of Canada station number. Multiple stations can inputted. See examples
#' @param PROV_TERR_STATE_LOC Jurisdiction where the station is located. Functionality is currently limited. Defaults to BC. 
#' Other jurisdictions can be used but the STATION_NUMBER argument must be located in that jurisdiction. 
#' 
#' @return A tibble of water flow and level values
#' 
#' @export
#' 
#' @note This function is heavily adapted from the RealTimeData function from the HYDAT package. 
#' That package can be viewed here: \url{https://github.com/CentreForHydrology/HYDAT}.
#' Differences between HYDAT::RealTimeData and download_realtime include
#' \itemize{
#' \item Column name outputted by download_realtime are identical to corresponding measures in HYDAT
#' \item Uses readr::read_csv and outputs a tibble
#' \item download_network is approximately 50 times faster than HYDAT::RealTimeNetwork
#' }
#' 
#' @examples
#' download_realtime(STATION_NUMBER="08MF005")
#' 
#' download_realtime(STATION_NUMBER=c("08MF005", "08NL071"))
#' 
download_realtime <- function(STATION_NUMBER, PROV_TERR_STATE_LOC="BC") {
  
  output_c <- c()
  for (i in 1:length(STATION_NUMBER) ){
    STATION_NUMBER_SEL = STATION_NUMBER[i]
  
  base_url = "http://dd.weather.gc.ca/hydrometric"
   ## Currently only implemented for BC
  
  # build URL
  type <- c("hourly", "daily")
  url <- sprintf("%s/csv/%s/%s", base_url, PROV_TERR_STATE_LOC, type)
  infile <- sprintf("%s/%s_%s_%s_hydrometric.csv", url, PROV_TERR_STATE_LOC, STATION_NUMBER_SEL, type)
  
  # Define column names as the same as HYDAT
  colHeaders <- c("STATION_NUMBER", "date_time", "LEVEL", "LEVEL_GRADE", "LEVEL_SYMBOL", "LEVEL_CODE",
                  "FLOW", "FLOW_GRADE", "FLOW_SYMBOL", "FLOW_CODE")
  
  # download hourly file
  h <- try(readr::read_csv(infile[1], skip = 1, col_names = colHeaders, col_types = readr::cols()))
  
  if(class(h)[1]=="try-error") {
    stop(sprintf("Station [%s] cannot be found within Province/Territory [%s]...url not located %s",
                 STATION_NUMBER_SEL, PROV_TERR_STATE_LOC, infile[1]))
    close(h)
  }
  
  # download daily file
  d <- try(readr::read_csv(infile[2], skip = 1, col_names = colHeaders, col_types = readr::cols()))

  # now merge the hourly + daily (hourly data overwrites daily where dates are the same)
  p <- which(d$date_time < min(h$date_time))
  output <- rbind(d[p,], h)
  
  output_c <- rbind(output, output_c)

  }
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

download_network <- function(PROV_TERR_STATE_LOC){
  ## Need to implement a search by station
  #try((if(hasArg(PROV_TERR_STATE_LOC_SEL) == FALSE) stop("Stopppppte")))
  
  net_tibble <- readr::read_csv("http://dd.weather.gc.ca/hydrometric/doc/hydrometric_StationList.csv", skip = 1,
                                col_names = c("STATION_NUMBER", "STATION_NAME", "LATITUDE", "LONGITUDE", 
                                              "PROV_TERR_STATE_LOC", "TIMEZONE"), col_types = cols())
  
  if((PROV_TERR_STATE_LOC == "ALL")[1]){
    return(net_tibble)
  } 
  
  net_tibble = filter(net_tibble, PROV_TERR_STATE_LOC %in% PROV_TERR_STATE_LOC)
  return(net_tibble)
}
