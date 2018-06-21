library(lutz) ##dev version devtools::install_github("ateucher/lutz")
library(tidyhydat)
library(tidyverse)
library(devtools)

station_timezones <- hy_stations() %>% 
  mutate(lutz_tz = tz_lookup_coords2(LATITUDE, LONGITUDE)) %>% 
  select(STATION_NUMBER, lutz_tz)

use_data(station_timezones)

