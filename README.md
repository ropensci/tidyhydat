<a rel="Exploration" href="https://github.com/BCDevExchange/docs/blob/master/discussion/projectstates.md"><img alt="Being designed and built, but in the lab. May change, disappear, or be buggy." style="border-width:0" src="https://assets.bcdevexchange.org/images/badges/exploration.svg" title="Being designed and built, but in the lab. May change, disappear, or be buggy." /></a>

<!-- README.md is generated from README.Rmd. Please edit that file -->
tidyhydat
=========

Here is a list of what tidyhydat does: - Perform a number of common queries on the HYDAT database and returns a tibble - Maintains column names as the database itself - Can select one, two... x stations - Keep functions are low-level as possible. For example, for daily flows, the function should query the database then format the dates and that is it.

Installation
------------

To install the tidyhydat package, you need to install the devtools package then the tidyhydat package

``` r
install.packages("devtools")
devtools::install_github("bcgov/tidyhydat")
```

Then to load the package you need to use the library command:

``` r
library(tidyhydat)
```

Example
-------

This is a basic example of `tidyhydat` usage

``` r
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

Basin realtime data acquisition usage
-------------------------------------

Using `download_realtime()` we can easily select specific stations by supplying a station of interest:

``` r
download_realtime(STATION_NUMBER = "08LG006")
#> Warning: call dbDisconnect() when finished working with a connection
#> # A tibble: 8,718 x 10
#>    STATION_NUMBER           date_time LEVEL LEVEL_GRADE LEVEL_SYMBOL
#>             <chr>              <dttm> <dbl>       <chr>        <chr>
#>  1        08LG006 2017-06-14 08:00:00 2.277        <NA>         <NA>
#>  2        08LG006 2017-06-14 08:05:00 2.277        <NA>         <NA>
#>  3        08LG006 2017-06-14 08:10:00 2.277        <NA>         <NA>
#>  4        08LG006 2017-06-14 08:15:00 2.277        <NA>         <NA>
#>  5        08LG006 2017-06-14 08:20:00 2.277        <NA>         <NA>
#>  6        08LG006 2017-06-14 08:25:00 2.277        <NA>         <NA>
#>  7        08LG006 2017-06-14 08:30:00 2.277        <NA>         <NA>
#>  8        08LG006 2017-06-14 08:35:00 2.278        <NA>         <NA>
#>  9        08LG006 2017-06-14 08:40:00 2.278        <NA>         <NA>
#> 10        08LG006 2017-06-14 08:45:00 2.278        <NA>         <NA>
#> # ... with 8,708 more rows, and 5 more variables: LEVEL_CODE <int>,
#> #   FLOW <dbl>, FLOW_GRADE <chr>, FLOW_SYMBOL <chr>, FLOW_CODE <int>
```

Example with spatial data
-------------------------

The `download_realtime()` functions allows us to directly query the Environment Canada and Climate Change datamart selecting by station. If we wanted to look at all the realtime stations in a particular hydrologic zone, we could easily do this using the `dplyr`,`sf` and `bcmaps` packages. To install those packages use these commands:

``` r
devtools::install_github("bcgov/bcmaps")
install.packages(c("sf","dplyr")
```

And then load these packages. tidyhydat is already loaded above.

``` r
library(bcmaps)
#> Loading required package: sp
#> Warning: package 'sp' was built under R version 3.4.1
library(sf)
#> Linking to GEOS 3.5.0, GDAL 2.1.1, proj.4 4.9.3
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

Now to return the question. BC is divided into hydrologic zones. If use the hydrozones layer in `bcmaps` and convert it to `sf` format, determining which stations reside in which hydrologic zone is trivial. Using `st_join` allows to ask which hydrometric stations (called by `download_network`) are in which hydrologic zones. If we are interested in all stations in the QUEEN CHARLOTTE ISLANDS hydrologic zone, we can generate that list by filtering by the relevant hydrologic zone:

``` r
## Convert to sf format
hydrozones_sf <- st_as_sf(bcmaps::hydrozones) %>%
  select(HYDZN_NAME)


qci_stations <- download_network(PROV_TERR_STATE_LOC = "BC") %>%
  st_as_sf(., coords = c("LONGITUDE", "LATITUDE"), 
              crs = 4326, 
              agr = "constant") %>%
  st_transform(crs = 3005) %>%
  st_join(.,hydrozones_sf) %>%
  filter(HYDZN_NAME == "QUEEN CHARLOTTE ISLANDS") %>%
  pull(STATION_NUMBER)

qci_stations
#> [1] "08OA002" "08OA003" "08OA004" "08OA005" "08OB002"
```

Now that vector (`qci_stations`) is useful to select which stations we are interested in.

``` r
qci_realtime <- download_realtime(STATION_NUMBER = qci_stations)
```

Then using `ggplot2` we could plot these results to have look at the data

``` r
library(ggplot2)

ggplot(qci_realtime, aes(x = date_time, y = FLOW)) +
  geom_line(aes(colour = STATION_NUMBER))
```

![](README-unnamed-chunk-10-1.png)
