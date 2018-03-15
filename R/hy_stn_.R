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
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con))
  }

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  ## Creating rlang symbols
  sym_STATION_NUMBER <- sym("STATION_NUMBER")

  stn_remarks <- dplyr::tbl(hydat_con, "STN_REMARKS") 
  stn_remarks <- dplyr::filter(stn_remarks, !!sym_STATION_NUMBER %in% stns)
  stn_remarks <- dplyr::left_join(stn_remarks, dplyr::tbl(hydat_con, "STN_REMARK_CODES"), by = c("REMARK_TYPE_CODE"))
  stn_remarks <- dplyr::select(stn_remarks, .data$STATION_NUMBER, .data$REMARK_TYPE_EN, .data$YEAR, .data$REMARK_EN)
  
  dplyr::collect(stn_remarks)
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
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con))
  }

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  ## Creating rlang symbols
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  sym_DATUM_EN <- sym("DATUM_EN")

  stn_datum_conversion <- dplyr::tbl(hydat_con, "STN_DATUM_CONVERSION") 
  stn_datum_conversion <- dplyr::filter(stn_datum_conversion, !!sym_STATION_NUMBER %in% stns)
  stn_datum_conversion <- dplyr::left_join(stn_datum_conversion, dplyr::tbl(hydat_con, "DATUM_LIST"), by = c("DATUM_ID_FROM" = "DATUM_ID"))
  stn_datum_conversion <- dplyr::rename(stn_datum_conversion, DATUM_EN_FROM = !!sym_DATUM_EN)
  stn_datum_conversion <- dplyr::left_join(stn_datum_conversion, dplyr::tbl(hydat_con, "DATUM_LIST"), by = c("DATUM_ID_TO" = "DATUM_ID"))
  stn_datum_conversion <- dplyr::rename(stn_datum_conversion, DATUM_EN_TO = !!sym_DATUM_EN)
  stn_datum_conversion <- dplyr::select(stn_datum_conversion, .data$STATION_NUMBER, .data$DATUM_EN_FROM, .data$DATUM_EN_TO, .data$CONVERSION_FACTOR)
  
  dplyr::collect(stn_datum_conversion)
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
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con))
  }
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  ## Creating rlang symbols
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  
  stn_datum_unrelated <- dplyr::tbl(hydat_con, "STN_DATUM_UNRELATED")
  stn_datum_unrelated <- dplyr::filter(stn_datum_unrelated, !!sym_STATION_NUMBER %in% stns)
    
  dplyr::collect(stn_datum_unrelated) 
  
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
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con))
  }
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  ## Creating rlang symbols
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  
  stn_data_range <- dplyr::tbl(hydat_con, "STN_DATA_RANGE")
  stn_data_range <- dplyr::filter(stn_data_range, !!sym_STATION_NUMBER %in% stns)
    
  dplyr::collect(stn_data_range)
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
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con))
  }
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  ## Creating rlang symbols
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  
  stn_data_coll <- dplyr::tbl(hydat_con, "STN_DATA_COLLECTION")
  stn_data_coll <- dplyr::filter(stn_data_coll, !!sym_STATION_NUMBER %in% stns)
  stn_data_coll <- dplyr::left_join(stn_data_coll, dplyr::tbl(hydat_con, "MEASUREMENT_CODES"), by = c("MEASUREMENT_CODE"))
  stn_data_coll <- dplyr::left_join(stn_data_coll, dplyr::tbl(hydat_con, "OPERATION_CODES"), by = c("OPERATION_CODE"))
  stn_data_coll <- dplyr::collect(stn_data_coll)
  
  stn_data_coll <- dplyr::left_join(stn_data_coll, tidyhydat::hy_data_types, by = c("DATA_TYPE"))
  stn_data_coll <- dplyr::select(stn_data_coll, .data$STATION_NUMBER, .data$DATA_TYPE_EN, .data$YEAR_FROM, .data$YEAR_TO, 
                  .data$MEASUREMENT_EN, .data$OPERATION_EN)
  dplyr::arrange(stn_data_coll, .data$STATION_NUMBER, .data$YEAR_FROM)
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
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con))
  }
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  ## Creating rlang symbols
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  
  stn_operation_schedule <- dplyr::tbl(hydat_con, "STN_OPERATION_SCHEDULE")
  stn_operation_schedule <- dplyr::filter(stn_operation_schedule, !!sym_STATION_NUMBER %in% stns)
  stn_operation_schedule <- dplyr::collect(stn_operation_schedule)
  stn_operation_schedule <- dplyr::left_join(stn_operation_schedule, tidyhydat::hy_data_types, by = c("DATA_TYPE"))
  
  dplyr::select(stn_operation_schedule, .data$STATION_NUMBER, .data$DATA_TYPE_EN, .data$YEAR, .data$MONTH_FROM, .data$MONTH_TO)
}
