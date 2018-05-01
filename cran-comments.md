tidyhydat 0.3.4
=========================
### IMPROVEMENT
* Added rlang as a dependency and applied tidyeval idiom to more safety control variable environments
* 15% speed improvement in `realtime_dd` by elimating loop (#91)
* 40% speed improvement when querying full provinces (#89)
* reorganized file naming so that helper functions are placed in utils-* files

### BUG FIXES
* Fixed `hy_monthly_flows` and `hy_monthly_levels` date issue (#24)

### MINOR IMPROVEMENT
* realtime tidying now not duplicated and is handled by a function
* simplified `tidyhydat:::station_choice` and added more unit testing
* no longer outputting a message when `station_number = "ALL"`.
* Exporting pipe (`%>%`)

## Test environments
* win-builder (via `devtools::build_win()`)
* local Windows 7, R 3.4.3 (via R CMD check --as-cran)
* local Windows 10, R 3.4.3 (via R CMD check --as-cran)
* ubuntu, R 3.4.3 (travis-ci) (release)
* Debian Linux, R-devel, GCC (debian-gcc-devel) - r-ub
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit - r-hub
* Ubuntu Linux 16.04 LTS, R-release, GCC (ubuntu-gcc-release) - r-hub
* Ubuntu Linux 16.04 LTS, R-devel, GCC (ubuntu-gcc-release) - r-hub
* macOS 10.11 El Capitan, R-release (experimental) - r-hub
* macOS 10.9 Mavericks, R-oldrel (experimental) (macos-mavericks-oldrel) - r-hub
 
## R CMD check results

* No warnings
* No notes
* No errors



## Downstream dependencies

There are currently no downstream dependencies.
