tidyhydat 0.3.0 
=========================

### NEW FEATURES

  * New NEWS template!
  * Moved `station_number` to first argument to facilitate piped analysis (#54)
  * `search_stn_name` and `search_stn_number` now query both realtime and historical data sources and have tests for a more complete list (#56)
  * With credential stored in .Renviron file, `ws_token` can successfully be called by `ws_token()`.
  * `.onAttach()` checks if HYDAT is downloaded on package load.

### MINOR IMPROVEMENTS
  * Significant function and argument name changes (see below)
  * Adding `rappdirs` to imports and using to generate download path for `download_hydat()` (#44)
  * Adding `rappdirs` so that all the hy_* functions access hydat from `rappdirs::user_data_dir()` via `hy_dir()` (#44)
  * Revised and cleaned up documentation including two vignettes (#48)
  * `FULL MONTH` evaluate to a logic (#51)
  * All download tests are skipped on cran (#53)  
  * Removed time limit for `download_realtime_ws()` with some documentation on actual limits. [(3234c22)](https://github.com/ropensci/tidyhydat/commit/3234c2246c97fed5860e8dfb9adc3d6f0aa503fe)


### BUG FIXES

  * Add informative error message for a single missing station input (#38)
  * No longer trying to build .Rd file for `.onload` (#47)
  * Fixed `SED_MONTHLY_LOADS` (#51)
  

### FUNCTION NAME CHANGES (#45)
  * hy_agency_list <- AGENCY_LIST
  * hy_annual_instant_peaks <- ANNUAL_INSTANT_PEAKS
  * hy_annual_stats <- ANNUAL_STATISTICS
  * hy_daily_flows <- DLY_FLOWS
  * hy_daily_levels <- DLY_LEVELS
  * hy_monthly_flows <- MONTHLY_FLOWS
  * hy_monthly_levels <- MONTHLY_LEVELS
  * hy_sed_daily_loads <- SED_DLY_LOADS
  * hy_sed_daily_suscon <- SED_DLY_SUSCON
  * hy_sed_monthly_loads <- SED_MONTHLY_LOADS
  * hy_sed_monthly_suscon <- SED_MONTHLY_SUSCON
  * hy_sed_samples <- SED_SAMPLES
  * hy_sed_samples_psd <- SED_SAMPLES_PSD
  * hy_stations <- STATIONS
  * hy_stn_remarks <- STN_REMARKS
  * hy_stn_datum_conv <- STN_DATUM_CONVERSION
  * hy_stn_datum_unrelated <- STN_DATUM_UNRELATED
  * hy_stn_data_range <- STN_DATA_RANGE
  * hy_stn_data_coll <- STN_DATA_COLLECTION
  * hy_stn_op_schedule <- STN_OPERATION_SCHEDULE
  * hy_stn_regulation <- STN_REGULATION
  * hy_agency_list <- AGENCY_LIST
  * hy_reg_office_list <- REGIONAL_OFFICE_LIST
  * hy_datum_list <- DATUM_LIST
  * hy_version <- VERSION
  * realtime_dd <- download_realtime_dd
  * realtime_stations <- realtime_network_meta
  * search_stn_name <- search_name
  * search_stn_number <- search_number
  
### ARGUMENT NAME CHANGES (#45)
  * station_number <- STATION_NUMBER
  * prov_terr_state_loc <- PROV_TERR_STATE_LOC



tidyhydat 0.2.9
=========================
* Explicitly state in docs that time is in UTC (#32)
* Added test for realtime_network_meta and moved to httr to download.
* download functions all use httr now
* removed need for almost all @import statement by referencing them all directly (#34)
* Fixed error message when directly calling some tidyhydat function using :: (#31)
* To reduce overhead, `output_symbol` has been added as an argument so code can be produced if desired (#33)

tidyhydat 0.2.8
=========================
* Added examples to every function
* Completed test suite including `download_realtime_ws` (#27)
* Fixed bugs in several `STN_*` functions
* Added `STN_DATUM_RELATED`
* Updated documentation

tidyhydat 0.2.7
=========================
* Updated documentation
* Updated README
* Created a small database so that unit testing occurs remotely (#1)
* Fixed `STN_DATA_RANGE` bug (#26)

tidyhydat 0.2.6
=========================
* using `styler` package to format code to tidyverse style guide
* added `PROV_TERR_STATE_LOC` to `allstations`
* added `search_number` function
* added `MONTHLY` functions
* created function families
* added `on.exit()` to internal code; a better way to disconnect
* Updated documentation

tidyhydat 0.2.5
=========================
* fixed minor bug in download_realtime_ws so that better error message is outputted when no data is returned

tidyhydat 0.2.4
=========================
* download_realtime_dd can now accept stations from multiple provinces or simply select multiple provinces
* better error messages for get_ws_token and download_realtime_ws
* All functions that previously accepted STATION_NUMBER == "ALL" now throw an error. 
* Added function to download hydat

tidyhydat 0.2.3
=========================
* Remove significant redundancy in station selecting mechanism
* Added package startup message when HYDAT is out of date  
* Add internal allstations data
* Added all the tables as functions or data from HYDAT
* Made missing station ouput truncated at 10 missing stations

tidyhdyat 0.2.2
=========================
* Adding several new tables
* removed need for both prov and stn args
* reduced some repetition in code

tidyhydat 0.2.1
=========================
* added STN_REGULATION
* tidied ANNUAL_STATISTICS
* added a series of lookup tables (DATUM_LIST, AGENCY_LIST, REGIONAL_OFFICE_LIST)
* cleared up output of STATIONS

tidyhydat 0.2.0
=========================
* standardize hydat outputs to consistent tibble structure
* Adding search_name function
* final names for download functions
* functions output an information message about stations retrieved

tidyhydat 0.1.1
=========================
*Renamed real-time function as download_realtime and download_realtime2
*Added more units tests
*Wrote vignette for package utilization
*Brought all data closer to a "tidy" state

tidyhydat 0.1.0
=========================
*Added ability for STATIONS to retrieve ALL stations in the HYDAT database
*Added ability for STATIONS to retrieve ALL stations in the HYDAT database
*Standardize documentation; remove hydat_path default
*Better error handling for download_realtime
*Update documentation
*Adding param_id data, data-raw and documentation
*Dates filter to ANNUAL_STATISTICS and DLY_FLOWS; func and docs
*DLY_LEveLS function and docs
*download_ws and get_ws_token function and docs
*UPDATE README

tidyhydat 0.0.4
=========================
*Added ability for STATIONS to retrieve ALL stations in the HYDAT database
*Added ability for STATIONS to retrieve ALL stations in the HYDAT database
*Standardize documentation; remove hydat_path default
*Better error handling for download_realtime
*Update documentation
*Adding param_id data, data-raw and documentation
*Dates filter to ANNUAL_STATISTICS and DLY_FLOWS; func and docs
*DLY_LEveLS function and docs
*download_ws and get_ws_token function and docs
*UPDATE README

tidyhydat 0.0.3
=========================
*fixed db connection problem; more clear documentation
*better error handling; more complete realtime documentation
*harmonized README with standardized arguments

tidyhydat 0.0.2
=========================
*Added example analysis to README
*Added devex badge; license to all header; import whole readr package
*Able to take other protidyhydat inces than BC now
*Update documentation; README

tidyhydat 0.0.1
=========================
*Initial package commit
*Add license and include bcgotidyhydat  files in RBuildIgnore
*Two base working function; package level R file and associated documentation
*Only importing functions used in the function
*Update README with example
*Added download_ functions
*Added ANNUAL_STATISTICS query/table and docs
*Updated docs and made DLY_FLOWS more rigorous
