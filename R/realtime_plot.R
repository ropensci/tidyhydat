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
#' More complicated plotting needs should consider using \code{ggplot2}. 
#' 
#' @inheritParams hy_stations
#' @param Parameter Parameter of interest. Either "Flow" or "Level".
#' 
#' @return A plot of recent realtime values
#' 
#' @examples 
#' \dontrun{
#' realtime_plot("08MF005")
#' }
#' 
#' @export

realtime_plot <- function(station_number = NULL, Parameter = c("Flow","Level")){
  
  Parameter = match.arg(Parameter)
  
  if(length(station_number) > 1L) stop("realtime_plot only accepts one station number")
  
  rldf <- realtime_dd(station_number)
  
  if(is.null(rldf)) stop("Station not present in the datamart")
  
  rldf <- rldf[rldf$Parameter == Parameter,]
  
  stn_name <- search_stn_number(station_number)$STATION_NAME
  
  y_axis <- ifelse(Parameter == "Flow", "Discharge (m^3/s)", "Level (m)")
  
  graphics::plot(x = rldf$Date, y = rldf$Value, 
       type = "l", 
       col = "blue",
       main=paste0(stn_name, " - ", station_number, "\n Parameter of interest: ", Parameter),
       xlab="Date", ylab=paste0(y_axis))
  
  
}
