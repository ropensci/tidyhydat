# Testing Documentation

## HTTP Mocking with httptest2

The historical webservice tests use [httptest2](https://enpiar.com/httptest2/) to mock HTTP requests. This allows tests to run without making real API calls to the ECCC web service.

### Test Fixtures

HTTP response fixtures are stored in `testthat/fixtures/` as `.R` files containing serialized `httr2_response` objects.

### Re-recording Fixtures

If the ECCC API changes or you need to update test data:

1. **Delete existing fixtures:**
   ```r
   unlink("tests/testthat/fixtures/wateroffice.ec.gc.ca", recursive = TRUE)
   ```

2. **Record new fixtures:**
   ```r
   library(httptest2)
   devtools::load_all()
   .mockPaths('tests/testthat/fixtures')

   # IMPORTANT: Use simplify=FALSE to preserve HTTP headers
   httptest2::capture_requests(simplify = FALSE, {
     # Historical webservice - record full year of data
     ws_daily_flows(
       station_number = "08MF005",
       start_date = as.Date("2023-01-01"),
       end_date = as.Date("2023-12-31")
     )

     ws_daily_levels(
       station_number = "08MF005",
       start_date = as.Date("2023-01-01"),
       end_date = as.Date("2023-12-31")
     )

     # Record error cases (empty responses)
     tryCatch(
       ws_daily_flows("08MF005", Sys.Date() - 2, Sys.Date()),
       error = function(e) invisible(NULL)
     )

     tryCatch(
       ws_daily_levels("08MF005", Sys.Date() - 2, Sys.Date()),
       error = function(e) invisible(NULL)
     )

     # Realtime webservice - use recent dates that will have data
     recent_date <- Sys.Date() - 7

     realtime_ws(
       station_number = "08MF005",
       parameters = 46,  # Water level
       start_date = recent_date,
       end_date = recent_date
     )

     realtime_ws(
       station_number = "08MF005",
       parameters = 46,
       start_date = recent_date - 1,
       end_date = recent_date
     )
   })
   ```

3. **Verify tests pass:**
   ```r
   devtools::test_active_file("tests/testthat/test-historical-webservice.R")
   ```

