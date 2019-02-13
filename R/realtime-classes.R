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

## Add "realtime" class
as.realtime <- function(x) {
  class(x) <- c("realtime", setdiff(class(x), "realtime"))
  x
}

#' @export
print.realtime <- function(x, ...){
  cat(paste("  Queried on", format(Sys.time(), tz = "UTC"), "(UTC)\n"))
  if(c("Date") %in% names(x)){
    date_range = paste0(range(as.Date(x$Date), na.rm = TRUE), collapse = " to ")
    cat(paste0("  Date range: ", date_range, " \n"))
  }
  print(dplyr::as_tibble(x))
}
