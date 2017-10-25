#' hy_stn_remarks function
#'
#' hy_stn_remarks look-up Table
#' @inheritParams hy_stations
#'
#' @return A tibble of hy_stn_remarks
#'
#' @export
#' 
#' @examples
#' \donttest{
#' hy_stn_remarks(station_number = c("02JE013","08MF005"))
#'}
#'
hy_stn_remarks <- function(station_number = NULL, 
                        hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"),
                        prov_terr_state_loc = NULL) {
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
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

#' hy_stn_datum_conv function
#'
#' hy_stn_datum_conv look-up Table
#' @inheritParams hy_stations
#'
#' @return A tibble of hy_stn_datum_conv
#'
#' @export
#' @examples
#' \donttest{
#' hy_stn_datum_conv(station_number = c("02JE013","08MF005"))
#'}
hy_stn_datum_conv <- function(station_number = NULL, 
                                 hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"), prov_terr_state_loc = NULL) {
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
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

#' hy_stn_datum_unrelated function
#'
#' hy_stn_datum_unrelated look-up Table
#' @inheritParams hy_stations
#'
#' @return A tibble of hy_stn_datum_unrelated
#'
#' @export
#' @examples
#' \donttest{
#' hy_stn_datum_unrelated()
#'}
#'
hy_stn_datum_unrelated <- function(station_number = NULL, 
                                hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"), prov_terr_state_loc = NULL) {
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
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

#' hy_stn_data_range function
#'
#' hy_stn_data_range look-up Table
#' @inheritParams hy_stations
#'
#' @return A tibble of hy_stn_data_range
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \donttest{
#' hy_stn_data_range(station_number = c("02JE013","08MF005"))
#'}
#'
hy_stn_data_range <- function(station_number = NULL, 
                           hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"), 
                           prov_terr_state_loc = NULL) {
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
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

#' hy_stn_data_coll function
#'
#' hy_stn_data_coll look-up Table
#' @inheritParams hy_stations
#'
#' @return A tibble of hy_stn_data_coll
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \donttest{
#' hy_stn_data_coll(station_number = c("02JE013","08MF005"))
#'}
#'
hy_stn_data_coll <- function(station_number = NULL, 
                                hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"), prov_terr_state_loc = NULL) {
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  stn_data_range <- dplyr::tbl(hydat_con, "STN_DATA_COLLECTION") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::left_join(dplyr::tbl(hydat_con, "MEASUREMENT_CODES"), by = c("MEASUREMENT_CODE")) %>%
    dplyr::left_join(dplyr::tbl(hydat_con, "OPERATION_CODES"), by = c("OPERATION_CODE")) %>%
    dplyr::collect() %>%
    dplyr::left_join(tidyhydat::data_types, by = c("DATA_TYPE")) %>%
    dplyr::select(STATION_NUMBER, DATA_TYPE_EN, YEAR_FROM, YEAR_TO, MEASUREMENT_EN, OPERATION_EN) %>%
    dplyr::arrange(STATION_NUMBER, YEAR_FROM)
  
  
  stn_data_range
}


#' hy_stn_op_schedule function
#'
#' hy_stn_op_schedule look-up Table
#' @inheritParams hy_stations
#'
#' @return A tibble of hy_stn_op_schedule
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \donttest{
#' hy_stn_op_schedule(station_number = c("02JE013"))
#'}
#'
hy_stn_op_schedule <- function(station_number = NULL, 
                                   hydat_path = paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"), 
                                   prov_terr_state_loc = NULL) {
  
  ## Check if hydat is present
  if (!file.exists(hydat_path)){
    stop(paste0("No Hydat.sqlite3 found at ",rappdirs::user_data_dir(),". Run download_hydat() to download the database."))
  }
  
  
  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  on.exit(DBI::dbDisconnect(hydat_con))
  
  stn_operation_schedule <- dplyr::tbl(hydat_con, "STN_OPERATION_SCHEDULE") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect() %>%
    dplyr::left_join(tidyhydat::data_types, by = c("DATA_TYPE")) %>%
    dplyr::select(STATION_NUMBER, DATA_TYPE_EN, YEAR, MONTH_FROM, MONTH_TO)
  
  stn_operation_schedule
}
