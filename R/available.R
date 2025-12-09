# Copyright 2025 Hakai Institute
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

#' Get all available flow data (final + provisional)
#'
#' Convenience function that combines final historical data
#' (from HYDAT or web service) with provisional real-time data in a single call.
#'
#' @inheritParams hy_daily_flows
#' @param start_date Start date for data retrieval in YYYY-MM-DD format.
#'   Defaults to NULL (retrieves all available historical data).
#' @param end_date End date for data retrieval in YYYY-MM-DD format.
#'   Defaults to current date (Sys.Date()).
#'
#' @details
#' This function combines data from final and provisional data sources to provide a complete
#' discharge record.
#'
#' ## Data Sources and Priority
#'
#' **Historical (Final) Data:**
#'
#' The function automatically determines the best source for historical data:
#' - **`hydat_path` provided** (path to database): Uses local HYDAT database at that path
#' - **`hydat_path = FALSE`**: Forces use of web service (useful when HYDAT unavailable)
#' - **`hydat_path = NULL`** (default): Uses HYDAT default location, automatically falls back
#'   to web service if HYDAT is unavailable
#'
#' **Real-time (Provisional) Data:**
#'
#' Provisional data is retrieved from ECCC's real-time web service using the
#' `realtime_ws()` function. This data covers approximately the last 18 months
#' and is updated regularly.
#'
#' ## Data Approval Status
#'
#' The `Approval` column uses ECCC's terminology
#' (see \url{https://wateroffice.ec.gc.ca/contactus/faq_e.html}):
#'
#' - **"final"**: Historical data from HYDAT or web service that has been approved by ECCC.
#'
#' - **"provisional"**: Real-time data from the web service representing the best
#'   available measurements, but subject to revision and not yet approved by ECCC.
#'
#'
#' @return A tibble with class `available` combining final and provisional data
#'   with an additional `Approval` column indicating whether each record is
#'   "final" or "provisional". The object includes attributes for tracking data
#'   sources and query metadata. 
#'
#' @format A tibble with 6 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Date}{Observation date. Formatted as a Date class.}
#'   \item{Parameter}{Parameter being measured. Value is "Flow"}
#'   \item{Value}{Discharge value. The units are m^3/s.}
#'   \item{Symbol}{Measurement/river conditions}
#'   \item{Approval}{Approval status: "final" (approved) or "provisional" (subject to revision)}
#' }
#'
#' @examples
#' \dontrun{
#' ## Basic usage - get all available data
#' flows <- available_flows("08MF005")
#'
#' ## Multiple stations
#' flows <- available_flows(c("08MF005", "08NM116"))
#'
#' ## Get only recent data (last 2 years)
#' recent_flows <- available_flows(
#'   "08MF005",
#'   start_date = Sys.Date() - lubridate::years(2),
#'   end_date = Sys.Date()
#' )
#'
#' ## Force use of web service (when HYDAT not available)
#' flows_ws <- available_flows("08MF005", hydat_path = FALSE)
#' }
#'
#' @family available functions
#' @export
available_flows <- function(
    station_number,
    start_date = NULL,
    end_date = Sys.Date(),
    hydat_path = NULL,
    prov_terr_state_loc = NULL
) {
  get_available_data(
    station_number = station_number,
    start_date = start_date,
    end_date = end_date,
    hydat_path = hydat_path,
    prov_terr_state_loc = prov_terr_state_loc,
    parameter_type = "Flow",
    parameter_code = 47
  )
}


#' Get all available level data (final + provisional)
#'
#' Convenience function that combines final historical data
#' (from HYDAT or web service) with provisional real-time data in a single call.
#'
#' @inheritParams available_flows
#'
#' @details
#' This function combines data from final and provisional data sources to provide a complete
#' water level record.
#'
#' ## Data Sources and Priority
#'
#' **Historical (Final) Data:**
#'
#' The function automatically determines the best source for historical data:
#' - **`hydat_path` provided** (path to database): Uses local HYDAT database at that path
#' - **`hydat_path = FALSE`**: Forces use of web service (useful when HYDAT unavailable)
#' - **`hydat_path = NULL`** (default): Uses HYDAT default location, automatically falls back
#'   to web service if HYDAT is unavailable
#'
#' **Real-time (Provisional) Data:**
#'
#' Provisional data is retrieved from ECCC's real-time web service using the
#' `realtime_ws()` function. This data covers approximately the last 18 months
#' and is updated regularly.
#'
#' ## Data Approval Status
#'
#' The `Approval` column uses ECCC's terminology
#' (see \url{https://wateroffice.ec.gc.ca/contactus/faq_e.html}):
#'
#' - **"final"**: Historical data from HYDAT or web service that has been approved by ECCC.
#'
#' - **"provisional"**: Real-time data from the web service representing the best
#'   available measurements, but subject to revision and not yet approved by ECCC.
#'
#' @return A tibble with class `available` combining final and provisional data
#'   with an additional `Approval` column indicating whether each record is
#'   "final" or "provisional". The object includes attributes for tracking data
#'   sources and query metadata.
#'
#' @format A tibble with 6 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Date}{Observation date. Formatted as a Date class.}
#'   \item{Parameter}{Parameter being measured. Value is "Level"}
#'   \item{Value}{Level value. The units are metres.}
#'   \item{Symbol}{Measurement/river conditions}
#'   \item{Approval}{Approval status: "final" (approved) or "provisional" (subject to revision)}
#' }
#'
#' @examples
#' \dontrun{
#' ## Basic usage - get all available data
#' levels <- available_levels("08MF005")
#'
#' ## Multiple stations
#' levels <- available_levels(c("08MF005", "08NM116"))
#'
#' ## Get only recent data (last 2 years)
#' recent_levels <- available_levels(
#'   "08MF005",
#'   start_date = Sys.Date() - lubridate::years(2),
#'   end_date = Sys.Date()
#' )
#'
#' ## Force use of web service (when HYDAT not available)
#' levels_ws <- available_levels("08MF005", hydat_path = FALSE)
#' }
#'
#' @family available functions
#' @export
available_levels <- function(
    station_number,
    start_date = NULL,
    end_date = Sys.Date(),
    hydat_path = NULL,
    prov_terr_state_loc = NULL
) {
  get_available_data(
    station_number = station_number,
    start_date = start_date,
    end_date = end_date,
    hydat_path = hydat_path,
    prov_terr_state_loc = prov_terr_state_loc,
    parameter_type = "Level",
    parameter_code = 46
  )
}


#' Internal helper to get available data
#'
#' Core logic for available_flows() and available_levels(). Handles data source
#' selection, retrieval, and combination.
#'
#' @param station_number Station number(s)
#' @param start_date Start date (YYYY-MM-DD)
#' @param end_date End date (YYYY-MM-DD)
#' @param hydat_path Path to HYDAT database (NULL/FALSE for auto/web service)
#' @param prov_terr_state_loc Province/territory/state location code
#' @param parameter_type "Flow" or "Level"
#' @param parameter_code Parameter code for realtime_ws (47=Flow, 46=Level)
#'
#' @return Combined tibble with Approval column
#' @noRd
#' @keywords internal
get_available_data <- function(
    station_number,
    start_date = NULL,
    end_date = Sys.Date(),
    hydat_path = NULL,
    prov_terr_state_loc = NULL,
    parameter_type,
    parameter_code
) {

  ## Initialize variables to store data
  final_data <- NULL
  provisional_data <- NULL
  historical_source <- NA_character_

  ## Get final data using hy_daily_* functions
  ## These now handle data source selection internally based on hydat_path
  if (parameter_type == "Flow") {
    hydat_fn <- hy_daily_flows
  } else if (parameter_type == "Level") {
    hydat_fn <- hy_daily_levels
  } else {
    stop("parameter_type must be 'Flow' or 'Level'", call. = FALSE)
  }

  ## Get final data - try HYDAT first, fallback to web service if NULL
  final_data <- tryCatch(
    {
      result <- hydat_fn(
        station_number = station_number,
        hydat_path = hydat_path,
        prov_terr_state_loc = prov_terr_state_loc,
        start_date = start_date,
        end_date = end_date
      )

      ## Determine source based on class
      if (inherits(result, "hy")) {
        historical_source <- "HYDAT"
      } else if (inherits(result, "ws")) {
        historical_source <- "Web Service"
      } else {
        historical_source <- "Unknown"
      }

      result
    },
    error = function(e) {
      ## Only fallback to web service if hydat_path was NULL
      if (is.null(hydat_path)) {
        message("HYDAT unavailable, falling back to web service...")

        ## Ensure dates for web service
        ws_start <- if (is.null(start_date)) as.Date("1850-01-01") else start_date
        ws_end <- if (is.null(end_date)) Sys.Date() else end_date

        tryCatch(
          {
            result <- hydat_fn(
              station_number = station_number,
              hydat_path = FALSE,  # Force web service
              start_date = ws_start,
              end_date = ws_end
            )
            historical_source <<- "Web Service"
            result
          },
          error = function(e2) {
            warning(
              "Failed to retrieve validated data from both HYDAT and web service",
              call. = FALSE
            )
            NULL
          }
        )
      } else {
        ## If hydat_path was explicitly set (not NULL), just error
        warning(
          "Failed to retrieve validated data: ", e$message,
          call. = FALSE
        )
        NULL
      }
    }
  )

  ## Add Approval column to final data
  if (!is.null(final_data) && nrow(final_data) > 0) {
    final_data$Approval <- "final"
  }


  # Get provisional/realtime data
  # Determine starting date for realtime query
  # Use the latest date from final data as the starting point
  realtime_start <- if (!is.null(final_data) && nrow(final_data) > 0) {
    ## Start from the day after the last final record
    max(final_data$Date, na.rm = TRUE) + lubridate::days(1)
  } else if (!is.null(start_date)) {
    ## No final data, use user-provided start_date
    as.Date(start_date)
  } else {
    ## No final data and no start_date, query from 18 months ago
    Sys.Date() - lubridate::months(18)
  }

  ## End date defaults to today unless user specified
  realtime_end <- if (!is.null(end_date)) {
    as.Date(end_date)
  } else {
    Sys.Date()
  }

  ## Only query realtime if there's a valid date range
  if (realtime_start <= realtime_end) {
    ## Query realtime web service
    rt_data <- tryCatch(
      {
        realtime_ws(
          station_number = station_number,
          parameters = parameter_code,
          start_date = realtime_start,
          end_date = realtime_end
        )
      },
      error = function(e) {
        if (grepl("No data exists for this station query", e$message, fixed = TRUE)) {
          return(NULL)
        }
        stop(e)
      }
    )

    ## Only process if we got realtime data
    if (!is.null(rt_data)) {
      ## Convert Date to Date class (it comes as POSIXct)
      rt_data$Date <- as.Date(rt_data$Date)

      ## Aggregate to daily means
      sym_STATION_NUMBER <- sym("STATION_NUMBER")
      sym_Date <- sym("Date")
      sym_Value <- sym("Value")

      provisional_data <- rt_data |>
        dplyr::group_by(!!sym_STATION_NUMBER, !!sym_Date) |>
        dplyr::summarise(Value = mean(!!sym_Value, na.rm = TRUE), .groups = "drop") |>
        dplyr::mutate(
          Parameter = parameter_type,
          Symbol = NA_character_,
          Approval = "provisional"
        ) |>
        dplyr::select(STATION_NUMBER, Date, Parameter, Value, Symbol, Approval)
    }
  }


  ## Combine final and provisional data
  combined_data <- dplyr::bind_rows(final_data, provisional_data)

  ## Apply date filtering and sorting only if we have data
  if (nrow(combined_data) > 0) {
    ## Apply date filtering if not already applied
    if (!is.null(start_date) || !is.null(end_date)) {
      sym_Date <- sym("Date")

      if (!is.null(start_date)) {
        combined_data <- dplyr::filter(combined_data, !!sym_Date >= as.Date(start_date))
      }
      if (!is.null(end_date)) {
        combined_data <- dplyr::filter(combined_data, !!sym_Date <= as.Date(end_date))
      }
    }

    ## Sort by station and date
    sym_STATION_NUMBER <- sym("STATION_NUMBER")
    sym_Date <- sym("Date")
    combined_data <- dplyr::arrange(combined_data, !!sym_STATION_NUMBER, !!sym_Date)
  }

  ## Store metadata as attributes
  attr(combined_data, "historical_source") <- historical_source

  ## Calculate missed stations only if we have data
  if (nrow(combined_data) > 0) {
    attr(combined_data, "missed_stns") <- setdiff(
      unique(station_number),
      unique(combined_data$STATION_NUMBER)
    )
  } else {
    ## If no data at all, all requested stations were missed
    attr(combined_data, "missed_stns") <- unique(station_number)
  }

  ## Return with available class
  as.available(combined_data)
}
