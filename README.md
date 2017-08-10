<a rel="Exploration" href="https://github.com/BCDevExchange/docs/blob/master/discussion/projectstates.md"><img alt="Being designed and built, but in the lab. May change, disappear, or be buggy." style="border-width:0" src="https://assets.bcdevexchange.org/images/badges/exploration.svg" title="Being designed and built, but in the lab. May change, disappear, or be buggy." /></a>

[![Travis-CI Build Status](https://travis-ci.org/bcgov/tidyhydat.svg?branch=master)](https://travis-ci.org/bcgov/tidyhydat)

<!-- README.md is generated from README.Rmd. Please edit that file -->
tidyhydat
=========

Here is a list of what tidyhydat does:

-   Perform a number of common queries on the HYDAT database and returns tidy data
-   Keep functions are low-level as possible. For example, for daily flows, the `DLY_FLOWS()` function queries the database, *tidies* the data and returns the data.

Installation
------------

To install the `tidyhydat` package, you need to install the `devtools` package then the `tidyhydat` package

``` r
install.packages("devtools")
devtools::install_github("bcgov/tidyhydat")
```

Then to load the package you need to using the `library` function. When you install `tidyhydat`, several other packages will be installed as well. One of those packages, `dplyr`, is useful for data manipulations and is used regularly here. Even though `dplyr` is installed alongside `tidyhydat`, it is helpful to load it by itself as there are many useful functions contained within `dplyr`. A helpful `dplyr` tutorial can be found [here](https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html).

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

Usage
-----

This is a basic example of `tidyhydat` usage. All functions that interact with HYDAT are capitalized (e.g. `STATIONS`). These functions follow a common argument structure which can be illustrated with the `DLY_FLOWS()` function. If you would like to extract only station `08LA001` you must supply the `STATION_NUMBER` and the `PROV_TERR_STATE_LOC` arguments. The `hydat_path` argument is supplied here as a local path the database. Yours will be different.

``` r
DLY_FLOWS(STATION_NUMBER = "08LA001", PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3")
#> No start and end dates specified. All dates available will be returned.
#> # A tibble: 28,794 x 5
#>    STATION_NUMBER       Date  FLOW FLOW_SYMBOL SYMBOL_EN
#>             <chr>     <date> <dbl>       <chr>     <chr>
#>  1        08LA001 1914-01-01   144        <NA>      <NA>
#>  2        08LA001 1914-01-02   144        <NA>      <NA>
#>  3        08LA001 1914-01-03   144        <NA>      <NA>
#>  4        08LA001 1914-01-04   140        <NA>      <NA>
#>  5        08LA001 1914-01-05   140        <NA>      <NA>
#>  6        08LA001 1914-01-06   136        <NA>      <NA>
#>  7        08LA001 1914-01-07   136        <NA>      <NA>
#>  8        08LA001 1914-01-08   140        <NA>      <NA>
#>  9        08LA001 1914-01-09   140        <NA>      <NA>
#> 10        08LA001 1914-01-10   140        <NA>      <NA>
#> # ... with 28,784 more rows
```

Project Status
--------------

This package is under continual development.

Getting Help or Reporting an Issue
----------------------------------

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/tidyhydat/issues/).

These are very welcome!

How to Contribute
-----------------

If you would like to contribute to the package, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

License
-------

    Copyright 2017 Province of British Columbia

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at 

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
