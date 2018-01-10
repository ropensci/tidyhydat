library(dbplyr)
library(devtools)
library(tidyverse)
##dont forget load_all()

##param_id




#' A tibble of all Canadian Stations stations and their names.
allstations <- realtime_stations() %>%
  bind_rows(hy_stations()) %>%
  distinct(STATION_NUMBER, .keep_all = TRUE) %>%
  select(STATION_NUMBER, STATION_NAME, PROV_TERR_STATE_LOC, LATITUDE, LONGITUDE) 

use_data(allstations, overwrite = TRUE)

## Load up hydat connection
## Read in database
hydat_con <- DBI::dbConnect(RSQLite::SQLite(), file.path(hy_dir(),"Hydat.sqlite3"))

## DATA_TYPES
hy_data_types <- tbl(hydat_con, "DATA_TYPES") %>%
  collect() %>%
  mutate(DATA_TYPE_FR = iconv(DATA_TYPE_FR,from = "UTF-8", to = "ASCII//TRANSLIT"))
use_data(hy_data_types, overwrite = TRUE)

## DATA_SYMBOLS
hy_data_symbols <- tbl(hydat_con, "DATA_SYMBOLS") %>%
  collect() %>%
  mutate(SYMBOL_FR = iconv(SYMBOL_FR, from = "UTF-8", to = "ASCII//TRANSLIT"))
use_data(hy_data_symbols, overwrite = TRUE)

DBI::dbDisconnect(hydat_con)
