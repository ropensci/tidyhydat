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


#' Extract tidy water data
#'
#' @description tidyhydat provides a series of functions to make downloading and importing data from HYDAT into R a 
#' simple process for a user. HYDAT is the Canada national water data archive, published quarterly by 
#' the Government of Canada's Department of Environment and Climate Change. It is relational database that 
#' contains daily, monthly and annual data on water flow, water levels and sediment data. Functions are also 
#' provided to extract station metadata like position and record history.
#' 
#' In addition to historical data from HYDAT, tidhydat also provide functions to access realtime water flow and 
#' water level data. This data is raw and unapproved originating directly from the station. 
#' 
#' Regardless of the data source, tidyhydat organizes all this data in a consistent format that allows the user to 
#' quickly and efficient connect with Canadian hydrological data. 
#'
#'
#' @docType package
#' @name tidyhydat
#' 
#' @importFrom dplyr %>%
#'
#' @references 
#' 
#' To download the latest version of hydat please:
#'  \itemize{
#'   \item use the \code{download_hydat()} function.
#'   }
#' 
#' For more information on tidy data please see
#' \itemize{
#'  \item Wickham, Hadley. 2014. Tidy Data. The Journal of Statistical Software. 59. \url{https://www.jstatsoft.org/article/view/v059i10}
#'  \item tidy data vignette: \url{https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html}
#'  }
#'
#'  For more information on HYDAT 
#'  \itemize{
#'    \item Please see this description of the database: goo.gl/H3NXJQ
#'    \item This page is landing page for technical description of HYDAT:
#'    \url{http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/}
#'    \item This page links to a document that outlines database table definitions:
#'    \url{http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/HYDAT_Definition_EN.pdf}
#'    }
#'
NULL
