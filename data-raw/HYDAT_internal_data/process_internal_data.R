library(dbplyr)
library(devtools)
library(tidyverse)

##param_id


## Load up hydat connection
## Read in database
hydat_con <- DBI::dbConnect(RSQLite::SQLite(), Sys.getenv("hydat"))

## bc stations
bcstations <- tbl(hydat_con, "STATIONS") %>%
  filter(PROV_TERR_STATE_LOC == "BC") %>%
  select(STATION_NUMBER, STATION_NAME) %>%
  collect()
use_data(bcstations, overwrite = TRUE)

## all stations
allstations <- tbl(hydat_con, "STATIONS") %>%
  select(STATION_NUMBER, STATION_NAME, PROV_TERR_STATE_LOC) %>%
  collect()
use_data(allstations, overwrite = TRUE)

## DATA_TYPES
DATA_TYPES <- tbl(hydat_con, "DATA_TYPES") %>%
  collect()
use_data(DATA_TYPES, overwrite = TRUE)

## DATA_SYMBOLS
DATA_SYMBOLS <- tbl(hydat_con, "DATA_SYMBOLS") %>%
  collect()
use_data(DATA_SYMBOLS, overwrite = TRUE)

DBI::dbDisconnect(hydat_con)
