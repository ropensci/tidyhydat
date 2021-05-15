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
#'   \item{REMARK_TYPE}{Type of Remark}
#'   \item{Year}{Year of the remark}
#'   \item{REMARK}{Remark}
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
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  ## Creating rlang symbols
  sym_STATION_NUMBER <- sym("STATION_NUMBER")

  stn_remarks <- dplyr::tbl(hydat_con, "STN_REMARKS") 
  stn_remarks <- dplyr::filter(stn_remarks, !!sym_STATION_NUMBER %in% stns)
  stn_remarks <- dplyr::left_join(stn_remarks, dplyr::tbl(hydat_con, "STN_REMARK_CODES"), by = c("REMARK_TYPE_CODE"))
  stn_remarks <- dplyr::select(stn_remarks, .data$STATION_NUMBER, 
                               REMARK_TYPE = .data$REMARK_TYPE_EN, Year = .data$YEAR, REMARK = .data$REMARK_EN)
  
  stn_remarks <- dplyr::collect(stn_remarks)  
  
  attr(stn_remarks,'missed_stns') <- setdiff(unique(stns), unique(stn_remarks$STATION_NUMBER))
  as.hy(stn_remarks)
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
#'   \item{DATUM_FROM}{Identifying a datum from which water level is being converted}
#'   \item{DATUM_TO}{Identifying a datum to which water level is being converted}
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
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
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
  stn_datum_conversion <- dplyr::select(stn_datum_conversion, .data$STATION_NUMBER, 
                                        DATUM_FROM = .data$DATUM_EN_FROM, 
                                        DATUM_TO = .data$DATUM_EN_TO, .data$CONVERSION_FACTOR)
  
  stn_datum_conversion <- dplyr::collect(stn_datum_conversion)
  
  attr(stn_datum_conversion,'missed_stns') <- setdiff(unique(stns), unique(stn_datum_conversion$STATION_NUMBER))
  as.hy(stn_datum_conversion)
  
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
#'   \item{Year_from}{First year of use}
#'   \item{Year_to}{Last year of use}
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
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  ## Creating rlang symbols
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  
  stn_datum_unrelated <- dplyr::tbl(hydat_con, "STN_DATUM_UNRELATED")
  stn_datum_unrelated <- dplyr::filter(stn_datum_unrelated, !!sym_STATION_NUMBER %in% stns)
  stn_datum_unrelated <- dplyr::collect(stn_datum_unrelated) 
  
  stn_datum_unrelated$YEAR_FROM <- lubridate::ymd(as.Date(stn_datum_unrelated$YEAR_FROM))
  stn_datum_unrelated$YEAR_TO <- lubridate::ymd(as.Date(stn_datum_unrelated$YEAR_TO))
  
  stn_datum_unrelated <- dplyr::rename(stn_datum_unrelated, Year_from = .data$YEAR_FROM, Year_to = .data$YEAR_TO)  
  
  attr(stn_datum_unrelated,'missed_stns') <- setdiff(unique(stns), unique(stn_datum_unrelated$STATION_NUMBER))
  as.hy(stn_datum_unrelated)
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
#'   \item{Year_from}{First year of use}
#'   \item{Year_to}{Last year of use}
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
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  ## Creating rlang symbols
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  
  stn_data_range <- dplyr::tbl(hydat_con, "STN_DATA_RANGE")
  stn_data_range <- dplyr::filter(stn_data_range, !!sym_STATION_NUMBER %in% stns)
    
  stn_data_range <- dplyr::collect(stn_data_range)
  
  stn_data_range[stn_data_range$SED_DATA_TYPE == "NA",]$SED_DATA_TYPE <- NA_character_
  
  stn_data_range <- dplyr::rename(stn_data_range, Year_from = .data$YEAR_FROM, Year_to = .data$YEAR_TO)
  
  attr(stn_data_range,'missed_stns') <- setdiff(unique(stns), unique(stn_data_range$STATION_NUMBER))
  as.hy(stn_data_range)

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
#'   \item{DATA_TYPE}{The type of data}
#'   \item{Year_from}{First year of use}
#'   \item{Year_to}{Last year of use}
#'   \item{MEASUREMENT}{The sampling method used in the collection of 
#'   sediment data or the type of the gauge used in the collection of the hydrometric data}
#'   \item{OPERATION}{The schedule of station operation 
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
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
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
  stn_data_coll <- dplyr::select(stn_data_coll, .data$STATION_NUMBER, DATA_TYPE = .data$DATA_TYPE_EN, 
                                 Year_from = .data$YEAR_FROM, Year_to = .data$YEAR_TO, 
                                 MEASUREMENT = .data$MEASUREMENT_EN, OPERATION = .data$OPERATION_EN)
  stn_data_coll <- dplyr::arrange(stn_data_coll, .data$STATION_NUMBER, .data$Year_from)
  
  attr(stn_data_coll,'missed_stns') <- setdiff(unique(stns), unique(stn_data_coll$STATION_NUMBER))
  as.hy(stn_data_coll)
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
#'   \item{DATA_TYPE}{The type of data}
#'   \item{Year}{Year of operation schedule}
#'   \item{Month_from}{First month of use}
#'   \item{Month_to}{Last month of use}
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
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }
  
  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)
  
  ## Creating rlang symbols
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  
  stn_operation_schedule <- dplyr::tbl(hydat_con, "STN_OPERATION_SCHEDULE")
  stn_operation_schedule <- dplyr::filter(stn_operation_schedule, !!sym_STATION_NUMBER %in% stns)
  stn_operation_schedule <- dplyr::collect(stn_operation_schedule)
  stn_operation_schedule <- dplyr::left_join(stn_operation_schedule, tidyhydat::hy_data_types, by = c("DATA_TYPE"))
  
  stn_operation_schedule <- dplyr::select(stn_operation_schedule, .data$STATION_NUMBER, 
                DATA_TYPE = .data$DATA_TYPE_EN, Year =.data$YEAR, 
                Month_from = .data$MONTH_FROM, Month_to = .data$MONTH_TO)
  
  attr(stn_operation_schedule,'missed_stns') <- setdiff(unique(stns), unique(stn_operation_schedule$STATION_NUMBER))
  as.hy(stn_operation_schedule)
}

#' @title Output OS-independent path to the HYDAT sqlite database
#'
#' @description Provides the download location for \link{download_hydat} in an OS independent manner.
#' 
#' @param ... arguments potentially passed to \code{rappdirs::user_data_dir}
#' 
#' @examples \dontrun{
#' hy_dir()
#' }
#'
#' @export
#'
#'
hy_dir <- function(...){
  rappdirs::user_data_dir(appname = "tidyhydat", ...)
}

#' hy_agency_list function
#'
#' AGENCY look-up Table
#' 
#' @param hydat_path The path to the hydat database or NULL to use the default location
#'   used by \link{download_hydat}. It is also possible to pass in an existing 
#'   \link[dplyr]{src_sqlite} such that the database only needs to be opened once per
#'   user-level call.
#'
#' @return A tibble of agencies
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \dontrun{
#' hy_agency_list()
#'}
#'
hy_agency_list <- function(hydat_path = NULL) {
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }
  
  agency_list <- dplyr::tbl(hydat_con, "AGENCY_LIST") %>%
    dplyr::collect()
  
  as.hy(agency_list)
}


#'  Extract regional office list from HYDAT database
#'
#'  OFFICE look-up Table
#' @inheritParams hy_agency_list
#' @return A tibble of offices
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \dontrun{
#' hy_reg_office_list()
#'}
#'
#'
hy_reg_office_list <- function(hydat_path = NULL) {
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }
  
  regional_office_list <- dplyr::tbl(hydat_con, "REGIONAL_OFFICE_LIST") %>%
    dplyr::collect()
  
  as.hy(regional_office_list)
}

#'  Extract datum list from HYDAT database
#'
#'  DATUM look-up Table
#' @inheritParams hy_agency_list
#'
#' @return A tibble of DATUMS
#'
#' @family HYDAT functions
#' @source HYDAT
#' @examples
#' \dontrun{
#' hy_datum_list()
#'}
#'
#' @export
#'
hy_datum_list <- function(hydat_path = NULL) {
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }
  
  datum_list <- dplyr::tbl(hydat_con, "DATUM_LIST") %>%
    dplyr::collect()
  
  as.hy(datum_list)
}


#' Extract version number from HYDAT database
#' 
#' A function to get version number of hydat
#'
#' @inheritParams hy_agency_list
#'
#' @return version number and release date
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export
#' @examples
#' \dontrun{
#' hy_version()
#'}
#'
#'
hy_version <- function(hydat_path = NULL) {
  
  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }
  
  version <- dplyr::tbl(hydat_con, "VERSION") %>%
    dplyr::collect() %>%
    dplyr::mutate(Date = lubridate::ymd_hms(.data$Date))
  
  version
  
}


