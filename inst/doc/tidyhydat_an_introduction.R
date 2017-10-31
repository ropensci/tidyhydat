## ----options, include=FALSE----------------------------------------------
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, message = FALSE, fig.width = 8, fig.height = 12)

## ----packages, warning=FALSE, message=FALSE, echo = FALSE----------------
library(tidyhydat)
library(dbplyr)

## ---- eval=FALSE---------------------------------------------------------
#  download_hydat()

## ----warning=FALSE, warning=FALSE, message=FALSE, eval=FALSE-------------
#  hy_daily_flows(station_number = c("08LA001","08NL071"))

## ----warning=FALSE, warning=FALSE, message=FALSE, eval=FALSE-------------
#  hy_daily_flows(prov_terr_state_loc = "PE")

## ----warning=FALSE, warning=FALSE, message=FALSE, eval=FALSE-------------
#  hy_daily_flows(station_number = "08LA001", hydat_path = "H:/Hydat.sqlite3",
#            start_date = "1981-01-01", end_date = "1981-12-31")

## ---- echo=TRUE----------------------------------------------------------
search_stn_name("liard")

## ---- eval=FALSE---------------------------------------------------------
#  realtime_stations(prov_terr_state_loc = "PE")

## ----stations, eval=FALSE------------------------------------------------
#  hy_stations(prov_terr_state_loc = "PE")

## ---- echo=TRUE, eval=TRUE-----------------------------------------------
data("param_id")
param_id

## ---- eval=FALSE---------------------------------------------------------
#  ## Get token
#  token_out <- token_ws(username = Sys.getenv("WS_USRNM"), password = Sys.getenv("WS_PWD"))
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

## ---- eval=FALSE---------------------------------------------------------
#  realtime_dd(station_number = "08LG006")

## ---- eval=FALSE---------------------------------------------------------
#  realtime_dd(prov_terr_state_loc = "PE")

