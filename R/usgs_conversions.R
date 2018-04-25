usgs_to_wsc_streamflow <- function(.data){
  
  ## What is the variable we are dealing with?
  variableCode <- attr(.data, "variableInfo")$unit

  if(!any(parameter_units %in% check_valid_usgs_param(parameter = "discharge"))){
    stop(paste0(parameter_units," is an unrecognized unit for this conversion"))
  }
  
  ## Proceed with the conversion
  conv <- dplyr::as_tibble(.data)
  
  conv$Parameter <- "Flow"
  
  if(parameter_units == "ft3/s"){
    ## Convert ft3/s to m3/s
    conv$Value <- 28.3168*conv$X_00060_00003
  }
  
  if(parameter_units == "m3/sec"){
    conv$Value <- conv$X_00060_00003
  } 
  
  conv$STATION_NUMBER <- conv$site_no
  conv$Symbol <- conv$X_00060_00003_cd
  
  conv[c("STATION_NUMBER", "Date", "Parameter", "Value", "Symbol")]
  
}


check_valid_usgs_param <- function(parameter){
  
  ## discharge and height are possible values
  
  df <- dataRetrieval::parameterCdFile[grep(parameter, parameterCdFile$parameter_nm, ignore.case = TRUE),]
  unique(df$parameter_units)
}

