# tidyhydat 0.7.0
- bump minimum R version to 4.2.0
- dropped httr in favour of httr2
- fix bug where `download_hydat()` fails if `tempdir()` is on a different device than `hydat_path` (@mpdavison, #192)
- fix bug where `download_hydat()` wasn't checking alternative paths for success (@Travis-Simmons)

# tidyhydat 0.6.1
- Add `...` to print methods so you can pass arguments all the way down. 
- Add workaround for vroom#519 bug that prevents `realtime_*` functions from working
- `realtime_ws` now returns the `Approval/Approbation` column as a character vector rather than a integer. ECCC is now putting non-integers in that column so this is a less strict formatting solution. 

# tidyhydat 0.6.0
- Add capability to access ECCC webservice. The return of `realtime_ws`!

# tidyhydat 0.5.9
- drop `.data` pronoun throughout
- fixed failing CRAN test

# tidyhydat 0.5.8
- fix bug where hydat folder was not being created

# tidyhydat 0.5.7
- new `hy_remote` function which looks to see what version is available from ECCC (#183)
- Improved logic to download HYDAT even if there is some clutter present (@gdelaplante #180)
- Updated to work with coming changes to dbplyr (#179)
- Use testthat 3rd edition and update a bunch of tests
- Make tinyhydat even tinier to remove R CMD check note

# tidyhydat 0.5.6
- fixed CRAN document issue
- fixed bug created by HYDAT database name (#175)

# tidyhydat 0.5.5

### MINOR IMPROVEMENTS
- `download_hydat()` now has an `ask` parameter that can be used to bypass the keypress confirmation when downloading the HYDAT database (@rchlumsk, #165). 
- Change maintainer email. 
- Precompile vignettes for CRAN
- Minor tweaks to vignettes

# tidyhydat 0.5.4
- When add a local timezone column, use the most common timezone in the data rather than the first one. This just seems more likely to be useful to users
- Add more documentation to `realtime_add_local_datetime` to make how timezones are dealt with clearer (#157)
- Expose the query time for realtime functions as an attribute (#160)
- Add Government of Canada as data contributor (#156)

# tidyhydat 0.5.3
- Allow pkg to loaded without internet and rather just issue an message when it is not. (#149)
- Added `add = TRUE` to all `on.exit` call so add not to overwrite previous call (#151)
- Remove redundant and ill-advised  `closeAllConnections` (#153)
- Update internal data
- Convert most of the docs to markdown (#121)

# tidyhydat 0.5.2
- add internal function `hy_check` to verify that HYDAT contains all the right tables and that those tables contain data. 

# tidyhydat 0.5.1
- Replace `class(x) ==` with `inherits`
- Fix bug and added corresponding tests where a request for multiple stations to `realtime_dd` would fail if any data was missing
- Update internal data
- Fix all non-secure or borken links

# tidyhydat 0.5.0

### MINOR FIXES
- Revise multi prov test to realtime because of network load and prone to intermittent failure
- Adding rOpenSci doc site to DESCRIPTION
- Fix character NA's in `hy_stations` (#125)
- Allow downloading HYDAT to alternative locations (#129)
- Provide better documentation of how change default db location in `hy_set_default_db()`

# tidyhydat 0.4.0


### IMPROVEMENTS
* All functions now return either "hy" or "realtime" class with associated print and plot methods (#119)
* prov_terr_state_loc now accepts a "CA" value to specify only stations located in Canada (#112)
* functions that access internet resources now fail with an informative error message (#116)
* tests that require internet resources are skipped when internet is down 
* Add small join example to calculate runoff to introduction vignette (#120)

### BUG FIXES
* `pull_station_number` now only returns unique values (#109)
* Adding a offset column that reflects OlsonNames() and is thus DST independent (#110)
* Caught all `R_CHECK_LENGTH_1_CONDITION` instances

# tidyhydat 0.3.5

### IMPROVEMENTS
* New function: `realtime_add_local_datetime()` adds a local datetime column to `realtime_dd()` tibble (#64)
* New function: `pull_station_number()` wraps `pull(STATION_NUMBER)` for convenience

### MINOR BREAKING CHANGES
* In effort to standardize, the case of column names for some rarely used function outputs were changed to reflect more commonly used function outputs. This may impact some workflows where columns are referenced by names (#99).   

### BUG FIXES
* Functions that have a `start_date` and `end_date` actually work with said argument (#98)
* `hy_annual_instant_peaks()` now parses the date correctly into UTC and includes a datetime and time zone column.  (#64)
* `hy_stn_data_range()` now returns actual `NA`'s rather than string NA's (#97)

### MINOR IMPROVEMENT
* `download_hydat()` now returns an informative error if the download fails due to proxy-related connection issues (@rywhale, #101). 

# tidyhydat 0.3.4

### IMPROVEMENT
* Added rlang as a dependency and applied tidyeval idiom to more safety control variable environments
* 15% speed improvement in `realtime_dd` by eliminating loop (#91)
* 40% speed improvement when querying full provinces (#89)
* reorganized file naming so that helper functions are placed in utils-* files

### BUG FIXES
* Fixed `hy_monthly_flows` and `hy_monthly_levels` date issue (#24)

### MINOR IMPROVEMENT
* realtime tidying now not duplicated and is handled by a function
* simplified `tidyhydat:::station_choice` and added more unit testing
* no longer outputting a message when `station_number = "ALL"`.
* Exporting pipe (`%>%`)

# tidyhydat 0.3.3

### NEW FEATURES
  * Open a connection to the HYDAT database directly using `hy_src()` for advanced functionality (PR#77).
  * New vignette outlining `hy_src()` (PR#77)
  * Add some tools to improve the usability of the test database (PR#77).
  * `download_hydat()` now uses `httr::GET()`

### MINOR IMPROVEMENTS
  * Better downloading messages
  
### BUG FIXES
  * Fixed package startup message so it can be supressed. (#79)
  * Fixed bug that resulted in `download_hydat` choice wasn't respected.
  * `onAttach()` now checks 115 days after last HYDAT release to prevent slow package load times if HYDAT is longer than 3 months between RELEASES.
  * Fixed margin error in `hy_plot()`
  * Fixed a bug in `realtime_plot()` that prevented a lake level station from being called
  * Fixed a bug in `hy_daily()` that threw an error when only a level station was called
  * Added new tests for `hy_daily()` and `realtime_plot()`
  * Added `HYD_STATUS` and `REAL_TIME` columns to `allstations`. 


# tidyhydat 0.3.2

### NEW FEATURES
  * New `hy_daily()` function which combines all daily data into one dataframe.
  * Add a quick base R plotting feature for quick visualization of realtime and historical data.
  * Add `realtime_daily_mean` function that quickly converts higher resolution data into daily means.
  * New vignette outlining some example usage.
  
### BUG FIXES
  * Fixed bug in `download_hydat()` that create a path that wasn't OS-independent.
  * Fixed a bug on `download_hydat()` where by sometimes R had trouble overwriting an existing version of existing database. Now the old database is simply deleted before the new one is downloaded.
  * `hy_annual_instant_peaks()` now returns a date object with HOUR, MINUTE and TIME_ZONE returned as separed columns. (#10)
  * All variable values of LEVEL and FLOW have been changed to Level and Flow to match the output of `hy_data_types`. (#60)
  * Tidier and coloured error messages throughout.
  * Review field incorrectly specified the rOpenSci review page. Removed the link from the DESCRIPTION.
  


# tidyhydat 0.3.1

### NEW FEATURES

  * When package is loaded, tidyhydat checks to see if HYDAT is even present
  * When package is loaded, it now tests to see if their a new version of HYDAT if the current date is greater than 3 months after the last release date of HYDAT. 
  * Prep for CRAN release
  * Starting to use raw SQL for table queries
  * Removing 2nd vignette from build. Still available on github

# tidyhydat 0.3.0 

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



# tidyhydat 0.2.9

* Explicitly state in docs that time is in UTC (#32)
* Added test for realtime_network_meta and moved to httr to download.
* download functions all use httr now
* removed need for almost all @import statement by referencing them all directly (#34)
* Fixed error message when directly calling some tidyhydat function using :: (#31)
* To reduce overhead, `output_symbol` has been added as an argument so code can be produced if desired (#33)

# tidyhydat 0.2.8

* Added examples to every function
* Completed test suite including `download_realtime_ws` (#27)
* Fixed bugs in several `STN_*` functions
* Added `STN_DATUM_RELATED`
* Updated documentation

# tidyhydat 0.2.7

* Updated documentation
* Updated README
* Created a small database so that unit testing occurs remotely (#1)
* Fixed `STN_DATA_RANGE` bug (#26)

# tidyhydat 0.2.6

* using `styler` package to format code to tidyverse style guide
* added `PROV_TERR_STATE_LOC` to `allstations`
* added `search_number` function
* added `MONTHLY` functions
* created function families
* added `on.exit()` to internal code; a better way to disconnect
* Updated documentation

# tidyhydat 0.2.5

* fixed minor bug in download_realtime_ws so that better error message is outputted when no data is returned

# tidyhydat 0.2.4

* download_realtime_dd can now accept stations from multiple provinces or simply select multiple provinces
* better error messages for get_ws_token and download_realtime_ws
* All functions that previously accepted STATION_NUMBER == "ALL" now throw an error. 
* Added function to download hydat

# tidyhydat 0.2.3

* Remove significant redundancy in station selecting mechanism
* Added package startup message when HYDAT is out of date  
* Add internal allstations data
* Added all the tables as functions or data from HYDAT
* Made missing station ouput truncated at 10 missing stations

# tidyhydat 0.2.2

* Adding several new tables
* removed need for both prov and stn args
* reduced some repetition in code

# tidyhydat 0.2.1

* added STN_REGULATION
* tidied ANNUAL_STATISTICS
* added a series of lookup tables (DATUM_LIST, AGENCY_LIST, REGIONAL_OFFICE_LIST)
* cleared up output of STATIONS

# tidyhydat 0.2.0

* standardize hydat outputs to consistent tibble structure
* Adding search_name function
* final names for download functions
* functions output an information message about stations retrieved

# tidyhydat 0.1.1

*Renamed real-time function as download_realtime and download_realtime2
*Added more units tests
*Wrote vignette for package utilization
*Brought all data closer to a "tidy" state

# tidyhydat 0.1.0

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

# tidyhydat 0.0.4

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

# tidyhydat 0.0.3

*fixed db connection problem; more clear documentation
*better error handling; more complete realtime documentation
*harmonized README with standardized arguments

# tidyhydat 0.0.2

*Added example analysis to README
*Added devex badge; license to all header; import whole readr package
*Able to take other protidyhydat inces than BC now
*Update documentation; README

# tidyhydat 0.0.1

*Initial package commit
*Add license and include bcgotidyhydat  files in RBuildIgnore
*Two base working function; package level R file and associated documentation
*Only importing functions used in the function
*Update README with example
*Added download_ functions
*Added ANNUAL_STATISTICS query/table and docs
*Updated docs and made DLY_FLOWS more rigorous
