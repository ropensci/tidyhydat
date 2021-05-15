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


#' Extract annual statistics information from the HYDAT database
#'
#' Provides wrapper to turn the ANNUAL_STATISTICS table in HYDAT into a tidy data frame of annual statistics.
#' Statistics provided include MEAN, MAX and MIN on an annual basis.
#'
#' @inheritParams hy_stations
#' @param start_year First year of the returned record
#' @param end_year Last year of the returned record
#'
#' @return A tibble of hy_annual_stats.
#'
#' @format A tibble with 8 variables:
#' \describe{
#'   \item{STATION_NUMBER}{Unique 7 digit Water Survey of Canada station number}
#'   \item{Parameter}{Parameter being measured. Only possible values are FLOW and LEVEL}
#'   \item{Year}{Year of record.}
#'   \item{Sum_stat}{Summary statistic being used.}
#'   \item{Value}{Value of the measurement. If Parameter equals FLOW the units are m^3/s. If Parameter equals LEVEL the
#'   units are metres.}
#'   \item{Date}{Observation date. Formatted as a Date class. MEAN is a annual summary
#'   and therefore has an NA value for Date.}
#'   \item{Symbol}{Measurement/river conditions}
#' }
#'
#' @examples
#' \dontrun{
#'   ## Multiple stations province not specified
#'   hy_annual_stats(station_number = c("08NM083","05AE027"))
#'
#'   ## Multiple province, station number not specified
#'   hy_annual_stats(prov_terr_state_loc = c("AB","SK"))
#' }
#'
#' @family HYDAT functions
#' @source HYDAT
#' @export

hy_annual_stats <- function(station_number =NULL,
                            hydat_path = NULL,
                            prov_terr_state_loc=NULL,
                            start_year = "ALL", end_year = "ALL") {


  ## Read in database
  hydat_con <- hy_src(hydat_path)
  if (!dplyr::is.src(hydat_path)) {
    on.exit(hy_src_disconnect(hydat_con), add = TRUE)
  }

  ## Determine which stations we are querying
  stns <- station_choice(hydat_con, station_number, prov_terr_state_loc)

  ## Data manipulations
  annual_statistics <- dplyr::tbl(hydat_con, "ANNUAL_STATISTICS")

  ## Creating rlang symbols
  sym_YEAR <- sym("YEAR")
  sym_STATION_NUMBER <- sym("STATION_NUMBER")
  sym_SUM_STAT <- sym("SUM_STAT")
  sym_Value <- sym("Value")

  ## If a yearis supplied...
  if (start_year != "ALL" | end_year != "ALL") {
    annual_statistics <- dplyr::filter(annual_statistics, !!sym_YEAR >= start_year & !!sym_YEAR <= end_year)
  }

  annual_statistics <- dplyr::filter(annual_statistics, !!sym_STATION_NUMBER %in% stns) %>%
    dplyr::collect()

  ## TODO: Figure out how to do this in fewer steps
  ## Mean tibble
  as_mean <- dplyr::select(annual_statistics, .data$STATION_NUMBER, .data$DATA_TYPE, .data$YEAR, .data$MEAN)
  as_mean <- tidyr::gather(as_mean, !!sym_SUM_STAT, !!sym_Value, -.data$STATION_NUMBER, -.data$DATA_TYPE, -.data$YEAR)

  ## Min tibble
  as_min <- dplyr::select(
    annual_statistics, .data$STATION_NUMBER, .data$DATA_TYPE, .data$YEAR, .data$MIN_MONTH,
    .data$MIN_DAY, .data$MIN, .data$MIN_SYMBOL
  )
  as_min <- tidyr::gather(
    as_min, !!sym_SUM_STAT, !!sym_Value, -.data$STATION_NUMBER, -.data$DATA_TYPE, -.data$YEAR,
    -.data$MIN_MONTH, -.data$MIN_DAY, -.data$MIN_SYMBOL
  )
  colnames(as_min) <- gsub("MIN_", "", names(as_min))

  ## Max tibble
  as_max <- dplyr::select(
    annual_statistics, .data$STATION_NUMBER, .data$DATA_TYPE, .data$YEAR, .data$MAX_MONTH,
    .data$MAX_DAY, .data$MAX, .data$MAX_SYMBOL
  )
  as_max <- tidyr::gather(
    as_max, !!sym_SUM_STAT, !!sym_Value, -.data$STATION_NUMBER, -.data$DATA_TYPE, -.data$YEAR, -.data$MAX_MONTH,
    -.data$MAX_DAY, -.data$MAX_SYMBOL
  )
  colnames(as_max) <- gsub("MAX_", "", names(as_max))

  ## bind into 1 dataframe and by year and join in the symbol
  annual_statistics <- as_mean %>%
    dplyr::bind_rows(as_min) %>%
    dplyr::bind_rows(as_max) %>%
    dplyr::arrange(.data$YEAR) %>%
    dplyr::left_join(tidyhydat::hy_data_symbols, by = c("SYMBOL" = "SYMBOL_ID"))

  ## Format date of occurence; SuppressWarnings are justified because NA's are valid for MEAN Sum_stat
  annual_statistics <- dplyr::mutate(annual_statistics, Date = suppressWarnings(
    lubridate::ymd(paste(.data$YEAR, .data$MONTH, .data$DAY, sep = "-"))
  ))

  ## Format
  annual_statistics <- dplyr::left_join(annual_statistics, tidyhydat::hy_data_types, by = c("DATA_TYPE"))

  ## Clean up the variables
  annual_statistics <- dplyr::select(
    annual_statistics, .data$STATION_NUMBER, .data$DATA_TYPE_EN, .data$YEAR:.data$Value,
    .data$Date, .data$SYMBOL_EN
  )

  ## Rename to tidyhydat format
  colnames(annual_statistics) <- c("STATION_NUMBER", "Parameter", "Year", "Sum_stat", "Value", "Date", "Symbol")
  attr(annual_statistics,'missed_stns') <- setdiff(unique(stns), unique(annual_statistics$STATION_NUMBER))
  as.hy(annual_statistics)
}
