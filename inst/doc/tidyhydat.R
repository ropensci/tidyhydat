## ----options, include=FALSE----------------------------------------------
knitr::opts_chunk$set(echo = TRUE, warning = FALSE, messages = FALSE, fig.width = 8, fig.height = 12)

## ----packages, warning=FALSE, message=FALSE, echo = FALSE----------------
library(tidyverse)
library(tidyhydat)
library(dbplyr)

## ---- eval=FALSE---------------------------------------------------------
#  download_hydat(dl_hydat_here = "H:/")

## ---- eval = FALSE-------------------------------------------------------
#  STATIONS(hydat_path = "H:/Hydat.sqlite3")

## ---- eval= FALSE, echo = TRUE-------------------------------------------
#  file.edit("~/.Renviron")

## ---- eval=FALSE, echo=TRUE----------------------------------------------
#  hydat = "YOUR HYDAT PATH"

## ----warning=FALSE, warning=FALSE, message=FALSE, eval=FALSE-------------
#  DLY_FLOWS(STATION_NUMBER = c("08LA001","08NL071"))

## ----warning=FALSE, warning=FALSE, message=FALSE, eval=FALSE-------------
#  DLY_FLOWS(PROV_TERR_STATE_LOC = "PE")

## ----warning=FALSE, warning=FALSE, message=FALSE, eval=FALSE-------------
#  DLY_FLOWS(STATION_NUMBER = "08LA001", hydat_path = "H:/Hydat.sqlite3",
#            start_date = "1981-01-01", end_date = "1981-12-31")

## ---- echo=TRUE----------------------------------------------------------
search_name("liard")

## ---- eval= FALSE, echo = TRUE-------------------------------------------
#  file.edit("~/.Renviron")

## ---- eval=FALSE, echo=TRUE----------------------------------------------
#  hydat = "YOUR HYDAT PATH"

## ---- eval=FALSE---------------------------------------------------------
#  realtime_network_meta(PROV_TERR_STATE_LOC = "PE")

## ----stations, eval=FALSE------------------------------------------------
#  STATIONS(PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")

## ---- echo=TRUE, eval=TRUE-----------------------------------------------
data("param_id")
param_id

## ---- eval=FALSE---------------------------------------------------------
#  ## Get token
#  token_out <- get_ws_token(username = Sys.getenv("WS_USRNM"), password = Sys.getenv("WS_PWD"))
#  
#  ## Input STATION_NUMBER, parameters and date range
#  ws_test <- download_realtime_ws(STATION_NUMBER = "08LG006",
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

## ------------------------------------------------------------------------
download_realtime_dd(STATION_NUMBER = "08LG006")

## ------------------------------------------------------------------------
download_realtime_dd(PROV_TERR_STATE_LOC = "PE")

