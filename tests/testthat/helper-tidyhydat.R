skip_if_net_down <- function() {
  if (has_internet()) {
    return()
  }
  testthat::skip("no internet")
}

skip_on_actions <- function() {
  if (!Sys.getenv("GITHUB_ACTIONS")) {
    return(invisible(TRUE))
  }
  skip("On GitHub Actions")
}
