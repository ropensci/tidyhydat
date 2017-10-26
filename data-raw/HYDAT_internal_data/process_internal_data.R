library(dbplyr)
library(devtools)
library(tidyverse)

##param_id




#' A tibble of all Canadian Stations stations and their names.
allstations <- realtime_stations() %>%
  bind_rows(hy_stations()) %>%
  distinct(STATION_NUMBER, .keep_all = TRUE) %>%
  select(STATION_NUMBER, STATION_NAME, PROV_TERR_STATE_LOC, LATITUDE, LONGITUDE) 

use_data(allstations, overwrite = TRUE)

## Load up hydat connection
## Read in database
hydat_con <- DBI::dbConnect(RSQLite::SQLite(), paste0(rappdirs::user_data_dir(),"\\Hydat.sqlite3"))

## DATA_TYPES
data_types <- tbl(hydat_con, "DATA_TYPES") %>%
  collect()
use_data(data_types, overwrite = TRUE)

## DATA_SYMBOLS
data_symbols <- tbl(hydat_con, "DATA_SYMBOLS") %>%
  collect()
use_data(data_symbols, overwrite = TRUE)

DBI::dbDisconnect(hydat_con)
