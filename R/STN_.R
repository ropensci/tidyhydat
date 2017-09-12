#' STN_REMARKS function
#'
#' STN_REMARKS look-up Table
#' @inheritParams STATIONS
#'
#' @return A tibble of STN_REMARKS
#'
#' @export
#'
STN_REMARKS <- function(hydat_path=NULL, STATION_NUMBER = NULL, PROV_TERR_STATE_LOC = NULL) {
  if (is.null(hydat_path)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
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
#'
STN_DATUM_CONVERSION <- function(hydat_path=NULL, STATION_NUMBER = NULL, PROV_TERR_STATE_LOC = NULL) {
  if (is.null(hydat_path)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
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
#'
STN_DATA_RANGE <- function(hydat_path=NULL, STATION_NUMBER = NULL, PROV_TERR_STATE_LOC = NULL) {
  if (is.null(hydat_path)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
  }

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  stn_data_range <- dplyr::tbl(hydat_con, "STN_DATA_RANGE") %>%
    filter(STATION_NUMBER %in% stns) %>%
    collect()
  
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
#'
STN_DATA_RANGE <- function(hydat_path=NULL, STATION_NUMBER = NULL, PROV_TERR_STATE_LOC = NULL) {
  if (is.null(hydat_path)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
  }

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
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
#'
STN_OPERATION_SCHEDULE <- function(hydat_path=NULL, STATION_NUMBER = NULL, PROV_TERR_STATE_LOC = NULL) {
  if (is.null(hydat_path)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
  }

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  stn_operation_schedule <- dplyr::tbl(hydat_con, "STN_OPERATION_SCHEDULE") %>%
    dplyr::filter(STATION_NUMBER %in% stns) %>%
    dplyr::collect() %>%
    dplyr::left_join(tidyhydat::DATA_TYPES, by = c("DATA_TYPE")) %>%
    dplyr::select(STATION_NUMBER, DATA_TYPE_EN, YEAR, MONTH_FROM, MONTH_TO)

  stn_operation_schedule
}
