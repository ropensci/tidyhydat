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
#' Provides wrapper to turn the SED_MONTHLY_SUSCON table in HYDAT into a tidy data frame.  \code{STATION_NUMBER} and
#'   \code{PROV_TERR_STATE_LOC} can both be supplied. If both are omitted all values from the \code{STATIONS} table are returned.
#'   That is a large vector for \code{SED_MONTHLY_SUSCON}.
#'
#' @inheritParams STATIONS
#' @param start_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#' @param end_date Leave blank if all dates are required. Date format needs to be in YYYY-MM-DD. Date is inclusive.
#'
#' @return A tibble of monthly suspended sediment concentrations. This includes a \code{Date_occured} column which indicates the date of the \code{Sum_stat}. For MEAN and 
#'   TOTAL this is not presented as those are not daily values.
#'
#' @examples
#' \donttest{
#' SED_MONTHLY_SUSCON(PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")
#'           }
#' @family HYDAT functions
#' @source HYDAT
#' @export



SED_MONTHLY_SUSCON <- function(hydat_path=NULL, STATION_NUMBER = NULL, PROV_TERR_STATE_LOC = NULL, start_date ="ALL", end_date = "ALL") {
  if (!is.null(STATION_NUMBER) && STATION_NUMBER == "ALL") {
    stop("Deprecated behaviour.Omit the STATION_NUMBER = \"ALL\" argument. See ?SED_MONTHLY_SUSCON for examples.")
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
  sed_monthly_suscon <- dplyr::tbl(hydat_con, "SED_DLY_SUSCON")
  sed_monthly_suscon <- dplyr::filter(sed_monthly_suscon, STATION_NUMBER %in% stns)

  ## Do the initial subset to take advantage of dbplyr only issuing sql query when it has too
  if (start_date != "ALL" | end_date != "ALL") {
    sed_monthly_suscon <- dplyr::filter(sed_monthly_suscon, YEAR >= start_year &
      YEAR <= end_year)
    
    #sed_monthly_suscon <- dplyr::filter(sed_monthly_suscon, MONTH >= start_month &
    #                             MONTH <= end_month)
  }
  
  sed_monthly_suscon <- dplyr::select(sed_monthly_suscon, STATION_NUMBER:MAX)
  sed_monthly_suscon <- dplyr::collect(sed_monthly_suscon)
  
  if(is.data.frame(sed_monthly_suscon) && nrow(sed_monthly_suscon)==0)
  {stop("This station is not present in HYDAT")}
  
  ## Need to rename columns for gather
  colnames(sed_monthly_suscon) <- c("STATION_NUMBER","YEAR","MONTH", "FULL_MONTH", "NO_DAYS",
                                    "TOTAL_Value", "MIN_DAY","MIN_Value", "MAX_DAY","MAX_Value")
  
  
  
  sed_monthly_suscon <- tidyr::gather(sed_monthly_suscon, variable, temp, -(STATION_NUMBER:NO_DAYS))
  sed_monthly_suscon <- tidyr::separate(sed_monthly_suscon, variable, into = c("Sum_stat","temp2"), sep = "_")
  
  sed_monthly_suscon <- tidyr::spread(sed_monthly_suscon, temp2, temp)
  
  ## convert into R date for date of occurence.
  sed_monthly_suscon <- dplyr::mutate(sed_monthly_suscon, Date_occurred = lubridate::ymd(paste0(YEAR, "-", MONTH, "-", DAY), quiet = TRUE))
  
  sed_monthly_suscon <- dplyr::select(sed_monthly_suscon, -DAY)
  sed_monthly_suscon <- dplyr::mutate(sed_monthly_suscon, FULL_MONTH = FULL_MONTH == 1)
  
  ## What stations were missed?
  differ <- setdiff(unique(stns), unique(sed_monthly_suscon$STATION_NUMBER))
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
  

  sed_monthly_suscon
}
