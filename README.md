<!-- README.md is generated from README.Rmd. Please edit that file -->

tidyhydat <img src="man/figures/tidyhydat.png" align="right" />
===============================================================

[![dev](https://assets.bcdevexchange.org/images/badges/delivery.svg)](https://github.com/BCDevExchange/assets/blob/master/README.md)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Travis-CI Build
Status](http://travis-ci.org/ropensci/tidyhydat.svg?branch=master)](https://travis-ci.org/ropensci/tidyhydat)
[![Coverage
status](https://codecov.io/gh/ropensci/tidyhydat/branch/master/graph/badge.svg)](https://codecov.io/github/ropensci/tidyhydat?branch=master)
[![R build
status](https://github.com/ropensci/tidyhydat/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/tidyhydat/actions)

[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/tidyhydat)](https://cran.r-project.org/package=tidyhydat)
[![CRAN
Downloads](https://cranlogs.r-pkg.org/badges/tidyhydat?color=brightgreen)](https://CRAN.R-project.org/package=tidyhydat)
[![cran
checks](https://cranchecks.info/badges/worst/tidyhydat)](https://cran.r-project.org/web/checks/check_results_tidyhydat.html)

[![](http://badges.ropensci.org/152_status.svg)](https://github.com/ropensci/onboarding/issues/152)
[![DOI](http://joss.theoj.org/papers/10.21105/joss.00511/status.svg)](https://doi.org/10.21105/joss.00511)
[![DOI](https://zenodo.org/badge/100978874.svg)](https://zenodo.org/badge/latestdoi/100978874)

Project Status
--------------

This package is maintained by the Data Science and Analytics Branch of
the [British Columbia Ministry of Citizens’
Services](https://www2.gov.bc.ca/gov/content/governments/organizational-structure/ministries-organizations/ministries/citizens-services).

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
    data and returns a [tibble](http://tibble.tidyverse.org/) of daily
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

    realtime_dd(station_number = "08LG006")
    #>   Queried on: 2020-08-28 22:34:06 (UTC)
    #>   Date range: 2020-07-29 to 2020-08-28 
    #> # A tibble: 17,580 x 8
    #>    STATION_NUMBER PROV_TERR_STATE~ Date                Parameter Value Grade
    #>    <chr>          <chr>            <dttm>              <chr>     <dbl> <chr>
    #>  1 08LG006        BC               2020-07-29 08:00:00 Flow       19.3 <NA> 
    #>  2 08LG006        BC               2020-07-29 08:05:00 Flow       19.2 <NA> 
    #>  3 08LG006        BC               2020-07-29 08:10:00 Flow       19.2 <NA> 
    #>  4 08LG006        BC               2020-07-29 08:15:00 Flow       19.2 <NA> 
    #>  5 08LG006        BC               2020-07-29 08:20:00 Flow       19.2 <NA> 
    #>  6 08LG006        BC               2020-07-29 08:25:00 Flow       19.2 <NA> 
    #>  7 08LG006        BC               2020-07-29 08:30:00 Flow       19.2 <NA> 
    #>  8 08LG006        BC               2020-07-29 08:35:00 Flow       19.2 <NA> 
    #>  9 08LG006        BC               2020-07-29 08:40:00 Flow       19.2 <NA> 
    #> 10 08LG006        BC               2020-07-29 08:45:00 Flow       19.2 <NA> 
    #> # ... with 17,570 more rows, and 2 more variables: Symbol <chr>, Code <chr>

### Plotting

Plot methods are also provided to quickly visualize realtime data:

    realtime_ex <- realtime_dd(station_number = "08LG006")

    plot(realtime_ex)

![](man/figures/README-unnamed-chunk-7-1.png)

and also historical data:

    hy_ex <- hy_daily_flows(station_number = "08LA001", start_date = "2013-01-01")

    plot(hy_ex)

![](man/figures/README-unnamed-chunk-8-1.png)

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

    citation("tidyhydat")

[![ropensci\_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)

License
-------

Copyright 2017 Province of British Columbia

Licensed under the Apache License, Version 2.0 (the “License”); you may
not use this file except in compliance with the License. You may obtain
a copy of the License at

<a href="http://www.apache.org/licenses/LICENSE-2.0" class="uri">http://www.apache.org/licenses/LICENSE-2.0</a>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an “AS IS” BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
