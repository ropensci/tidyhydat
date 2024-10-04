
#' Open a connection to the HYDAT database
#'
#' This function gives low-level access to the underlying HYDAT database used by
#' other functions. Many of these tables are too large to load into memory,
#' so it is best to use dplyr to [dplyr::filter()] them before using
#' [dplyr::collect()] to read them into memory.
#'
#' @param src A  as returned by [hy_src()].
#' @inheritParams hy_agency_list
#'
#' @return A SQLite DBIConnection
#' @export
#'
#' @seealso
#' [download_hydat()]
#'
#' @examples
#' \dontrun{
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
#' tbl(src, "STATIONS") |>
#'   filter(PROV_TERR_STATE_LOC == "BC") |>
#'   collect()
#'
#' # close the connection to the database
#' hy_src_disconnect(src)
#' }
hy_src <- function(hydat_path = NULL) {
  # hydat_path can also be an src to support one connection for
  # nested calls
  if (dplyr::is.src(hydat_path)) {
    hydat_path
  } else {
    # NULL means the default location of the hydat database
    if (is.null(hydat_path)) {
      hydat_path <- hy_default_db()
    }

    ## Check if hydat_path is present
    if (!file.exists(hydat_path)) {
      stop(sprintf(
        "No %s found at %s. Run download_hydat() to download the database.",
        basename(hydat_path), dirname(hydat_path)
      ))
    }

    dbplyr::src_dbi(DBI::dbConnect(RSQLite::SQLite(), hydat_path))
  }
}

#' @rdname hy_src
#' @export
hy_src_disconnect <- function(src) {
  if (dplyr::is.src(src)) {
    con <- src$con
  } else {
    stop(
      "hy_src_disconnect doesn't know how to deal with object of class ",
      paste(class(src), collapse = " / ")
    )
  }

  # close the connection (will throw warning if con is already connected)
  invisible(DBI::dbDisconnect(con))
}

#' Get the location of the HYDAT database
#'
#' The full HYDAT database needs to be downloaded from \link{download_hydat}, but for testing
#' purposes, a small test database is included in this package. Use
#' \code{hydat_path = hy_test_db()} in hy_* functions to explicitly use the test database;
#' use \code{hydat_path = hy_downloaded_db()} to explicitly use the full, most recent
#' downloaded database (this is also the path returned by \code{hy_default_db()}).
#'
#' @return The file location of a HYDAT database.
#' @export
#'
#' @seealso
#' \link{hy_src}, \link{hy_set_default_db}.
#'
#' @examples
#' \dontrun{
#' hy_test_db()
#' hy_downloaded_db()
#' hy_default_db()
#' }
#'
hy_test_db <- function() {
  system.file("test_db/tinyhydat.sqlite3", package = "tidyhydat")
}

#' @rdname hy_test_db
#' @export
hy_downloaded_db <- function() {
  file.path(hy_dir(), "Hydat.sqlite3")
}

#' @rdname hy_test_db
#' @export
hy_default_db <- function() {
  if ("default_db" %in% names(hy_db_default_options)) {
    hy_db_default_options$default_db
  } else {
    hy_downloaded_db()
  }
}

#' Set the default database path
#'
#' For many reasons, it may be convenient to set the default
#' database location to somewhere other than the global default. Users
#' may wish to use a previously downloaded version of the database for
#' reproducibility purposes, store hydat somewhere other than hy_dir().
#'
#' @param hydat_path The path to the a HYDAT sqlite3 database file
#'   (e.g., \link{hy_test_db})
#'
#' @return returns the previous value of \link{hy_default_db}.
#' @export
#'
#' @examples
#' \dontrun{
#' # set default to the test database
#' hy_set_default_db(hy_test_db())
#'
#' # get the default value
#' hy_default_db()
#'
#' # set back to the default db location
#' hy_set_default_db(NULL)
#' }
#'
hy_set_default_db <- function(hydat_path = NULL) {
  old_value <- hy_default_db()

  ## NULL means reset to the original default
  if (is.null(hydat_path)) {
    hydat_path <- hy_downloaded_db()
  } else {
    # make sure value is a character vector of length 1
    stopifnot(is.character(hydat_path), length(hydat_path) == 1)

    # the file should exist, unless it is hy_downloaded_db(),
    # in which case a more informative error is provided when the user
    # calls hy_src()
    if (hydat_path != hy_downloaded_db()) {
      stopifnot(file.exists(hydat_path))
    }
  }

  assign("default_db", hydat_path, envir = hy_db_default_options)
  invisible(old_value)
}

#* the internal environment that stores database options
hy_db_default_options <- new.env(parent = emptyenv())
