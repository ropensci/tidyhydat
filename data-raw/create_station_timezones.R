library(lutz) ##dev version devtools::install_github("ateucher/lutz")
library(tidyhydat)
library(tidyverse)
library(devtools)

offsets <- map_df(OlsonNames(), ~ {
  tz = .x
  gmt_offset = as.POSIXlt(Sys.time(), tz = .x)$gmtoff
  if (is.null(gmt_offset)) gmt_offset <- 0
  data.frame(tz, 
             gmt_offset_h = gmt_offset / 3600, 
             stringsAsFactors = FALSE)
})

station_timezones <- hy_stations() %>% 
  mutate(tz = tz_lookup_coords2(LATITUDE, LONGITUDE)) %>% 
  select(STATION_NUMBER, tz) #%>% 
  #left_join(offsets, by = c("tz" = "tz"))

use_data(station_timezones, overwrite = TRUE)

