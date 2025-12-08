#' Internal helper to get historical data from web service
#'
#' @param station_number Water Survey of Canada station number
#' @param parameters Either "flow" or "level"
#' @param start_date Start date in YYYY-MM-DD format (required)
#' @param end_date End date in YYYY-MM-DD format (required)
#'
#' @return A tibble with historical data from the web service
#' @noRd
#' @keywords internal
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

  ## Apply ws class and store missed stations as attribute
  csv_df <- as.ws(csv_df)
  attr(csv_df, "missed_stns") <- differ

  ## Return it
  csv_df
}
