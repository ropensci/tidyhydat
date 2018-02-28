# 0.3.3
  * Open a connection to the HYDAT database directly using `hy_src()` for advanced functionality (PR#77).
  * New vignette outlining `hy_src()` (PR#77)
  * Add some tools to improve the usability of the test database (PR#77).
  * `download_hydat()` now uses `httr::GET()`

# 0.3.2
* 2nd submission same version: more comprehensive test via rhub and locally with --as-cran
* Fixed UTF-8 strings causing NOTEs
* Critical bug fixed where path in `download_hydat()` was constructed in a non-OS independent way
    - Prevented non-windows users from downloading the database which is essential to most functions in the package.
* Some minor improvments outlined in NEWS section

# 0.3.1
* Initial release

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

There were no ERRORs or WARNINGs.

NOTE R CMD check --as-cran:
* checking DESCRIPTION meta-information ... NOTE
Authors@R field gives persons with non-standard roles:
  Luke Winslow [rev] (Reviewed for rOpenSci): rev
  Laura DeCicco [rev] (Reviewed for rOpenSci): rev

* I am seeking to give reviewer credit to these folks


## Downstream dependencies

There are currently no downstream dependencies.
