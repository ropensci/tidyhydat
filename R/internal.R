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
  
  if (!is.null(station_number) && station_number == "ALL") {
    stop("Deprecated behaviour. Omit the station_number = \"ALL\" argument", call. = FALSE)
  }
  
  sym_PROV_TERR_STATE_LOC <- sym("PROV_TERR_STATE_LOC")


  ## Only possible values for prov_terr_state_loc
  stn_option <- dplyr::tbl(hydat_con, "STATIONS") %>%
    dplyr::distinct(!!sym_PROV_TERR_STATE_LOC) %>%
    dplyr::pull(!!sym_PROV_TERR_STATE_LOC)

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
      dplyr::pull(.data$STATION_NUMBER)
  }

  if (stns[1] == "ALL") {
    
    stns <- dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::filter(!!sym_PROV_TERR_STATE_LOC %in% prov) %>%
      dplyr::pull(.data$STATION_NUMBER)
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
ask <- function(...) {
    choices <- c("Yes", "No")
    cat(crayon::green(paste0(...,"\n", collapse = "")))
    cli::cat_rule(col = "green")
    utils::menu(choices) == which(choices == "Yes")
}

## Get realtime station data - single station
single_realtime_station <- function(station_number){
  
  ## If station is provided
  if (!is.null(station_number)) {
    sym_STATION_NUMBER <- sym("STATION_NUMBER")
    
    if(any(tidyhydat::allstations$STATION_NUMBER %in% station_number)){ ## first check internal dataframe for station info
      choose_df <- dplyr::filter(tidyhydat::allstations, !!sym_STATION_NUMBER %in% station_number)
      choose_df <- dplyr::select(choose_df, .data$STATION_NUMBER, .data$PROV_TERR_STATE_LOC)
    } else{
      choose_df <- realtime_stations()
      choose_df <- dplyr::filter(choose_df, !!sym_STATION_NUMBER %in% station_number)
      choose_df <- dplyr::select(choose_df, .data$STATION_NUMBER, .data$PROV_TERR_STATE_LOC)
    }
    
  }
  
  ## Specify from choose_df
  STATION_NUMBER_SEL <- choose_df$STATION_NUMBER
  PROV_SEL <- choose_df$PROV_TERR_STATE_LOC
  
  
  base_url <- "http://dd.weather.gc.ca/hydrometric"
  
  # build URL
  type <- c("hourly", "daily")
  url <-
    sprintf("%s/csv/%s/%s", base_url, PROV_SEL, type)
  infile <-
    sprintf(
      "%s/%s_%s_%s_hydrometric.csv",
      url,
      PROV_SEL,
      STATION_NUMBER_SEL,
      type
    )
  
  # Define column names as the same as HYDAT
  colHeaders <-
    c(
      "STATION_NUMBER",
      "Date",
      "Level",
      "Level_GRADE",
      "Level_SYMBOL",
      "Level_CODE",
      "Flow",
      "Flow_GRADE",
      "Flow_SYMBOL",
      "Flow_CODE"
    )
  
  url_check <- httr::GET(infile[1])
  ## check if a valid url
  if(httr::http_error(url_check) == TRUE){
    info(paste0("No hourly data found for ",STATION_NUMBER_SEL))
    
    h <- dplyr::tibble(A = STATION_NUMBER_SEL, B = NA, C = NA, D = NA, E = NA,
                       F = NA, G = NA, H = NA, I = NA, J = NA)
    
    colnames(h) <- colHeaders
  } else{
    h <- httr::content(
      url_check,
      type = "text/csv",
      encoding = "UTF-8",
      skip = 1,
      col_names = colHeaders,
      col_types = readr::cols(
        STATION_NUMBER = readr::col_character(),
        Date = readr::col_datetime(),
        Level = readr::col_double(),
        Level_GRADE = readr::col_character(),
        Level_SYMBOL = readr::col_character(),
        Level_CODE = readr::col_integer(),
        Flow = readr::col_double(),
        Flow_GRADE = readr::col_character(),
        Flow_SYMBOL = readr::col_character(),
        Flow_CODE = readr::col_integer()
      )
    )
  }
  
  # download daily file
  url_check_d <- httr::GET(infile[2])
  ## check if a valid url
  if(httr::http_error(url_check_d) == TRUE){
    info(paste0("No daily data found for ",STATION_NUMBER_SEL))
    
    d <- dplyr::tibble(A = NA, B = NA, C = NA, D = NA, E = NA,
                       F = NA, G = NA, H = NA, I = NA, J = NA)
    colnames(d) <- colHeaders
  } else{
    d <- httr::content(
      url_check_d,
      type = "text/csv",
      encoding = "UTF-8",
      skip = 1,
      col_names = colHeaders,
      col_types = readr::cols(
        STATION_NUMBER = readr::col_character(),
        Date = readr::col_datetime(),
        Level = readr::col_double(),
        Level_GRADE = readr::col_character(),
        Level_SYMBOL = readr::col_character(),
        Level_CODE = readr::col_integer(),
        Flow = readr::col_double(),
        Flow_GRADE = readr::col_character(),
        Flow_SYMBOL = readr::col_character(),
        Flow_CODE = readr::col_integer()
      )
    )
  }
  
  
  
  # now merge the hourly + daily (hourly data overwrites daily where dates are the same)
  if(NROW(stats::na.omit(h)) == 0){
    output <- d
  } else{
    p <- which(d$Date < min(h$Date))
    output <- rbind(d[p, ], h)
  }
  
  ## Create symbols
  sym_temp <- sym("temp")
  sym_val <- sym("val")
  sym_key <- sym("key")
  
  ## Now tidy the data
  ## TODO: Find a better way to do this
  output <- dplyr::rename(output, `Level_` = .data$Level, `Flow_` = .data$Flow)
  output <- tidyr::gather(output, !!sym_temp, !!sym_val, -.data$STATION_NUMBER, -.data$Date)
  output <- tidyr::separate(output, !!sym_temp, c("Parameter", "key"), sep = "_", remove = TRUE)
  output <- dplyr::mutate(output, key = ifelse(.data$key == "", "Value", .data$key))
  output <- tidyr::spread(output, !!sym_key, !!sym_val)
  output <- dplyr::rename(output, Code = .data$CODE, Grade = .data$GRADE, Symbol = .data$SYMBOL)
  output <- dplyr::mutate(output, PROV_TERR_STATE_LOC = PROV_SEL)
  output <- dplyr::select(output, .data$STATION_NUMBER, .data$PROV_TERR_STATE_LOC, .data$Date, .data$Parameter, .data$Value,
                          .data$Grade, .data$Symbol, .data$Code)
  output <- dplyr::arrange(output, .data$Parameter, .data$STATION_NUMBER, .data$Date)
  output$Value <- as.numeric(output$Value)
  
  output
  

}
