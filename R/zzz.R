.onLoad <-
  function(libname = find.package("tidyhydat"),
           pkgname = "tidyhydat") {
    # CRAN Note avoidance
    if (getRversion() >= "2.15.1")
      utils::globalVariables(
        # Vars used in Non-Standard Evaluations, declare here to avoid CRAN warnings
        ## This is getting ridiculous
        c("STATION_NUMBER",
          "STATION_NAME",
          "REAL_TIME",
          "REGULATED",
          "RHBN",
          "LATITUDE",
          "LONGITUDE",
          "PROV_TERR_STATE_LOC",
          "FULL_MONTH",
          "MAX",
          "DAY",
          "FLOW",
          "MONTH",
          "YEAR",
          "Date",
          "stns",
          "FLOW",
          "LEVEL",
          "PRECISION_CODE",
          "NO_DAYS",
          "variable",
          "temp",
          "hy_data_symbols",
          "FLOW_SYMBOL",
          "SYMBOL_EN",
          "Value",
          "Unit",
          "Grade",
          "Symbol",
          "Approval",
          "Parameter",
          "Code",
          "param_id",
          "Name_En",
          "Name_Fr",
          "LEVEL_SYMBOL",
          "ID",
          "val",
          "key",
          "CODE",
          "GRADE",
          "SYMBOL",
          "DATA_TYPE",
          "hy_data_types",
          "DATA_TYPE_EN",
          "MAX_DAY",
          "MAX_MONTH",
          "MAX_SYMBOL",
          "MEAN",
          "MIN",
          "MIN_DAY",
          "MIN_MONTH",
          "MIN_SYMBOL",
          "SUM_STAT",
          "HOUR",
          "MINUTE",
          "PEAK",
          "PEAK_CODE",
          "REGIONAL_OFFICE_ID",
          "TIME_ZONE",
          "SUSCON",
          "CONCENTRATION",
          "CONCENTRATION_EN",
          "CONVERSION_FACTOR",
          "DATE",
          "DATUM_EN",
          "DATUM_EN_FROM",
          "DATUM_EN_TO",
          "LOAD",
          "MEASUREMENT_EN",
          "MONTH_FROM",
          "MONTH_TO",
          "OPERATION_EN",
          "PARTICLE_SIZE",
          "PERCENT",
          "REMARK_EN",
          "REMARK_TYPE_EN",
          "SAMPLER_TYPE",
          "SAMPLE_REMARK_EN",
          "SAMPLING_VERTICAL_EN",
          "SAMPLING_VERTICAL_LOCATION",
          "SED_DATA_TYPE_EN",
          "SV_DEPTH2",
          "TEMPERATURE",
          "TIME_SYMBOL",
          "YEAR_FROM",
          "YEAR_TO",
          "condensed_date",
          "temp2",
          "SYMBOL_FR",
          "SUSCON_SYMBOL",
          "Flow",
          "Level",
          "STATION",
          "." # piping requires '.' at times
        )
      )
    invisible()
  }

# Won't pass cmd check with this uncommented
.onAttach <- function(libname, pkgname) {

  if(!file.exists(file.path(hy_dir(),"Hydat.sqlite3"))){
    packageStartupMessage(
      not_done("tidyhydat requires HYDAT which has not yet been downloaded. Run download_hydat() now.")
      )
  }
  
  ## HYDAT is updated quarterly - should we go check if a new one is available for download?
  ## Only check when there is likely a new version i.e. about 3 months after last version
  if(file.exists(file.path(hy_dir(),"Hydat.sqlite3")) && Sys.Date() > (as.Date(hy_version()$Date) + 115)){
    
    packageStartupMessage(info("Checking for a new version of HYDAT..."))
    
    base_url <- "http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/"
    x <- httr::GET(base_url)
    httr::stop_for_status(x)
    
    ## Extract newest HYDAT
    new_hydat <- as.Date(substr(gsub(
      "^.*\\Hydat_sqlite3_", "",
      httr::content(x, "text")
    ), 1, 8),  "%Y%m%d")
    
    ## Compare that to existing HYDAT
    if (new_hydat != as.Date(hy_version()$Date)){
      packageStartupMessage(
        not_done(
          paste0("Your version of HYDAT is out of date. Use download_hydat() to get the new version."))
        )
    } else{
      packageStartupMessage(congrats("You are using the most current version of HYDAT"))
    }
  }

}
