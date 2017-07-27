<a rel="Exploration" href="https://github.com/BCDevExchange/docs/blob/master/discussion/projectstates.md"><img alt="Being designed and built, but in the lab. May change, disappear, or be buggy." style="border-width:0" src="https://assets.bcdevexchange.org/images/badges/exploration.svg" title="Being designed and built, but in the lab. May change, disappear, or be buggy." /></a>

[![Travis-CI Build Status](https://travis-ci.org/bcgov/tidyhydat.svg?branch=master)](https://travis-ci.org/bcgov/tidyhydat)

<!-- README.md is generated from README.Rmd. Please edit that file -->
tidyhydat
=========

Here is a list of what tidyhydat does:

-   Perform a number of common queries on the HYDAT database and returns a tibble
-   Maintains the same column names as the database itself
-   Can select one, two... x stations
-   Can provide a date range
-   Keep functions are low-level as possible. For example, for daily flows, the function should query the database then format the dates and that is it.
-   An additional auxiliary feature outside the HYDAT database is the downloading of realtime data. This functionality is provided by `download_realtime()`, `download_network()` and `download_ws`.

Installation
------------

To install the `tidyhydat` package, you need to install the `devtools` package then the `tidyhydat` package

``` r
install.packages("devtools")
devtools::install_github("bcgov/tidyhydat")
```

Then to load the package you need to use the `library` function. When you install `tidyhydat`, several other packages will be installed as well. One of those packages, `dplyr`, is useful for data manipulations and is used regularly here. Even though `dplyr` is installed alongside `tidyhydat`, it is helpful to load it by itself as there are many useful functions contained within `dplyr`. A helpful `dplyr` tutorial can be found [here](https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html).

``` r
library(tidyhydat)
library(dplyr)
#> Warning: package 'dplyr' was built under R version 3.4.1
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

HYDAT download
--------------

To use most of the `tidyhydat` package you will need the most recent version of the HYDAT database. The sqlite3 version can be downloaded here:

-   <http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/>

You will need to download that file, unzip it and put it somewhere on local storage. The path to the sqlite3 must be specified within each function that uses HYDAT. If the path is very long it may be useful to store it as an object with a smaller name like this:

``` r
hydat_loc = "A very long path that points to the HYDAT sqlite3 database"
```

These are the functions that are currently implemented to query HYDAT:

-   `STATIONS`
-   `DLY_FLOWS`
-   `DLY_LEVELS`
-   `ANNUAL_STATISTICS`

This is a list of function to be implemented:

-   `ANNUAL_INSTANT_PEAKS`
-   `SED_DLY_LOADS`
-   `SED_DLY_SUSCON`
-   `SED_SAMPLES_PSD`

Example
-------

This is a basic example of `tidyhydat` usage. All functions that interact with HYDAT are capitalized (e.g. `STATIONS`). These functions follow a common argument structure which can be illustrated with the `DLY_FLOWS()` function. If you would like to extract only station `08LA001` you must supply the `STATION_NUMBER` and the `PROV_TERR_STATE_LOC` arguments. The `hydat_path` argument is supplied here as a local path the database. Yours will be different.

``` r
DLY_FLOWS(STATION_NUMBER = "08LA001", PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3")
#> No start and end dates specified. All dates available will be returned.
#> Applying predicate on the first 100 rows
#> # A tibble: 28,794 x 3
#> # Groups:   STATION_NUMBER [1]
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
#> # ... with 28,784 more rows
```

If you would like to query the database for two or more stations you would combine the `STATION_NUMBER` into a vector using `c()`:

``` r
DLY_FLOWS(STATION_NUMBER = c("08LA001","08NL071"), PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3")
#> No start and end dates specified. All dates available will be returned.
#> Applying predicate on the first 100 rows
#> # A tibble: 42,522 x 3
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
#> # ... with 42,512 more rows
```

If instead you would like to extract all stations from a jurisdictions, you can use the "ALL" argument for `STATION_NUMBER`:

``` r
DLY_FLOWS(STATION_NUMBER = "ALL", PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")
#> No start and end dates specified. All dates available will be returned.
#> Applying predicate on the first 100 rows
#> # A tibble: 185,763 x 3
#> # Groups:   STATION_NUMBER [40]
#>    STATION_NUMBER  FLOW       Date
#>             <chr> <dbl>     <date>
#>  1        01CA001    NA 1919-08-01
#>  2        01CA001 0.042 1919-09-01
#>  3        01CA001 0.085 1919-10-01
#>  4        01CA001 0.255 1919-11-01
#>  5        01CA001 1.130 1919-12-01
#>  6        01CA001 0.085 1920-01-01
#>  7        01CA001 0.057 1920-02-01
#>  8        01CA001 0.085 1920-03-01
#>  9        01CA001 4.160 1920-04-01
#> 10        01CA001 2.890 1920-05-01
#> # ... with 185,753 more rows
```

In all the previous examples, no start or end date was specified. In those cases all dates in HYDAT were returned. If, however, we were only interested in a subset of dates we could use the `start_date` and `end_date` arguments. A date must be supplied to both these arguments in the form of YYYY-MM-DD. If you were interested in all daily flow data from station number "08LA001" for 1981, you would specify all days in 1981 :

``` r
DLY_FLOWS(STATION_NUMBER = "08LA001", PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3",
          start_date = "1981-01-01", end_date = "1981-12-31")
#> Applying predicate on the first 100 rows
#> # A tibble: 365 x 3
#> # Groups:   STATION_NUMBER [1]
#>    STATION_NUMBER  FLOW       Date
#>             <chr> <dbl>     <date>
#>  1        08LA001 139.0 1981-01-01
#>  2        08LA001 111.0 1981-02-01
#>  3        08LA001  83.1 1981-03-01
#>  4        08LA001  89.8 1981-04-01
#>  5        08LA001 216.0 1981-05-01
#>  6        08LA001 897.0 1981-06-01
#>  7        08LA001 500.0 1981-07-01
#>  8        08LA001 415.0 1981-08-01
#>  9        08LA001 217.0 1981-09-01
#> 10        08LA001 123.0 1981-10-01
#> # ... with 355 more rows
```

Basin realtime data acquisition usage
-------------------------------------

To download realtime data we can use approximately the same conventions discussed above. All non-HYDAT functions are in lower case. Using `download_realtime()` we can easily select specific stations by supplying a station of interest. Note that again, we need to supply both the station and the province that we are interested in but do not need to supply the HYDAT location because we accessing this data online:

``` r
download_realtime(STATION_NUMBER = "08LG006", PROV_TERR_STATE_LOC = "BC")
#> # A tibble: 8,646 x 10
#>    STATION_NUMBER           date_time LEVEL LEVEL_GRADE LEVEL_SYMBOL
#>             <chr>              <dttm> <dbl>       <chr>        <chr>
#>  1        08LG006 2017-06-27 08:00:00 1.994        <NA>         <NA>
#>  2        08LG006 2017-06-27 08:05:00 1.995        <NA>         <NA>
#>  3        08LG006 2017-06-27 08:10:00 1.995        <NA>         <NA>
#>  4        08LG006 2017-06-27 08:15:00 1.995        <NA>         <NA>
#>  5        08LG006 2017-06-27 08:20:00 1.996        <NA>         <NA>
#>  6        08LG006 2017-06-27 08:25:00 1.996        <NA>         <NA>
#>  7        08LG006 2017-06-27 08:30:00 1.996        <NA>         <NA>
#>  8        08LG006 2017-06-27 08:35:00 1.996        <NA>         <NA>
#>  9        08LG006 2017-06-27 08:40:00 1.997        <NA>         <NA>
#> 10        08LG006 2017-06-27 08:45:00 1.997        <NA>         <NA>
#> # ... with 8,636 more rows, and 5 more variables: LEVEL_CODE <int>,
#> #   FLOW <dbl>, FLOW_GRADE <chr>, FLOW_SYMBOL <chr>, FLOW_CODE <int>
```

Downloading by jurisdiction
---------------------------

We can use the `download_network()` functionality to get a vector of stations by jurisdiction. For example, we can choose all the stations in Prince Edward Island using the following:

``` r
download_realtime(STATION_NUMBER = "ALL", PROV_TERR_STATE_LOC = "PE")
#> # A tibble: 34,669 x 10
#>    STATION_NUMBER           date_time LEVEL LEVEL_GRADE LEVEL_SYMBOL
#>             <chr>              <dttm> <dbl>       <chr>        <chr>
#>  1        01CD005 2017-06-27 04:00:00 0.582        <NA>         <NA>
#>  2        01CD005 2017-06-27 04:15:00 0.583        <NA>         <NA>
#>  3        01CD005 2017-06-27 04:30:00 0.583        <NA>         <NA>
#>  4        01CD005 2017-06-27 04:45:00 0.583        <NA>         <NA>
#>  5        01CD005 2017-06-27 05:00:00 0.582        <NA>         <NA>
#>  6        01CD005 2017-06-27 05:15:00 0.581        <NA>         <NA>
#>  7        01CD005 2017-06-27 05:30:00 0.580        <NA>         <NA>
#>  8        01CD005 2017-06-27 05:45:00 0.580        <NA>         <NA>
#>  9        01CD005 2017-06-27 06:00:00 0.581        <NA>         <NA>
#> 10        01CD005 2017-06-27 06:15:00 0.583        <NA>         <NA>
#> # ... with 34,659 more rows, and 5 more variables: LEVEL_CODE <int>,
#> #   FLOW <dbl>, FLOW_GRADE <chr>, FLOW_SYMBOL <chr>, FLOW_CODE <int>
```

Web service realtime data
-------------------------

We can also download realtime data using the ECCC web service via the `download_ws()` function. To retrieve data in this manner, we must do a two stage process whereby we get a token from the webservice then use that token to access the web service. Credentials to get the token are also required and can only be requested from ECCC:

``` r
## Get token
token_out <- get_ws_token(username = username, password = password)

## Input STATION_NUMBER, parameters and date range
ws_test <- download_ws_realtime(STATION_NUMBER = "08LG006",
                                parameters = c(46,5), ## see data("param_id") for a list of codes
                                start_date = "2017-06-25",
                                end_date = "2017-07-24",
                                token = token_out)
```

Compare download\_ws and download\_realtime
-------------------------------------------

`tidyhydat` provides two methods to download realtime data. `download_realtime()` provides a function to import openly accessible .csv files from [here](http://dd.weather.gc.ca/hydrometric/csv/BC/). `download_ws()`, coupled with `get_ws_token()`, is an API client for a web service hosted by ECCC. `download_ws()` has several difference to `download_realtime()`. These include:

-   *Speed*: The `download_ws()` is much faster for larger queries (i.e. many stations). For single station queries `download_realtime()` if more appropriate.
-   *Length of record*: `download_ws()` records goes back further though only two months of data can accessed at one time.
-   *Type of parameters*: `download_realtime()` are retricted to river flow (either LEVEL and FLOW) data. In contrast `download_ws()` can download several different parameters depending on what is available for that station. See `data("param_id")` for a list and explanation of the parameters.
-   *Date/Time filtering*: `download_ws()` provides argument to select a date range. Selecting a data range with `download_realtime()` is not possible until after all files have been downloaded.
-   *Accessibility*: `download_realtime()` downloads data that openly accessible. `download_ws()` downloads data using a username and password which must be provided by ECCC.

### On the distinction between STATIONS() and download\_network()

`STATIONS()` and `download_network()` perform similar tasks albeit on different data sources. `STATIONS()` extracts directly from the HYDAT sqlite3 database. In addition to realtime stations, `STATIONS()` outputs discontinued and non-realtime stations:

``` r
STATIONS(STATION_NUMBER = "ALL", PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")
#> # A tibble: 41 x 15
#>    STATION_NUMBER                      STATION_NAME PROV_TERR_STATE_LOC
#>             <chr>                             <chr>               <chr>
#>  1        01CA001      CARRUTHERS BROOK NEAR HOWLAN                  PE
#>  2        01CA002      TROUT RIVER NEAR TYNE VALLEY                  PE
#>  3        01CA003 CARRUTHERS BROOK NEAR ST. ANTHONY                  PE
#>  4        01CA004        SMELT CREEK NEAR ELLERSLIE                  PE
#>  5        01CA005  MIMINEGASH RIVER AT ST. LAWRENCE                  PE
#>  6        01CB001         DUNK RIVER AT ROGERS MILL                  PE
#>  7        01CB002           DUNK RIVER AT WALL ROAD                  PE
#>  8        01CB003          PLAT RIVER AT SHERBROOKE                  PE
#>  9        01CB004   WILMOT RIVER NEAR WILMOT VALLEY                  PE
#> 10        01CB005        NORTH BROOK NEAR WALL ROAD                  PE
#> # ... with 31 more rows, and 12 more variables: REGIONAL_OFFICE_ID <chr>,
#> #   HYD_STATUS <chr>, SED_STATUS <chr>, LATITUDE <dbl>, LONGITUDE <dbl>,
#> #   DRAINAGE_AREA_GROSS <dbl>, DRAINAGE_AREA_EFFECT <dbl>, RHBN <int>,
#> #   REAL_TIME <int>, CONTRIBUTOR_ID <int>, OPERATOR_ID <int>,
#> #   DATUM_ID <int>
```

This is contrast to `download_network()` which downloads all realtime stations. Though this is not always the case, it is best to use `download_network()` when dealing with realtime data and `STATIONS()` when interacting with HYDAT.

Example with spatial data
-------------------------

The `download_realtime()` functions allows us to directly query the Environment Canada and Climate Change datamart selecting by station. If we wanted to look at all the realtime stations in a particular hydrologic zone, we could easily do this using the `dplyr`,`sf` and `bcmaps` packages. To install those packages use these commands:

``` r
devtools::install_github("bcgov/bcmaps")
install.packages("sf")
```

And then load these packages. `tidyhydat` and `dplyr` is already loaded above.

``` r
library(bcmaps)
#> Loading required package: sp
#> Warning: package 'sp' was built under R version 3.4.1
library(sf)
#> Warning: package 'sf' was built under R version 3.4.1
#> Linking to GEOS 3.6.1, GDAL 2.2.0, proj.4 4.9.3
```

Now to return the question. BC is divided into hydrologic zones. If use the hydrozones layer in `bcmaps` and convert it to `sf` format, determining which stations reside in which hydrologic zone is trivial. Using `st_join` allows to ask which hydrometric stations in the realtime network (called by `download_network`) are in which hydrologic zones. If we are interested in all realtime stations in the QUEEN CHARLOTTE ISLANDS hydrologic zone, we can generate that list by filtering by the relevant hydrologic zone:

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
qci_realtime <- download_realtime(STATION_NUMBER = qci_stations, PROV_TERR_STATE_LOC = "BC")
```

Then using `ggplot2` we could plot these results to have look at the data

``` r
library(ggplot2)

ggplot(qci_realtime, aes(x = date_time, y = FLOW)) +
  geom_line(aes(colour = STATION_NUMBER))
```

![](README-unnamed-chunk-16-1.png)

Project Status
--------------

This package is under continual development.

Getting Help or Reporting an Issue
----------------------------------

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/tidyhydat/issues/).

How to Contribute
-----------------

If you would like to contribute to the package, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

License
-------

    Copyright 2015 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at 

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
