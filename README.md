<!-- README.md is generated from README.Rmd. Please edit that file -->
tidyhydat
=========

Here is a list of what tidyhydat does: - Perform a number of common queries on the HYDAT database and returns a tibble - Maintains column names as the database itself - Can select one, two... x stations - Keep functions are low-level as possible. For example, for daily flows, the function should query the database then format the dates and that is it.

Example
-------

This is a basic example of `tidyhydat` usage

``` r
library(tidyhydat)

DLY_FLOWS(STATION_NUMBER = c("08LA001","08LG006"))
#> Applying predicate on the first 100 rows
#> Warning: 532 failed to parse.
#> Warning: 426 failed to parse.
#> # A tibble: 52,300 x 3
#> # Groups:   STATION_NUMBER [2]
#>    STATION_NUMBER  FLOW       Date
#>             <chr> <dbl>     <date>
#>  1        08LA001   144 1914-01-01
#>  2        08LA001   150 1914-02-01
#>  3        08LA001   166 1914-03-01
#>  4        08LA001   160 1914-04-01
#>  5        08LA001   173 1914-05-01
#>  6        08LA001   411 1914-06-01
#>  7        08LA001   589 1914-07-01
#>  8        08LA001   374 1914-08-01
#>  9        08LA001   199 1914-09-01
#> 10        08LA001   289 1914-10-01
#> # ... with 52,290 more rows
```
