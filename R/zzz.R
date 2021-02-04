# Won't pass cmd check with this uncommented
.onAttach <- function(libname, pkgname) {
  if (interactive()) {
    if (!file.exists(file.path(hy_dir(), "Hydat.sqlite3"))) {
      packageStartupMessage(
        not_done("tidyhydat requires HYDAT which has not yet been downloaded. Run download_hydat() now.")
      )
    }

    if (!has_internet()) {
      return(done("No access to internet."))
    }
    

    ## HYDAT is updated quarterly - should we go check if a new one is available for download?
    ## Only check when there is likely a new version i.e. about 3 months after last version
    if (file.exists(file.path(hy_dir(), "Hydat.sqlite3")) && Sys.Date() > (as.Date(hy_version()$Date) + 115)) {
      
      packageStartupMessage(info("Checking for a new version of HYDAT..."))

      base_url <- "http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/"
      x <- httr::GET(base_url)
      httr::stop_for_status(x)

      ## Extract newest HYDAT
      new_hydat <- as.Date(substr(gsub(
        "^.*\\Hydat_sqlite3_", "",
        httr::content(x, "text")
      ), 1, 8), "%Y%m%d")

      ## Compare that to existing HYDAT
      if (new_hydat != as.Date(hy_version()$Date)) {
        packageStartupMessage(
          not_done(
            paste0("Your version of HYDAT is out of date. Use download_hydat() to get the new version.")
          )
        )
      } else {
        packageStartupMessage(congrats("You are using the most current version of HYDAT"))
      }
    }
  }
}
