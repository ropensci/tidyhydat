# Copyright 2025 Province of British Columbia
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

## Add "ws" class for webservice functions
as.ws <- function(x) {
  class(x) <- c("ws", setdiff(class(x), "ws"))
  t <- Sys.time()
  attr(t, "tzone") <- "UTC"
  attr(x, "query_time") <- t

  x
}

#' @export
print.ws <- function(x, ...) {
  cat(paste("  Queried on:", attributes(x)$query_time, "(UTC)\n"))

  if (c("Date") %in% names(x) && !all(is.na(x$Date))) {
    date_range <- paste0(
      range(as.Date(x$Date), na.rm = TRUE),
      collapse = " to "
    )
    cat(paste0("  Date range: ", date_range, " \n"))
  }

  if ("STATION_NUMBER" %in% names(x)) {
    n_stns <- format(dplyr::n_distinct(x$STATION_NUMBER), big.mark = ",")
    cat(paste0("  Station(s) returned: ", n_stns, "\n"))

    differ <- attributes(x)$missed_stns
    if (!is.null(differ) && length(differ) > 0) {
      cat("  Stations requested but not returned: \n")
      if (length(differ) > 10) {
        cat(crayon::cyan(
          "    More than 10 stations requested but not returned.\n"
        ))
      } else {
        cat(crayon::cyan(paste0("    ", paste0(differ, collapse = " "), "\n")))
      }
    } else if (!is.null(differ)) {
      cat(crayon::cyan("  All stations successfully retrieved.\n"))
    }
  }

  if ("Parameter" %in% names(x)) {
    missed_params <- attributes(x)$missed_params
    if (!is.null(missed_params) && length(missed_params) > 0) {
      cat(crayon::cyan(paste0(
        "  Parameter(s) not retrieved: ",
        paste0(missed_params, collapse = " "),
        "\n"
      )))
    } else if (!is.null(missed_params)) {
      cat(crayon::cyan("  All parameters successfully retrieved.\n"))
    }
  }

  print(dplyr::as_tibble(x), ...)
}
