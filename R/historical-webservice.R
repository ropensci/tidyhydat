#' Download historical flow and level data from the ECCC web service
#'
#' Functions to retrieve historical flow and levels data from ECCC web service. This data is
#' the same as HYDAT data but provides the convenience of not having to download
#' the HYDAT database. This function is useful when a smaller amount of data is needed. If
#' you need lots of data, consider using HYDAT and the `hy_` family of functions
#'
#' @param station_number Water Survey of Canada station number.
#' @param start_date Accepts YYYY-MM-DD. You need to provide a start date. 
#' The default value is NULL
#' @param end_date Accepts either YYYY-MM-DD. You need to provide an end date. 
#' The default value is NULL
#'
#'
#' @format A tibble with 6 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Date}{Observation date and time. Formatted as a POSIXct class as UTC for consistency.}
#'   \item{Parameter}{Type of parameter}
#'   \item{Value}{Value of the measurement.}
#'   \item{Symbol}{future use}
#' }
#'
#' @seealso hy_daily_flows
#' @examples
#' \dontrun{
#' try(
#'    flow_data <- ws_daily_flows(
#'      station_number = c("08NL071", "08NM174"),
#'      start_date = Sys.Date() - 365,
#'      end_date = Sys.Date()
#'    )
#' )
#' try(
#'    level_data <- ws_daily_level(
#'      station_number = c("08NL071", "08NM174"),
#'      start_date = Sys.Date() - 365,
#'      end_date = Sys.Date()
#'      )
#' )
#'}
#' @export
ws_daily_flows <- function(
    station_number,
    start_date = NULL,
    end_date = NULL) {
  
  get_historical_data(
    station_number = station_number,
    parameters = "flow",
    start_date = start_date,
    end_date = end_date
  )
}

#' @rdname ws_daily_flows
#' @export
ws_daily_levels <- function(
    station_number,
    start_date = NULL,
    end_date = NULL) {
  
  get_historical_data(
    station_number = station_number,
    parameters = "level",
    start_date = start_date,
    end_date = end_date
  )
}


get_historical_data <- function(
    station_number,
    parameters = "flow",
    start_date = NULL,
    end_date = NULL) {
  parameters <- match.arg(parameters, choices = c("level", "flow"))

  if (is.null(start_date)) {
    stop("please provide a valid date for the start_date argument", call. = FALSE)
  }

  if (is.null(end_date)) {
    stop("please provide a valid date for the end_date argument", call. = FALSE)
  }

  if (end_date < start_date) {
    stop("end_date must be after start_date", call. = FALSE)
  }

  ## Build link for GET
  baseurl <- base_url_historical_webservice()

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
    I(httr2::resp_body_string(resp)),
    col_types = "cDcdc",
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

  ## Return it
  csv_df
}
