## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE, fig.width=7, fig.height=7)

## ----pkg_load_1----------------------------------------------------------
library(tidyhydat)
library(dplyr)
library(ggplot2)
library(lubridate)

## ----dl_hy, eval=FALSE---------------------------------------------------
#  download_hydat()

## ---- eval= FALSE, warning=FALSE, message=FALSE--------------------------
#  longest_record_data <- hy_stn_data_range() %>%
#    filter(RECORD_LENGTH == max(RECORD_LENGTH)) %>%
#    pull(STATION_NUMBER) %>%
#    hy_daily_flows()

## ----data_range----------------------------------------------------------
hy_stn_data_range()

## ----filter--------------------------------------------------------------
hy_stn_data_range() %>%
  filter(RECORD_LENGTH == max(RECORD_LENGTH))

## ----pull----------------------------------------------------------------
hy_stn_data_range() %>%
  filter(RECORD_LENGTH == max(RECORD_LENGTH)) %>%
  pull(STATION_NUMBER)

## ---- full1--------------------------------------------------------------
longest_record_data <- hy_stn_data_range() %>%
  filter(RECORD_LENGTH == max(RECORD_LENGTH)) %>%
  pull(STATION_NUMBER) %>%
  hy_daily_flows()

## ----hy_stns-------------------------------------------------------------
hy_stations(station_number = unique(longest_record_data$STATION_NUMBER)) %>%
  as.list()

## ----old_rec-------------------------------------------------------------
longest_record_data %>%
  ggplot(aes(x = Date, y = Value)) +
  geom_line() +
  geom_point() +
  geom_smooth() +
  labs(y = "Discharge (m)") +
  theme_minimal()

## ----old_rec_yr----------------------------------------------------------
longest_record_data %>%
  mutate(dayofyear = yday(Date), Year = year(Date)) %>%
  mutate(dayofyear_formatted = as.Date(dayofyear - 1, origin = "2016-01-01")) %>% ## leap year as placeholder
  ggplot(aes(x = dayofyear_formatted, y = Value, colour = Year)) +
  geom_line() +
  geom_point() +
  scale_x_date(date_labels = "%b %d") +
  labs(y = "Discharge (m)") +
  theme_minimal()

## ----tile_plt------------------------------------------------------------
longest_record_data %>%
  mutate(dayofyear = yday(Date), Year = year(Date)) %>%
  mutate(dayofyear_formatted = as.Date(dayofyear - 1, origin = "2016-01-01")) %>% ## leap year as placeholder
  ggplot(aes(x = dayofyear_formatted, y = Year, fill = Value)) +
  geom_tile() +
  scale_x_date(date_labels = "%b %d") +
  scale_fill_gradientn(name = "Discharge (m^3/s)", colours = rainbow(10)) +
  labs(y = "Year", x = "Date") +
  theme_minimal() +
  theme(legend.position="bottom")

## ----pkg_load_2----------------------------------------------------------
library(tidyhydat)
library(dplyr)
library(ggplot2)
library(lubridate)

## ------------------------------------------------------------------------
nunavut_stn_flows <- hy_stations() %>%
  filter(HYD_STATUS == "ACTIVE") %>%
  filter(REAL_TIME == TRUE) %>%
  filter(RHBN == TRUE) %>%
  filter(PROV_TERR_STATE_LOC == "NU") %>%
  pull(STATION_NUMBER) %>%
  hy_stn_data_range() %>%
  filter(RECORD_LENGTH == max(RECORD_LENGTH)) %>%
  pull(STATION_NUMBER) %>%
  hy_daily_flows()

## ------------------------------------------------------------------------
pct_flow <- nunavut_stn_flows %>%
  mutate(dayofyear = yday(Date), Year = year(Date)) %>%
  filter(dayofyear %in% yday(seq.Date(from = (Sys.Date()-30), 
                                     to = Sys.Date(), by = "day"))) %>%
  group_by(dayofyear) %>%
  mutate(prctile = ecdf(Value)(Value)) %>%
  mutate(Date_no_year = dmy(paste0(day(Date),"-",month(Date),"-",year(Sys.Date()))))

## ----realtime------------------------------------------------------------
nunavut_realtime <- realtime_dd(unique(nunavut_stn_flows$STATION_NUMBER)) %>%
  mutate(Date_day = as.Date(Date)) %>%
  group_by(Date_day) %>%
  summarise(Value = mean(Value, na.rm = TRUE))

## ---- pcrtile_plt--------------------------------------------------------
ggplot(pct_flow, aes(x = Date_no_year, y = Value)) +
  geom_point(aes(colour = prctile)) +
  geom_line(data = nunavut_realtime, aes(x = Date_day), colour = "black") +
  geom_point(data = nunavut_realtime, aes(x = Date_day, shape = factor(year(Date_day))), colour = "black") +
  scale_colour_gradientn(name = "Discharge Percentile", colours = rainbow(10)) +
  scale_shape_discrete(name = "Year") +
  theme_minimal() +
  labs(title = "Historical flow relative to current year",
       subtitle = "Current year flows are displayed in black",
       caption = "Real time data is presents AS IS and represents unapproved data",
       x = "Date", y = "Discharge (m^3/s)")

