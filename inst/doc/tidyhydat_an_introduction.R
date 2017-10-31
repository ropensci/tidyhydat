## ----options, include=FALSE----------------------------------------------
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE, fig.width = 8, fig.height = 12)

## ----packages, warning=FALSE, message=FALSE, echo = TRUE-----------------
library(tidyhydat)
library(dplyr)

## ---- eval=FALSE---------------------------------------------------------
#  download_hydat()

## ----example1, warning=FALSE---------------------------------------------
hy_daily_flows(station_number = "08LA001")

## ----example2, warning=FALSE---------------------------------------------
PEI_stns <- hy_stations() %>%
  filter(HYD_STATUS == "ACTIVE") %>%
  filter(PROV_TERR_STATE_LOC == "PE") %>%
  pull(STATION_NUMBER)

PEI_stns

hy_daily_flows(station_number = PEI_stns)

## ---- example3-----------------------------------------------------------
search_stn_name("canada") %>%
  pull(STATION_NUMBER) %>%
  hy_daily_flows()

## ----warning=FALSE, warning=FALSE, message=FALSE, eval=FALSE-------------
#  hy_daily_flows(station_number = "08LA001",
#                 start_date = "1981-01-01", end_date = "1981-12-31")

## ---- eval=FALSE---------------------------------------------------------
#  realtime_stations(prov_terr_state_loc = "PE")

## ----stations, eval=FALSE------------------------------------------------
#  hy_stations(prov_terr_state_loc = "PE")

## ---- eval=FALSE---------------------------------------------------------
#  realtime_dd(station_number = "08LG006")

## ---- eval=FALSE---------------------------------------------------------
#  realtime_dd(prov_terr_state_loc = "PE")

## ---- echo=TRUE, eval=TRUE-----------------------------------------------
data("param_id")
param_id

## ---- eval=FALSE---------------------------------------------------------
#  ## Get token
#  token_out <- token_ws()
#  
#  ## Input station_number, parameters and date range
#  ws_test <- realtime_ws(station_number = "08LG006",
#                                  parameters = c(46,5), ## Water level and temperature
#                                  start_date = "2017-06-25",
#                                  end_date = "2017-07-24",
#                                  token = token_out)

## ---- eval = FALSE-------------------------------------------------------
#  file.edit("~/.Renviron")

## ---- eval=FALSE---------------------------------------------------------
#  ## Credentials for ECCC web service
#  WS_USRNM = "here is the username that ECCC gave you"
#  WS_PWD = "here is the password that ECCC gave you"

## ---- echo=TRUE----------------------------------------------------------
search_stn_name("liard")

## ---- echo=TRUE----------------------------------------------------------
search_stn_number("08MF")

