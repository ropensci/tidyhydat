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
#' @param dl_hydat_here Directory to the HYDAT database. The path is chosen by the `rappdirs` package and is OS specific and can be view by [hy_dir()]. 
#' This path is also supplied automatically to any function that uses the HYDAT database. A user specified path can be set though this is not the advised approach. 
#' It also downloads the database to a directory specified by [hy_dir()].
#' @param ask Whether to ask (as \code{TRUE}/\code{FALSE}) if HYDAT should be downloaded. If \code{FALSE} the keypress question is skipped.
#' @export
#'
#' @examples \dontrun{
#' download_hydat()
#' }
#'

download_hydat <- function(dl_hydat_here = NULL, ask = TRUE) {
  
  if(is.null(dl_hydat_here)){
    dl_hydat_here <- hy_dir()
    dir.create(dl_hydat_here, showWarnings = FALSE, recursive= TRUE)
  } else {
    if (!dir.exists(dl_hydat_here)) {
      dir.create(dl_hydat_here)
      message(crayon::blue("You have downloaded hydat to", dl_hydat_here))
      message(crayon::blue("See ?hy_set_default_db to change where tidyhydat looks for HYDAT"))
    }
  }

  if (!is.logical(ask)) stop("Parameter ask must be a logical")
  

  ## Create actual hydat_path
  hydat_path <- file.path(dl_hydat_here, "Hydat.sqlite3")
  
  ## If there is an existing hydat file get the date of release
  if (file.exists(hydat_path)) {
    existing_hydat <- as.Date(hy_version(hydat_path)$Date) 
    existing_hydat <- gsub("-", "", as.character(existing_hydat))
  } else {
    existing_hydat <- "HYDAT not present"
  }


  new_hydat <- hy_remote()
  #Make the download URL
  url <- paste0(hy_base_url(), "Hydat_sqlite3_", new_hydat, ".zip")
  response <- httr::HEAD(url)
  httr::stop_for_status(response)
  size <- round(as.numeric(httr::headers(response)[["Content-Length"]])/1000000, 0)

  
  ## Do we need to download a new version?
  if (new_hydat == existing_hydat & ask) { #DB exists and no new version
    msg <- paste0(
      "The existing local version of HYDAT, published on ",
      lubridate::ymd(existing_hydat), 
      ", is the most recent version available. \nDo you wish to overwrite it? \nDownloading HYDAT could take up to 10 minutes (", 
      size, " MB).")
    dl_overwrite <- ask(msg)
  } else {
    dl_overwrite <- TRUE
  }

  if (!dl_overwrite){
    info("HYDAT is updated on a quarterly basis, check again soon for an updated version.")
  }
  
  if (new_hydat != existing_hydat & ask) { #New DB available or no local DB at all
    msg <- paste0(
      "Downloading HYDAT will take up to 10 minutes (", 
      size, " MB).  \nThis will remove any older versions of HYDAT, if applicable.  \nIs that okay?"
      )
    ans <- ask(msg)
  } else {
    ans <- TRUE
  }
  
  if (!ans) {
    stop("Maybe another day...", call. = FALSE)
  } else if (dl_overwrite) {
    green_message(paste0("Downloading HYDAT to ", dl_hydat_here))
  }
    
  
  if (dl_overwrite){
    if (new_hydat == existing_hydat){
      info(paste0("Your local copy of HYDAT published on ", crayon::blue(lubridate::ymd(new_hydat)), " will be overwritten."))
    } else {
      info(paste0("Downloading new version of HYDAT created on ", crayon::blue(lubridate::ymd(new_hydat))))
      }
    
    ## temporary path to save
    tmp <- tempfile("hydat_", fileext = ".zip")
    
    ## Download the zip file
    res <- httr::GET(url, httr::write_disk(tmp), httr::progress("down"), 
                     httr::user_agent("https://github.com/ropensci/tidyhydat"))
    on.exit(file.remove(tmp), add = TRUE)
    httr::stop_for_status(res)
    
    ## Extract the file to a temporary dir
    if(file.exists(tmp)) info("Extracting HYDAT")
    tempdir <- file.path(tempdir(), "extracted")
    dir.create(tempdir)
    utils::unzip(tmp, exdir = tempdir, overwrite = TRUE)
    on.exit(unlink(tempdir, recursive=TRUE))
    
    ## Move to final resting place and rename to consistent name
    file.rename(
      list.files(tempdir, pattern = "\\.sqlite3$", full.names = TRUE),
      hydat_path
    )

    
    if (file.exists(hydat_path)) {
      congrats("HYDAT successfully downloaded")
    } else {
    not_done("HYDAT not successfully downloaded")
    }
    
    hy_check()
    
    invisible(hydat_path)
    
  } #End of DL and overwrite if statement
  

}

hy_base_url <- function() {
  "https://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/"
}

#' Get the version date of HYDAT that is current on the ECCC website
#' 
#' Retrieve the date of the HYDAT version available for download.
#' 
#' @export
hy_remote <- function() {

  # Run network check
  network_check(hy_base_url())
  
  x <- httr::GET(hy_base_url())
  httr::stop_for_status(x)
  raw_date <- substr(
    gsub("^.*\\Hydat_sqlite3_", "", httr::content(x, "text")), 
    1, 8)
  
  raw_date
}


hy_check <- function(hydat_path = NULL) {
  con <- hy_src(hydat_path)
  on.exit(hy_src_disconnect(con), add = TRUE)
  
  have_tbls <- dplyr::src_tbls(con)
  
  tbl_diff <- setdiff(hy_expected_tbls(), have_tbls)
  if (!rlang::is_empty(tbl_diff)) {
    red_message("The following tables are missing from HYDAT")
    red_message(paste0(tbl_diff, "\n"))
  }
  
  
  invisible(lapply(have_tbls, function(x) {
    tbl_rows <- dplyr::tbl(con, x) %>% 
      utils::head(1) %>% 
      dplyr::collect() %>% 
      nrow()
    
    if(tbl_rows == 0) {
      red_message(paste0(x, " table has no data."))
    } 
  }))
}
