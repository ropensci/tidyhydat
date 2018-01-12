
#' Open a connection to the HYDAT database
#'
#' This function gives low-level access to the underlying HYDAT database used by
#' other functions. Many of these tables are too large to load into memory,
#' so it is best to use dplyr to \link[dplyr]{filter} them before using
#' \link[dplyr]{collect} to read them into memory.
#'
#' @param check_exists Throw an error if hydat_path or the default database do not exist.
#' @param src A \link[dplyr]{src_sqlite} as returned by \code{hy_src()}.
#' @inheritParams hy_agency_list
#'
#' @return \code{hy_src} returns a dplyr \link[dplyr]{src_sqlite}; 
#'   \code{hy_db} returns the file locations of the downloaded HYDAT database
#' @export
#' 
#' @seealso 
#' \link{download_hydat}
#'
#' @examples
#' library(dplyr)
#' 
#' # src is a src_sqlite
#' src <- hy_src(hydat_path = hy_test_db())
#' src_tbls(src)
#' 
#' # to get a table, use dplyr::tbl()
#' tbl(src, "STATIONS")
#' 
#' # one you're sure the results are what you want
#' # get a data.frame using collect()
#' tbl(src, "STATIONS") %>%
#'   filter(PROV_TERR_STATE_LOC == "BC") %>%
#'   collect()
#'   
#' # close the connection to the database by removing the object
#' # (and triggering garbage collection)
#' hy_src_disconnect(src)
#' 
hy_src <- function(hydat_path = NULL) {
  # hydat_path can also be an src to support one connection for
  # nested calls
  if (dplyr::is.src(hydat_path)) {
    hydat_path
  } else {
    # check that file exists using hy_db
    hydat_path <- hy_db(hydat_path, check_exists = TRUE)
    dbplyr::src_dbi(DBI::dbConnect(RSQLite::SQLite(), hydat_path))
  }
}

#' @rdname hy_src
#' @export
hy_src_disconnect <- function(src) {
  # src can technically be a database connection or an src
  # so this function can be applied in 
  if (dplyr::is.src(src)) {
    con <- src$con
  } else if (inherits(src, "SQLiteConnection")){
    con <- src
  } else {
    stop("hy_src_disconnect doesn't know how to deal with object of class ",
         paste(class(src), collapse = " / "))
  }
  
  # close the connection (will throw warning if con is already connected)
  invisible(DBI::dbDisconnect(con))
}

#' @rdname hy_src
#' @export
hy_db <- function(hydat_path = NULL, check_exists = TRUE) {
  # the default location of the hydat database
  if(is.null(hydat_path)){
    hydat_path <- hy_get_default_db()
  }
  
  ## Check if default Hydat is present
  if (check_exists && !file.exists(hydat_path)) {
    stop(sprintf(
      "No %s found at %s. Run download_hydat() to download the database.",
      basename(hydat_path), dirname(hydat_path)
    ))
  }
  
  hydat_path
}

#' Get the location of the test HYDAT database
#' 
#' The full HYDAT database needs to be downloaded from \link{download_hydat}, but for testing
#' purposes, a small test database is included in this package. Use
#' \code{hydat_path = hy_test_db()} in hy_* functions to use the test database.
#'
#' @return The file location of tinyhydat.sqlite3
#' @export
#' 
#' @seealso 
#' \link{hy_db}
#'
#' @examples
#' hy_test_db()
#' 
hy_test_db <- function() {
  system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
}

#' Set the default database path
#' 
#' For testing purposes, it may be convenient to set the default
#' database location to somewhere other than the global default. This is
#' not exported and is only for internal use.
#'
#' @param hydat_path The new path to the default database (e.g., \link{hy_test_db()})
#'
#' @return hy_set_default_db() returns the previous value; 
#'   hy_get_default_db() returns the current default database path.
#' @noRd
#'
#' @examples
#' # set default to the test database
#' hy_set_default_db(hy_test_db())
#' 
#' # get the default value
#' hy_get_default_db()
#' 
#' # set back to the default db location
#' hy_set_default_db(NULL)
#' 
hy_set_default_db <- function(hydat_path = NULL) {
  old_value <- hy_get_default_db()
  
  ## NULL means reset to the original default
  if (is.null(hydat_path)) {
    hydat_path <- file.path(hy_dir(), "Hydat.sqlite3")
  }

  assign("default_db", hydat_path, envir = hy_db_default_options)
  invisible(old_value)
}

#' @rdname hy_set_default_db
#' @noRd
hy_get_default_db <- function() {
  if ("default_db" %in% names(hy_db_default_options)) {
    hy_db_default_options$default_db
  } else {
    file.path(hy_dir(), "Hydat.sqlite3")
  }
}

#' @rdname hy_set_default_db
#' @noRd
hy_db_default_options <- new.env(parent = emptyenv())
