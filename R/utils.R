#' A search function for hydrometric station name or number
#'
#' Use this search function when you only know the partial station name or want to search.
#'
#' @param search_term Only accepts one word.
#'
#' @return A tibble of stations that match the \code{search_term}
#' 
#' @examples 
#' \dontrun{
#' search_stn_name("Cowichan")
#' 
#' search_stn_number("08HF")
#' }
#'
#' @export

search_stn_name <- function(search_term) {
  
  results <- realtime_stations() %>%
    dplyr::bind_rows(suppressMessages(hy_stations())) %>%
    dplyr::distinct(STATION_NUMBER, .keep_all = TRUE) %>%
    dplyr::select(STATION_NUMBER, STATION_NAME, PROV_TERR_STATE_LOC, LATITUDE, LONGITUDE)
  
  results <- results[grepl(toupper(search_term), results$STATION_NAME), ]
  
  if (nrow(results) == 0) {
    message("No station names match this criteria!")
  } else {
    results
  }
}

#' @rdname search_stn_name
#' @export
#' 
search_stn_number <- function(search_term) {
  
  results <- realtime_stations() %>%
    dplyr::bind_rows(suppressMessages(hy_stations())) %>%
    dplyr::distinct(STATION_NUMBER, .keep_all = TRUE) %>%
    dplyr::select(STATION_NUMBER, STATION_NAME, PROV_TERR_STATE_LOC, LATITUDE, LONGITUDE)
  
  results <- results[grepl(toupper(search_term), results$STATION_NUMBER), ]
  
  if (nrow(results) == 0) {
    message("No station number match this criteria!")
  } else {
    results
  }
}

#' @title Wrapped on rappdirs::user_data_dir("tidyhydat")
#'
#' @description A function to avoid having to always type rappdirs::user_data_dir("tidyhydat")
#' 
#' @param ... arguments potentially passed to \code{rappdirs::user_data_dir}
#' 
#' @examples \dontrun{
#' hy_dir()
#' }
#'
#' @export
#'
#'
hy_dir <- function(...){
  rappdirs::user_data_dir("tidyhydat")
}

#' hy_agency_list function
#'
#' AGENCY look-up Table
#' @param hydat_path The default for this argument is to look for hydat in the same location where it
#' was saved by using \code{download_hydat}. Therefore this argument is almost always omitted from a function call. 
#' You can see where hydat was downloaded using \code{hy_dir()}
#'
#' @return A tibble of agencies
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \dontrun{
#' hy_agency_list()
#'}
#'
hy_agency_list <- function(hydat_path = NULL) {
  
  if(is.null(hydat_path)){
    hydat_path <- file.path(hy_dir(),"Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",hy_dir(),". Run download_hydat() to download the database."))
  }
  

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  agency_list <- dplyr::tbl(hydat_con, "AGENCY_LIST") %>%
    dplyr::collect()

  agency_list
}


#'  Extract regional office list from HYDAT database
#'
#'  OFFICE look-up Table
#' @inheritParams hy_agency_list
#' @return A tibble of offices
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \dontrun{
#' hy_reg_office_list()
#'}
#'
#'
hy_reg_office_list <- function(hydat_path = NULL) {
  
  if(is.null(hydat_path)){
    hydat_path <- file.path(hy_dir(),"Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",hy_dir(),". Run download_hydat() to download the database."))
  }
  

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))



  regional_office_list <- dplyr::tbl(hydat_con, "REGIONAL_OFFICE_LIST") %>%
    dplyr::collect()
  
  regional_office_list
}

#'  Extract datum list from HYDAT database
#'
#'  DATUM look-up Table
#' @inheritParams hy_agency_list
#'
#' @return A tibble of DATUMS
#'
#' @family HYDAT functions
#' @source HYDAT
#' @examples
#' \dontrun{
#' hy_datum_list()
#'}
#'
#' @export
#'
hy_datum_list <- function(hydat_path = NULL) {
  if(is.null(hydat_path)){
    hydat_path <- file.path(hy_dir(),"Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",hy_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  datum_list <- dplyr::tbl(hydat_con, "DATUM_LIST") %>%
    dplyr::collect()
  
  datum_list
}


#' Extract version number from HYDAT database
#' 
#' A function to get version number of hydat
#'
#' @inheritParams hy_agency_list
#'
#' @return version number and release date
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \dontrun{
#' hy_version()
#'}
#'
#'
hy_version <- function(hydat_path = NULL) {
  
  if(is.null(hydat_path)){
    hydat_path <- file.path(hy_dir(),"Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",hy_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  version <- dplyr::tbl(hydat_con, "VERSION") %>%
    dplyr::collect() %>%
    dplyr::mutate(Date = lubridate::ymd_hms(Date))
  
  version
  
}

#' Calculate daily means from higher resolution realtime data
#' 
#' This function is meant to be used within a pipe as a means of easily moving from higher resolution 
#' data to daily means.
#' 
#' @param .data A data argument that is designed to take only the output of realtime_dd
#' @param na.rm a logical value indicating whether NA values should be stripped before the computation proceeds.
#' 
#' @examples
#' \dontrun{
#' realtime_dd("08MF005") %>% realtime_daily_mean()
#' }
#' 
#' @export
realtime_daily_mean <- function(.data, na.rm = FALSE){
  
  .data <- dplyr::mutate(.data, Date = as.Date(Date))
  
  .data <- dplyr::group_by(.data, STATION_NUMBER, PROV_TERR_STATE_LOC, Date, Parameter)
  
  dplyr::summarise(.data, Value = mean(Value, na.rm = na.rm)) %>%
    dplyr::ungroup()
}
