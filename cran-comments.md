# 0.3.2
* Critical bug fixed where path in `download_hydat()` was constructed in a non-OS independent way
    - Prevented non-windows users from downloading the database which is essential to most functions in the package.
* Some minor improvments outlined in NEWS section

# 0.3.1
* Initial release

## Test environments

* local Windows 7, R 3.4.3
* ubuntu, R 3.4.3 (travis-ci)
* win-builder (devel and release)
* local Windows 10, R 3.4.3 
* Debian Linux, R-release, GCC (debian-gcc-release) - r-hub
* macOS 10.11 El Capitan, R-release (experimental) - r-hub


## R CMD check results

There were no ERRORs or WARNINGs.

One NOTE:
* checking data for non-ASCII characters ... NOTE
  Note: found 7 marked UTF-8 strings
  
* These are accents in French.

## Downstream dependencies

There are currently no downstream dependencies.
