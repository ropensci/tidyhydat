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
