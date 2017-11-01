#' Extract station remarks from HYDAT database
#'
#' hy_stn_remarks look-up Table
#' @inheritParams hy_stations
#'
#' @return A tibble of hy_stn_remarks
#' 
#' @format A tibble with 4 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{REMARK_TYPE_EN}{Type of Remark}
#'   \item{YEAR}{Year of the remark}
#'   \item{REMARK_EN}{Remark}
#' }
#'
#' @export
#' 
#' @examples
#' \dontrun{
#' hy_stn_remarks(station_number = c("02JE013","08MF005"))
#'}
#'
hy_stn_remarks <- function(station_number = NULL, 
                        hydat_path = NULL,
                        prov_terr_state_loc = NULL) {
  if(is.null(hydat_path)){
    hydat_path <- paste0(hy_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",hy_dir(),". Run download_hydat() to download the database."))
  }
  

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)

  stn_remarks <- dplyr::tbl(hydat_con, "STN_REMARKS") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::left_join(dplyr::tbl(hydat_con, "STN_REMARK_CODES"), by = c("REMARK_TYPE_CODE")) %>%
    dplyr::select(STATION_NUMBER, REMARK_TYPE_EN, YEAR, REMARK_EN) %>%
    dplyr::collect()

  stn_remarks
}

#' Extract station datum conversions from HYDAT database
#'
#' hy_stn_datum_conv look-up Table
#' @inheritParams hy_stations
#'
#' @return A tibble of hy_stn_datum_conv
#' 
#' @format A tibble with 4 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{DATUM_EN_FROM}{Identifying a datum from which water level is being converted}
#'   \item{DATUM_EN_TO}{Identifying a datum to which water level is being converted}
#'   \item{CONVERSTION_FACTOR}{The conversion factor applied to water levels referred to 
#'   one datum to obtain water levels referred to another datum}
#' }
#'
#'
#' @export
#' @examples
#' \dontrun{
#' hy_stn_datum_conv(station_number = c("02JE013","08MF005"))
#'}
hy_stn_datum_conv <- function(station_number = NULL, 
                                 hydat_path = NULL, prov_terr_state_loc = NULL) {
  if(is.null(hydat_path)){
    hydat_path <- paste0(hy_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",hy_dir(),". Run download_hydat() to download the database."))
  }
  

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)

  stn_datum_conversion <- dplyr::tbl(hydat_con, "STN_DATUM_CONVERSION") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::left_join(dplyr::tbl(hydat_con, "DATUM_LIST"), by = c("DATUM_ID_FROM" = "DATUM_ID")) %>%
    dplyr::rename(DATUM_EN_FROM = DATUM_EN) %>%
    dplyr::left_join(dplyr::tbl(hydat_con, "DATUM_LIST"), by = c("DATUM_ID_TO" = "DATUM_ID")) %>%
    dplyr::rename(DATUM_EN_TO = DATUM_EN) %>%
    dplyr::select(STATION_NUMBER, DATUM_EN_FROM, DATUM_EN_TO, CONVERSION_FACTOR) %>%
    dplyr::collect()

  stn_datum_conversion
}

#' Extract station datum unrelated from HYDAT database
#'
#' hy_stn_datum_unrelated look-up Table
#' @inheritParams hy_stations
#'
#' @return A tibble of hy_stn_datum_unrelated
#' 
#' @format A tibble with 4 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{DATUM_ID}{Unique code identifying a datum}
#'   \item{YEAR_FROM}{First year of use}
#'   \item{YEAR_TO}{Last year of use}
#' } 
#'
#' @export
#' @examples
#' \dontrun{
#' hy_stn_datum_unrelated()
#'}
#'
hy_stn_datum_unrelated <- function(station_number = NULL, 
                                hydat_path = NULL, prov_terr_state_loc = NULL) {
  if(is.null(hydat_path)){
    hydat_path <- paste0(hy_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",hy_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  stn_datum_unrelated <- dplyr::tbl(hydat_con, "STN_DATUM_UNRELATED") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect() 
  
  stn_datum_unrelated
}

#' Extract station data range from HYDAT database
#'
#' hy_stn_data_range look-up Table
#' @inheritParams hy_stations
#'
#' @return A tibble of hy_stn_data_range
#'
#' @format A tibble with 6 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{DATA_TYPE}{Code for the type of data}
#'   \item{SED_DATA_TYPE}{Code for the type of instantaneous sediment data}
#'   \item{YEAR_FROM}{First year of use}
#'   \item{YEAR_TO}{Last year of use}
#'   \item{RECORD_LENGTH}{Number of years of data available in the HYDAT database}
#' }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \dontrun{
#' hy_stn_data_range(station_number = c("02JE013","08MF005"))
#'}
#'
hy_stn_data_range <- function(station_number = NULL, 
                           hydat_path = NULL, 
                           prov_terr_state_loc = NULL) {
  
  if(is.null(hydat_path)){
    hydat_path <- paste0(hy_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",hy_dir(),". Run download_hydat() to download the database."))
  }
  
  
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  stn_data_range <- dplyr::tbl(hydat_con, "STN_DATA_RANGE") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect()
  
  stn_data_range
}

#' Extract station data collection from HYDAT database
#'
#' hy_stn_data_coll look-up Table
#' @inheritParams hy_stations
#'
#' @return A tibble of hy_stn_data_coll
#' 
#' @format A tibble with 6 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{DATA_TYPE_EN}{The type of data}
#'   \item{YEAR_FROM}{First year of use}
#'   \item{YEAR_TO}{Last year of use}
#'   \item{MEASUREMENT_CODE_EN}{Either 1) the sampling method used in the collection of 
#'   sediment data or 2) the type of the gauge used in the collection of the hydrometric data}
#'   \item{OPERATION_CODE_EN}{The schedule of station operation 
#'   for the collection of sediment or hydrometric data}
#' }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \dontrun{
#' hy_stn_data_coll(station_number = c("02JE013","08MF005"))
#'}
#'
hy_stn_data_coll <- function(station_number = NULL, 
                                hydat_path = NULL, prov_terr_state_loc = NULL) {
  
  if(is.null(hydat_path)){
    hydat_path <- paste0(hy_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",hy_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  stn_data_coll <- dplyr::tbl(hydat_con, "STN_DATA_COLLECTION") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::left_join(dplyr::tbl(hydat_con, "MEASUREMENT_CODES"), by = c("MEASUREMENT_CODE")) %>%
    dplyr::left_join(dplyr::tbl(hydat_con, "OPERATION_CODES"), by = c("OPERATION_CODE")) %>%
    dplyr::collect() %>%
    dplyr::left_join(tidyhydat::hy_data_types, by = c("DATA_TYPE")) %>%
    dplyr::select(STATION_NUMBER, DATA_TYPE_EN, YEAR_FROM, YEAR_TO, MEASUREMENT_EN, OPERATION_EN) %>%
    dplyr::arrange(STATION_NUMBER, YEAR_FROM)
  
  
  stn_data_coll
}


#' Extract station operation schedule from HYDAT database
#'
#' hy_stn_op_schedule look-up Table
#' @inheritParams hy_stations
#'
#' @return A tibble of hy_stn_op_schedule
#' 
#' @format A tibble with 6 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{DATA_TYPE_EN}{The type of data}
#'   \item{YEAR}{Year of operation schedule}
#'   \item{MONTH_FROM}{First month of use}
#'   \item{MONTH_TO}{Last month of use}
#' }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \dontrun{
#' hy_stn_op_schedule(station_number = c("02JE013"))
#'}
#'
hy_stn_op_schedule <- function(station_number = NULL, 
                                   hydat_path = NULL, 
                                   prov_terr_state_loc = NULL) {
  
  if(is.null(hydat_path)){
    hydat_path <- paste0(hy_dir(),"\\Hydat.sqlite3")
  }
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",hy_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  stn_operation_schedule <- dplyr::tbl(hydat_con, "STN_OPERATION_SCHEDULE") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect() %>%
    dplyr::left_join(tidyhydat::hy_data_types, by = c("DATA_TYPE")) %>%
    dplyr::select(STATION_NUMBER, DATA_TYPE_EN, YEAR, MONTH_FROM, MONTH_TO)
  
  stn_operation_schedule
}
