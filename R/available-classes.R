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
  cat(paste("  Queried on:", attr(x, "query_time"), "(UTC)\n"))

  hist_source <- attr(x, "historical_source")
  if (!is.null(hist_source) && !is.na(hist_source)) {
    cat(paste0("  Historical data source: ", hist_source, "\n"))
  }

  if ("Date" %in% names(x)) {
    cat(paste0(
      "  Overall date range: ",
      format_date_range(x$Date),
      "\n"
    ))
  }

  if ("Approval" %in% names(x)) {
    param <- if ("Parameter" %in% names(x)) unique(x$Parameter)[1] else NULL
    print_approval_counts(x$Approval, parameter = param)
  }

  if ("STATION_NUMBER" %in% names(x)) {
    print_station_coverage(x)
  }

  cat(crayon::cyan("  Use summary() for per-station date ranges.\n"))

  print(dplyr::as_tibble(x), ...)
}


#' Format a date range as "start to end" string
#' @noRd
format_date_range <- function(dates) {

  paste0(range(as.Date(dates), na.rm = TRUE), collapse = " to ")
}


#' Print date range for a given approval status
#' @noRd
print_date_range <- function(x, approval_value, label) {
  subset_data <- x[x$Approval == approval_value & !is.na(x$Approval), ]
  if (nrow(subset_data) > 0) {
    cat(paste0("  ", label, " data range: ", format_date_range(subset_data$Date), "\n"))
  } else {
    cat(crayon::yellow(paste0("  ", label, " data range: No ", tolower(label), " data\n")))
  }
}


#' Print approval status record counts
#' @noRd
print_approval_counts <- function(approval, parameter) {
  counts <- table(approval)
  cat(paste0("  ", parameter, " records by approval status:\n"))
  for (status in names(counts)) {
    cat(paste0("    ", status, ": ", format(counts[status], big.mark = ","), "\n"))
  }
}


#' Print station coverage information
#' @noRd
print_station_coverage <- function(x) {
  n_stns <- format(dplyr::n_distinct(x$STATION_NUMBER), big.mark = ",")
  cat(paste0("  Station(s) returned: ", n_stns, "\n"))

  missed <- attr(x, "missed_stns")
  if (is.null(missed)) {
    return()
  }

  if (length(missed) == 0) {
    cat(crayon::cyan("  All stations successfully retrieved.\n"))
  } else if (length(missed) > 10) {
    cat("  Stations requested but not returned: \n")
    cat(crayon::cyan("    More than 10 stations requested but not returned.\n"))
  } else {
    cat("  Stations requested but not returned: \n")
    cat(crayon::cyan(paste0("    ", paste0(missed, collapse = " "), "\n")))
  }
}

#' Summarize available data by station
#'
#' Returns a tibble with date ranges and record counts for each station,
#' broken down by approval status (final vs provisional).
#'
#' @param object Object created by `available_flows()` or `available_levels()`
#' @param ... ignored
#'
#' @return A tibble with columns:
#' \itemize{
#'   \item STATION_NUMBER
#'   \item final_start, final_end - date range for validated data
#'   \item provisional_start, provisional_end - date range for provisional data
#'   \item final_n, provisional_n - record counts
#' }
#'
#' @method summary available
#' @export
#'
#' @examples
#' \dontrun{
#' flows <- available_flows(c("08MF005", "08MF010"))
#' summary(flows)
#' }
#'
summary.available <- function(object, ...) {
  x <- object

  ranges <- x |>
    dplyr::group_by(.data$STATION_NUMBER, .data$Approval) |>
    dplyr::summarise(
      start = min(as.Date(.data$Date), na.rm = TRUE),
      end = max(as.Date(.data$Date), na.rm = TRUE),
      n = dplyr::n(),
      .groups = "drop"
    ) |>
    tidyr::pivot_wider(
      names_from = "Approval",
      values_from = c("start", "end", "n"),
      names_glue = "{Approval}_{.value}"
    )

  # Reorder columns for nicer display
  col_order <- c(
    "STATION_NUMBER",
    "final_start", "final_end", "final_n",
    "provisional_start", "provisional_end", "provisional_n"
  )
  col_order <- col_order[col_order %in% names(ranges)]
  ranges <- ranges[, col_order]

  ranges
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
  required_cols <- c("STATION_NUMBER", "Date", "Parameter", "Value", "Approval")
  if (!all(required_cols %in% names(x))) {
    stop(
      "plot.available requires STATION_NUMBER, Date, Parameter, Value, and Approval columns",
      call. = FALSE
    )
  }

  hydf <- dplyr::left_join(
    x,
    suppressMessages(tidyhydat::allstations),
    by = "STATION_NUMBER"
  )
  hydf$STATION <- factor(paste(hydf$STATION_NAME, hydf$STATION_NUMBER, sep = " - "))

  stations <- unique(hydf$STATION)
  num_stns <- length(stations)

  if (num_stns > 4L) {
    stop("You are trying to plot more than four stations at once.", call. = FALSE)
  }

  setup_plot_layout(num_stns)
  draw_plot_title()

  for (station in stations) {
    draw_station_plot(hydf, station, unique(hydf$Parameter), ...)
  }

  draw_plot_legend()
  invisible(TRUE)
}


#' Set up the plot layout based on number of stations
#' @noRd
setup_plot_layout <- function(num_stns) {
  layout_config <- switch(
    as.character(num_stns),
    "1" = list(
      mat = matrix(c(1, 2, 3), nrow = 3, ncol = 1, byrow = TRUE),
      heights = c(0.2, 0.6, 0.2)
    ),
    "2" = list(
      mat = matrix(c(1, 1, 2, 3, 4, 4), nrow = 3, ncol = 2, byrow = TRUE),
      heights = c(0.2, 0.6, 0.2)
    ),
    list(
      mat = matrix(c(1, 1, 2, 3, 4, 5, 6, 6), nrow = 4, ncol = 2, byrow = TRUE),
      heights = c(0.1, 0.35, 0.35, 0.2)
    )
  )
  graphics::layout(mat = layout_config$mat, heights = layout_config$heights)
}


#' Draw the plot title
#' @noRd
draw_plot_title <- function() {
  graphics::par(mar = c(1, 1, 1, 1))
  graphics::plot.new()
  graphics::text(
    0.5, 0.5,
    "Water Survey of Canada Gauges\n(Final + Provisional Data)",
    cex = 2,
    font = 2
  )
}


#' Draw a single station's plot
#' @noRd
draw_station_plot <- function(hydf, station, parameter, ...) {
  graphics::par(
    mar = c(4, 5, 2, 1),
    mgp = c(3.1, 0.4, 0),
    las = 1,
    tck = -0.01,
    xaxs = "r",
    yaxs = "r"
  )

  station_data <- hydf[hydf$STATION == station, ]
  final_data <- station_data[station_data$Approval == "final", ]
  provisional_data <- station_data[station_data$Approval == "provisional", ]

  graphics::plot(
    Value ~ Date,
    data = station_data,
    xlab = "Date",
    ylab = eval(parse(text = label_helper(unique(parameter)))),
    axes = FALSE,
    type = "n",
    ylim = c(0, max(station_data$Value, na.rm = TRUE)),
    frame.plot = TRUE,
    ...
  )

  if (nrow(final_data) > 0) {
    graphics::points(Value ~ Date, data = final_data, pch = 20, cex = 0.75, col = "#000000")
  }
  if (nrow(provisional_data) > 0) {
    graphics::points(Value ~ Date, data = provisional_data, pch = 20, cex = 0.75, col = "#82D6FF")
  }

  at_y <- utils::head(pretty(station_data$Value), -1)
  graphics::mtext(side = 2, text = at_y, at = at_y, col = "grey20", line = 1, cex = 0.75)

  at_x <- utils::tail(utils::head(pretty(station_data$Date), -1), -1)
  graphics::mtext(side = 1, text = format(at_x, "%Y"), at = at_x, col = "grey20", line = 1, cex = 0.75)

  graphics::title(main = as.character(station), cex.main = 1.1)
}


#' Draw the legend for available data plots
#' @noRd
draw_plot_legend <- function() {
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
}
