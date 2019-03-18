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
#' 
#' @describeIn plot plot.realtime
#'
#' @method plot realtime
#'
#' @examples 
#' \dontrun{
#' # One station
#' fraser_realtime <- realtime_dd("08MF005")
#' plot(fraser_realtime)
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
  
  graphics::par(mar = c(4, 5, 2, 1), 
                mgp = c(3.1, 0.4, 0), 
                las = 1, 
                tck = -.01, 
                xaxs = "i", yaxs = "i") 
  
  graphics::plot(Value ~ Date,
                 data = rldf,
                 xlab = "Date", 
                 ylab = eval(parse(text = label_helper(unique(rldf$Parameter)))),
                 axes = FALSE,
                 col = rgb(130, 214, 255, alpha = 150, maxColorValue = 255),
                 #ylim = c(min(rldf$Value, na.rm = TRUE), max(rldf$Value, na.rm = TRUE) + 2),
                 pch = 20, 
                 cex = 0.75,
                 frame.plot = TRUE,
                 ...)
  
  at_y = tail(head(pretty(rldf$Value), -1), -1)
  mtext(side = 2, text = at_y, at = at_y, 
        col = "grey20", line = 1, cex = 1)
  
  at_x = tail(head(pretty(rldf$Date), -1), -1)
  mtext(side = 1, text = format(at_x, "%b-%d"), at = at_x, col = "grey20", line = 1, cex = 1)
  
  graphics::title(main=paste0(unique(rldf$STATION)), cex.main = 1.1)
  
  
  
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
