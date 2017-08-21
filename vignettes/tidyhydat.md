> "Tidy datasets are all alike but every messy dataset is messy in its own way - " Wickham (2014)

Introduction
============

Environment and Climate Change Canada (ECCC) through the Water Survey of Canada (WSC) maintains several national hydrometric data sources. These data are partially funded by provincial partners and constitute the main data product of a national integrated hydrometric network. Historical data are stored in the [HYDAT database](http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/). Real-time data are provided by ECCC through two sources. The first real-time data option is a login only web service which is faster and contains more data that the datamart. Files are updated to the datamart on an hourly basis though the lag between actual hydrometric measurement and the available of hydrometric data is more like 2.5 hours. The second is the [datamart](http://dd.weather.gc.ca/hydrometric/) which is an open source organized as a directory tree structure by province. The objective of this document is the outline the usage of `tidyhydat`, an R package that makes ECCC hydrometric data *tidy*. The primary goal of `tidyhydat` is to provide a common API and data structure for ECCC data sources using a clean, easy to use interface that use tidy data principles developed by Wickham (2014) within the R project (R Core Team 2017).

Why use R?
----------

There are many statistical computing projects that offer great functionality for users. For `tidyhydat` we have chosen to use R. R is a mature open-source project that provides significant potential for advanced modelling, visualization and data manipulation. There are several commonly cited reasons to use R:

-   R is and always will be free to use and modify
-   R is flexible and can be easily adapted to a wide range of problems
-   R is well established and well used.
-   R has a friendly community which is an important infrastructure element of any open source project.

What is tidy data?
------------------

Embedded within `tidyhydat` is the principle of *tidy data*. Wickham (2014) defines tidy data by three principles:

-   Each variable variable forms a column
-   Each observation forms a row
-   Each type of observational unit forms a table

It is illustrative here to provide an example of the types of data *tidying* processes that `tidyhydat` does for you automatically. A basic SQL query to the `DLY_FLOWS` table in the HYDAT database returns data that looks like this:

    ## # Source:   lazy query [?? x 73]
    ## # Database: sqlite 3.19.3 [H:\Hydat.sqlite3]
    ##    STATION_NUMBER  YEAR MONTH FULL_MONTH NO_DAYS MONTHLY_MEAN
    ##             <chr> <int> <int>      <int>   <int>        <dbl>
    ##  1        08MF005  1912     3          1      31          485
    ##  2        08MF005  1912     4          1      30         1150
    ##  3        08MF005  1912     5          1      31         4990
    ##  4        08MF005  1912     6          1      30         6130
    ##  5        08MF005  1912     7          1      31         4780
    ##  6        08MF005  1912     8          1      31         3960
    ##  7        08MF005  1912     9          1      30         2160
    ##  8        08MF005  1912    10          1      31         1530
    ##  9        08MF005  1912    11          1      30         1060
    ## 10        08MF005  1912    12          1      31          761
    ## # ... with more rows, and 67 more variables: MONTHLY_TOTAL <dbl>,
    ## #   FIRST_DAY_MIN <int>, MIN <dbl>, FIRST_DAY_MAX <int>, MAX <dbl>,
    ## #   FLOW1 <dbl>, FLOW_SYMBOL1 <chr>, FLOW2 <dbl>, FLOW_SYMBOL2 <chr>,
    ## #   FLOW3 <dbl>, FLOW_SYMBOL3 <chr>, FLOW4 <dbl>, FLOW_SYMBOL4 <chr>,
    ## #   FLOW5 <dbl>, FLOW_SYMBOL5 <chr>, FLOW6 <dbl>, FLOW_SYMBOL6 <chr>,
    ## #   FLOW7 <dbl>, FLOW_SYMBOL7 <chr>, FLOW8 <dbl>, FLOW_SYMBOL8 <chr>,
    ## #   FLOW9 <dbl>, FLOW_SYMBOL9 <chr>, FLOW10 <dbl>, FLOW_SYMBOL10 <chr>,
    ## #   FLOW11 <dbl>, FLOW_SYMBOL11 <chr>, FLOW12 <dbl>, FLOW_SYMBOL12 <chr>,
    ## #   FLOW13 <dbl>, FLOW_SYMBOL13 <chr>, FLOW14 <dbl>, FLOW_SYMBOL14 <chr>,
    ## #   FLOW15 <dbl>, FLOW_SYMBOL15 <chr>, FLOW16 <dbl>, FLOW_SYMBOL16 <chr>,
    ## #   FLOW17 <dbl>, FLOW_SYMBOL17 <chr>, FLOW18 <dbl>, FLOW_SYMBOL18 <chr>,
    ## #   FLOW19 <dbl>, FLOW_SYMBOL19 <chr>, FLOW20 <dbl>, FLOW_SYMBOL20 <chr>,
    ## #   FLOW21 <dbl>, FLOW_SYMBOL21 <chr>, FLOW22 <dbl>, FLOW_SYMBOL22 <chr>,
    ## #   FLOW23 <dbl>, FLOW_SYMBOL23 <chr>, FLOW24 <dbl>, FLOW_SYMBOL24 <chr>,
    ## #   FLOW25 <dbl>, FLOW_SYMBOL25 <chr>, FLOW26 <dbl>, FLOW_SYMBOL26 <chr>,
    ## #   FLOW27 <dbl>, FLOW_SYMBOL27 <chr>, FLOW28 <dbl>, FLOW_SYMBOL28 <chr>,
    ## #   FLOW29 <dbl>, FLOW_SYMBOL29 <chr>, FLOW30 <dbl>, FLOW_SYMBOL30 <chr>,
    ## #   FLOW31 <dbl>, FLOW_SYMBOL31 <chr>

This data structure clearly violates the principles of tidy data - this is messy data. For example, column header (e.g. `FLOW1`) contains the day number - a value. HYDAT is structured like this for very reasonable historical reasons. It does, however, significantly limit the analyst's ability to efficiently extract hydrometric data. For example, given the current data structure, it is not possible to only extract from the 15th of one month to the 15th of the next. Rather a query would need to be made on all data from the relevant months and then further processing would need to occur.

`tidyhydat` makes this process simpler. If we want the same data as the example above, we can use the `DLY_FLOWS()` function in `tidyhydat` to query the same data in HYDAT but return a much tidier data structure. It is now very simple to extract data between say March 15, 1992 and April 15, 1992. We just need to supply these arguments to `DLY_FLOWS()` after loading the package itself:

``` r
library(tidyhydat)
DLY_FLOWS(hydat_path = "H:/Hydat.sqlite3",
          STATION_NUMBER = "08MF005",
          PROV_TERR_STATE_LOC = "BC",
          start_date = "1992-03-15",
          end_date = "1992-04-15")
```

    ## # A tibble: 32 x 5
    ##    STATION_NUMBER       Date Parameter Value Symbol
    ##             <chr>     <date>     <chr> <dbl>  <chr>
    ##  1        08MF005 1992-03-15      FLOW  1630   <NA>
    ##  2        08MF005 1992-03-16      FLOW  1730   <NA>
    ##  3        08MF005 1992-03-17      FLOW  1900   <NA>
    ##  4        08MF005 1992-03-18      FLOW  2040   <NA>
    ##  5        08MF005 1992-03-19      FLOW  2140   <NA>
    ##  6        08MF005 1992-03-20      FLOW  2180   <NA>
    ##  7        08MF005 1992-03-21      FLOW  2170   <NA>
    ##  8        08MF005 1992-03-22      FLOW  2150   <NA>
    ##  9        08MF005 1992-03-23      FLOW  2130   <NA>
    ## 10        08MF005 1992-03-24      FLOW  2120   <NA>
    ## # ... with 22 more rows

As you can see, this is much tidier data and is much easier to work with. In addition to these tidy principles, specific to `tidyhydat` we can also define that *for a common data structure, variables should be referred to by a common name*. For example, hydrometric stations are given a unique 7 digit identifier that contains important watershed information. This identifier is variously referred to as `STATION_NUMBER` or `ID` depending on the ECCC data source. To tidy this hydrometric data, we have renamed where necessary each instance of the unique identifier as `STATION_NUMBER`.

`tidyhydat` package
===================

There have also been recent calls to use R more broadly in the field of hydrology (Moore and Hutchinson 2017). The `tidyhydat` package is an effort to push this call forward by being the standard package by which hydrologists and other users interact with WSC data in R. Functions in `tidyhydat` can be split into two categories: functions that directly access HYDAT and functions that access real-time data ultimately destined for HYDAT. We've already seen some usage of `tidyhydat` when we illustrated the principles of tidy data above. In this section, we will outline a few key options that will hopefully make `tidyhydat` useful.

HYDAT functions
---------------

All functions that interact with HYDAT are capitalized (e.g. `STATIONS`). To use any of these functions you will need a locally stored copy of the HYDAT database which can be downloaded here:

-   <http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/>

These are the HYDAT functions that are currently implemented:

-   `STATIONS`
-   `DLY_FLOWS`
-   `DLY_LEVELS`
-   `ANNUAL_STATISTICS`

These functions follow a common argument structure which can be illustrated with the `DLY_FLOWS()` function. For these functions, you must supply both the `STATION_NUMBER` and the `PROV_TERR_STATE_LOC` arguments. The `hydat_path` argument is supplied here as a local path to the database. Yours will be different:

``` r
DLY_FLOWS(STATION_NUMBER = "08LA001", PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3")
```

If you would like to query the database for two or more stations you would combine the `STATION_NUMBER` into a vector using `c()`:

``` r
DLY_FLOWS(STATION_NUMBER = c("08LA001","08NL071"), PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3")
```

If instead you would like to extract flows for all stations from a jurisdiction, you can use the "ALL" argument for `STATION_NUMBER`:

``` r
DLY_FLOWS(STATION_NUMBER = "ALL", PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")
```

We saw above that if we were only interested in a subset of dates we could use the `start_date` and `end_date` arguments. A date must be supplied to both these arguments in the form of YYYY-MM-DD. If you were interested in all daily flow data from station number "08LA001" for 1981, you would specify all days in 1981 :

``` r
DLY_FLOWS(STATION_NUMBER = "08LA001", PROV_TERR_STATE_LOC = "BC", hydat_path = "H:/Hydat.sqlite3",
          start_date = "1981-01-01", end_date = "1981-12-31")
```

You can also make use of auxiliary function in `tidyhdyat` called `search_name` to look for matches when you know part of a name of a station. For example:

``` r
search_name("liard")
```

    ## # A tibble: 3 x 2
    ##   STATION_NUMBER                    STATION_NAME
    ##            <chr>                           <chr>
    ## 1        10BE001   LIARD RIVER AT LOWER CROSSING
    ## 2        10BE005  LIARD RIVER ABOVE BEAVER RIVER
    ## 3        10BE006 LIARD RIVER ABOVE KECHIKA RIVER

This generally outlines the usage of the HYDAT functions within `tidyhydat`.

Real-time functions
-------------------

In addition to the approved and vetted data in the HYDAT database ECCC also offers unapproved data that is subject to revision. `tidyhydat` provides three functions to access these data sources. Remember these are **unapproved** data and should treated as such:

-   `realtime_network_meta()`
-   `download_realtime_ws()`
-   `download_reatime2()`

Not every stations is currently part of the real-time network. Therefore `realtime_network_meta()` points to a (hopefully) updated ECCC data file of active real-time stations. We can use the `realtime_network_meta()` functionality to get a vector of stations by jurisdiction. For example, we can choose all the stations in Prince Edward Island using the following:

``` r
realtime_network_meta(PROV_TERR_STATE_LOC = "PE")
```

`STATIONS()` and `realtime_network_meta()` perform similar tasks albeit on different data sources. `STATIONS()` extracts directly from HYDAT. In addition to real-time stations, `STATIONS()` outputs discontinued and non-real-time stations:

``` r
STATIONS(STATION_NUMBER = "ALL", PROV_TERR_STATE_LOC = "PE", hydat_path = "H:/Hydat.sqlite3")
```

This is contrast to `realtime_network_meta()` which downloads all real-time stations. Though this is not always the case, it is best to use `realtime_network_meta()` when dealing with real-time data and `STATIONS()` when interacting with HYDAT. It is also appropriate to filter the output of `STATIONS()` by the `REAL_TIME` column.

Water Office web service - `download_realtime_ws()`
---------------------------------------------------

The National Hydrological Service has recently introduced an efficient service from which to query real-time data. The `download_realtime_ws()` function, which provides a convenient way to import this data into R, introduces two new arguments that impact the data that is returned. The web service provides additional data beyond simply hydrometric information. This is specified using the `parameters` argument as an integer code. The corresponding parameters can be examined using the internal `param_id` dataset:

``` r
data("param_id")
param_id
```

    ## # A tibble: 8 x 7
    ##   Parameter  Code                     Name_En
    ##       <int> <chr>                       <chr>
    ## 1        46    HG     Water level provisional
    ## 2        16   HG2       Secondary water level
    ## 3        52   HG3        Tertiary water level
    ## 4        47    QR       Discharge Provisional
    ## 5         8   QRS           Discharge, sensor
    ## 6         5    TW           Water temperature
    ## 7        41   TW2 Secondary water temperature
    ## 8        18    PC   Accumulated precipitation
    ## # ... with 4 more variables: Name_Fr <chr>, Unit <chr>,
    ## #   Description_En <chr>, Description_Fr <chr>

The `parameters` argument will take any value in the `param_id$Parameter` column. The web service requires credentials to access which can only be requested from ECCC. To retrieve data in this manner, `tidyhydat` employs a two stage process whereby we get a token from the web service using our credentials then use that token to access the web service. Therefore the second new argument is `token` the value of which is provided by `get_ws_token()`:

``` r
## Get token
token_out <- get_ws_token(username = Sys.getenv("WS_USRNM"), password = Sys.getenv("WS_PWD"))

## Input STATION_NUMBER, parameters and date range
ws_test <- download_realtime_ws(STATION_NUMBER = "08LG006",
                                parameters = c(46,5), ## Water level and temperature
                                start_date = "2017-06-25",
                                end_date = "2017-07-24",
                                token = token_out)
```

Tokens only last for 10 minutes and users can only have 5 tokens at once. Therefore it is best to query the web service a little as possible by being efficient and strategic with your queries. `download_realtime_ws()` will only return data that is available. A message is returned if a particular station was not available. `parameters`, `start_date` and `end_date` fail silently if the station does not collect that parameter or data on that date. The web service constrains queries to be under 60 days and fewer than 300 stations. If more data is required, multiple queries should be made and combined using a function like `rbind()`.

### Managing your credentials in R

Because you are accessing the web service using credentials and potentially will be sharing your code will others, it is important that you set up some method so that your secrets aren't shared widely. Please read [this article](http://httr.r-lib.org/articles/secrets.html) to familiarize yourself with credential management. [This section](http://httr.r-lib.org/articles/secrets.html#environment-variables) is summarized here specific to `tidyhydat`. If you receive your credentials from ECCC it not advisable to directly include them in any code. Rather these important value are stored the `.Renviron` file. Run the following in a console:

``` r
file.edit("~/.Renviron")
```

This opens your `.Renviron` file which is most likely blank. This is where you enter the credentials given to you by ECCC. The code that you paste into the `.Renviron` file might look like something like this:

``` r
## Credentials for ECCC web service
WS_USRNM = "here is the username that ECCC gave you"
WS_PWD = "here is the password that ECCC gave you"
```

Now these values can be accessed within an R session without giving away your secrets (Using `Sys.getenv()`). Just remember to call them directly and don't assign them to a variable.

MSC datamart - `download_realtime_dd()`
---------------------------------------

To download real-time data using the datamart we can use approximately the same conventions discussed above. Using `download_realtime_dd()` we can easily select specific stations by supplying a station of interest. Note that in contrast to `download_realtime_ws()` but similar to `DLY_FLOWS()`, we need to supply both the station and the province that we are interested in:

``` r
download_realtime_dd(STATION_NUMBER = "08LG006", PROV_TERR_STATE_LOC = "BC")
```

    ## # A tibble: 17,340 x 7
    ##    STATION_NUMBER                Date Parameter Value Grade Symbol  Code
    ##             <chr>              <dttm>     <chr> <dbl> <chr>  <chr> <chr>
    ##  1        08LG006 2017-07-22 08:00:00      FLOW  9.07  <NA>   <NA>     1
    ##  2        08LG006 2017-07-22 08:05:00      FLOW  9.11  <NA>   <NA>     1
    ##  3        08LG006 2017-07-22 08:10:00      FLOW  9.11  <NA>   <NA>     1
    ##  4        08LG006 2017-07-22 08:15:00      FLOW  9.11  <NA>   <NA>     1
    ##  5        08LG006 2017-07-22 08:20:00      FLOW  9.11  <NA>   <NA>     1
    ##  6        08LG006 2017-07-22 08:25:00      FLOW  9.11  <NA>   <NA>     1
    ##  7        08LG006 2017-07-22 08:30:00      FLOW  9.07  <NA>   <NA>     1
    ##  8        08LG006 2017-07-22 08:35:00      FLOW  9.11  <NA>   <NA>     1
    ##  9        08LG006 2017-07-22 08:40:00      FLOW  9.07  <NA>   <NA>     1
    ## 10        08LG006 2017-07-22 08:45:00      FLOW  9.11  <NA>   <NA>     1
    ## # ... with 17,330 more rows

Compare `download_realtime_ws` and `download_realtime_dd`
---------------------------------------------------------

`tidyhydat` provides two methods to download real-time data. `download_realtime_ws()`, coupled with `get_ws_token()`, is an API client for a web service hosted by ECCC. `download_realtime_dd()` provides a function to import openly accessible .csv files from [here](http://dd.weather.gc.ca/hydrometric/). `download_realtime_ws()` has several difference to `download_realtime_dd()`. These include:

-   *Speed*: `download_realtime_ws()` is much faster for larger queries (i.e. many stations). For single station queries `download_realtime_dd()` if more appropriate.
-   *Length of record*: `download_realtime_ws()` records goes back further though only two months of data can accessed at one time. Though it varies for each station, typically the last 18 months of data are available with the web service.
-   *Type of parameters*: `download_realtime_dd()` is restricted to river flow (either LEVEL and FLOW) data. In contrast `download_realtime_ws()` can download several different parameters depending on what is available for that station. See `data("param_id")` for a list and explanation of the parameters.
-   *Date/Time filtering*: `download_realtime_ws()` provides argument to select a date range. Selecting a data range with `download_realtime_dd()` is not possible until after all files have been downloaded.
-   *Accessibility*: `download_realtime_dd()` downloads data that openly accessible. `download_realtime_ws()` downloads data using a username and password which must be provided by ECCC.

License
=======

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

References
==========

Moore, RD Dan, and David Hutchinson. 2017. “Why Watershed Analysts Should Use R for Data Processing and Analysis.” *Confluence: Journal of Watershed Science and Management* 1 (1).

R Core Team. 2017. *R: A Language and Environment for Statistical Computing*. Vienna, Austria: R Foundation for Statistical Computing. <https://www.R-project.org/>.

Wickham, Hadley. 2014. “Tidy Data.” *Journal of Statistical Software* 59 (10). Foundation for Open Access Statistics: 1–23.
