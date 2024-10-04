# Copyright 2018 Province of BC
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

###############################################
tidyhydat_realtime_csv_parser <- function(file) {
  req <- httr2::request(file)
  req <- httr2::req_user_agent(req, "https://github.com/ropensci/tidyhydat")
  resp <- tidyhydat_perform(req)
  httr2::resp_body_string(resp)
}

## Get realtime station data - single station
single_realtime_station <- function(station_number) {
  ## If station is provided
  if (!is.null(station_number)) {
    sym_STATION_NUMBER <- sym("STATION_NUMBER")

    ## first check internal dataframe for station info
    if (any(tidyhydat::allstations$STATION_NUMBER %in% station_number)) {
      choose_df <- dplyr::filter(tidyhydat::allstations, !!sym_STATION_NUMBER %in% station_number)
      STATION_NUMBER_SEL <- choose_df$STATION_NUMBER
      PROV <- choose_df$PROV_TERR_STATE_LOC
    } else {
      choose_df <- dplyr::filter(realtime_stations(), !!sym_STATION_NUMBER %in% station_number)
      STATION_NUMBER_SEL <- choose_df$STATION_NUMBER
      PROV <- choose_df$PROV_TERR_STATE_LOC
    }
  }


  base_url <- "https://dd.weather.gc.ca/hydrometric"

  # build URL
  type <- c("hourly", "daily")
  url <- sprintf("%s/csv/%s/%s", base_url, PROV, type)
  infile <- sprintf(
    "%s/%s_%s_%s_hydrometric.csv",
    url,
    PROV,
    STATION_NUMBER_SEL,
    type
  )

  # Define column names as the same as HYDAT
  colHeaders <-
    c(
      "STATION_NUMBER",
      "Date",
      "Level",
      "Level_GRADE",
      "Level_SYMBOL",
      "Level_CODE",
      "Flow",
      "Flow_GRADE",
      "Flow_SYMBOL",
      "Flow_CODE"
    )

  h_resp_str <- tidyhydat_realtime_csv_parser(infile[1])
  h <- readr::read_csv(
    h_resp_str,
    col_names = colHeaders,
    col_types = readr::cols(
      STATION_NUMBER = readr::col_character(),
      Date = readr::col_datetime(),
      Level = readr::col_double(),
      Level_GRADE = readr::col_character(),
      Level_SYMBOL = readr::col_character(),
      Level_CODE = readr::col_integer(),
      Flow = readr::col_double(),
      Flow_GRADE = readr::col_character(),
      Flow_SYMBOL = readr::col_character(),
      Flow_CODE = readr::col_integer()
    )
  )

  # download daily file
  p_resp_str <- tidyhydat_realtime_csv_parser(infile[2])

  d <- readr::read_csv(
    p_resp_str,
    col_names = colHeaders,
    col_types = readr::cols(
      STATION_NUMBER = readr::col_character(),
      Date = readr::col_datetime(),
      Level = readr::col_double(),
      Level_GRADE = readr::col_character(),
      Level_SYMBOL = readr::col_character(),
      Level_CODE = readr::col_integer(),
      Flow = readr::col_double(),
      Flow_GRADE = readr::col_character(),
      Flow_SYMBOL = readr::col_character(),
      Flow_CODE = readr::col_integer()
    )
  )

  # now merge the hourly + daily (hourly data overwrites daily where dates are the same)
  p <- dplyr::filter(d, Date < min(h$Date))
  output <- dplyr::bind_rows(p, h)

  ## Offloading tidying to another function
  realtime_tidy_data(output, PROV)
}

all_realtime_station <- function(PROV) {
  base_url <- "https://dd.weather.gc.ca/hydrometric/csv/"
  prov_url <- paste0(base_url, PROV, "/daily/", PROV, "_daily_hydrometric.csv")

  res <- tidyhydat_realtime_csv_parser(prov_url)

  # Define column names as the same as HYDAT
  colHeaders <-
    c(
      "STATION_NUMBER",
      "Date",
      "Level",
      "Level_GRADE",
      "Level_SYMBOL",
      "Level_CODE",
      "Flow",
      "Flow_GRADE",
      "Flow_SYMBOL",
      "Flow_CODE"
    )

  output <- readr::read_csv(
    res,
    col_names = colHeaders,
    col_types = readr::cols(
      STATION_NUMBER = readr::col_character(),
      Date = readr::col_datetime(),
      Level = readr::col_double(),
      Level_GRADE = readr::col_character(),
      Level_SYMBOL = readr::col_character(),
      Level_CODE = readr::col_integer(),
      Flow = readr::col_double(),
      Flow_GRADE = readr::col_character(),
      Flow_SYMBOL = readr::col_character(),
      Flow_CODE = readr::col_integer()
    )
  )


  ## Offloading tidying to another function
  realtime_tidy_data(output, PROV)
}


realtime_tidy_data <- function(data, prov) {
  ## Create symbols
  sym_temp <- sym("temp")
  sym_val <- sym("val")
  sym_key <- sym("key")

  ## Now tidy the data
  ## TODO: Find a better way to do this
  data <- dplyr::rename(data, `Level_` = Level, `Flow_` = Flow)
  data <- tidyr::gather(data, !!sym_temp, !!sym_val, -STATION_NUMBER, -Date)
  data <- tidyr::separate(data, !!sym_temp, c("Parameter", "key"), sep = "_", remove = TRUE)
  data <- dplyr::mutate(data, key = ifelse(key == "", "Value", key))
  data <- tidyr::spread(data, !!sym_key, !!sym_val)
  data <- dplyr::rename(data, Code = CODE, Grade = GRADE, Symbol = SYMBOL)
  data <- dplyr::mutate(data, PROV_TERR_STATE_LOC = prov)
  data <- dplyr::select(
    data, STATION_NUMBER, PROV_TERR_STATE_LOC, Date, Parameter, Value,
    Grade, Symbol, Code
  )
  data <- dplyr::arrange(data, Parameter, STATION_NUMBER, Date)
  data$Value <- as.numeric(data$Value)

  data
}

has_internet <- function() {
  z <- try(suppressWarnings(readLines("https://www.google.ca", n = 1)),
    silent = TRUE
  )
  !inherits(z, "try-error")
}
