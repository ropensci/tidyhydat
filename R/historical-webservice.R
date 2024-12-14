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
#' If only start date is supplied (i.e. YYYY-MM-DD) values are returned from the start of that day.
#' Defaults to 30 days before current date. Time is supplied in UTC.
#' @param end_date Accepts either YYYY-MM-DD or YYYY-MM-DD HH:MM:SS.
#' If only a date is supplied (i.e. YYYY-MM-DD) values are returned from the end of that day.
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
#' flow_data <- historical_ws(
#'   station_number = c("08NL071", "08NM174"),
#'   parameters = "flow"
#' )
#'
#' level_data <- realtime_ws(
#'   station_number = c("08NL071", "08NM174"),
#'   parameters = "level"
#' )
#' }
#' @export


historical_ws <- function(
    station_number,
    parameters = "flow",
    start_date = Sys.Date() - 365,
    end_date = Sys.Date()) {
  
  parameters <- match.arg(parameters, choices = c("level", "flow"))

  # validate_params(parameters, start_date, end_date)

  ## Build link for GET
  baseurl <- "https://wateroffice.ec.gc.ca/services/daily_data/csv/inline?"

  query_url <- construct_url(
    venue = "historical",
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
    httr2::resp_body_string(resp),
    col_types = "cDcdc"
  )


  ## Check here to see if csv_df has any data in it
  if (nrow(csv_df) == 0) {
    stop(c("No data exists for this station query during the period chosen"))
  }

  ## Rename columns to reflect tidyhydat naming
  colnames(csv_df) <- c("STATION_NUMBER", "Date", "Parameter", "Value", "Symbol")

  ## What stations were missed?
  differ <- setdiff(unique(station_number), unique(csv_df$STATION_NUMBER))
  if (length(differ) != 0) {
    if (length(differ) <= 10) {
      message("The following station(s) were not retrieved: ", paste0(differ, sep = " "))
      message("Check station number for typos or if it is a valid station in the network")
    } else {
      message("More than 10 stations from the initial query were not returned. Ensure realtime and active status are correctly specified.")
    }
  } else {
    message("All station successfully retrieved")
  }

  p_differ <- setdiff(unique(parameters), unique(csv_df$Parameter))
  if (length(p_differ) != 0) {
    message("The following valid parameter(s) were not retrieved for at least one station you requested: ", paste0(p_differ, sep = " "))
  } else {
    message("All parameters successfully retrieved")
  }


  ## Return it
  csv_df
}
