# Copyright 2017 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.



#' @title Extract tidy river data
#' 
#' @description tidyhydat provides functions to extract river data from Water Survey of Canada sources and make it tidy.
#' 
#' \code{tidyhydat} package
#' 
#' @docType package
#' @name tidyhydat
#' 
#' @importFrom DBI dbConnect
#' @importFrom DBI dbDisconnect
#' @importFrom RSQLite SQLite
#' @importFrom tidyr gather
#' @importFrom tibble tibble
#' @importFrom lubridate ymd
#' @importFrom lubridate year
#' @importFrom lubridate month
#' @importFrom lubridate day
#' @import readr
#' @import dplyr
#' @import httr
#' 
#' @references For more information on tidy data please see
#' \itemize{
#'  \item Wickham, Hadley. 2014. Tidy Data. The Journal of Statistical Software. 59. \url{https://www.jstatsoft.org/article/view/v059i10}
#'  \item tidy data vignette: \url{https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html}
#'  }
#'  
#'  To download the latest version of hydat please follow this link: 
#'  \itemize{
#'   \item \url{http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/}
#'   }
#'   
NULL


#' REmoves notes from R CMD check for NSE
#'
.onLoad <- function(libname = find.package("tidyhydat"), pkgname = "tidyhydat"){
  # CRAN Note avoidance
  if(getRversion() >= "2.15.1")
    utils::globalVariables(
      # Vars used in Non-Standard Evaluations, declare here to avoid CRAN warnings
      c("PROV_TERR_STATE_LOC", "FULL_MONTH", "MAX", "DAY", "FLOW", "MONTH",
        "YEAR", "Date","stns", "FLOW", "LEVEL","PRECISION_CODE",
        "." # piping requires '.' at times
      )
    )
  invisible()
}
