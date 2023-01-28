library(dbplyr)
library(devtools)
library(tidyverse)
library(lutz)

load_all()


## Borrowed from @steffilazerte
tz_offset <- function(tz) {
  t <- as.numeric(difftime(as.POSIXct("2016-01-01 00:00:00", tz = "UTC"),
    as.POSIXct("2016-01-01 00:00:00", tz = tz),
    units = "hours"
  ))
  t
}

create_olson <- function(t) {
  if (t > 0) t <- paste0("Etc/GMT-", t)
  if (t <= 0) t <- paste0("Etc/GMT+", abs(t))
  t
}

#' A tibble of all Canadian Stations stations and their names.
allstations <- realtime_stations() %>%
  mutate(HYD_STATUS = "ACTIVE", REAL_TIME = TRUE) %>%
  bind_rows(hy_stations()) %>%
  distinct(STATION_NUMBER, .keep_all = TRUE) %>%
  select(STATION_NUMBER, STATION_NAME, PROV_TERR_STATE_LOC, HYD_STATUS, REAL_TIME, LATITUDE, LONGITUDE) %>%
  mutate(station_tz = tz_lookup_coords(LATITUDE, LONGITUDE, method = "accurate")) %>%
  mutate(standard_offset = map_dbl(station_tz, ~ tz_offset(.x))) %>%
  mutate(OlsonName = map_chr(standard_offset, ~ create_olson(.x))) %>%
  write_csv("./data-raw/HYDAT_internal_data/allstations.csv")

## Manually adding NL for now
if (!all(unique(allstations$OlsonName) %in% c(OlsonNames(), "Etc/GMT+3.5"))) {
  stop("Invalid OlsonNames generated", call. = FALSE)
} else {
  use_data(allstations, overwrite = TRUE)
}



## Load up hydat connection
## Read in database
hydat_con <- DBI::dbConnect(RSQLite::SQLite(), file.path(hy_dir(), "Hydat.sqlite3"))

## DATA_TYPES
hy_data_types <- tbl(hydat_con, "DATA_TYPES") %>%
  collect() %>%
  mutate(DATA_TYPE_FR = iconv(DATA_TYPE_FR, from = "UTF-8", to = "ASCII//TRANSLIT"))
use_data(hy_data_types, overwrite = TRUE)

## DATA_SYMBOLS
hy_data_symbols <- tbl(hydat_con, "DATA_SYMBOLS") %>%
  collect() %>%
  mutate(SYMBOL_FR = iconv(SYMBOL_FR, from = "UTF-8", to = "ASCII//TRANSLIT"))
use_data(hy_data_symbols, overwrite = TRUE)

DBI::dbDisconnect(hydat_con)
