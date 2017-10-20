tidyhydat 0.3.0 ()
=========================

### NEW FEATURES

  * New NEWS template!

### MINOR IMPROVEMENTS
  * Adding `rappdirs` to imports and using to generate download path for `download_hydat()` (bcgov/tidyhydat#44)
  * Add informative error message for a single missing station input (bcgov/tidyhydat#38)
  * `FULL MONTH` evaluate to a logic (bcgov/tidyhydat#51)

### BUG FIXES

  * Fixed `SED_MONTHLY_LOADS` (bcgov/tidyhydat#51)
  * Fixed failing behaviour of `get_ws_token` (bcgov/tidyhydat#43)
  * No longer trying to build .Rd file for `.onload` (bcgov/tidyhydat#47)
  * Fixed httr:content parsing error in `download_realtime_ws`. (bcgov/tidyhydat#42)

### DEPRECATED AND DEFUNCT



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
