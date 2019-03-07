# Copyright 2018 Province of British Columbia
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

#' plot realtime object
#' 
#' This method plots daily time series data from the ECCC datamart. Functionality is very basic
#' and is intended for exploratory purposes only.
#' 
#' @inheritParams plot.hy
#' @param Parameter Parameter of interest. Either "Flow" or "Level". Defaults to "Flow".

#' 
#' @method plot realtime
#' @name plot
#' 
#' @examples 
#' \dontrun{
#' # One station
#' fraser <- realtime_dd("08MF005")
#' plot(fraser)
#' }
#' 
#' @export

plot.realtime <- function(x = NULL, Parameter = c("Flow","Level"), ...){
  #browser()
  rldf = x
  
  Parameter <- match.arg(Parameter)
  
  if(length(unique(rldf$STATION_NUMBER)) > 1L) {
    stop("realtime plot methods only work with objects that contain one station", call. = FALSE)
  }

  if(is.null(rldf)) stop("Station(s) not present in the datamart")
  
  ## Is there any NA's in the flow data?
  if(any(is.na(rldf[rldf$Parameter == "Flow",]$Value)) & Parameter == "Flow"){
    rldf <- rldf[rldf$Parameter == "Level",]
    message(paste0(rldf$STATION_NUMBER," is lake level station. Defaulting Parameter = 'Level'"))
  } else{
    rldf <- rldf[rldf$Parameter == Parameter,]
  }
  
  
  
  
  ## Join with meta data to get station name
  rldf <- dplyr::left_join(rldf, tidyhydat::allstations, by = c("STATION_NUMBER","PROV_TERR_STATE_LOC"))
  
  rldf$STATION <- paste(rldf$STATION_NAME, rldf$STATION_NUMBER, sep = " - ")
  
  rldf$STATION <- factor(rldf$STATION)
  
  
  y_axis <- ifelse(Parameter == "Flow", expression(Discharge~(m^3/s)), "Level (m)")
  
  ## Set the palette
  #palette(rainbow(length(unique(rldf$STATION_NUMBER))))
  
  graphics::plot(Value ~ Date,
                 data = rldf,
                 main= unique(rldf$STATION),
                 xlab="Date", 
                 ylab="",
                 bty= "L",
                 pch = 20, cex = 1)
  
  graphics::title(ylab=y_axis, line=2.25)
  
  
  
}



#' Convenience function to plot realtime data
#' 
#' This is an easy way to visualize a single station using base R graphics. 
#' More complicated plotting needs should consider using \code{ggplot2}. Inputting more 
#' 5 stations will result in very busy plots and longer load time. Legend position will
#' sometimes overlap plotted points.
#' 
#' @param station_number A seven digit Water Survey of Canada station number. Can only be one value.
#' @param Parameter Parameter of interest. Either "Flow" or "Level". Defaults to "Flow".
#' 
#' @return A plot of recent realtime values
#' 
#' @examples 
#' \dontrun{
#' ## One station
#' realtime_plot("08MF005")
#' 
#' ## Multiple stations
#' realtime_plot(c("07EC002","01AD003"))
#' }
#' 
#' @export

realtime_plot <- function(station_number = NULL, Parameter = c("Flow","Level")){
  
  Parameter <- match.arg(Parameter)
  
  if(length(station_number) > 1L) stop("realtime_plot only accepts one station number")
  
  rldf <- realtime_dd(station_number)
  
  if(is.null(rldf)) stop("Station(s) not present in the datamart")
  
  ## Is there any NA's in the flow data?
  if(any(is.na(rldf[rldf$Parameter == "Flow",]$Value)) & Parameter == "Flow"){
    rldf <- rldf[rldf$Parameter == "Level",]
    message(paste0(station_number," is lake level station. Defaulting Parameter = 'Level'"))
  } else{
    rldf <- rldf[rldf$Parameter == Parameter,]
  }
  
  
  
  
  ## Join with meta data to get station name
  rldf <- dplyr::left_join(rldf, realtime_stations(), by = c("STATION_NUMBER","PROV_TERR_STATE_LOC"))
  
  rldf$STATION <- paste(rldf$STATION_NAME, rldf$STATION_NUMBER, sep = " - ")
  
  rldf$STATION <- factor(rldf$STATION)
  
  
  y_axis <- ifelse(Parameter == "Flow", expression(Discharge~(m^3/s)), "Level (m)")
  
  ## Set the palette
  #palette(rainbow(length(unique(rldf$STATION_NUMBER))))
  
  graphics::plot(Value ~ Date,
                 data = rldf,
                 col = rldf$STATION,
                 main="Realtime Water Survey of Canada Gauges",
                 xlab="Date", 
                 ylab="",
                 bty= "L",
                 pch = 20, cex = 1)
  
  graphics::title(ylab=y_axis, line=2.25)

  graphics::legend(x = "topright",
         legend = unique(rldf$STATION), 
         fill = unique(rldf$STATION),
         bty = "n",
         cex = 0.75)
  
  
}
