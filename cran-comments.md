tidyhydat 0.5.8
=========================

There were zero WARNINGS and zero ERRORS.

## NEWS
- fix bug where hydat folder was not being created

## Test environments
* win-builder (via `devtools::check_win_devel()` and `devtools::check_win_release()`)
* local macOS, R 4.2.1 (via R CMD check --as-cran)
* ubuntu-20.04, r: 'release' (github actions)
* ubuntu-20.04, r: 'devel' (github actions)
* macOS,        r: 'release' (github actions)
* windows,      r: 'release' (github actions)
* Fedora Linux, R-devel, clang, gfortran - r-hub
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit - r-hub

tidyhydat 0.5.7
=========================

There were zero WARNINGS and zero ERRORS.

## NEWS
- new `hy_remote` function which looks to see what version is available from ECCC (#183)
- Improved logic to download HYDAT even if there is some clutter present (@gdelaplante #180)
- Updated to work with coming changes to dbplyr (#179)
- Use testthat 3rd edition and update a bunch of tests
- Make tinyhydat even tinier to remove R CMD check note


## Test environments
* win-builder (via `devtools::check_win_devel()` and `devtools::check_win_release()`)
* local macOS, R 4.2.1 (via R CMD check --as-cran)
* ubuntu-20.04, r: 'release' (github actions)
* ubuntu-20.04, r: 'devel' (github actions)
* macOS,        r: 'release' (github actions)
* windows,      r: 'release' (github actions)
* Fedora Linux, R-devel, clang, gfortran - r-hub
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit - r-hub


tidyhydat 0.5.6
=========================

There were zero WARNINGS and zero ERRORS.

There was one NOTE: 'Note: found 122 marked UTF-8 strings'. These strings are necessary for testing as the data source that this package accesses includes data with UTF-8 strings (french language accents)

## NEWS
- fixed CRAN document issue
- fixed bug created by HYDAT database name (#175)

## Test environments
* win-builder (via `devtools::check_win_devel()` and `devtools::check_win_release()`)
* local macOS, R 4.2.1 (via R CMD check --as-cran)
* ubuntu-20.04, r: 'release' (github actions)
* ubuntu-20.04, r: 'devel' (github actions)
* macOS,        r: 'release' (github actions)
* windows,      r: 'release' (github actions)
* Fedora Linux, R-devel, clang, gfortran - r-hub
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit - r-hub

tidyhydat 0.5.5
=========================

There were zero WARNINGS and zero ERRORS.

There was one NOTE: 'Note: found 122 marked UTF-8 strings'. These strings are necessary for testing as the data source that this package accesses includes data with UTF-8 strings (french language accents)

## NEWS
- `download_hydat()` now has an `ask` parameter that can be used to bypass the keypress confirmation when downloading the HYDAT database (@rchlumsk, #165). 
- Change maintainer email. 
- Precompile vignettes for CRAN
- Minor tweaks to vignettes

## Test environments
* win-builder (via `devtools::check_win_devel()` and `devtools::check_win_release()`)
* local Windows 10, R 4.1.2 (via R CMD check --as-cran)
* ubuntu-20.04, r: 'release' (github actions)
* ubuntu-20.04, r: 'devel' (github actions)
* macOS,        r: 'release' (github actions)
* windows,      r: 'release' (github actions)
* Fedora Linux, R-devel, clang, gfortran - r-hub
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit - r-hub

tidyhydat 0.5.4
=========================
- When add a local timezone column, use the most common timezone in the data rather than the first one. This just seems more likely to be useful to users
- Add more documentation to `realtime_add_local_datetime` to make how timezones are dealt with clearer (#157)
- Expose the query time for realtime functions as an attribute (#160)

## Test environments
* win-builder (via `devtools::check_win_devel()` and `devtools::check_win_release()`)
* local Windows 10, R 4.1.0 (via R CMD check --as-cran)
* ubuntu-20.04, r: 'release' (github actions)
* ubuntu-20.04, r: 'devel' (github actions)
* macOS,        r: 'release' (github actions)
* windows,      r: 'release' (github actions)
* Fedora Linux, R-devel, clang, gfortran - r-hub
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit - r-hub


tidyhydat 0.5.3
=========================
## NEWS
- Allow pkg to loaded without internet and rather just issue an message when it is not. (#149)
- Added `add = TRUE` to all `on.exit` call so add not to overwrite previous call (#151)
- Remove redundant and ill-advised  `closeAllConnections` (#153)
- Update internal data
- Convert most of the docs to markdown (#121)

## Test environments
* win-builder (via `devtools::check_win_devel()` and `devtools::check_win_release()`)
* local Windows 10, R 4.0.5 (via R CMD check --as-cran)
* ubuntu-20.04, r: 'release' (github actions)
* ubuntu-20.04, r: 'devel' (github actions)
* macOS,        r: 'release' (github actions)
* windows,      r: 'release' (github actions)
* Fedora Linux, R-devel, clang, gfortran - r-hub
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit - r-hub



tidyhydat 0.5.2
=========================
## NEWS
- add internal function `hy_check` to verify that HYDAT contains all the right tables and that those tables contain data. 

## Test environments
* win-builder (via `devtools::check_win_devel()` and `devtools::check_win_release()`)
* local Windows 10, R 4.0.3 (via R CMD check --as-cran)
* ubuntu-20.04, r: 'release' (github actions)
* ubuntu-20.04, r: 'devel' (github actions)
* macOS,        r: 'release' (github actions)
* windows,      r: 'release' (github actions)
* Fedora Linux, R-devel, clang, gfortran - r-hub
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit - r-hub



tidyhydat 0.5.1
=========================
## Re-submission note
- Fix all non-secure or broken links

## NEWS
- Replace `class(x) ==` with `inherits`
- Fix bug and added corresponding tests where a request for multiple stations to `realtime_dd` would fail if any data was missing
- Update internal data

## Test environments
* win-builder (via `devtools::check_win_devel()` and `devtools::check_win_release()`)
* local Windows 10, R 4.0.2 (via R CMD check --as-cran)
* ubuntu-20.04, r: 'release' (github actions)
* ubuntu-20.04, r: 'devel' (github actions)
* macOS,        r: 'release' (github actions)
* windows,      r: 'release' (github actions)
* Fedora Linux, R-devel, clang, gfortran - r-hub
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit - r-hub


tidyhydat 0.5.0
=========================
## Re-submission note
* Vignette linked changed to canonical form. 
* GitHub actions badge link now points only to GitHub repo.
* `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md` now link directly to GitHub repo.
* CRAN checks link changed to `CRAN.R-project.org` link
* Add title to README and fixed bug in realtime `plot` method and reduce size of README as per Uwe comments

## Test environments
* win-builder (via `devtools::check_win_devel()` and `devtools::check_win_release()`)
* local Windows 10, R 3.6.1 (via R CMD check --as-cran)
* ubuntu, R 3.6.1 (travis-ci) (release)
* ubuntu, (travis-ci) (devel)
* ubuntu-16.04, r: '3.3' (github actions)
* ubuntu-16.04, r: '3.4' (github actions)
* ubuntu-16.04, r: '3.5' (github actions)
* ubuntu-16.04, r: '3.6' (github actions)
* Fedora Linux, R-devel, clang, gfortran - r-hub
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit - r-hub
* macOS 10.11 El Capitan, R-release (experimental) - r-hub


tidhydat 0.4.0
=========================
## Test environments
* win-builder (via `devtools::check_win_devel()` and `devtools::check_win_release()`)
* local Windows 10, R 3.5.3 (via R CMD check --as-cran)
* ubuntu, R 3.5.3 (travis-ci) (release)
* ubuntu, R 3.5.3 (travis-ci) (devel)
* Fedora Linux, R-devel, clang, gfortran - r-hub
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit - r-hub
* macOS 10.11 El Capitan, R-release (experimental) - r-hub


tidyhydat 0.3.5
=========================
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

## Test environments
* win-builder (via `devtools::build_win()`)
* local Windows 10, R 3.4.3 (via R CMD check --as-cran)
* ubuntu, R 3.4.3 (travis-ci) (release)
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit - r-hub
* macOS 10.11 El Capitan, R-release (experimental) - r-hub
* macOS 10.9 Mavericks, R-oldrel (experimental) (macos-mavericks-oldrel) - r-hub
 
## R CMD check results

* No warnings
* No notes
* No errors



## Downstream dependencies

There are currently no downstream dependencies.
