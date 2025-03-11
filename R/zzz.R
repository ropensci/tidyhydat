# Won't pass cmd check with this uncommented
.onAttach <- function(libname, pkgname) {
  if (interactive()) {
    if (!file.exists(file.path(hy_dir(), "Hydat.sqlite3"))) {
      packageStartupMessage(
        not_done(
          "tidyhydat requires HYDAT which has not yet been downloaded. Run download_hydat() now."
        )
      )
    }

    if (!has_internet()) {
      return(done("No access to internet."))
    }

    ## HYDAT is updated quarterly - should we go check if a new one is available for download?
    ## Only check when there is likely a new version i.e. about 3 months after last version
    if (
      file.exists(file.path(hy_dir(), "Hydat.sqlite3")) &&
        Sys.Date() > (as.Date(hy_version()$Date) + 115)
    ) {
      packageStartupMessage(info("Checking for a new version of HYDAT..."))

      base_url <- "http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/"
      x <- realtime_parser(base_url)

      ## Extract newest HYDAT
      new_hydat <- as.Date(
        substr(
          gsub(
            "^.*\\Hydat_sqlite3_",
            "",
            x
          ),
          1,
          8
        ),
        "%Y%m%d"
      )

      ## Compare that to existing HYDAT
      if (new_hydat != as.Date(hy_version()$Date)) {
        packageStartupMessage(
          not_done(
            paste0(
              "Your version of HYDAT is out of date. Use download_hydat() to get the new version."
            )
          )
        )
      } else {
        packageStartupMessage(congrats(
          "You are using the most current version of HYDAT"
        ))
      }
    }
  }
}

globalVariables(unique(c(
  # hy_annual_instant_peaks:
  "DATA_TYPE_EN",
  "Date",
  "Datetime",
  "DAY",
  "HOUR",
  "MINUTE",
  "MONTH",
  "PEAK",
  "PEAK_CODE",
  "PRECISION_CODE",
  "standard_offset",
  "STATION_NUMBER",
  "station_tz",
  "SYMBOL_EN",
  "YEAR",
  # hy_annual_stats:
  "DATA_TYPE",
  "DATA_TYPE_EN",
  "Date",
  "DAY",
  "MAX",
  "MAX_DAY",
  "MAX_MONTH",
  "MAX_SYMBOL",
  "MEAN",
  "MIN",
  "MIN_DAY",
  "MIN_MONTH",
  "MIN_SYMBOL",
  "MONTH",
  "STATION_NUMBER",
  "SYMBOL_EN",
  "Value",
  "YEAR",
  # hy_daily:
  "Date",
  "STATION_NUMBER",
  # hy_daily_flows:
  "Date",
  "DAY",
  "FLOW",
  "FLOW_SYMBOL",
  "MONTH",
  "NO_DAYS",
  "Parameter",
  "STATION_NUMBER",
  "SYMBOL_EN",
  "SYMBOL_FR",
  "temp",
  "variable",
  "YEAR",
  # hy_daily_levels:
  "Date",
  "DAY",
  "LEVEL",
  "LEVEL_SYMBOL",
  "MONTH",
  "NO_DAYS",
  "Parameter",
  "STATION_NUMBER",
  "SYMBOL_EN",
  "SYMBOL_FR",
  "temp",
  "variable",
  "YEAR",
  # hy_monthly_flows:
  "Date_occurred",
  "DAY",
  "Full_Month",
  "MAX",
  "Month",
  "No_days",
  "STATION_NUMBER",
  "Year",
  # hy_monthly_levels:
  "Date_occurred",
  "DAY",
  "Full_month",
  "MAX",
  "Month",
  "No_days",
  "STATION_NUMBER",
  "Year",
  # hy_sed_daily_loads:
  "Date",
  "DAY",
  "LOAD",
  "MONTH",
  "NO_DAYS",
  "Parameter",
  "STATION_NUMBER",
  "variable",
  "YEAR",
  # hy_sed_daily_suscon:
  "Date",
  "DAY",
  "MONTH",
  "NO_DAYS",
  "Parameter",
  "STATION_NUMBER",
  "SUSCON",
  "SUSCON_SYMBOL",
  "SYMBOL_EN",
  "SYMBOL_FR",
  "variable",
  "YEAR",
  # hy_sed_monthly_loads:
  "Date_occurred",
  "DAY",
  "Full_Month",
  "MAX",
  "Month",
  "No_days",
  "STATION_NUMBER",
  "Year",
  # hy_sed_monthly_suscon:
  "Date_occurred",
  "DAY",
  "Full_Month",
  "MAX",
  "Month",
  "No_days",
  "STATION_NUMBER",
  "Year",
  # hy_sed_samples:
  "CONCENTRATION",
  "CONCENTRATION_EN",
  "DATE",
  "FLOW",
  "SAMPLE_REMARK_EN",
  "SAMPLER_TYPE",
  "SAMPLING_VERTICAL_EN",
  "SAMPLING_VERTICAL_LOCATION",
  "SED_DATA_TYPE_EN",
  "STATION_NUMBER",
  "SV_DEPTH2",
  "SYMBOL_EN",
  "TEMPERATURE",
  "TIME_SYMBOL",
  # hy_sed_samples_psd:
  "DATE",
  "PARTICLE_SIZE",
  "PERCENT",
  "SED_DATA_TYPE_EN",
  "STATION_NUMBER",
  # hy_stations:
  "REAL_TIME",
  "REGIONAL_OFFICE_ID",
  "RHBN",
  # hy_stn_data_coll:
  "DATA_TYPE_EN",
  "MEASUREMENT_EN",
  "OPERATION_EN",
  "STATION_NUMBER",
  "Year_from",
  "YEAR_FROM",
  "YEAR_TO",
  # hy_stn_data_range:
  "YEAR_FROM",
  "YEAR_TO",
  # hy_stn_datum_conv:
  "CONVERSION_FACTOR",
  "DATUM_EN_FROM",
  "DATUM_EN_TO",
  "STATION_NUMBER",
  # hy_stn_datum_unrelated:
  "YEAR_FROM",
  "YEAR_TO",
  # hy_stn_op_schedule:
  "DATA_TYPE_EN",
  "MONTH_FROM",
  "MONTH_TO",
  "STATION_NUMBER",
  "YEAR",
  # hy_stn_regulation:
  "REGULATED",
  # hy_stn_remarks:
  "REMARK_EN",
  "REMARK_TYPE_EN",
  "STATION_NUMBER",
  "YEAR",
  # hy_version:
  "Date",
  # multi_param_msg:
  "STATION_NUMBER",
  # realtime_add_local_datetime:
  "Date",
  "local_datetime",
  "PROV_TERR_STATE_LOC",
  "STATION_NUMBER",
  "station_tz",
  # realtime_daily_mean:
  "Date",
  "Parameter",
  "PROV_TERR_STATE_LOC",
  "STATION_NUMBER",
  "Value",
  # realtime_stations:
  "PROV_TERR_STATE_LOC",
  # realtime_tidy_data:
  "Code",
  "CODE",
  "Date",
  "Flow",
  "Grade",
  "GRADE",
  "key",
  "Level",
  "Parameter",
  "PROV_TERR_STATE_LOC",
  "STATION_NUMBER",
  "Symbol",
  "SYMBOL",
  "Value",
  # search_stn_name:
  "LATITUDE",
  "LONGITUDE",
  "PROV_TERR_STATE_LOC",
  "STATION_NAME",
  "STATION_NUMBER",
  # search_stn_number:
  "LATITUDE",
  "LONGITUDE",
  "PROV_TERR_STATE_LOC",
  "STATION_NAME",
  "STATION_NUMBER",
  # single_realtime_station:
  "Date",
  # station_choice:
  "STATION_NUMBER",
  # realtime_ws:
  "Approval",
  "Name_En",
  "Name_Fr",
  "param_id",
  "Unit",
  "ID",
  "Qualifier",
  "Qualifiers"
)))
