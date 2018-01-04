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

#' Convenience function to plot realtime data
#' 
#' This is a quick and easy way to visualize a single station using base R graphics. 
#' More complicated plotting needs should consider using \code{ggplot2}. Inputting more 
#' 5 stations will result in very busy plots and longer load time. 
#' 
#' @param station_number A (or several) seven digit Water Survey of Canada station number. 
#' @param Parameter Parameter of interest. Either "Flow" or "Level".
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
  
  Parameter = match.arg(Parameter)
  
  #if(length(station_number) > 1L) stop("realtime_plot only accepts one station number")
  
  rldf <- realtime_dd(station_number)
  
  if(is.null(rldf)) stop("Station(s) not present in the datamart")
  
  rldf <- rldf[rldf$Parameter == Parameter,]
  rldf$STATION_NUMBER <- factor(rldf$STATION_NUMBER)
  
  #stn_name <- search_stn_number(station_number)$STATION_NAME
  
  y_axis <- ifelse(Parameter == "Flow", "Discharge (m^3/s)", "Level (m)")
  
  
  ## Set the palette
  #palette(rainbow(length(unique(rldf$STATION_NUMBER))))
  
  graphics::plot(Value ~ Date,
                 data = rldf,
                 col = STATION_NUMBER,
                 main="Realtime Water Survey of Canada Gauges",
                 xlab="Date", 
                 ylab=paste0(y_axis),
                 bty= "L",
                 pch = 20, cex = 1)

  graphics::legend(x = "topright",
         legend = unique(rldf$STATION_NUMBER), 
         fill = unique(rldf$STATION_NUMBER),
         bty = "n",
         cex = 0.75)
  
  
}
