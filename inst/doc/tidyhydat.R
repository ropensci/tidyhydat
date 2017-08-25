## ----options, include=FALSE----------------------------------------------
#render_keep_md = function(vignette_name){
#  rmarkdown::render(paste0("./vignettes/",vignette_name, ".Rmd"), clean=FALSE)
#  files_to_remove = paste0("./vignettes/",vignette_name,c(".html",".md",".utf8.md"))
#  lapply(files_to_remove, file.remove)
#  
#  file.rename(from = paste0("./vignettes/",vignette_name, ".knit.md"), to = paste0("./vignettes/",vignette_name, ".md"))
#}
#
#
#render_keep_md("tidyhydat")

knitr::opts_chunk$set(echo = TRUE, warning = FALSE, messages = FALSE, fig.width = 8, fig.height = 12)

## ----packages, warning=FALSE, message=FALSE, echo = FALSE----------------
library(tidyverse)
library(tidyhydat)
library(dbplyr)

## ---- echo = FALSE-------------------------------------------------------
hydat_con <- DBI::dbConnect(RSQLite::SQLite(), 'H:/Hydat.sqlite3')
tbl(hydat_con, "DLY_FLOWS") %>%
  filter(STATION_NUMBER == "08MF005")# %>%
  #select(STATION_NUMBER:FLOW_SYMBOL10) %>%
  #mutate(`Truncated for the sake of brevity` = NA) %>%
  #glimpse()

## ---- echo = TRUE, message=FALSE-----------------------------------------
library(tidyhydat)
DLY_FLOWS(hydat_path = "H:/Hydat.sqlite3",
          STATION_NUMBER = "08MF005",
          start_date = "1992-03-15",
          end_date = "1992-04-15")

## ----example, warning=FALSE, message=FALSE, eval=FALSE-------------------
#  DLY_FLOWS(STATION_NUMBER = "08LA001", hydat_path = "H:/Hydat.sqlite3")

## ----warning=FALSE, warning=FALSE, message=FALSE, eval=FALSE-------------
#  DLY_FLOWS(STATION_NUMBER = c("08LA001","08NL071"), hydat_path = "H:/Hydat.sqlite3")

## ----warning=FALSE, warning=FALSE, message=FALSE, eval=FALSE-------------
#  DLY_FLOWS(PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")

## ----warning=FALSE, warning=FALSE, message=FALSE, eval=FALSE-------------
#  DLY_FLOWS(STATION_NUMBER = "08LA001", hydat_path = "H:/Hydat.sqlite3",
#            start_date = "1981-01-01", end_date = "1981-12-31")

## ---- echo=TRUE----------------------------------------------------------
search_name("liard")

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
download_realtime_dd(STATION_NUMBER = "08LG006", PROV_TERR_STATE_LOC = "BC")

