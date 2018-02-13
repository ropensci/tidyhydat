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
#' This is an easy way to visualize a single station using base R graphics. 
#' More complicated plotting needs should consider using \code{ggplot2}. Inputting more 
#' 5 stations will result in very busy plots and longer load time. Legend position will
#' sometimes overlap plotted points.
#' 
#' @param station_number A (or several) seven digit Water Survey of Canada station number. 
#' @param Parameter Parameter of interest. Either "Flow" or "Level".
#' 
#' @return A plot of recent realtime values
#' 
#' @examples 
#' \dontrun{
#' ## One station
#' hy_plot("08MF005")
#' 
#' ## Multiple stations
#' hy_plot(c("07EC002","01AD003"))
#' }
#' 
#' @export

hy_plot <- function(station_number = NULL, Parameter = c("Flow","Level", "Suscon","Load")){
  
  Parameter <- match.arg(Parameter, several.ok = TRUE)
  
  hydf <- hy_daily(station_number)
  
  hydf <- hydf[hydf$Parameter %in% Parameter,]
  
  params <- unique(hydf$Parameter)
  
  ### Join with meta data to get station name
  hydf <- dplyr::left_join(hydf, 
                           suppressMessages(hy_stations()), 
                           by = c("STATION_NUMBER"))
  
  hydf$STATION <- paste(hydf$STATION_NAME, hydf$STATION_NUMBER, sep = "\n")
  
  hydf$STATION <- factor(hydf$STATION)
  
  
  #y_axis <- ifelse(Parameter == "Flow", expression(Discharge~(m^3/s)), "Level (m)")
  
  ## Set the palette
  #palette(rainbow(length(unique(rldf$STATION_NUMBER))))
  
  if(length(params) > 2){
  #par(mfrow = c(2, 2))
    m <- matrix(c(1,1,2,3,4,5,6,6),nrow = 4,ncol = 2,byrow = TRUE)
    
    graphics::layout(mat = m,heights = c(0.1,0.35,0.35,0.2))
  } 
  
  if(length(params) == 2){
    m <- matrix(c(1,1,2,3,4,4),nrow = 3,ncol = 2,byrow = TRUE)
    
    graphics::layout(mat = m,heights = c(0.2,0.6,0.2))
  } 
  
  
  if(length(params) == 1){
    m <- matrix(c(1,2,3),nrow = 3,ncol = 1,byrow = TRUE)
    
    graphics::layout(mat = m,heights = c(0.2,0.6,0.2))
  } 

  graphics::par(mar=c(1,1,1,1))
  graphics::plot.new()
  #graphics::plot(1, type = "n", axes=FALSE, xlab="", ylab="")
  graphics::text(0.5,0.5,"Historical Water Survey of Canada Gauges",cex=2,font=2)
  
  for(i in seq_along(params)){
    graphics::par(mar = c(2,2,1,1))
    graphics::plot(Value ~ Date,
                 data = hydf[hydf$Parameter == params[i],],
                 col = STATION,
                 xlab="Date", 
                 ylab = paste0(params[i]),
                 bty= "L",
                 pch = 20, cex = 1)
    
    graphics::title(main=paste0(params[i]), cex.main = 1.75)
  
  
  }
  
  
  graphics::plot(1, type = "n", axes=FALSE, xlab="", ylab="")
  graphics::legend(x = "top", inset = 0,
                   legend = unique(hydf$STATION), 
                   fill = unique(hydf$STATION),
                   bty = "n",
                   cex = 1, horiz = TRUE)
  
  
}
