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


## Load in packages
library(purrr)
library(dplyr)
library(dbplyr)

## Create a subset of the data
hydat_con <- DBI::dbConnect(RSQLite::SQLite(), file.path(hy_dir(),"Hydat.sqlite3"))

all_tables <- DBI::dbListTables(hydat_con)

#table_vector <- DBI::dbListTables(hydat_con)
# Don't need all the tables. I will export what I need for testing
table_vector <- c("ANNUAL_INSTANT_PEAKS", "ANNUAL_STATISTICS", 
                  "DLY_FLOWS", "DLY_LEVELS", "SED_DLY_LOADS", "SED_DLY_SUSCON", "SED_SAMPLES", "SED_SAMPLES_PSD", 
                  "STATIONS","STN_REGULATION","STN_REMARKS", "STN_DATUM_CONVERSION", "STN_DATA_RANGE","STN_DATA_COLLECTION",
                  "STN_OPERATION_SCHEDULE","STN_DATUM_UNRELATED")

## List of tables with STATION_NUMBER INFORMATION
list_of_small_tables <- table_vector %>%
  map(~tbl(src = hydat_con, .) %>%
        filter(STATION_NUMBER %in% c("08MF005","08NM083","08NE102","08AA003",
                                     "05AA008","01AP003","08BB005", "05HD008")) %>%
        collect()
      ) %>% 
  set_names(table_vector)

## All tables without STATION_NUMBER
no_stn_table_vector <- all_tables[!all_tables %in% table_vector]

list_of_no_stn_tables <- no_stn_table_vector %>%
  map(~tbl(src = hydat_con, .) %>%
        head(50) %>%
        collect()
  ) %>% 
  set_names(no_stn_table_vector)

SED_DATA_TYPES <- dplyr::tbl(hydat_con, "SED_DATA_TYPES") %>% collect()

DBI::dbDisconnect(hydat_con)

## Create the new smaller database
createIndex <- TRUE

db_path <- "./inst/test_db/tinyhydat.sqlite3"

con <- DBI::dbConnect(RSQLite::SQLite(), db_path)

## Add tables to mini database
imap(table_vector, ~ {DBI::dbWriteTable(con, .x, list_of_small_tables[[.x]], overwrite=TRUE)})
imap(no_stn_table_vector, ~ {DBI::dbWriteTable(con, .x, list_of_no_stn_tables[[.x]], overwrite=TRUE)})

DBI::dbDisconnect(con)

## Check to make sure the tables that I want are in the db
testdb <- DBI::dbConnect(RSQLite::SQLite(), db_path)

## Check to make sure all the tables from HYDAT are in the test db
all(DBI::dbListTables(testdb) %in% all_tables) == TRUE

DBI::dbDisconnect(con)

