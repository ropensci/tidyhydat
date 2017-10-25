library(dbplyr)
library(devtools)
library(tidyverse)

##param_id


## Load up hydat connection
## Read in database
hydat_con <- DBI::dbConnect(RSQLite::SQLite(), paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"))

## To add to list
# allstations <- download_network() %>%
#  anti_join(hy_stations(), by = c("station_number", "STATION_NAME")) %>%
#  select(STATION_NUMBER, STATION_NAME) 
#' A tibble of all Canadian Stations stations and their names.

## all stations
allstations <- tbl(hydat_con, "STATIONS") %>%
  select(STATION_NUMBER, STATION_NAME, PROV_TERR_STATE_LOC) %>%
  collect()
use_data(allstations, overwrite = TRUE)

## DATA_TYPES
data_types <- tbl(hydat_con, "DATA_TYPES") %>%
  collect()
use_data(data_types, overwrite = TRUE)

## DATA_SYMBOLS
data_symbols <- tbl(hydat_con, "DATA_SYMBOLS") %>%
  collect()
use_data(data_symbols, overwrite = TRUE)

DBI::dbDisconnect(hydat_con)
