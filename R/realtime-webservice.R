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

#' Download realtime data from the ECCC web service
#'
#' Function to actually retrieve data from ECCC web service.
#' The maximum number of days that can be queried depends on other parameters being requested.
#' If one station is requested, 18 months of data can be requested. If you continually receiving
#' errors when invoking this function, reduce the number of observations (via station_number,
#' parameters or dates) being requested.
#'
#' @param station_number Water Survey of Canada station number.
#' @param parameters parameter ID. Can take multiple entries. Parameter is a numeric code. See \code{param_id}
#' for some options though undocumented parameters may be implemented. Defaults to Water level provisional, Secondary water level,
#' Tertiary water level, Discharge Provisional, Discharge, sensor, Water temperature, Secondary water temperature, Accumulated precipitation
#' @param start_date Accepts either YYYY-MM-DD or YYYY-MM-DD HH:MM:SS.
#' If only `start date`` is supplied (i.e. YYYY-MM-DD) values are returned from the start of that day.
#' Defaults to 30 days before current date. Time is supplied in UTC.
#' @param end_date Accepts either YYYY-MM-DD or YYYY-MM-DD HH:MM:SS.
#' If only `end_date`` is supplied (i.e. YYYY-MM-DD) values are returned from the end of that day.
#' Defaults to current date. Time is supplied in UTC.
#'
#'
#' @format A tibble with 6 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Date}{Observation date and time. Formatted as a POSIXct class as UTC for consistency.}
#'   \item{Name_En}{Code name in English}
#'   \item{Value}{Value of the measurement.}
#'   \item{Unit}{Value units}
#'   \item{Grade}{future use}
#'   \item{Symbol}{future use}
#'   \item{Approval}{future use}
#'   \item{Parameter}{Numeric parameter code}
#'   \item{Code}{Letter parameter code}
#' }
#'
#' @examples
#' \dontrun{
#'
#' ws_08 <- realtime_ws(
#'   station_number = c("08NL071", "08NM174"),
#'   parameters = c(47, 5)
#' )
#'
#' fivedays <- realtime_ws(
#'   station_number = c("08NL071", "08NM174"),
#'   parameters = c(47, 5),
#'   end_date = Sys.Date(), # today
#'   start_date = Sys.Date() - lubridate::days(5) # five days ago
#' )
#' }
#' @family realtime functions
#' @export

realtime_ws <- function(
  station_number,
  parameters = NULL,
  start_date = Sys.Date() - lubridate::days(30),
  end_date = Sys.Date()
) {
  if (is.null(parameters)) parameters <- c(46, 16, 52, 47, 8, 5, 41, 18)

  if (any(!parameters %in% tidyhydat::param_id$Parameter)) {
    stop(
      paste0(
        paste0(
          parameters[!parameters %in% tidyhydat::param_id$Parameter],
          collapse = ","
        ),
        " are invalid parameters. Check tidyhydat::param_id for a list of valid options."
      ),
      call. = FALSE
    )
  }

  if (!is.numeric(parameters))
    stop("parameters should be a number", call. = FALSE)

  if (inherits(start_date, "Date"))
    start_date <- paste0(start_date, " 00:00:00")
  if (inherits(end_date, "Date")) end_date <- paste0(end_date, " 23:59:59")

  validate_params(parameters, start_date, end_date)

  ## Build link for GET
  baseurl <- "https://wateroffice.ec.gc.ca/services/real_time_data/csv/inline?"

  query_url <- construct_url(
    venue = "realtime",
    baseurl,
    station_number,
    parameters, 
    start_date, 
    end_date
  )

  ## Get data
  req <- httr2::request(query_url)
  req <- tidyhydat_agent(req)
  resp <- httr2::req_perform(req)

  ## Give webservice some time
  Sys.sleep(1)

  ## Check the respstatus
  httr2::resp_check_status(resp)

  if (httr2::resp_headers(resp)$`Content-Type` != "text/csv; charset=utf-8") {
    stop("Response is not a csv file")
  }

  ## Turn it into a tibble and specify correct column classes
  csv_df <- readr::read_csv(
    I(httr2::resp_body_string(resp)),
    col_types = "cTidccc"
  )

  ## Check here to see if csv_df has any data in it
  if (nrow(csv_df) == 0) {
    stop("No data exists for this station query")
  }

  ## Rename columns to reflect tidyhydat naming
  csv_df = dplyr::rename(
    csv_df,
    STATION_NUMBER = ID,
    Parameter = "Parameter/Param\u00e8tre",
    Value = "Value/Valeur",
    Qualifier = "Qualifier/Qualificatif",
    Symbol = "Symbol/Symbole",
    Approval = "Approval/Approbation",
    Grade = "Grade/Classification",
    Qualifiers = "Qualifiers/Qualificatifs"
  )

  csv_df <- dplyr::left_join(
    csv_df,
    dplyr::select(tidyhydat::param_id, -Name_Fr),
    by = c("Parameter")
  )
  csv_df <- dplyr::select(
    csv_df,
    STATION_NUMBER,
    Date,
    Name_En,
    Value,
    Unit,
    Grade,
    Symbol,
    Approval,
    Parameter,
    Code,
    Qualifier,
    Qualifiers
  )

  ## What stations were missed?
  differ <- setdiff(unique(station_number), unique(csv_df$STATION_NUMBER))
  p_differ <- setdiff(unique(parameters), unique(csv_df$Parameter))

  ## Apply ws class and store missed stations/parameters as attributes
  csv_df <- as.ws(csv_df)
  attr(csv_df, "missed_stns") <- differ
  attr(csv_df, "missed_params") <- p_differ

  ## Return it
  csv_df
}
