### Summary

-   What does this package do? (explain in 50 words or less): `tidyhydat` provides functions to extract historical and real-time national hydrometric data from Water Survey of Canada data sources

-   Paste the full DESCRIPTION file inside a code block below:

```
Package: tidyhydat
Title: Extract and Tidy Canadian Hydrometric Data
Version: 0.2.8
Authors@R: c(person("Sam", "Albers", email = "sam.albers@gov.bc.ca", role = c("aut", "cre"),
           ), person("David", "Hutchinson", email = "david.hutchinson@canada.ca", role = "ctb"),
           person("Province of British Columbia", role = "cph"))
Description: `tidyhydat` provides functions to extract historical and real-time national hydrometric
  data from Water Survey of Canada data sources (http://dd.weather.gc.ca/hydrometric/csv/ and
  http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/) and then apply tidy data principles.
Depends: R (>= 3.4.0)
License: Apache License (== 2.0) | file LICENSE
URL: https://github.com/bcgov/tidyhydat
BugReports: https://github.com/bcgov/tidyhydat/issues
Encoding: UTF-8
Imports:
    dplyr (>= 0.7.3),
    readr (>= 1.1.1),
    lubridate (>= 1.6.0),
    tidyr (>= 0.7.1),
    DBI (>= 0.7),
    RSQLite (>= 2.0),
    tibble (>= 1.3.4),
    httr (>= 1.3.1)
Suggests:
    tidyverse,
    dbplyr,
    knitr,
    rmarkdown,
    testthat
LazyData: true
RoxygenNote: 6.0.1
VignetteBuilder: knitr
```

-   URL for the package (the development repository, not a stylized html page): https://github.com/bcgov/tidyhydat

- Please indicate which category or categories from our [package fit policies](https://github.com/ropensci/onboarding/blob/master/policies.md#package-fit) this package falls under ***and why**:

    - data retrieval: `tidyhydat` retrieves data from the Water Survey of Canada *datamart* via the `download_realtime_dd()` function from http://dd.weather.gc.ca/hydrometric/csv/. `download_realtime_ws` provides access via the `httr` package to a new password protected web service provided by Environment and Climate Change Canada (ECCC). Differences between the download realtime functions are outlined [here](https://github.com/bcgov/tidyhydat/blob/master/vignettes/tidyhydat.Rmd#compare-download_realtime_ws-and-download_realtime_dd)
    - data extraction: The majority of `tidyhydat`'s exported functions provide easy access to ECCC's publicly available and open-licenced HYDAT sqlite3 database (http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/) of historical river and lake levels in Canada. HYDAT is updated quarterly and is distributed via the [Canadian Open Government Licence](https://github.com/bcgov/tidyhydat/blob/master/data-raw/HYDAT_internal_data/LICENSE.OGL-CAN-2.0). HYDAT is not included with this package because it is regularly updated and because the file size is prohibitively large (>1GB) for inclusion in an R package. Rather `tidyhydat` provides the `download_hydat()` function that downloads it for the user. 

-   Who is the target audience?  

    - Anyone who is interested in making use of the Water Survey of Canada data sources in R including industry, government and academics.

-   Are there other R packages that accomplish the same thing? If so, how does
yours differ or meet [our criteria for best-in-category](https://github.com/ropensci/onboarding/blob/master/policies.md#overlap)?

    - A search of the term "hydat" on github reveals two R packages that provide similar (but not all the same) functionality:
    - [HYDAT](https://github.com/CentreForHydrology/HYDAT): the original author of **HYDAT** has contributed to this package and further development or maintenance of **HYDAT** is unlikely. 
    - [hydatr](https://github.com/paleolimbot/hydatr) was developed at approximately the same time as `tidyhydat`. 
    - `tidyhydat` documentation is more comprehensive than both packages.
    - Through the realtime functions `tidyhydat` provides added functionality not present in both packages. Neither `HYDAT` nor `hydatr` provide any functionality to access the web service and `hydatr` does not access any real-time datamart data.
    - An express goal of `tidyhydat` is to provide data in a tidy format. This conceptual data science goal provides a clear objective that is missing from both other packages. 


### Requirements

Confirm each of the following by checking the box.  This package:

- [x] does not violate the Terms of Service of any service it interacts with. 
- [x] has a CRAN and OSI accepted license.
- [x] contains a README with instructions for installing the development version. 
- [x] includes documentation with examples for all functions.
- [x] contains a vignette with examples of its essential functions and uses.
- [x] has a test suite.
- [x] has continuous integration, including reporting of test coverage, using services such as Travis CI, Coeveralls and/or CodeCov.
- [x] I agree to abide by [ROpenSci's Code of Conduct](https://github.com/ropensci/onboarding/blob/master/policies.md#code-of-conduct) during the review process and in maintaining my package should it be accepted.

#### Publication options

- [x] Do you intend for this package to go on CRAN?  
- [x] Do you wish to automatically submit to the [Journal of Open Source Software](http://joss.theoj.org/)? If so:
    - [x] The package has an **obvious research application** according to [JOSS's definition](http://joss.theoj.org/about#submission_requirements).
    - [x] The package contains a `paper.md` matching [JOSS's requirements](http://joss.theoj.org/about#paper_structure) with a high-level description in the package root or in `inst/`.
    - [ ] The package is deposited in a long-term repository with the DOI: 
    - (*Do not submit your package separately to JOSS*)

### Detail

- [x] Does `R CMD check` (or `devtools::check()`) succeed?  Paste and describe any errors or warnings:

- [x] Does the package conform to [rOpenSci packaging guidelines](https://github.com/ropensci/onboarding/blob/master/packaging_guide.md)? Please describe any exceptions:

- If this is a resubmission following rejection, please explain the change in circumstances:

- If possible, please provide recommendations of reviewers - those with experience with similar packages and/or likely users of your package - and their GitHub user names:


