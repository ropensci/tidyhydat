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



#' @title Make HYDAT data tidy
#' 
#' @description This package provides several wrappers to extract data from the HYDAT database and turn that into tidy data. 
#' Each function reflects a table in the HYDAT database.
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
#' @importFrom lubridate ymd
#' @importFrom tibble as_tibble
#' @import readr
#' @import dplyr
#' 
#' @references For more information on tidy data please see
#' \itemize{
#'  \item Wickham, Hadley. 2014. Tidy Data. The Journal of Statistical Software. 59. \url{https://www.jstatsoft.org/article/view/v059i10}
#'  \item tidy data vignette: \url{https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html}
#'  }
#'  
#'  To download the latest version of hydat please follow this link: 
#'  \itemize{
#'   \item \url{http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/Hydat_sqlite3_20170418.zip}
#'   }
#'   
NULL


## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))
