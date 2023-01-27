# Copyright 2019 Province of British Columbia
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
  if (!is.null(station_number) && !is.null(prov_terr_state_loc)) {
    stop("Only specify one of station_number or prov_terr_state_loc.", call. = FALSE)
  }

  if (!is.null(prov_terr_state_loc) && prov_terr_state_loc[1] == "CA") {
    prov_terr_state_loc <- c(
      "QC", "NB", "PE", "NS", "ON", "NL", "MB",
      "AB", "SK", "NU", "NT", "BC", "YT"
    )
  }


  ## Prov symbol
  sym_PROV_TERR_STATE_LOC <- sym("PROV_TERR_STATE_LOC")


  ## Get all stations
  if (is.null(station_number) && is.null(prov_terr_state_loc)) {
    stns <- dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::collect() %>%
      dplyr::pull(STATION_NUMBER)
    return(stns)
  }

  ## When a station number is supplied but no province
  if (!is.null(station_number)) {
    ## Convert to upper case
    stns <- toupper(station_number)
    return(stns)
  }

  ## When a province is supplied but no station number
  if (!is.null(prov_terr_state_loc)) {
    prov_terr_state_loc <- toupper(prov_terr_state_loc)
    ## Only possible values for prov_terr_state_loc
    stn_option <- unique(tidyhydat::allstations$PROV_TERR_STATE_LOC)

    if (any(!prov_terr_state_loc %in% stn_option) == TRUE) stop("Invalid prov_terr_state_loc value")

    dplyr::tbl(hydat_con, "STATIONS") %>%
      dplyr::filter(!!sym_PROV_TERR_STATE_LOC %in% prov_terr_state_loc) %>%
      dplyr::collect() %>%
      dplyr::pull(STATION_NUMBER)
  }
}


## Deal with date choice and formatting
#' @noRd
#'
date_check <- function(start_date = NULL, end_date = NULL) {
  start_is_null <- is.null(start_date)
  end_is_null <- is.null(end_date)

  ## Check date is in the right format TODO
  if (!is.null(start_date)) {
    if (!grepl("[0-9]{4}-[0-1][0-9]-[0-3][0-9]", start_date)) stop("Invalid date format. start_date need to be in YYYY-MM-DD format", call. = FALSE)
  }

  if (!is.null(end_date)) {
    if (!grepl("[0-9]{4}-[0-1][0-9]-[0-3][0-9]", end_date)) stop("Invalid date format. end_date need to be in YYYY-MM-DD format", call. = FALSE)
  }

  if (!is.null(start_date) & !is.null(end_date)) {
    if (lubridate::ymd(end_date) < lubridate::ymd(start_date)) stop("start_date is after end_date. Try swapping values.", call. = FALSE)
  }


  invisible(list(start_is_null = start_is_null, end_is_null = end_is_null))
}

#' @importFrom dplyr %>%
#' @export
dplyr::`%>%`


## Simple error handler
#' @noRd
handle_error <- function(code) {
  tryCatch(code, error = function(c) {
    msg <- conditionMessage(c)
    invisible(structure(msg, class = "try-error"))
  })
}

## Differ message for all the hy_* functions
#' @noRd
differ_msg <- function(stns_input, stns_output) {
  differ <- setdiff(stns_input, stns_output)
  if (length(differ) != 0) {
    if (length(differ) <= 10) {
      message(
        "The following station(s) were not retrieved: ",
        paste0(differ, sep = " ")
      )
      message("Check station number typos or if it is a valid station in the network")
    } else {
      message(
        "More than 10 stations from the initial query were not returned. Ensure realtime and active status are correctly specified."
      )
    }
  } else {
    message("All station successfully retrieved")
  }
}


## Multi parameter message
#' @noRd
multi_param_msg <- function(data_arg, stns, params) {
  cli::cat_line(cli::rule(
    left = crayon::bold(params)
  ))

  ## Is the data anything other than a tibble?
  if (!inherits(data_arg, "tbl_df")) {
    return(
      cli::cat_line(paste0(crayon::red(cli::symbol$cross), " ", stns, collapse = "\n"))
    )
  }

  sym_Parameter <- sym("Parameter")

  flow_stns <- data_arg %>%
    dplyr::filter(!!sym_Parameter == params) %>%
    dplyr::distinct(STATION_NUMBER) %>%
    dplyr::arrange(STATION_NUMBER) %>%
    dplyr::pull(STATION_NUMBER)

  good_stns <- c()
  if (length(flow_stns) > 0L) {
    good_stns <- paste0(crayon::green(cli::symbol$tick), " ", flow_stns, collapse = "\n")
  }

  ## Station not in output
  not_in <- setdiff(stns, flow_stns)

  bad_stns <- c()
  if (length(not_in) > 0L) {
    bad_stns <- paste0(crayon::red(cli::symbol$cross), " ", not_in, collapse = "\n")
  }

  cli::cat_line(paste0(good_stns, "\n", bad_stns))
}

## Ask for something
#' @noRd
ask <- function(...) {
  choices <- c("Yes", "No")
  cat(crayon::green(paste0(..., "\n", collapse = "")))
  cli::cat_rule(col = "green")
  utils::menu(choices) == which(choices == "Yes")
}


# Catch network timeout error generated
# when dealing with proxy-related connection
# issues and fail with an informative error
# message on where to download HYDAT.
#' @noRd
network_check <- function(url) {
  tryCatch(httr::GET(url),
    error = function(e) {
      if (grepl("Timeout was reached:", e$message)) {
        stop(paste0("Could not connect to HYDAT source. Check your connection settings.
            Try downloading HYDAT_sqlite3 from this url:
            [http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/]
            and unzipping the saved file to this directory: ", hy_dir()),
          call. = FALSE
        )
      }
    }
  )
}


#' Convenience function to pull station number from tidyhydat functions
#'
#' This function mimics \code{dplyr::pull} to avoid having to always type
#' dplyr::pull(STATION_NUMBER). Instead we can now take advantage of autocomplete.
#' This can be used with \code{realtime_} and \code{hy_} functions.
#'
#' @param .data A table of data
#'
#' @return A vector of station_numbers
#'
#' @export
#'
#' @examples
#' \dontrun{
#'
#' hy_stations(prov_terr_state_loc = "PE") %>%
#'   pull_station_number() %>%
#'   hy_annual_instant_peaks()
#' }
#'
pull_station_number <- function(.data) {
  if (!("STATION_NUMBER" %in% colnames(.data))) stop("No STATION_NUMBER column present", call. = FALSE)

  unique(.data$STATION_NUMBER)
}


## expected tables
hy_expected_tbls <- function() {
  c(
    "AGENCY_LIST", "ANNUAL_INSTANT_PEAKS", "ANNUAL_STATISTICS",
    "CONCENTRATION_SYMBOLS", "DATA_SYMBOLS", "DATA_TYPES", "DATUM_LIST",
    "DLY_FLOWS", "DLY_LEVELS", "MEASUREMENT_CODES", "OPERATION_CODES",
    "PEAK_CODES", "PRECISION_CODES", "REGIONAL_OFFICE_LIST", "SAMPLE_REMARK_CODES",
    "SED_DATA_TYPES", "SED_DLY_LOADS", "SED_DLY_SUSCON", "SED_SAMPLES",
    "SED_SAMPLES_PSD", "SED_VERTICAL_LOCATION", "SED_VERTICAL_SYMBOLS",
    "STATIONS", "STN_DATA_COLLECTION", "STN_DATA_RANGE", "STN_DATUM_CONVERSION",
    "STN_DATUM_UNRELATED", "STN_OPERATION_SCHEDULE", "STN_REGULATION",
    "STN_REMARKS", "STN_REMARK_CODES", "STN_STATUS_CODES", "VERSION"
  )
}
