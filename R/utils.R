#' A search function for hydrometric station name or number
#'
#' Use this search function when you only know the partial station name or want to search.
#'
#' @param search_term Only accepts one word.
#'
#' @return A tibble of stations that match the \code{search_term}
#' 
#' @examples 
#' search_stn_name("Cowichan")
#' 
#' search_stn_number("08HF")
#'
#' @export

search_stn_name <- function(search_term) {
  
  results <- tidyhydat::allstations[grepl(toupper(search_term), tidyhydat::allstations$STATION_NAME), ]

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
  results <- tidyhydat::allstations[grepl(toupper(search_term), tidyhydat::allstations$station_number), ]
  
  if (nrow(results) == 0) {
    message("No station number match this criteria!")
  } else {
    results
  }
}

#' hy_agency_list function
#'
#' AGENCY look-up Table
#' @param hydat_path The default for this argument is to look for hydat in the same location where it
#' was saved by using \code{download_hydat}. Therefore this argument is almost always omitted from a function call. 
#' You can see where hydat was downloaded using \code{rappdirs::user_data_dir()}
#'
#' @return A tibble of agencies
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \donttest{
#' hy_agency_list()
#'}
#'
hy_agency_list <- function(hydat_path = NULL) {
  
  if(is.null(hydat_path)){
    hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  agency_list <- dplyr::tbl(hydat_con, "AGENCY_LIST") %>%
    dplyr::collect()

  agency_list
}


#'  hy_reg_office_list function
#'
#'  OFFICE look-up Table
#' @inheritParams hy_agency_list
#' @return A tibble of offices
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \donttest{
#' hy_reg_office_list()
#'}
#'
#'
hy_reg_office_list <- function(hydat_path = NULL) {
  
  if(is.null(hydat_path)){
    hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))



  regional_office_list <- dplyr::tbl(hydat_con, "REGIONAL_OFFICE_LIST") %>%
    dplyr::collect()
  
  regional_office_list
}

#'  hy_datum_list function
#'
#'  DATUM look-up Table
#' @inheritParams hy_agency_list
#'
#' @return A tibble of DATUMS
#'
#' @family HYDAT functions
#' @source HYDAT
#' @examples
#' \donttest{
#' hy_datum_list()
#'}
#'
#' @export
#'
hy_datum_list <- function(hydat_path = NULL) {
  if(is.null(hydat_path)){
    hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  datum_list <- dplyr::tbl(hydat_con, "DATUM_LIST") %>%
    dplyr::collect()
  
  datum_list
}


#' Version number of HYDAT
#' A function to get version number of hydat
#'
#' @inheritParams hy_agency_list
#'
#' @return version number
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \donttest{
#' hy_version()
#'}
#'
#'
hy_version <- function(hydat_path = NULL) {
  
  if(is.null(hydat_path)){
    hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  version <- dplyr::tbl(hydat_con, "VERSION") %>%
    dplyr::collect() %>%
    dplyr::mutate(Date = lubridate::ymd_hms(Date))
  
  version
  
}
