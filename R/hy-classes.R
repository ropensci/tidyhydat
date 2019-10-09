# Copyright 2019 Province of British Columbia
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

## Add "hy" class
as.hy <- function(x) {
  class(x) <- c("hy", setdiff(class(x), "hy"))
  x
}

#' @export
print.hy <- function(x, ...){
  summary_msg(x)
  if(c("Date") %in% names(x)) date_range_msg(x)
  if("STATION_NUMBER" %in% names(x)) missed_station_msg(x)
  print(dplyr::as_tibble(x))
}

summary_msg <- function(x){
  cat(paste0("  Queried from version of HYDAT released on ", as.Date(hy_version()$Date),"\n"))
  
  n_records = format(nrow(x), big.mark = ",")
  cat(paste0("   Observations:                      ", n_records, "\n"))
  
  if("Symbol" %in% names(x)){
    n_flags = format(length(x$Symbol[!is.na(x$Symbol)]), big.mark = ",")
    cat(paste0("   Measurement flags:                 ", n_flags, "\n"))
  }
  
  if("PROV_TERR_STATE_LOC" %in% names(x)){
    cat(paste0("   Jurisdictions: ",paste0(unique(x$PROV_TERR_STATE_LOC), collapse = ", "), "\n"))
  }
  
  if("Parameter" %in% names(x)){
    cat(paste0("   Parameter(s):                      ",paste0(unique(x$Parameter), collapse = "/"), "\n"))
  }
}

date_range_msg <- function(x){
  date_range = paste0(range(as.Date(x$Date), na.rm = TRUE), collapse = " to ")
  cat(paste0("   Date range:                        ", date_range, " \n"))
}

missed_station_msg <- function(x){

  n_stns = format(dplyr::n_distinct(x$STATION_NUMBER), big.mark = ",")
  cat(paste0("   Station(s) returned:               ", n_stns, "\n"))
  
  differ = attributes(x)$missed_stns
  #browser()
  cat("   Stations requested but not returned: \n")
  if (length(differ) != 0) {
    if(length(differ) > 50){
      cat(crayon::cyan("     More than 50 stations requested but not returned. \n"))
      cat(crayon::cyan(paste0("     See object attributes for complete list of missing stations.\n")))
    } else{
      cat(
        crayon::cyan(
          paste0("    ", 
                 strwrap(
                   paste0(differ, collapse = " ")
                   , width = 40
                   ), 
                 collapse = "\n")
          )
      )
      }
    cat("\n")
  } else {
    cat(crayon::cyan("    All stations returned.\n"))
  }
}

