
<!-- README.md is generated from README.Rmd. Please edit that file -->
tidyhydat <img src="img/tidyhydat.png" align="right" />
=======================================================

<a rel="Delivery" href="https://github.com/BCDevExchange/docs/blob/master/discussion/projectstates.md"><img alt="In production, but maybe in Alpha or Beta. Intended to persist and be supported." style="border-width:0" src="https://assets.bcdevexchange.org/images/badges/delivery.svg" title="In production, but maybe in Alpha or Beta. Intended to persist and be supported." /></a> [![Travis-CI Build Status](https://travis-ci.org/bcgov/tidyhydat.svg?branch=master)](https://travis-ci.org/bcgov/tidyhydat) [![](https://badges.ropensci.org/152_status.svg)](https://github.com/ropensci/onboarding/issues/152)

Here is a list of what `tidyhydat` does:

-   Provide function that access each tables in the HYDAT database and return tidy data.
-   Keep functions are low-level as possible. For example, for daily flows, the `DLY_FLOWS()` function queries the database, *tidies* the data and returns the data.
-   Provide functions that access Environment and Climate Change Canada's real-time hydrometric data source.
-   Provide functions that search full station lists and aid in generating station vectors

A more thorough vignette outlining the full functionality of `tidyhydat` is outlined [here](https://github.com/bcgov/tidyhydat/blob/master/vignettes/tidyhydat.Rmd)

Installation
------------

To install the `tidyhydat` package, you need to install the `devtools` package then the `tidyhydat` package

``` r
install.packages("remotes")
remotes::install_github("bcgov/tidyhydat")
```

Then to load the package you need to using the `library()` function. When you install `tidyhydat`, several other packages will be installed as well. One of those packages, `dplyr`, is useful for data manipulations and is used regularly here. Even though `dplyr` is installed alongside `tidyhydat`, it is helpful to load it by itself as there are many useful functions contained within `dplyr`. A helpful `dplyr` tutorial can be found [here](https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html).

``` r
library(tidyhydat)
library(dplyr)
#> Warning: package 'dplyr' was built under R version 3.4.2
```

### HYDAT download

To use most of the `tidyhydat` package you will need the most recent version of the HYDAT database, Environment and Climate Change Canada's comprehensive database of historical hydrometric data. A zipped version of sqlite3 version can be downloaded here:

-   <http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/>

`tidyhydat` also provides a convenience function to download hydat (be patient though this takes a long time!):

``` r
download_hydat(dl_hydat_here = "H:/")
```

However you download it, the path to the sqlite3 must be specified within each function that uses HYDAT; you need tell `tidyhydat` where the HYDAT database. One option to is enter the path in each function like this:

``` r
STATIONS(hydat_path = "H:/Hydat.sqlite3")
```

It will quickly get tiring manually entering `hydat_path =`. R provides a means setting a hydat path once in the `.Renviron` file which is then automatically called by each HYDAT function. In R you can open up `.Renviron` like this:

``` r
file.edit("~/.Renviron")
```

This opens your `.Renviron` file which may be a blank file. Add this line somewhere in the file:

``` r
hydat = "YOUR HYDAT PATH"
```

It is important that you name the variable `hydat` as that is name of the variable that the functions are looking for.

Usage
-----

### HYDAT functions

All functions that interact with HYDAT are capitalized. These functions follow a common argument structure which can be illustrated with the `DLY_FLOWS()` function. If you would like to extract only station `08LA001` you can supply the `STATION_NUMBER`. The `hydat_path` argument is omitted here and it is assumed you set the variable in your `.Renviron` file which is highly recommend.

``` r
DLY_FLOWS(STATION_NUMBER = "08LA001")
#> No start and end dates specified. All dates available will be returned.
#> All station successfully retrieved
#> # A tibble: 28,794 x 5
#>    STATION_NUMBER       Date Parameter Value Symbol
#>             <chr>     <date>     <chr> <dbl>  <chr>
#>  1        08LA001 1914-01-01      FLOW   144   <NA>
#>  2        08LA001 1914-01-02      FLOW   144   <NA>
#>  3        08LA001 1914-01-03      FLOW   144   <NA>
#>  4        08LA001 1914-01-04      FLOW   140   <NA>
#>  5        08LA001 1914-01-05      FLOW   140   <NA>
#>  6        08LA001 1914-01-06      FLOW   136   <NA>
#>  7        08LA001 1914-01-07      FLOW   136   <NA>
#>  8        08LA001 1914-01-08      FLOW   140   <NA>
#>  9        08LA001 1914-01-09      FLOW   140   <NA>
#> 10        08LA001 1914-01-10      FLOW   140   <NA>
#> # ... with 28,784 more rows
```

If you would instead prefer all stations from a province, you can use the `PROV_TERR_STATE_LOC` argument and omit the `STATION_NUMBER` argument:

``` r
DLY_FLOWS(PROV_TERR_STATE_LOC = "PE")
#> No start and end dates specified. All dates available will be returned.
#> The following station(s) were not retrieved: 01CB011
#> Check station number typos or if it is a valid station in the network
#> # A tibble: 186,858 x 5
#>    STATION_NUMBER       Date Parameter Value Symbol
#>             <chr>     <date>     <chr> <dbl>  <chr>
#>  1        01CC001 1919-07-01      FLOW    NA   <NA>
#>  2        01CE001 1919-07-01      FLOW    NA   <NA>
#>  3        01CE002 1919-07-01      FLOW    NA   <NA>
#>  4        01CC001 1919-07-02      FLOW    NA   <NA>
#>  5        01CE001 1919-07-02      FLOW    NA   <NA>
#>  6        01CE002 1919-07-02      FLOW    NA   <NA>
#>  7        01CC001 1919-07-03      FLOW    NA   <NA>
#>  8        01CE001 1919-07-03      FLOW    NA   <NA>
#>  9        01CE002 1919-07-03      FLOW    NA   <NA>
#> 10        01CC001 1919-07-04      FLOW    NA   <NA>
#> # ... with 186,848 more rows
```

### Real-time

To download real-time data using the datamart we can use approximately the same conventions discussed above. Using `download_realtime_dd()` we can easily select specific stations by supplying a station of interest:

``` r
download_realtime_dd(STATION_NUMBER = "08LG006")
```

Another option is to provide simply the province as an argument and download all stations from that province:

``` r
download_realtime_dd(PROV_TERR_STATE_LOC = "PE")
```

Additionally `download_realtime_ws()` provides another means of acquiring real time data though that requires a username and password from Environment and Climate Change Canada.

### Search functions

You can also make use of auxiliary functions in `tidyhdyat` called `search_name()` and `search_number()` to look for matches when you know part of a name of a station. For example:

``` r
search_name("liard")
#> # A tibble: 8 x 3
#>   STATION_NUMBER                      STATION_NAME PROV_TERR_STATE_LOC
#>            <chr>                             <chr>               <chr>
#> 1        10AA001     LIARD RIVER AT UPPER CROSSING                  YT
#> 2        10BE001     LIARD RIVER AT LOWER CROSSING                  BC
#> 3        10BE005    LIARD RIVER ABOVE BEAVER RIVER                  BC
#> 4        10BE006   LIARD RIVER ABOVE KECHIKA RIVER                  BC
#> 5        10ED001         LIARD RIVER AT FORT LIARD                  NT
#> 6        10ED002        LIARD RIVER NEAR THE MOUTH                  NT
#> 7        10ED008   LIARD RIVER AT LINDBERG LANDING                  NT
#> 8        10GC004 MACKENZIE RIVER ABOVE LIARD RIVER                  NT
```

Similarly, `search_number()` can be useful if you are interested in all stations from the *08MF* sub-sub-drainage:

``` r
search_number("08MF")
#> # A tibble: 49 x 3
#>    STATION_NUMBER                                STATION_NAME
#>             <chr>                                       <chr>
#>  1        08MF001              ANDERSON RIVER NEAR BOSTON BAR
#>  2        08MF002                  BOULDER CREEK NEAR LAIDLAW
#>  3        08MF003                  COQUIHALLA RIVER NEAR HOPE
#>  4        08MF004           FRASER RIVER ABOVE THOMPSON RIVER
#>  5        08MF005                        FRASER RIVER AT HOPE
#>  6        08MF006 WAHLEACH CREEK NEAR LAIDLAW (UPPER STATION)
#>  7        08MF007  NAHATLATCH RIVER AT OUTLET OF FRANCES LAKE
#>  8        08MF008               NAHATLATCH RIVER NEAR KEEFERS
#>  9        08MF009                  SILVERHOPE CREEK NEAR HOPE
#> 10        08MF011                     STEIN RIVER NEAR LYTTON
#> # ... with 39 more rows, and 1 more variables: PROV_TERR_STATE_LOC <chr>
```

Project Status
--------------

This package is under active development.

Getting Help or Reporting an Issue
----------------------------------

To report bugs/issues/feature requests, please file an [issue](https://github.com/bcgov/tidyhydat/issues/).

These are very welcome!

How to Contribute
-----------------

If you would like to contribute to the package, please see our [CONTRIBUTING](CONTRIBUTING.md) guidelines.

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

Citation
--------

Get citation information for `tidyhydat` in R by running:

``` r
citation("tidyhydat")
#> Warning in citation("tidyhydat"): no date field in DESCRIPTION file of
#> package 'tidyhydat'
#> Warning in citation("tidyhydat"): could not determine year for 'tidyhydat'
#> from package DESCRIPTION file
#> 
#> To cite package 'tidyhydat' in publications use:
#> 
#>   Sam Albers (NA). tidyhydat: Extract and Tidy Canadian
#>   Hydrometric Data. R package version 0.2.9.
#>   https://github.com/bcgov/tidyhydat
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {tidyhydat: Extract and Tidy Canadian Hydrometric Data},
#>     author = {Sam Albers},
#>     note = {R package version 0.2.9},
#>     url = {https://github.com/bcgov/tidyhydat},
#>   }
```

License
-------

Copyright 2017 Province of British Columbia

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
