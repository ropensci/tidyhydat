#' @title Get a tidy tibble of daily flows
#' @export
#' 
#' @description Provides wrapper to turn the DLY_FLOWS table into a tidy tibble
#' 
#' @param hydat_path Directory to the hydat database
#' @param STATION_NUMBER Water Survey of Canada station number. No default. Can also take the "ALL" argument if all stations in BC are requested.
#' 
#' @return A tibble of daily flows
#' 
#' @examples 
#' DLY_FLOWS(STATION_NUMBER = "08LA001")
#'
#' DLY_FLOWS(STATION_NUMBER = c("08LA001","08LG006"))



DLY_FLOWS <- function(hydat_path = "H:/Hydat.sqlite3", STATION_NUMBER) {
  stns = STATION_NUMBER
  STATION_NUMBER = NULL
  
  dbname <- hydat_path
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), dbname)
  
  if(stns[1] == "ALL"){
    stns = dplyr::tbl(hydat_con, "STATIONS") %>%
      filter(PROV_TERR_STATE_LOC == "BC") %>%
      pull(STATION_NUMBER)
  }
  
  ## Because of a bug in dbplyr: https://github.com/tidyverse/dplyr/issues/2898
  if (length(stns) == 1 & stns[1] != "ALL") {
    dly_flows = dplyr::tbl(hydat_con, "DLY_FLOWS") %>%
      dplyr::filter(STATION_NUMBER == stns) %>%
      dplyr::group_by(STATION_NUMBER) %>%
      dplyr::select_if(is.numeric) %>% ## select only numeric data
      dplyr::select(-(FULL_MONTH:MAX)) %>% ## Only columns we need
      dplyr::collect() %>% ## the end of the road for sqlite in this pipe
      tidyr::gather(DAY, FLOW, -(STATION_NUMBER:MONTH)) %>%
      dplyr::mutate(DAY = as.numeric(gsub("FLOW","", DAY))) %>% ##Extract day number
      dplyr::mutate(Date = lubridate::ymd(paste0(YEAR,"-",MONTH,"-",DAY))) %>% ##convert into R date. Failure to parse from invalid #days/motnh
      dplyr::select(STATION_NUMBER, FLOW, Date) %>%
      dplyr::filter(!is.na(Date)) %>%
      tibble::as_tibble()
    
    return(dly_flows)
  } else {
    dly_flows = dplyr::tbl(hydat_con, "DLY_FLOWS") %>%
      dplyr::filter(STATION_NUMBER %in% stns) %>%
      dplyr::group_by(STATION_NUMBER) %>%
      dplyr::select_if(is.numeric) %>% ## select only numeric data
      dplyr::select(-(FULL_MONTH:MAX)) %>% ## Only columns we need
      dplyr::collect() %>% ## the end of the road for sqlite in this pipe
      tidyr::gather(DAY, FLOW, -(STATION_NUMBER:MONTH)) %>%
      dplyr::mutate(DAY = as.numeric(gsub("FLOW","", DAY))) %>% ##Extract day number
      dplyr::mutate(Date = lubridate::ymd(paste0(YEAR,"-",MONTH,"-",DAY))) %>% ##convert into R date. Failure to parse from invalid #days/motnh
      dplyr::select(STATION_NUMBER, FLOW, Date) %>%
      dplyr::filter(!is.na(Date)) %>%
      tibble::as_tibble()
    
    return(dly_flows)
  }
  
  DBI::dbDisconnect()
}

