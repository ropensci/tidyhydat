<!-- README.md is generated from README.Rmd. Please edit that file -->

tidyhydat <img src="man/figures/logo.png" align="right" />
==========================================================

<!-- badges: start -->

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0/)
[![Coverage
status](https://codecov.io/gh/ropensci/tidyhydat/branch/master/graph/badge.svg)](https://codecov.io/github/ropensci/tidyhydat?branch=master)
[![R build
status](https://github.com/ropensci/tidyhydat/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/tidyhydat/actions)

[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/tidyhydat)](https://cran.r-project.org/package=tidyhydat)
[![CRAN
Downloads](https://cranlogs.r-pkg.org/badges/tidyhydat?color=brightgreen)](https://CRAN.R-project.org/package=tidyhydat)
[![cran
checks](https://badges.cranchecks.info/worst/tidyhydat.svg)](https://cran.r-project.org/web/checks/check_results_tidyhydat.html)
[![r-universe](https://ropensci.r-universe.dev/badges/tidyhydat)](https://ropensci.r-universe.dev/builds)
[![](http://badges.ropensci.org/152_status.svg)](https://github.com/ropensci/software-review/issues/152)
[![DOI](http://joss.theoj.org/papers/10.21105/joss.00511/status.svg)](https://doi.org/10.21105/joss.00511)
[![DOI](https://zenodo.org/badge/100978874.svg)](https://zenodo.org/badge/latestdoi/100978874)
[![R-CMD-check](https://github.com/ropensci/tidyhydat/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ropensci/tidyhydat/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

What does `tidyhydat` do?
-------------------------

-   Provides functions (`hy_*`) that access hydrometric data from the
    HYDAT database, a national archive of Canadian hydrometric data and
    return tidy data.
-   Provides functions (`realtime_*`) that access Environment and
    Climate Change Canada’s real-time hydrometric data source.
-   Provides functions (`search_*`) that can search through the
    approximately 7000 stations in the database and aid in generating
    station vectors
-   Keep functions as simple as possible. For example, for daily flows,
    the `hy_daily_flows()` function queries the database, *tidies* the
    data and returns a [tibble](https://tibble.tidyverse.org/) of daily
    flows.

Installation
------------

You can install `tidyhydat` from CRAN:

    install.packages("tidyhydat")

To install the development version of the `tidyhydat` package, you can
install directly from the rOpenSci development server:

    install.packages("tidyhydat", repos = "https://dev.ropensci.org")

Usage
-----

More documentation on `tidyhydat` can found at the rOpenSci doc page:
<a href="https://docs.ropensci.org/tidyhydat/" class="uri">https://docs.ropensci.org/tidyhydat/</a>

When you install `tidyhydat`, several other packages will be installed
as well. One of those packages, `dplyr`, is useful for data
manipulations and is used regularly here. To use actually use `dplyr` in
a session you must explicitly load it. A helpful `dplyr` tutorial can be
found
[here](https://cran.r-project.org/package=dplyr/vignettes/dplyr.html).

    library(tidyhydat)
    library(dplyr)

### HYDAT download

To use many of the functions in the `tidyhydat` package you will need to
download a version of the HYDAT database, Environment and Climate Change
Canada’s database of historical hydrometric data then tell R where to
find the database. Conveniently `tidyhydat` does all this for you via:

    download_hydat()

This downloads (with your permission) the most recent version of HYDAT
and then saves it in a location on your computer where `tidyhydat`’s
function will look for it. Do be patient though as this can take a long
time! To see where HYDAT was saved you can run `hy_default_db()`. Now
that you have HYDAT downloaded and ready to go, you are all set to begin
looking at Canadian hydrometric data.

### Real-time

To download real-time data using the datamart we can use approximately
the same conventions discussed above. Using `realtime_dd()` we can
easily select specific stations by supplying a station of interest:

    realtime_dd(station_number = "08MF005")
    #>   Queried on: 2023-04-03 03:53:02 (UTC)
    #>   Date range: 2023-03-04 to 2023-04-03 
    #> # A tibble: 16,902 × 8
    #>    STATION_NUMBER PROV_TE…¹ Date                Param…² Value Grade Symbol Code 
    #>    <chr>          <chr>     <dttm>              <chr>   <dbl> <chr> <chr>  <chr>
    #>  1 08MF005        BC        2023-03-04 08:00:00 Flow      566 <NA>  <NA>   1    
    #>  2 08MF005        BC        2023-03-04 08:05:00 Flow      564 <NA>  <NA>   1    
    #>  3 08MF005        BC        2023-03-04 08:10:00 Flow      564 <NA>  <NA>   1    
    #>  4 08MF005        BC        2023-03-04 08:15:00 Flow      564 <NA>  <NA>   1    
    #>  5 08MF005        BC        2023-03-04 08:20:00 Flow      565 <NA>  <NA>   1    
    #>  6 08MF005        BC        2023-03-04 08:25:00 Flow      564 <NA>  <NA>   1    
    #>  7 08MF005        BC        2023-03-04 08:30:00 Flow      566 <NA>  <NA>   1    
    #>  8 08MF005        BC        2023-03-04 08:35:00 Flow      564 <NA>  <NA>   1    
    #>  9 08MF005        BC        2023-03-04 08:40:00 Flow      564 <NA>  <NA>   1    
    #> 10 08MF005        BC        2023-03-04 08:45:00 Flow      564 <NA>  <NA>   1    
    #> # … with 16,892 more rows, and abbreviated variable names ¹​PROV_TERR_STATE_LOC,
    #> #   ²​Parameter

Or we can use `realtime_ws`:

    realtime_ws(
      station_number = "08MF005",
      parameters = c(46, 5), ## see param_id for a list of codes
      start_date = Sys.Date() - 14,
      end_date = Sys.Date()
    )
    #> Warning: One or more parsing issues, call `problems()` on your data frame for details, e.g.:
    #>   dat <- vroom(...)
    #>   problems(dat)
    #> All station successfully retrieved
    #> All parameters successfully retrieved
    #> # A tibble: 4,267 × 10
    #>    STATIO…¹ Date                Name_En Value Unit  Grade Symbol Appro…² Param…³
    #>    <chr>    <dttm>              <chr>   <dbl> <chr> <chr> <chr>    <int>   <dbl>
    #>  1 08MF005  2023-03-20 00:00:00 Water …  5.19 °C    -1    <NA>        NA       5
    #>  2 08MF005  2023-03-20 01:00:00 Water …  4.03 °C    -1    <NA>        NA       5
    #>  3 08MF005  2023-03-20 02:00:00 Water …  3.93 °C    -1    <NA>        NA       5
    #>  4 08MF005  2023-03-20 03:00:00 Water …  3.94 °C    -1    <NA>        NA       5
    #>  5 08MF005  2023-03-20 04:00:00 Water …  3.84 °C    -1    <NA>        NA       5
    #>  6 08MF005  2023-03-20 05:00:00 Water …  3.7  °C    -1    <NA>        NA       5
    #>  7 08MF005  2023-03-20 06:00:00 Water …  3.71 °C    -1    <NA>        NA       5
    #>  8 08MF005  2023-03-20 07:00:00 Water …  3.47 °C    -1    <NA>        NA       5
    #>  9 08MF005  2023-03-20 08:00:00 Water …  3.64 °C    -1    <NA>        NA       5
    #> 10 08MF005  2023-03-20 09:00:00 Water …  3.46 °C    -1    <NA>        NA       5
    #> # … with 4,257 more rows, 1 more variable: Code <chr>, and abbreviated variable
    #> #   names ¹​STATION_NUMBER, ²​Approval, ³​Parameter

Compare realtime\_ws and realtime\_dd
-------------------------------------

`tidyhydat` provides two methods to download realtime data.
`realtime_dd()` provides a function to import .csv files from
[here](https://dd.weather.gc.ca/hydrometric/csv/). `realtime_ws()` is an
client for a web service hosted by ECCC. `realtime_ws()` has several
difference to `realtime_dd()`. These include:

-   *Speed*: The `realtime_ws()` is much faster for larger queries
    (i.e. many stations). For single station queries to `realtime_dd()`
    is more appropriate.
-   *Length of record*: `realtime_ws()` records goes back further in
    time.
-   *Type of parameters*: `realtime_dd()` are restricted to river flow
    (either flow and level) data. In contrast `realtime_ws()` can
    download several different parameters depending on what is available
    for that station. See `data("param_id")` for a list and explanation
    of the parameters.
-   *Date/Time filtering*: `realtime_ws()` provides argument to select a
    date range. Selecting a data range with `realtime_dd()` is not
    possible until after all files have been downloaded.

### Plotting

Plot methods are also provided to quickly visualize realtime data:

    realtime_ex <- realtime_dd(station_number = "08MF005")

    plot(realtime_ex)

![](man/figures/README-unnamed-chunk-8-1.png)

and also historical data:

    hy_ex <- hy_daily_flows(station_number = "08MF005", start_date = "2013-01-01")

    plot(hy_ex)

![](man/figures/README-unnamed-chunk-9-1.png)

Getting Help or Reporting an Issue
----------------------------------

To report bugs/issues/feature requests, please file an
[issue](https://github.com/ropensci/tidyhydat/issues/).

These are very welcome!

How to Contribute
-----------------

If you would like to contribute to the package, please see our
[CONTRIBUTING](https://github.com/ropensci/tidyhydat/blob/master/CONTRIBUTING.md)
guidelines.

Please note that this project is released with a [Contributor Code of
Conduct](https://github.com/ropensci/tidyhydat/blob/master/CODE_OF_CONDUCT.md).
By participating in this project you agree to abide by its terms.

Citation
--------

Get citation information for `tidyhydat` in R by running:


    To cite package 'tidyhydat' in publications use:

      Albers S (2017). "tidyhydat: Extract and Tidy Canadian Hydrometric
      Data." _The Journal of Open Source Software_, *2*(20).
      doi:10.21105/joss.00511 <https://doi.org/10.21105/joss.00511>,
      <http://dx.doi.org/10.21105/joss.00511>.

    A BibTeX entry for LaTeX users is

      @Article{,
        title = {tidyhydat: Extract and Tidy Canadian Hydrometric Data},
        author = {Sam Albers},
        doi = {10.21105/joss.00511},
        url = {http://dx.doi.org/10.21105/joss.00511},
        year = {2017},
        publisher = {The Open Journal},
        volume = {2},
        number = {20},
        journal = {The Journal of Open Source Software},
      }

[![ropensci\_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)

License
-------

Copyright 2017 Province of British Columbia

Licensed under the Apache License, Version 2.0 (the “License”); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at

<a href="https://www.apache.org/licenses/LICENSE-2.0" class="uri">https://www.apache.org/licenses/LICENSE-2.0</a>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
