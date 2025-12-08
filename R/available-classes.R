# Copyright 2025 Hakai Institute
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

## Add "available" class for combined validated + provisional data
as.available <- function(x) {
  class(x) <- c("available", setdiff(class(x), "available"))
  t <- Sys.time()
  attr(t, "tzone") <- "UTC"
  attr(x, "query_time") <- t

  x
}

#' @export
print.available <- function(x, ...) {
  cat(paste("  Queried on:", attributes(x)$query_time, "(UTC)\n"))

  ## Historical data source
  hist_source <- attributes(x)$historical_source
  if (!is.null(hist_source) && !is.na(hist_source)) {
    cat(paste0("  Historical data source: ", hist_source, "\n"))
  }

  ## Date range by approval status
  if ("Date" %in% names(x) && "Approval" %in% names(x)) {
    ## Final/validated data range
    final_data <- x[x$Approval == "final" & !is.na(x$Approval), ]
    if (nrow(final_data) > 0) {
      final_range <- paste0(
        range(as.Date(final_data$Date), na.rm = TRUE),
        collapse = " to "
      )
      cat(paste0("  Final data range: ", final_range, "\n"))
    } else {
      cat(crayon::yellow("  Final data range: No final data\n"))
    }

    ## Provisional data range
    prov_data <- x[x$Approval == "provisional" & !is.na(x$Approval), ]
    if (nrow(prov_data) > 0) {
      prov_range <- paste0(
        range(as.Date(prov_data$Date), na.rm = TRUE),
        collapse = " to "
      )
      cat(paste0("  Provisional data range: ", prov_range, "\n"))
    } else {
      cat(crayon::yellow("  Provisional data range: No provisional data\n"))
    }

    ## Overall date range
    overall_range <- paste0(
      range(as.Date(x$Date), na.rm = TRUE),
      collapse = " to "
    )
    cat(paste0("  Overall date range: ", overall_range, "\n"))
  }

  ## Data source breakdown
  if ("Approval" %in% names(x)) {
    approval_counts <- table(x$Approval)
    cat("  Records by approval status:\n")
    for (status in names(approval_counts)) {
      count <- format(approval_counts[status], big.mark = ",")
      cat(paste0("    ", status, ": ", count, "\n"))
    }
  }

  ## Station coverage
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

  ## Parameter info
  if ("Parameter" %in% names(x)) {
    cat(paste0(
      "  Parameter(s): ",
      paste0(unique(x$Parameter), collapse = "/"),
      "\n"
    ))
  }

  print(dplyr::as_tibble(x), ...)
}

#' Plot available data (final + provisional)
#'
#' This method plots combined final and provisional data, visually distinguishing
#' between validated (final) and provisional records.
#'
#' @param x Object created by `available_flows()` or `available_levels()`
#' @param ... passed to [plot()]
#'
#' @method plot available
#' @name plot
#'
#' @examples
#' \dontrun{
#' # One station
#' flows <- available_flows("08MF005")
#' plot(flows)
#' }
#'
#' @export
#'
plot.available <- function(x = NULL, ...) {
  if (!all(c("STATION_NUMBER", "Date", "Parameter", "Value", "Approval") %in% names(x))) {
    stop("plot.available requires STATION_NUMBER, Date, Parameter, Value, and Approval columns", call. = FALSE)
  }

  ### Join with meta data to get station name
  hydf <- dplyr::left_join(
    x,
    suppressMessages(tidyhydat::allstations),
    by = c("STATION_NUMBER")
  )

  hydf$STATION <- paste(hydf$STATION_NAME, hydf$STATION_NUMBER, sep = " - ")
  hydf$STATION <- factor(hydf$STATION)

  num_stns <- length(unique(hydf$STATION))

  if (num_stns > 4L) {
    stop("You are trying to plot more than four stations at once.", call. = FALSE)
  }

  if (num_stns > 2L) {
    m <- matrix(c(1, 1, 2, 3, 4, 5, 6, 6), nrow = 4, ncol = 2, byrow = TRUE)
    graphics::layout(mat = m, heights = c(0.1, 0.35, 0.35, 0.2))
  }

  if (num_stns == 2L) {
    m <- matrix(c(1, 1, 2, 3, 4, 4), nrow = 3, ncol = 2, byrow = TRUE)
    graphics::layout(mat = m, heights = c(0.2, 0.6, 0.2))
  }

  if (num_stns == 1L) {
    m <- matrix(c(1, 2, 3), nrow = 3, ncol = 1, byrow = TRUE)
    graphics::layout(mat = m, heights = c(0.2, 0.6, 0.2))
  }

  graphics::par(mar = c(1, 1, 1, 1))
  graphics::plot.new()
  graphics::text(
    0.5,
    0.5,
    "Water Survey of Canada Gauges\n(Final + Provisional Data)",
    cex = 2,
    font = 2
  )

  for (i in seq_along(unique(hydf$STATION))) {
    graphics::par(
      mar = c(4, 5, 2, 1),
      mgp = c(3.1, 0.4, 0),
      las = 1,
      tck = -.01,
      xaxs = "i",
      yaxs = "i"
    )

    station_data <- hydf[hydf$STATION == unique(hydf$STATION)[i], ]

    ## Plot final data first
    final_data <- station_data[station_data$Approval == "final", ]
    provisional_data <- station_data[station_data$Approval == "provisional", ]

    graphics::plot(
      Value ~ Date,
      data = station_data,
      xlab = "Date",
      ylab = eval(parse(text = label_helper(unique(hydf$Parameter)))),
      axes = FALSE,
      type = "n",
      ylim = c(0, max(station_data$Value, na.rm = TRUE)),
      frame.plot = TRUE,
      ...
    )

    ## Plot final data in dark color
    if (nrow(final_data) > 0) {
      graphics::points(
        Value ~ Date,
        data = final_data,
        pch = 20,
        cex = 0.75,
        col = "#000000"
      )
    }

    ## Plot provisional data in lighter color
    if (nrow(provisional_data) > 0) {
      graphics::points(
        Value ~ Date,
        data = provisional_data,
        pch = 20,
        cex = 0.75,
        col = "#82D6FF"
      )
    }

    at_y <- utils::head(pretty(station_data$Value), -1)
    graphics::mtext(
      side = 2,
      text = at_y,
      at = at_y,
      col = "grey20",
      line = 1,
      cex = 0.75
    )

    at_x <- utils::tail(utils::head(pretty(station_data$Date), -1), -1)
    graphics::mtext(
      side = 1,
      text = format(at_x, "%Y"),
      at = at_x,
      col = "grey20",
      line = 1,
      cex = 0.75
    )

    graphics::title(main = paste0(unique(hydf$STATION)[i]), cex.main = 1.1)
  }

  ## Legend
  graphics::plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
  graphics::legend(
    x = "center",
    legend = c("Final (validated)", "Provisional"),
    pch = 20,
    col = c("#000000", "#82D6FF"),
    bty = "n",
    cex = 1.2,
    horiz = TRUE
  )

  invisible(TRUE)
}
