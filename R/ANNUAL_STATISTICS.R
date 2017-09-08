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


#' @title Extract daily flows information from the HYDAT database
#'
#' @description Provides wrapper to turn the ANNUAL_STATISTICS table in HYDAT into a tidy data frame. \code{STATION_NUMBER} and
#' \code{PROV_TERR_STATE_LOC} must both be supplied. When STATION_NUMBER="ALL" the PROV_TERR_STATE_LOC argument decides
#' where those stations come from.
#'
#' @inheritParams STATIONS
#' @param start_year First year of the returned record
#' @param end_year Last year of the returned record
#'
#' @return A tibble of ANNUAL_STATISTICS
#'
#' @examples
#' \donttest{
#' ## Multiple stations province not specified
#' ANNUAL_STATISTICS(STATION_NUMBER = c("08NM083","05AE027"), hydat_path = "H:/Hydat.sqlite3")
#'
#' ## Multiple province, station number not specified
#' ANNUAL_STATISTICS(PROV_TERR_STATE_LOC = c("AB","SK"), hydat_path = "H:/Hydat.sqlite3")
#' }
#'
#' @export

ANNUAL_STATISTICS <- function(hydat_path=NULL, STATION_NUMBER =NULL, PROV_TERR_STATE_LOC=NULL,
                              start_year = "ALL", end_year = "ALL") {
  if (!is.null(STATION_NUMBER) && STATION_NUMBER == "ALL") {
    stop("Deprecated behaviour.Omit the STATION_NUMBER = \"ALL\" argument. See ?ANNUAL_STATISTICS for examples.")
  }

  if (is.null(hydat_path)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
  }


  ## Read in database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
  
  on.exit(DBI::dbDisconnect(hydat_con))

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, STATION_NUMBER, PROV_TERR_STATE_LOC)

  ## Data manipulations
  annual_statistics <- dplyr::tbl(hydat_con, "ANNUAL_STATISTICS")

  ## If a yearis supplied...
  if (start_year != "ALL" | end_year != "ALL") {
    annual_statistics <- dplyr::filter(annual_statistics, YEAR >= start_year & YEAR <= end_year)
  }

  annual_statistics <- dplyr::filter(annual_statistics, STATION_NUMBER %in% stns) %>%
    dplyr::collect()

  ## TODO: Figure out how to do this in fewer steps
  ## Mean tibble
  as_mean <- select(annual_statistics, STATION_NUMBER, DATA_TYPE, YEAR, MEAN)
  as_mean <- gather(as_mean, SUM_STAT, Value, -STATION_NUMBER, -DATA_TYPE, -YEAR)

  ## Min tibble
  as_min <- select(annual_statistics, STATION_NUMBER, DATA_TYPE, YEAR, MIN_MONTH, MIN_DAY, MIN, MIN_SYMBOL)
  as_min <- gather(as_min, SUM_STAT, Value, -STATION_NUMBER, -DATA_TYPE, -YEAR, -MIN_MONTH, -MIN_DAY, -MIN_SYMBOL)
  colnames(as_min) <- gsub("MIN_", "", names(as_min))

  ## Max tibble
  as_max <- select(annual_statistics, STATION_NUMBER, DATA_TYPE, YEAR, MAX_MONTH, MAX_DAY, MAX, MAX_SYMBOL)
  as_max <- gather(as_max, SUM_STAT, Value, -STATION_NUMBER, -DATA_TYPE, -YEAR, -MAX_MONTH, -MAX_DAY, -MAX_SYMBOL)
  colnames(as_max) <- gsub("MAX_", "", names(as_max))

  ## bind into 1 dataframe and by year and join in the symbol
  annual_statistics <- as_mean %>%
    dplyr::bind_rows(as_min) %>%
    dplyr::bind_rows(as_max) %>%
    dplyr::arrange(YEAR) %>%
    dplyr::left_join(DATA_SYMBOLS, by = c("SYMBOL" = "SYMBOL_ID"))

  ## Format date of occurence; SuppressWarnings are justified because NA's are valid for MEAN Sum_stat
  annual_statistics <- dplyr::mutate(annual_statistics, Date = suppressWarnings(lubridate::ymd(paste(YEAR, MONTH, DAY, sep = "-"))))

  ## Format
  annual_statistics <- dplyr::left_join(annual_statistics, DATA_TYPES, by = c("DATA_TYPE"))

  ## Clean up the variables
  annual_statistics <- select(annual_statistics, STATION_NUMBER, DATA_TYPE_EN, YEAR:Value, Date, SYMBOL_EN)

  ## Rename to tidyhydat format
  colnames(annual_statistics) <- c("STATION_NUMBER", "Parameter", "Year", "Sum_stat", "Value", "Date", "Symbol")


  ## What stations were missed?
  differ <- setdiff(unique(stns), unique(annual_statistics$STATION_NUMBER))
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

  annual_statistics
}
