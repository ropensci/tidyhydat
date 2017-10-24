#' STN_REMARKS function
#'
#' STN_REMARKS look-up Table
#' @inheritParams STATIONS
#'
#' @return A tibble of STN_REMARKS
#'
#' @export
#' 
#' @examples
#' \donttest{
#' STN_REMARKS(STATION_NUMBER = c("02JE013","08MF005"))
#'}
#'
STN_REMARKS <- function(STATION_NUMBER = NULL, 
                        hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"),
                        PROV_TERR_STATE_LOC = NULL) {
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)

  stn_remarks <- dplyr::tbl(hydat_con, "STN_REMARKS") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::left_join(dplyr::tbl(hydat_con, "STN_REMARK_CODES"), by = c("REMARK_TYPE_CODE")) %>%
    dplyr::select(STATION_NUMBER, REMARK_TYPE_EN, YEAR, REMARK_EN) %>%
    dplyr::collect()

  stn_remarks
}

#' STN_DATUM_CONVERSION function
#'
#' STN_DATUM_CONVERSION look-up Table
#' @inheritParams STATIONS
#'
#' @return A tibble of STN_DATUM_CONVERSION
#'
#' @export
#' @examples
#' \donttest{
#' STN_DATUM_CONVERSION(STATION_NUMBER = c("02JE013","08MF005"))
#'}
STN_DATUM_CONVERSION <- function(STATION_NUMBER = NULL, 
                                 hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"), PROV_TERR_STATE_LOC = NULL) {
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)

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

#' STN_DATUM_UNRELATED function
#'
#' STN_DATUM_UNRELATED look-up Table
#' @inheritParams STATIONS
#'
#' @return A tibble of STN_DATUM_UNRELATED
#'
#' @export
#' @examples
#' \donttest{
#' STN_DATUM_UNRELATED()
#'}
#'
STN_DATUM_UNRELATED <- function(STATION_NUMBER = NULL, 
                                hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"), PROV_TERR_STATE_LOC = NULL) {
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)
  
  stn_datum_unrelated <- dplyr::tbl(hydat_con, "STN_DATUM_UNRELATED") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect() 
  
  stn_datum_unrelated
}

#' STN_DATA_RANGE function
#'
#' STN_DATA_RANGE look-up Table
#' @inheritParams STATIONS
#'
#' @return A tibble of STN_DATA_RANGE
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \donttest{
#' STN_DATA_RANGE(STATION_NUMBER = c("02JE013","08MF005"))
#'}
#'
STN_DATA_RANGE <- function(STATION_NUMBER = NULL, 
                           hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"), 
                           PROV_TERR_STATE_LOC = NULL) {
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  
  
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  stn_data_range <- dplyr::tbl(hydat_con, "STN_DATA_RANGE") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect()
  
  stn_data_range
}

#' STN_DATA_COLLECTION function
#'
#' STN_DATA_COLLECTION look-up Table
#' @inheritParams STATIONS
#'
#' @return A tibble of STN_DATA_COLLECTION
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \donttest{
#' STN_DATA_COLLECTION(STATION_NUMBER = c("02JE013","08MF005"))
#'}
#'
STN_DATA_COLLECTION <- function(STATION_NUMBER = NULL, 
                                hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"), PROV_TERR_STATE_LOC = NULL) {
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  stn_data_range <- dplyr::tbl(hydat_con, "STN_DATA_COLLECTION") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::left_join(dplyr::tbl(hydat_con, "MEASUREMENT_CODES"), by = c("MEASUREMENT_CODE")) %>%
    dplyr::left_join(dplyr::tbl(hydat_con, "OPERATION_CODES"), by = c("OPERATION_CODE")) %>%
    dplyr::collect() %>%
    dplyr::left_join(tidyhydat::DATA_TYPES, by = c("DATA_TYPE")) %>%
    dplyr::select(STATION_NUMBER, DATA_TYPE_EN, YEAR_FROM, YEAR_TO, MEASUREMENT_EN, OPERATION_EN) %>%
    dplyr::arrange(STATION_NUMBER, YEAR_FROM)
  
  
  stn_data_range
}


#' STN_OPERATION_SCHEDULE function
#'
#' STN_OPERATION_SCHEDULE look-up Table
#' @inheritParams STATIONS
#'
#' @return A tibble of STN_OPERATION_SCHEDULE
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \donttest{
#' STN_OPERATION_SCHEDULE(STATION_NUMBER = c("02JE013"))
#'}
#'
STN_OPERATION_SCHEDULE <- function(STATION_NUMBER = NULL, 
                                   hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"), 
                                   PROV_TERR_STATE_LOC = NULL) {
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  stn_operation_schedule <- dplyr::tbl(hydat_con, "STN_OPERATION_SCHEDULE") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect() %>%
    dplyr::left_join(tidyhydat::DATA_TYPES, by = c("DATA_TYPE")) %>%
    dplyr::select(STATION_NUMBER, DATA_TYPE_EN, YEAR, MONTH_FROM, MONTH_TO)
  
  stn_operation_schedule
}
