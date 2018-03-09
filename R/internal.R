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


  ## Only possible values for prov_terr_state_loc
  stn_option <- dplyr::tbl(hydat_con, "STATIONS") %>%
    dplyr::distinct(PROV_TERR_STATE_LOC) %>%
    dplyr::pull(PROV_TERR_STATE_LOC)

  ## If not station_number arg is supplied then this controls how to handle the PROV arg
  if ((is.null(station_number) & !is.null(prov_terr_state_loc))) {
    station_number <- "ALL" ## All stations
    prov <- prov_terr_state_loc ## Prov info

    if (any(!prov %in% stn_option) == TRUE) {
      stop("Invalid prov_terr_state_loc value")
    }
  }

  ## If PROV arg is supplied then simply use the station_number independent of PROV
  if (is.null(prov_terr_state_loc)) {
    station_number <- station_number
  }


  ## Steps to create the station vector
  stns <- station_number

  ## Get all stations
  if (is.null(stns) == TRUE && is.null(prov_terr_state_loc) == TRUE) {
    stns <- dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::collect() %>%
      dplyr::pull(STATION_NUMBER)
  }
  stns
}


## Simple error handler
handle_error <- function(code) {
  tryCatch(code, error = function(c) {
    msg <- conditionMessage(c)
    invisible(structure(msg, class = "try-error"))
  })
}

## Differ message for all the hy_* functions
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
  
  flow_stns <- data_arg %>%
    dplyr::filter(Parameter == params) %>%
    dplyr::distinct(STATION_NUMBER) %>%
    dplyr::arrange(STATION_NUMBER) %>%
    dplyr::pull(STATION_NUMBER)
  
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
ask <- function(...) {
    choices <- c("Yes", "No")
    cat(crayon::green(paste0(...,"\n", collapse = "")))
    cli::cat_rule(col = "green")
    utils::menu(choices) == which(choices == "Yes")
}

