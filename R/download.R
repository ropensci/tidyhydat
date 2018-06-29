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

#' Download and set the path to HYDAT
#'
#' Download the HYDAT sqlite database. This database contains all the historical hydrometric data for Canada's integrated hydrometric network.
#' The function will check for a existing sqlite file and won't download the file if the same version is already present. 

#'
#' @param dl_hydat_here Directory to the HYDAT database. The path is chosen by the \code{rappdirs} package and is OS specific and can be view by \code{hy_dir}. 
#' This path is also supplied automatically to any function that uses the HYDAT database. A user specified path can be set though this is not the advised approach. 
#' It also downloads the database to a directory specified by \code{hy_dir}.
#' @export
#'
#' @examples \dontrun{
#' download_hydat()
#' }
#'

download_hydat <- function(dl_hydat_here = NULL) {
  
  if(is.null(dl_hydat_here)){
    dl_hydat_here <- hy_dir()
  }
  
  ## Close all connections if function bonks halfway through
  on.exit(closeAllConnections())
  

  ans <- ask(paste("Downloading HYDAT will take ~10 minutes.","This will remove any older versions of HYDAT",
                   "Is that okay?", sep = "\n"))
  if (!ans) stop("Maybe another day...", call. = FALSE)
  

  info(paste0("Downloading HYDAT.sqlite3 to ", crayon::blue(dl_hydat_here)))


  ## Create actual hydat_path
  hydat_path <- file.path(dl_hydat_here, "Hydat.sqlite3")
  
 
  ## If there is an existing hydat file get the date of release
  if (file.exists(hydat_path)) {
    hy_version(hydat_path) %>%
      dplyr::mutate(condensed_date = paste0(
        substr(.data$Date, 1, 4),
        substr(.data$Date, 6, 7),
        substr(.data$Date, 9, 10)
      )) %>%
      dplyr::pull(.data$condensed_date) -> existing_hydat
  } else {
    existing_hydat <- "HYDAT not present"
  }


  ## Create the link to download HYDAT
  base_url <-
    "http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/"
  
  # Run network check
  network_check(base_url)
  
  x <- httr::GET(base_url)
  httr::stop_for_status(x)
  new_hydat <- substr(gsub("^.*\\Hydat_sqlite3_", "",
                           httr::content(x, "text")), 1, 8)

  ## Do we need to download a new version?
  if (new_hydat == existing_hydat) {
    handle_error(stop(not_done(paste0("The existing local version of hydat, published on ",
                lubridate::ymd(existing_hydat),
                ", is the most recent version available."))))
  } else {
    info(paste0("Downloading version of HYDAT created on ", crayon::blue(lubridate::ymd(new_hydat))))
  }

  url <- paste0(base_url, "Hydat_sqlite3_", new_hydat, ".zip")
  
  ## Remove current version of HYDAT
  #if (file.exists(hydat_path)){
  #  file.remove(hydat_path)
  #}

  ## temporary path to save
  tmp <- tempfile("hydat_")
  ## Create the directory if it doesn't exist already.
  #if(!dir.exists(dirname(tmp))) dir.create(dirname(tmp))
  
  ## Download the zip file
  res <- httr::GET(url, httr::write_disk(tmp), httr::progress("down"), 
                   httr::user_agent("https://github.com/ropensci/tidyhydat"))
  on.exit(file.remove(tmp))
  httr::stop_for_status(res)
  
  if(file.exists(tmp)) info("Extracting HYDAT")

  utils::unzip(tmp, exdir = dl_hydat_here, overwrite = TRUE)
  
  
  if (file.exists(hydat_path)){
    congrats("HYDAT successfully downloaded")
  } else(not_done("HYDAT not successfully downloaded"))
  
  invisible(TRUE)
}
