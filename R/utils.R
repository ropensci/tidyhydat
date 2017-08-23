#' @title A search function for hydrometric station name
#' 
#' @description Use this search function when you only know the partial station name. 
#' 
#' @param search_term Only accepts one word. 
#' 
#' @return A tibble of stations that match the \code{search_term}
#' 
#' 
#' @export



search_name = function(search_term){
  
  results = tidyhydat::bcstations[grepl(toupper(search_term), tidyhydat::bcstations$STATION_NAME), ]
  
  if(nrow(results) == 0){
    message("No station names match this criteria!")
  } else{
    return(results)
  }
  
}

#' @title AGENCY_LIST function
#' 
#' @description AGENCY_LIST – AGENCY look-up Table
#' @param hydat_path Directory to the hydat database. Can be set as "Hydat.sqlite3" which will look for Hydat in the working directory 
#' 
#' @return A tibble of agencies
#' 
#' @export
#' 
AGENCY_LIST = function(hydat_path){
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  agency_list = dplyr::tbl(hydat_con, "AGENCY_LIST") %>%
    collect()
  
  DBI::dbDisconnect(hydat_con)
  
  return(agency_list)
  
}


#' @title REGIONAL_OFFICE_LIST function
#' 
#' @description REGIONAL_OFFICE_LIST – OFFICE look-up Table
#' @param hydat_path Directory to the hydat database. Can be set as "Hydat.sqlite3" which will look for Hydat in the working directory  
#' @return A tibble of offices
#' 
#' @export
#' 
REGIONAL_OFFICE_LIST = function(hydat_path){
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  regional_office_list = dplyr::tbl(hydat_con, "REGIONAL_OFFICE_LIST") %>%
    collect()
  
  DBI::dbDisconnect(hydat_con)
  
  return(regional_office_list)
  
}

#' @title DATUM_LIST function
#' 
#' @description DATUM_LIST – DATUM look-up Table
#' @param hydat_path Directory to the hydat database. Can be set as "Hydat.sqlite3" which will look for Hydat in the working directory 
#' 
#' @return A tibble of DATUMS
#' 
#' @export
#' 
DATUM_LIST = function(hydat_path){
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  datum_list = dplyr::tbl(hydat_con, "DATUM_LIST") %>%
    collect()
  
  DBI::dbDisconnect(hydat_con)
  
  return(datum_list)
  
}

