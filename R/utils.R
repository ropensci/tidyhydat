#' @title Function to chose a station based on consistent arguments for hydat functions.
#'
#' @description A function to avoid duplication in HYDAT functions.  This function is not intended for external use.
#'
#' @inheritParams hy_stations
#' @param hydat_con A database connection
#'
#' @keywords internal
#'
#'
station_choice <- function(hydat_con, station_number, prov_terr_state_loc) {
  
  if (!is.null(station_number) && !is.null(prov_terr_state_loc)) {
    stop("Only specify one of station_number or prov_terr_state_loc.", call. = FALSE)
  }

  
  ### Is station_number 7 characters?
  #if(!is.null(station_number) & (nchar(station_number) != 7)) {
  #  stop("")
  #}

  
  ## Prov symbol
  sym_PROV_TERR_STATE_LOC <- sym("PROV_TERR_STATE_LOC")

  
  ## Get all stations
  if (is.null(station_number) && is.null(prov_terr_state_loc)) {
    stns <- dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::collect() %>%
      dplyr::pull(.data$STATION_NUMBER)
    return(stns)
  }
  
  ## When a station number is supplied but no province
  if (!is.null(station_number)){
    ## Convert to upper case
    stns <- toupper(station_number)
    return(stns)
  }
  
  ## When a province is supplied but no station number
  if (!is.null(prov_terr_state_loc)){
    prov_terr_state_loc <- toupper(prov_terr_state_loc)
    ## Only possible values for prov_terr_state_loc
    stn_option <- dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::distinct(!!sym_PROV_TERR_STATE_LOC) %>%
      dplyr::pull(!!sym_PROV_TERR_STATE_LOC)
    
    if (any(!prov_terr_state_loc %in% stn_option) == TRUE)  stop("Invalid prov_terr_state_loc value")
    
    stns <- dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::filter(!!sym_PROV_TERR_STATE_LOC %in% prov_terr_state_loc) %>%
      dplyr::collect() %>%
      dplyr::pull(.data$STATION_NUMBER)
    stns
    
  }


}


## Deal with date choice and formatting
#' @noRd
#' 
date_check <- function(start_date = NULL, end_date = NULL){
  
  start_is_null <- is.null(start_date) 
  end_is_null <- is.null(end_date)
  
  
  if (start_is_null & end_is_null) {
    message("No start and end dates specified. All dates available will be returned.")
    
  }
  
  ## Check date is in the right format TODO
  if (!is.null(start_date)) {
    if(!grepl('[0-9]{4}-[0-1][0-9]-[0-3][0-9]', start_date)) stop("Invalid date format. start_date need to be in YYYY-MM-DD format", call. = FALSE)
  }
  
  if (!is.null(end_date)) {
    if(!grepl('[0-9]{4}-[0-1][0-9]-[0-3][0-9]', end_date)) stop("Invalid date format. end_date need to be in YYYY-MM-DD format", call. = FALSE)
  }
  
  if(!is.null(start_date) & !is.null(end_date)){
    if (lubridate::ymd(end_date) < lubridate::ymd(start_date)) stop("start_date is after end_date. Try swapping values.", call. = FALSE)
  }

  
  invisible(list(start_is_null = start_is_null, end_is_null = end_is_null))
}

#' @importFrom dplyr %>%
#' @export
dplyr::`%>%`


## Simple error handler
#' @noRd
handle_error <- function(code) {
  tryCatch(code, error = function(c) {
    msg <- conditionMessage(c)
    invisible(structure(msg, class = "try-error"))
  })
}

## Differ message for all the hy_* functions
#' @noRd
differ_msg <- function(stns_input, stns_output) {
  differ <- setdiff(stns_input, stns_output)
  if (length(differ) != 0) {
    if (length(differ) <= 10) {
      message("The following station(s) were not retrieved: ",
              paste0(differ, sep = " "))
      message("Check station number typos or if it is a valid station in the network")
    }
    else {
      message(
        "More than 10 stations from the initial query were not returned. Ensure realtime and active status are correctly specified."
      )
    }
  } else {
    message("All station successfully retrieved")
  }
  
}


## Multi parameter message
#' @noRd
multi_param_msg <- function(data_arg, stns, params) {
  cli::cat_line(cli::rule(
    left = crayon::bold(params)
  ))
  
  ## Is the data anything other than a tibble?
  if(class(data_arg)[1] != "tbl_df"){
    return(
      cli::cat_line(paste0(crayon::red(cli::symbol$cross)," ", stns, collapse = "\n"))
      )
  }
  
  sym_Parameter <- sym("Parameter")
  
  flow_stns <- data_arg %>%
    dplyr::filter(!!sym_Parameter == params) %>%
    dplyr::distinct(.data$STATION_NUMBER) %>%
    dplyr::arrange(.data$STATION_NUMBER) %>%
    dplyr::pull(.data$STATION_NUMBER)
  
  good_stns <- c()
  if(length(flow_stns) > 0L){
    good_stns <- paste0(crayon::green(cli::symbol$tick)," ", flow_stns, collapse = "\n")
  }
  
  ## Station not in output
  not_in <- setdiff(stns,flow_stns)
  
  bad_stns <- c()
  if(length(not_in) > 0L){
    bad_stns <- paste0(crayon::red(cli::symbol$cross)," ", not_in, collapse = "\n")
  }
  
  cli::cat_line(paste0(good_stns, "\n", bad_stns))
  

}

## Ask for something
#' @noRd
ask <- function(...) {
    choices <- c("Yes", "No")
    cat(crayon::green(paste0(...,"\n", collapse = "")))
    cli::cat_rule(col = "green")
    utils::menu(choices) == which(choices == "Yes")
}

# Deal with proxy-related connection issues
#' @noRd
network_check <- function(url){
  tryCatch(httr::GET(base_url),
           error = function(e){
             if(grepl("Timeout was reached:", e$message))
               stop("Could not connect to HYDAT source. Check your connection settings.", 
                    call. = FALSE
               )}
  )}

