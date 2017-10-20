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

#' Extract monthly flows information from the HYDAT database
#'
#' Provides wrapper to turn the MONTHLY_FLOWS table in HYDAT into a tidy data frame.  \code{STATION_NUMBER} and
#'   \code{PROV_TERR_STATE_LOC} can both be supplied. If both are omitted all values from the \code{STATIONS} table are returned.
#'   That is a large vector for \code{MONTHLY_FLOWS}.
#'
#' @inheritParams STATIONS
#' @param start_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param end_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#'
#' @return A tibble of monthly flows. This includes a \code{Date_occured} column which indicates the date of the \code{Sum_stat}. For MEAN and 
#'   TOTAL this is not presented as those are not daily values.
#'
#' @examples
#' \donttest{
#' MONTHLY_FLOWS(STATION_NUMBER = c("02JE013","08MF005"), hydat_path = "H:/Hydat.sqlite3",
#' start_date = "1996-01-01", end_date = "2000-01-01")
#'
#' MONTHLY_FLOWS(PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")
#'           }
#' @family HYDAT functions
#' @source HYDAT
#' @export



MONTHLY_FLOWS <- function(hydat_path=NULL, STATION_NUMBER = NULL, PROV_TERR_STATE_LOC = NULL, start_date ="ALL", end_date = "ALL") {
  if (!is.null(STATION_NUMBER) && STATION_NUMBER == "ALL") {
    stop("Deprecated behaviour.Omit the STATION_NUMBER = \"ALL\" argument. See ?MONTHLY_FLOWS for examples.")
  }

  if (start_date == "ALL" & end_date == "ALL") {
    message("No start and end dates specified. All dates available will be returned.")
  } else {
    ## When we want date contraints we need to break apart the dates because SQL has no native date format
    ## Start
    start_year <- lubridate::year(start_date)
    start_month <- lubridate::month(start_date)
    start_day <- lubridate::day(start_date)

    ## End
    end_year <- lubridate::year(end_date)
    end_month <- lubridate::month(end_date)
    end_day <- lubridate::day(end_date)
  }

  ## Check date is in the right format
  if (start_date != "ALL" | end_date != "ALL") {
    if (is.na(as.Date(start_date, format = "%Y-%m-%d")) | is.na(as.Date(end_date, format = "%Y-%m-%d"))) {
      stop("Invalid date format. Dates need to be in YYYY-MM-DD format")
    }

    if (start_date > end_date) {
      stop("start_date is after end_date. Try swapping values.")
    }
  }

  if (is.null(hydat_path)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or 
           in your .Renviron file. See ?tidyhydat for more documentation.")
    }
  }


  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  on.exit(DBI::dbDisconnect(hydat_con))

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)


  ## Data manipulations to make it "tidy"
  monthly_flows <- dplyr::tbl(hydat_con, "DLY_FLOWS")
  monthly_flows <- dplyr::filter(monthly_flows, STATION_NUMBER %in% stns)

  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too
  if (start_date != "ALL" | end_date != "ALL") {
    monthly_flows <- dplyr::filter(monthly_flows, YEAR >= start_year &
      YEAR <= end_year)
    
    #monthly_flows <- dplyr::filter(monthly_flows, MONTH >= start_month &
    #                             MONTH <= end_month)
  }

  monthly_flows <- dplyr::select(monthly_flows, STATION_NUMBER:MAX)
  monthly_flows <- dplyr::collect(monthly_flows)
  
  if(is.data.frame(monthly_flows) && nrow(monthly_flows)==0)
  {stop("This station is not present in HYDAT")}
  
  ## Need to rename columns for gather
  colnames(monthly_flows) <- c("STATION_NUMBER","YEAR","MONTH", "FULL_MONTH", "NO_DAYS", "MEAN_Value",
                           "TOTAL_Value", "MIN_DAY","MIN_Value", "MAX_DAY","MAX_Value")
  
  

  monthly_flows <- tidyr::gather(monthly_flows, variable, temp, -(STATION_NUMBER:NO_DAYS))
  monthly_flows <- tidyr::separate(monthly_flows, variable, into = c("Sum_stat","temp2"), sep = "_")

  monthly_flows <- tidyr::spread(monthly_flows, temp2, temp)

  ## convert into R date for date of occurence.
  monthly_flows <- dplyr::mutate(monthly_flows, Date_occurred = lubridate::ymd(paste0(YEAR, "-", MONTH, "-", DAY), quiet = TRUE))

  monthly_flows <- dplyr::select(monthly_flows, -DAY)
  monthly_flows <- dplyr::mutate(monthly_flows, FULL_MONTH = FULL_MONTH == 1)

  ## What stations were missed?
  differ <- setdiff(unique(stns), unique(monthly_flows$STATION_NUMBER))
  if (length(differ) != 0) {
    if (length(differ) <= 10) {
      message("The following station(s) were not retrieved: ", paste0(differ, sep = " "))
      message("Check station number typos or if it is a valid station in the network")
    }
    else {
      message("More than 10 stations from the initial query were not returned. Ensure realtime and active status are correctly specified.")
    }
  } else {
    message("All station successfully retrieved")
  }


  monthly_flows
}
