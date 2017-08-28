.onAttach <- function(libname, pkgname){

  hydat_path = Sys.getenv("hydat")
    if(!is.na(hydat_path)){
      ## Read on database
      hydat_con <- DBI::dbConnect(RSQLite::SQLite(), hydat_path)
      
      path_to_test = dplyr::tbl(hydat_con, "VERSION") %>%
        dplyr::collect() %>%
        dplyr::mutate(Date = lubridate::ymd_hms(Date)) %>%
        mutate(file = paste0(
          "http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/Hydat_sqlite3_",
          substr(Date, 1,4),
          substr(Date, 6,7),
          substr(Date, 9,10),
          ".zip")) %>%
        pull(file)
      
      if(httr::http_error(path_to_test) == TRUE){
        packageStartupMessage("Your version of hydat is out of date. Navigate to http://collaboration.cmc.ec.gc.ca/cmc/hydrometrics/www/ and download the latest version.")
      }
      
      DBI::dbDisconnect(hydat_con)
    }
  

}
