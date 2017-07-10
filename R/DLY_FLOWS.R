#' @title Get a tidy tibble of daily flows
#' @export
#' 
#' @description Provides wrapper to turn the DLY_FLOWS table into a tidy data frame
#' 
#' @param hydat_path Directory to the hydat database
#' @param STATION_NUMBER_SEL Water Survey of Canada station number
#' 
#' @return A tibble of daily flows
#' 
#' @examples 
#' DLY_FLOWS(STATION_NUMBER = "08LA001")
#'
#' DLY_FLOWS(STATION_NUMBER = c("08LA001","08LG006"))



DLY_FLOWS <- function(hydat_path = "H:/Hydat.sqlite3", STATION_NUMBER_SEL = STATION_NUMBER) {
  
  dbname <- hydat_path
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), dbname)
  
  ## Because of a bug in dbplyr: https://github.com/tidyverse/dplyr/issues/2898
  if (length(STATION_NUMBER_SEL) == 1) {
    dly_flows = tbl(hydat_con, "DLY_FLOWS") %>%
      dplyr::filter(STATION_NUMBER == STATION_NUMBER_SEL) %>%
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
    dly_flows = tbl(hydat_con, "DLY_FLOWS") %>%
      dplyr::filter(STATION_NUMBER %in% STATION_NUMBER_SEL) %>%
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

