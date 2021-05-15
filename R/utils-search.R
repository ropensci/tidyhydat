#' A search function for hydrometric station name or number
#'
#' Use this search function when you only know the partial station name or want to search.
#'
#' @param search_term Only accepts one word.
#' @inheritParams hy_agency_list
#'
#' @return A tibble of stations that match the `search_term`
#' 
#' @examples 
#' \dontrun{
#' search_stn_name("Cowichan")
#' 
#' search_stn_number("08HF")
#' }
#'
#' @export

search_stn_name <- function(search_term, hydat_path = NULL) {
  if(!has_internet()) stop("No access to internet", call. = FALSE)
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }
  
  results <- realtime_stations() %>%
    dplyr::bind_rows(suppressMessages(hy_stations(hydat_path = hydat_con))) %>%
    dplyr::distinct(.data$STATION_NUMBER, .keep_all = TRUE) %>%
    dplyr::select(.data$STATION_NUMBER, .data$STATION_NAME, .data$PROV_TERR_STATE_LOC, .data$LATITUDE, .data$LONGITUDE)
  
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
search_stn_number <- function(search_term, hydat_path = NULL) {
  if(!has_internet()) stop("No access to internet", call. = FALSE)
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }
  
  results <- realtime_stations() %>%
    dplyr::bind_rows(suppressMessages(hy_stations(hydat_path = hydat_con))) %>%
    dplyr::distinct(.data$STATION_NUMBER, .keep_all = TRUE) %>%
    dplyr::select(.data$STATION_NUMBER, .data$STATION_NAME, .data$PROV_TERR_STATE_LOC, .data$LATITUDE, .data$LONGITUDE)
  
  results <- results[grepl(toupper(search_term), results$STATION_NUMBER), ]
  
  if (nrow(results) == 0) {
    message("No station number match this criteria!")
  } else {
    results
  }
}

