#' A search function for hydrometric station name or number
#'
#' Use this search function when you only know the partial station name or want to search.
#'
#' @param search_term Only accepts one word.
#'
#' @return A tibble of stations that match the \code{search_term}
#' 
#' @examples 
#' search_name("Cowichan")
#' 
#' search_number("08HF")
#'
#'
#' @export



search_name <- function(search_term) {
  results <- tidyhydat::allstations[grepl(toupper(search_term), tidyhydat::allstations$STATION_NAME), ]

  if (nrow(results) == 0) {
    message("No station names match this criteria!")
  } else {
    return(results)
  }
}

#' @rdname search_name
search_number <- function(search_term) {
  results <- tidyhydat::allstations[grepl(toupper(search_term), tidyhydat::allstations$STATION_NUMBER), ]
  
  if (nrow(results) == 0) {
    message("No station number match this criteria!")
  } else {
    return(results)
  }
}

#' @title AGENCY_LIST function
#'
#' @description AGENCY_LIST – AGENCY look-up Table
#' @param hydat_path Directory to the hydat database. Can be set as "Hydat.sqlite3" which will look for Hydat in the working directory.
#' The hydat path can also be set in the \code{.Renviron} file so that it doesn't have to specified every function call. The path should
#' set as the variable \code{hydat}. Open the \code{.Renviron} file using this command: \code{file.edit("~/.Renviron")}.
#'
#' @return A tibble of agencies
#'
#' @export
#'
AGENCY_LIST <- function(hydat_path=NULL) {
  if (is.null(hydat_path)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
  }


  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)

  agency_list <- dplyr::tbl(hydat_con, "AGENCY_LIST") %>%
    collect()

  DBI::dbDisconnect(hydat_con)

  return(agency_list)
}


#' @title REGIONAL_OFFICE_LIST function
#'
#' @description REGIONAL_OFFICE_LIST – OFFICE look-up Table
#' @inheritParams AGENCY_LIST
#' @return A tibble of offices
#'
#' @export
#'
REGIONAL_OFFICE_LIST <- function(hydat_path=NULL) {
  if (is.null(hydat_path)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
  }


  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)



  regional_office_list <- dplyr::tbl(hydat_con, "REGIONAL_OFFICE_LIST") %>%
    collect()

  DBI::dbDisconnect(hydat_con)

  return(regional_office_list)
}

#' @title DATUM_LIST function
#'
#' @description DATUM_LIST – DATUM look-up Table
#' @inheritParams AGENCY_LIST
#'
#' @return A tibble of DATUMS
#'
#' @export
#'
DATUM_LIST <- function(hydat_path=NULL) {
  if (is.null(hydat_path)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
  }

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)

  datum_list <- dplyr::tbl(hydat_con, "DATUM_LIST") %>%
    collect()

  DBI::dbDisconnect(hydat_con)

  return(datum_list)
}


#' @title Version number of HYDAT
#' @description A function to get version number of hydat
#'
#' @inheritParams AGENCY_LIST
#'
#' @return version number
#'
#' @export
#'
VERSION <- function(hydat_path=NULL) {
  if (is.null(hydat_path)) {
    hydat_path <- Sys.getenv("hydat")
    if (is.na(hydat_path)) {
      stop("No Hydat.sqlite3 path set either in this function or in your .Renviron file. See tidyhydat for more documentation.")
    }
  }

  ## Read on database
  hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)

  version <- dplyr::tbl(hydat_con, "VERSION") %>%
    dplyr::collect() %>%
    dplyr::mutate(Date = lubridate::ymd_hms(Date))

  DBI::dbDisconnect(hydat_con)

  return(version)
}
