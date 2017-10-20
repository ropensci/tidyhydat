# Copyright 2017 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


#' Download a tibble of realtime discharge data from the MSC datamart
#'
#' Download realtime discharge data from the Meteorological Service of Canada (MSC) datamart. The function will prioritize
#' downloading data collected at the highest resolution. In instances where data is not available at high (hourly or higher) resolution
#' daily averages are used. Currently, if a station does not exist or is not found, no data is returned.
#'
#' @param STATION_NUMBER Water Survey of Canada station number. If this argument is omitted from the function call, the value of \code{PROV_TERR_STATE_LOC}
#' is returned.
#' @param PROV_TERR_STATE_LOC Province, state or territory. If this argument is omitted from the function call, the value of \code{STATION_NUMBER}
#' is returned.
#'
#' @return A tibble of water flow and level values. Time is return as UTC for consistency.
#'
#'
#' @examples
#' ## Download from multiple provinces
#' download_realtime_dd(STATION_NUMBER=c("01CD005","08MF005"))
#'
#' # To download all stations in Prince Edward Island:
#' download_realtime_dd(PROV_TERR_STATE_LOC = "PE")
#' 
#' @family realtime functions
#' @export
download_realtime_dd <- function(STATION_NUMBER = NULL, PROV_TERR_STATE_LOC) {

  ## TODO: HAve a warning message if not internet connection exists
  if (!is.null(STATION_NUMBER) && STATION_NUMBER == "ALL") {
    stop("Deprecated behaviour.Omit the STATION_NUMBER = \"ALL\" argument. See ?download_realtime_dd for examples.")
  }


  if (!is.null(STATION_NUMBER)) {
    stns <- STATION_NUMBER
    choose_df <- realtime_network_meta()
    choose_df <- dplyr::filter(choose_df, STATION_NUMBER %in% stns)
    choose_df <- dplyr::select(choose_df, STATION_NUMBER, PROV_TERR_STATE_LOC)
  }

  if (is.null(STATION_NUMBER)) {
    choose_df <- realtime_network_meta(PROV_TERR_STATE_LOC = PROV_TERR_STATE_LOC)
    choose_df <- dplyr::select(choose_df, STATION_NUMBER, PROV_TERR_STATE_LOC)
  }

  output_c <- c()
  for (i in seq_along(choose_df$STATION_NUMBER)) {
    ## Specify from choose_df
    STATION_NUMBER_SEL <- choose_df$STATION_NUMBER[i]
    PROV_SEL <- choose_df$PROV_TERR_STATE_LOC[i]


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
        "LEVEL",
        "LEVEL_GRADE",
        "LEVEL_SYMBOL",
        "LEVEL_CODE",
        "FLOW",
        "FLOW_GRADE",
        "FLOW_SYMBOL",
        "FLOW_CODE"
      )
    
    url_check <- httr::GET(infile[1])
    ## check if a valid url
    if(httr::http_error(url_check) == TRUE){
      message(paste0("No hourly data found for ",STATION_NUMBER_SEL))
      
      h <- tibble::tibble(A = STATION_NUMBER_SEL, B = NA, C = NA, D = NA, E = NA,
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
          LEVEL = readr::col_double(),
          LEVEL_GRADE = readr::col_character(),
          LEVEL_SYMBOL = readr::col_character(),
          LEVEL_CODE = readr::col_integer(),
          FLOW = readr::col_double(),
          FLOW_GRADE = readr::col_character(),
          FLOW_SYMBOL = readr::col_character(),
          FLOW_CODE = readr::col_integer()
        )
      )
    }

    # download daily file
    url_check_d <- httr::GET(infile[2])
    ## check if a valid url
    if(httr::http_error(url_check_d) == TRUE){
      message(paste0("No daily data found for ",STATION_NUMBER_SEL))
      
      d <- tibble::tibble(A = NA, B = NA, C = NA, D = NA, E = NA,
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
          LEVEL = readr::col_double(),
          LEVEL_GRADE = readr::col_character(),
          LEVEL_SYMBOL = readr::col_character(),
          LEVEL_CODE = readr::col_integer(),
          FLOW = readr::col_double(),
          FLOW_GRADE = readr::col_character(),
          FLOW_SYMBOL = readr::col_character(),
          FLOW_CODE = readr::col_integer()
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

    ## Now tidy the data
    ## TODO: Find a better way to do this
    output <- dplyr::rename(output, `LEVEL_` = LEVEL, `FLOW_` = FLOW)
    output <- tidyr::gather(output, temp, val, -STATION_NUMBER, -Date)
    output <- tidyr::separate(output, temp, c("Parameter", "key"), sep = "_", remove = TRUE)
    output <- dplyr::mutate(output, key = ifelse(key == "", "Value", key))
    output <- tidyr::spread(output, key, val)
    output <- dplyr::rename(output, Code = CODE, Grade = GRADE, Symbol = SYMBOL)
    output <- dplyr::mutate(output, PROV_TERR_STATE_LOC = PROV_SEL)
    output <- dplyr::select(output, STATION_NUMBER, PROV_TERR_STATE_LOC, Date, Parameter, Value, Grade, Symbol, Code)
    output <- dplyr::arrange(output, Parameter, STATION_NUMBER, Date)
    output$Value <- as.numeric(output$Value)



    output_c <- dplyr::bind_rows(output, output_c)
  }
  output_c
}


#' download a tibble of active realtime stations
#'
#' An up to date dataframe of all stations in the Realtime Water Survey of Canada 
#'   hydrometric network operated by Environment and Climate Change Canada
#'
#' @param PROV_TERR_STATE_LOC Province/State/Territory or Location. See examples for list of available options. 
#'   realtime_network_meta() for all stations.
#'
#' @family realtime functions
#' @export
#'
#' @examples
#' ## Available inputs for PROV_TERR_STATE_LOC argument:
#' unique(realtime_network_meta()$PROV_TERR_STATE_LOC)
#'
#' realtime_network_meta(PROV_TERR_STATE_LOC = "BC")
#' realtime_network_meta(PROV_TERR_STATE_LOC = c("QC","PE"))


realtime_network_meta <- function(PROV_TERR_STATE_LOC = NULL) {
  prov <- PROV_TERR_STATE_LOC
  ## Need to implement a search by station
  # try((if(hasArg(PROV_TERR_STATE_LOC_SEL) == FALSE) stop("Stopppppte")))

  #net_tibble <- readr::read_csv(
  #  "http://dd.weather.gc.ca/hydrometric/doc/hydrometric_StationList.csv",
  #  skip = 1,
  #  col_names = c(
  #    "STATION_NUMBER",
  #    "STATION_NAME",
  #    "LATITUDE",
  #    "LONGITUDE",
  #    "PROV_TERR_STATE_LOC",
  #    "TIMEZONE"
  #  ),
  #  col_types = readr::cols()
  #)
  
  url_check <- httr::GET("http://dd.weather.gc.ca/hydrometric/doc/hydrometric_StationList.csv")
  
  ## Checking to make sure the link is valid
  if(httr::http_error(url_check) == "TRUE"){
    stop("http://dd.weather.gc.ca/hydrometric/doc/hydrometric_StationList.csv is not a valid url. Datamart may be
         down or the url has changed.")
  }
  
  net_tibble <- httr::content(url_check,
                              type = "text/csv",
                              encoding = "UTF-8",
                              skip = 1,
                              col_names = c(
                                "STATION_NUMBER",
                                "STATION_NAME",
                                "LATITUDE",
                                "LONGITUDE",
                                "PROV_TERR_STATE_LOC",
                                "TIMEZONE"
                              ),
                              col_types = readr::cols()
                          )
  
  if (is.null(prov)) {
    return(net_tibble)
  }

  net_tibble <- dplyr::filter(net_tibble, PROV_TERR_STATE_LOC %in% prov)
  net_tibble
}

#' Request a token from the Environment and Climate Change Canada
#' @param username Supplied by ECCC
#' @param password Supplied by ECCC
#' Request a token from the ECCC web service using the POST method. This token expires after 10 minutes.
#' You can only have 5 tokens out at once.
#'
#' @details The \code{username} and \code{password} should be treated carefully and should never be entered directly into an r script or console.
#' Rather these credentials should be stored in your \code{.Renviron} file. The .Renviron file can edited using \code{file.edit("~/.Renviron")}.
#' In that file, which is only stored locally and is only available to you, you can assign your \code{username} and \code{password} to variables
#' and then call those environmental variables in your R session. See \code{?download_ws} for examples.
#'
#' @return The token as a string that should be supplied the \code{download_ws_realtime} function.
#' 
#' @example \donttest{See ?download_realtime_ws}
#' 
#' @family realtime functions
#' @export
#'


get_ws_token <- function(username, password) {
  login <- list(
    username = username,
    password = password
  )
  r <- httr::POST("https://wateroffice.ec.gc.ca/services/auth", body = login)
  
  Sys.sleep(1)

  ## If the POST request was not a successful, print out why.
  ## Possibly could provide errors as per web service guidelines
  if (httr::status_code(r) == 422) {
    stop("422 Unprocessable Entity: Username and/or password are missing or are formatted incorrectly.")
  }

  if (httr::status_code(r) == 403) {
    stop("403 Forbidden: the web service is denying your request. Try any of the following options: ensure you are not currently using all 5 tokens, 
         wait a few minutes and try again or copy the get_ws_token code and paste it directly into the console.")
  }

  ## Catch all error for anything not covered above.
  httr::stop_for_status(r)

  message(paste0("This token will expire at ", format(Sys.time() + 10 * 60, "%H:%M:%S")))

  ## Extract token from POST
  token <- httr::content(r, "text", encoding = "UTF-8")

  token
}

#' Download realtime data from the ECCC web service
#' Function to actually retrieve data from ECCC web service. Before using this function,
#' a token from \code{get_ws_token()} is needed.
#' @param STATION_NUMBER Water Survey of Canada station number.
#' @param parameters parameter ID. Can take multiple entries. Parameter is a numeric code. See \code{param_id} for options. Defaults to all parameters.
#' @param start_date Need to be in YYYY-MM-DD. Defaults to 30 days before current date
#' @param end_date Need to be in YYYY-MM-DD. Defaults to current date
#' @param token generate by \code{get_ws_token()}
#' 
#' @return Time is return as UTC for consistency.
#'
#' @examples
#' \donttest{
#' token_out <- get_ws_token(username = Sys.getenv("WS_USRNM"), password = Sys.getenv("WS_PWD"))
#'
#' ws_08 <- download_realtime_ws(STATION_NUMBER = c("08NL071","08NM174"),
#'                          parameters = c(47, 5),
#'                          token = token_out)
#'
#' fivedays <- download_realtime_ws(STATION_NUMBER = c("08NL071","08NM174"),
#'                          parameters = c(47, 5),
#'                          end_date = Sys.Date(), #today
#'                          start_date = Sys.Date() - 5, #five days ago
#'                          token = token_out)
#' }
#' @family realtime functions
#' @export


download_realtime_ws <- function(STATION_NUMBER, parameters = c(46, 16, 52, 47, 8, 5, 41, 18),
                                 start_date = Sys.Date() - 30, end_date = Sys.Date(), token) {
  if (length(STATION_NUMBER) >= 300) {
    stop("Only 300 stations are supported for one request. If more stations are required, 
         a separate request should be issued to include the excess stations. This second request will 
         require an additional token.")
  }

  ## Check date is in the right format
  if (is.na(as.Date(start_date, format = "%Y-%m-%d")) | is.na(as.Date(end_date, format = "%Y-%m-%d"))) {
    stop("Invalid date format. Dates need to be in YYYY-MM-DD format")
  }

  if (as.Date(end_date) - as.Date(start_date) > 60) {
    stop("The time period of data being requested should not exceed 2 months. 
         If more data is required, then a separate request should be issued to include a different time period.")
  }
  ## English parameter names

  ## Is it a valid parameter name?

  ## Is it a valid Station name?


  ## Build link for GET
  baseurl <- "https://wateroffice.ec.gc.ca/services/real_time_data/csv/inline?"
  station_string <- paste0("stations[]=", STATION_NUMBER, collapse = "&")
  parameters_string <- paste0("parameters[]=", parameters, collapse = "&")
  date_string <- paste0("start_date=", start_date, "%2000:00:00&end_date=", end_date, "%2023:59:59")
  token_string <- paste0("token=", token)

  ## paste them all together
  url_for_GET <- paste0(
    baseurl,
    station_string, "&",
    parameters_string, "&",
    date_string, "&",
    token_string
  )

  ## Get data
  get_ws <- httr::GET(url_for_GET)

  if (httr::status_code(get_ws) == 403) {
    stop("403 Forbidden: the web service is denying your request. Try any of the following options: wait a few minutes and try 
         again or copy the get_ws_token code and paste it directly into the console.")
  }

  ## Check the GET status
  httr::stop_for_status(get_ws)

  if (httr::headers(get_ws)$`content-type` != "text/csv; charset=utf-8") {
    stop("GET response is not a csv file")
  }

  ## Turn it into a tibble
  csv_df <- httr::content(get_ws)

  ## Check here to see if csv_df has any data in it
  if (nrow(csv_df) == 0) {
    stop("No exists for this station query")
  }

  ## Rename columns to reflect tidyhydat naming
  csv_df <- dplyr::rename(csv_df, STATION_NUMBER = ID)
  csv_df <- dplyr::left_join(
    csv_df,
    dplyr::select(param_id, -Name_Fr),
    by = c("Parameter")
  )
  csv_df <- dplyr::select(csv_df, STATION_NUMBER, Date, Name_En, Value, Unit, Grade, Symbol, Approval, Parameter, Code)

  ## What stations were missed?
  differ <- setdiff(unique(STATION_NUMBER), unique(csv_df$STATION_NUMBER))
  if (length(differ) != 0) {
    if (length(differ) <= 10) {
      message("The following station(s) were not retrieved: ", paste0(differ, sep = " "))
      message("Check station number typos or if it is a valid station in the network")
    }
    else {
      message("More than 10 stations from the initial query were not returned. Ensure realtime and active status are correctly specified.")
    }
  } else {
    message("All station successfully retrieved")
  }

  ## Return it
  csv_df

  ## Need to output a warning to see if any stations weren't retrieved
}

#' A function to download hydat
#'
#' Download the hydat sqlite database. The function will check for a existing sqlite file and stop if the same version
#' is already present. \code{download_hydat} also looks to see if you have the hydat environmental variable set.
#'
#' @param dl_hydat_here Directory to the hydat database. The hydat path can also be set in the \code{.Renviron} file so that it doesn't have to specified every function call. The path should
#' set as the variable \code{hydat}. Open the \code{.Renviron} file using this command: \code{file.edit("~/.Renviron")}.
#'
#' @export
#'
#' @examples \donttest{
#' #download_hydat()
#' }
#'

download_hydat <- function(dl_hydat_here = NULL) {
  response <- readline(prompt = "Downloading HYDAT will take approximately 10 minutes. Are you sure you want to continue? (Y/N) ")

  if (!response %in% c("Y", "Yes", "yes", "y")) {
    stop("Maybe another day...")
  }

  if (is.null(dl_hydat_here)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
  } else {
    ## Create actual hydat_path
    hydat_path <- paste0(dl_hydat_here, "Hydat.sqlite3")
    # path_to = gsub("Hydat.sqlite3", "",hydat_path)
  }



  temp <- tempfile()



  ## If there is an existing hydat file get the date of release
  if (length(list.files(dl_hydat_here, pattern = "Hydat.sqlite3")) == 1) {
    VERSION(hydat_path) %>%
      dplyr::mutate(condensed_date = paste0(
        substr(Date, 1, 4),
        substr(Date, 6, 7),
        substr(Date, 9, 10)
      )) %>%
      dplyr::pull(condensed_date) -> existing_hydat
  } else {
    existing_hydat <- "HYDAT not present"
  }


  ## Create the link to download HYDAT
  base_url <- "http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/"
  x <- httr::GET(base_url)
  new_hydat <- substr(gsub(
    "^.*\\Hydat_sqlite3_", "",
    httr::content(x, "text")
  ), 1, 8)

  ## Do we need to download a new version?
  if (new_hydat == existing_hydat) {
    stop(paste0("Existing version of hydat, published on ", lubridate::ymd(existing_hydat), ", is the most recent version available."))
  } else {
    message(paste0("Downloading version of hydat published on ", lubridate::ymd(new_hydat)))
  }

  url <- paste0(base_url, "Hydat_sqlite3_", new_hydat, ".zip")

  utils::download.file(url, temp)

  utils::unzip(temp, files = (utils::unzip(temp, list = TRUE)$Name[1]), exdir = dl_hydat_here, overwrite = TRUE)
}
