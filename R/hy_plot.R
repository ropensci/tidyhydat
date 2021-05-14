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


#' Plot historical and realtime data
#' 
#' This method plots either daily time series data from HYDAT or realtime data from
#' the datamart. These plots are intended to be convenient and quick methods to 
#' visualize hydrometric data.
#' 
#' @param x Object created by either a hy_daily_* or realtime_dd data retrieval function
#' @param Parameter Parameter of interest. Either "Flow" or "Level". Defaults to "Flow".
#' @param ... passed to [plot()]
#' 
#' @method plot hy
#' @name plot
#' 
#' @examples 
#' \dontrun{
#' # One station
#' fraser <- hy_daily_flows("08MF005")
#' plot(fraser)
#' }
#' 
#' @export
#' 
plot.hy <- function(x = NULL, ...){
  if(!all(c("STATION_NUMBER", "Date", "Parameter", "Value") %in% names(x))){
    stop("plot methods only currently accept daily values", call. = FALSE)
  }
  
  ### Join with meta data to get station name
  hydf <- dplyr::left_join(x, 
                           suppressMessages(tidyhydat::allstations), 
                           by = c("STATION_NUMBER"))
  
  hydf$STATION <- paste(hydf$STATION_NAME, hydf$STATION_NUMBER, sep = " - ")
  
  hydf$STATION <- factor(hydf$STATION)
  
  num_stns <- length(unique(hydf$STATION))
  
  if(num_stns > 4L) stop("You are trying to plot more than four stations at once.", call. = FALSE)
  
  if(num_stns > 2L){
    m <- matrix(c(1,1,2,3,4,5,6,6),nrow = 4,ncol = 2,byrow = TRUE)
    graphics::layout(mat = m,heights = c(0.1,0.35,0.35,0.2))
  } 
  
  if(num_stns == 2L){
    m <- matrix(c(1,1,2,3,4,4),nrow = 3,ncol = 2,byrow = TRUE)
    graphics::layout(mat = m,heights = c(0.2,0.6,0.2))
  } 
  
  if(num_stns == 1L){
    m <- matrix(c(1,2,3),nrow = 3,ncol = 1,byrow = TRUE)
    graphics::layout(mat = m,heights = c(0.2,0.6,0.2))
  } 
  
  graphics::par(mar=c(1,1,1,1))
  graphics::plot.new()
  graphics::text(0.5,0.5,"Historical Water Survey of Canada Gauges",cex=2,font=2)
  
  for(i in seq_along(unique(hydf$STATION))){
    graphics::par(mar = c(4, 5, 2, 1), 
        mgp = c(3.1, 0.4, 0), 
        las = 1, 
        tck = -.01, 
        xaxs = "i", yaxs = "i") 
    
    graphics::plot(Value ~ Date,
                   data = hydf[hydf$STATION == unique(hydf$STATION)[i],],
                   xlab = "Date", 
                   ylab = eval(parse(text = label_helper(unique(hydf$Parameter)))),
                   axes = FALSE,
                   pch = 20, 
                   ylim = c(0, max(hydf[hydf$STATION == unique(hydf$STATION)[i],]$Value, na.rm = TRUE)),
                   cex = 0.75,
                   frame.plot = TRUE,
                   ...)
    
    at_y = utils::head(pretty(hydf[hydf$STATION == unique(hydf$STATION)[i],]$Value), -1)
    graphics::mtext(side = 2, text = at_y, at = at_y, 
          col = "grey20", line = 1, cex = 0.75)
    
    at_x = utils::tail(utils::head(pretty(hydf[hydf$STATION == unique(hydf$STATION)[i],]$Date), -1), -1)
    graphics::mtext(side = 1, text = format(at_x, "%Y"), at = at_x, col = "grey20", line = 1, cex = 0.75)

    graphics::title(main=paste0(unique(hydf$STATION)[i]), cex.main = 1.1)
    
  }
  
  
  graphics::plot(1, type = "n", axes=FALSE, xlab="", ylab="")

  invisible(TRUE)
  
}


label_helper <- function(parameter){
  x = dplyr::case_when(
    parameter == "Flow" ~ 'expression(paste("Discharge (m" ^3/s, ")"))',
    parameter == "Level" ~ 'expression("Water Level (m)")',
    parameter == "Load" ~ 'expression("Sediment load (tonnes)")',
    parameter == "Suscon" ~ 'expression("Suspended Sediment (mg/L)")'
  )
  
  return(x)
}


#' This function is deprecated in favour of generic plot methods
#' 
#' This is an easy way to visualize a single station using base R graphics. 
#' More complicated plotting needs should consider using \code{ggplot2}. Inputting more 
#' 5 stations will result in very busy plots and longer load time. Legend position will
#' sometimes overlap plotted points.
#' 
#' @param station_number A (or several) seven digit Water Survey of Canada station number. 
#' @param Parameter Parameter of interest. Either "Flow" or "Level".
#' 
#' @export
hy_plot <- function(station_number = NULL, Parameter = c("Flow","Level", "Suscon","Load")){
  message("hy_plot has been deprecated in favour of using the generic R plot method and will disappear in future versions.")
  
  
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
                   col = hydf$STATION,
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
