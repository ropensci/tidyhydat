#.onAttach <- function(libname, pkgname){
#
#  hydat_path = Sys.getenv("hydat")
#    if(!is.na(hydat_path)){
#      ## Read on database
#      hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
#      
#      path_to_test = dplyr::tbl(hydat_con, "VERSION") %>%
#        dplyr::collect() %>%
#        dplyr::mutate(Date = lubridate::ymd_hms(Date)) %>%
#        mutate(file = paste0(
#          "http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/Hydat_sqlite3_",
#          substr(Date, 1,4),
#          substr(Date, 6,7),
#          substr(Date, 9,10),
#          ".zip")) %>%
#        pull(file)
#      
#      if(httr::http_error(path_to_test) == TRUE){
#        packageStartupMessage("Your version of hydat is out of date. Navigate to http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/ and download the latest version.")
#      }
#      
#      DBI::dbDisconnect(hydat_con)
#    }
#  
#
#}

#' Removes notes from R CMD check for NSE
#'
.onLoad <- function(libname = find.package("tidyhydat"), pkgname = "tidyhydat"){
  # CRAN Note avoidance
  if(getRversion() >= "2.15.1")
    utils::globalVariables(
      # Vars used in Non-Standard Evaluations, declare here to avoid CRAN warnings
      ## This is getting ridiculous
      c("PROV_TERR_STATE_LOC", "FULL_MONTH", "MAX", "DAY", "FLOW", "MONTH",
        "YEAR", "Date","stns", "FLOW", "LEVEL","PRECISION_CODE","NO_DAYS",
        "variable","temp","DATA_SYMBOLS","FLOW_SYMBOL","SYMBOL_EN","Value",
        "Unit","Grade","Symbol","Approval","Parameter","Code","param_id","Name_En",
        "Name_Fr","LEVEL_SYMBOL","ID","val","key","CODE","GRADE","SYMBOL",
        "DATA_TYPE","DATA_TYPES","DATA_TYPE_EN","MAX_DAY","MAX_MONTH","MAX_SYMBOL","MEAN",
        "MIN","MIN_DAY","MIN_MONTH","MIN_SYMBOL","SUM_STAT","HOUR", "MINUTE", "PEAK", 
        "PEAK_CODE", "REGIONAL_OFFICE_ID","TIME_ZONE","SUSCON",  "CONCENTRATION","CONCENTRATION_EN",
        "CONVERSION_FACTOR", "DATE", "DATUM_EN","DATUM_EN_FROM", "DATUM_EN_TO", "LOAD", "MEASUREMENT_EN",
        "MONTH_FROM", "MONTH_TO", "OPERATION_EN", "PARTICLE_SIZE", "PERCENT", "REMARK_EN", "REMARK_TYPE_EN",
        "SAMPLER_TYPE", "SAMPLE_REMARK_EN", "SAMPLING_VERTICAL_EN", "SAMPLING_VERTICAL_LOCATION", "SED_DATA_TYPE_EN",
        "SV_DEPTH2", "TEMPERATURE", "TIME_SYMBOL", "YEAR_FROM", "YEAR_TO","condensed_date",
        "." # piping requires '.' at times
      )
    )
  invisible()
}
