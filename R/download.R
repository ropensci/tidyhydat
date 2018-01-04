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


#' Download a tibble of realtime discharge data from the Meteorological Service of Canada datamart
#'
#' Download realtime discharge data from the Meteorological Service of Canada (MSC) datamart. The function will prioritize
#' downloading data collected at the highest resolution. In instances where data is not available at high (hourly or higher) resolution
#' daily averages are used. Currently, if a station does not exist or is not found, no data is returned.
#'
#' @param station_number Water Survey of Canada station number. If this argument is omitted from the function call, the value of \code{prov_terr_state_loc}
#' is returned.
#' @param prov_terr_state_loc Province, state or territory. If this argument is omitted from the function call, the value of \code{station_number}
#' is returned.
#'
#' @return A tibble of water flow and level values. 
#' 
#' @format A tibble with 8 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{PROV_TERR_STATE_LOC}{The province, territory or state in which the station is located}
#'   \item{Date}{Observation date and time. Formatted as a POSIXct class as UTC for consistency.}
#'   \item{Parameter}{Parameter being measured. Only possible values are Flow and Level}
#'   \item{Value}{Value of the measurement. If Parameter equals Flow the units are m^3/s. 
#'   If Parameter equals Level the units are metres.}
#'   \item{Grade}{reserved for future use}
#'   \item{Symbol}{reserved for future use}
#'   \item{Code}{quality assurance/quality control flag for the discharge}
#' }
#'
#' @examples
#' \dontrun{
#' ## Download from multiple provinces
#' realtime_dd(station_number=c("01CD005","08MF005"))
#'
#' # To download all stations in Prince Edward Island:
#' realtime_dd(prov_terr_state_loc = "PE")
#' }
#' 
#' @family realtime functions
#' @export
realtime_dd <- function(station_number = NULL, prov_terr_state_loc = NULL) {

  ## TODO: HAve a warning message if not internet connection exists
  if (!is.null(station_number) && station_number == "ALL") {
    stop("Deprecated behaviour.Omit the station_number = \"ALL\" argument. See ?realtime_dd for examples.")
  }


  if (!is.null(station_number)) {
    stns <- station_number
    choose_df <- realtime_stations()
    choose_df <- dplyr::filter(choose_df, STATION_NUMBER %in% stns)
    choose_df <- dplyr::select(choose_df, STATION_NUMBER, PROV_TERR_STATE_LOC)
  }

  if (is.null(station_number)) {
    choose_df <- realtime_stations(prov_terr_state_loc = prov_terr_state_loc)
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

    ## Now tidy the data
    ## TODO: Find a better way to do this
    output <- dplyr::rename(output, `Level_` = Level, `Flow_` = Flow)
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
  
  ## What stations were missed?
  #differ_msg(unique(stns), unique(output_c$STATION_NUMBER))
  
  output_c
}


#' Download a tibble of active realtime stations
#'
#' An up to date dataframe of all stations in the Realtime Water Survey of Canada 
#'   hydrometric network operated by Environment and Climate Change Canada
#'
#' @param prov_terr_state_loc Province/State/Territory or Location. See examples for list of available options. 
#'   realtime_stations() for all stations.
#'
#' @family realtime functions
#' 
#' @format A tibble with 6 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{STATION_NAME}{Official name for station identification}
#'   \item{LATITUDE}{North-South Coordinates of the gauging station in decimal degrees}
#'   \item{LONGITUDE}{East-West Coordinates of the gauging station in decimal degrees}
#'   \item{PROV_TERR_STATE_LOC}{The province, territory or state in which the station is located}
#'   \item{TIMEZONE}{Timezone of the station}
#' }
#' 
#' @export
#'
#' @examples
#' \dontrun{
#' ## Available inputs for prov_terr_state_loc argument:
#' unique(realtime_stations()$prov_terr_state_loc)
#'
#' realtime_stations(prov_terr_state_loc = "BC")
#' realtime_stations(prov_terr_state_loc = c("QC","PE"))
#' }


realtime_stations <- function(prov_terr_state_loc = NULL) {
  prov <- prov_terr_state_loc

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

#' Download and set the path to HYDAT
#'
#' Download the HYDAT sqlite database. This database contains all the historical hydrometric data for Canada's integrated hydrometric network.
#' The function will check for a existing sqlite file and won't download the file if the same version is already present. 

#'
#' @param dl_hydat_here Directory to the HYDAT database. The path is chosen by the \code{rappdirs} package and is OS specific and can be view by \code{hy_dir}. 
#' This path is also supplied automatically to any function that uses the HYDAT database. A user specified path can be set though this is not the advised approach. 
#' It also downloads the database to a directory specified by \code{hy_dir}.
#' @export
#'
#' @examples \dontrun{
#' download_hydat()
#' }
#'

download_hydat <- function(dl_hydat_here = NULL) {
  
  if(is.null(dl_hydat_here)){
    dl_hydat_here <- hy_dir()
  }
  
  question <- "Downloading HYDAT will take ~10 minutes and will remove any older versions of HYDAT. Do you want to continue? (Y/N)"
  response <- readline(prompt = info(question))

  if (!response %in% c("Y", "Yes", "yes", "y")) {
    handle_error(stop(not_done("Maybe another day...")))
  }
  
  done(paste0("Downloading HYDAT.sqlite3 to ", crayon::red(dl_hydat_here)))


  ## Create actual hydat_path
  hydat_path <- paste0(dl_hydat_here, "\\Hydat.sqlite3")
  
  ## temporary path to save
  temp <- tempfile()


  ## If there is an existing hydat file get the date of release
  if (file.exists(hydat_path)) {
    hy_version(hydat_path) %>%
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
  base_url <-
    "http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/"
  x <- httr::GET(base_url)
  httr::stop_for_status(x)
  new_hydat <- substr(gsub("^.*\\Hydat_sqlite3_", "",
                           httr::content(x, "text")), 1, 8)

  ## Do we need to download a new version?
  if (new_hydat == existing_hydat) {
    handle_error(stop(not_done(paste0("The existing local version of hydat, published on ",
                lubridate::ymd(existing_hydat),
                ", is the most recent version available."))))
  } else {
    done(paste0("Downloading version of HYDAT published on ", crayon::blue(lubridate::ymd(new_hydat))))
  }

  url <- paste0(base_url, "Hydat_sqlite3_", new_hydat, ".zip")
  
  ## Remove current version of HYDAT
  if (file.exists(hydat_path)){
    file.remove(hydat_path)
  }

  utils::download.file(url, temp)
  
  if(file.exists(temp)) done("Extracting HYDAT")

  utils::unzip(temp, files = (utils::unzip(temp, list = TRUE)$Name[1]), 
               exdir = dl_hydat_here, overwrite = TRUE)
  
  
  if (file.exists(hydat_path)){
    done(paste0("HYDAT successfully downloaded"))
  } else(not_done("HYDAT not successfully downloaded"))
  
  invisible(TRUE)
}
