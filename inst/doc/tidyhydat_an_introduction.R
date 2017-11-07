## ----options, include=FALSE----------------------------------------------
knitr::opts_chunk$set(echo = TRUE, 
                      warning = FALSE, 
                      message = FALSE, 
                      eval = nzchar(Sys.getenv("hydat_eval")),
                      fig.width=7, fig.height=7)

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

## ---- echo=TRUE----------------------------------------------------------
search_stn_name("liard")

## ---- echo=TRUE----------------------------------------------------------
search_stn_number("08MF")

