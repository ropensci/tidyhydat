structure(list(method = "GET", url = "https://wateroffice.ec.gc.ca/services/real_time_data/csv/inline?stations[]=08MF005&parameters[]=47&start_date=2013-01-06%2000:00:00&end_date=2013-01-05%2023:59:59",
    status_code = 200L, headers = structure(list(Date = "Mon, 06 Jan 2013 12:00:00 GMT",
        Server = "Apache", `Strict-Transport-Security` = "max-age=63072000; preload",
        `Content-Disposition` = "inline; filename=real_time_data.csv",
        Pragma = "public", `Cache-Control` = "must-revalidate, post-check=0, pre-check=0",
        Vary = "Accept-Encoding", `Content-Encoding` = "gzip",
        `Referrer-Policy` = "no-referrer-when-downgrade", `Content-Security-Policy` = "frame-src 'self'; media-src 'self'; object-src 'self'; base-uri 'self'; form-action 'self' https://www.canada.ca https://canada.ca https://recherche-search.gc.ca https://weather.gc.ca https://meteo.gc.ca https://*.cmc.ec.gc.ca https://*.edc-mtl.ec.gc.ca",
        `Content-Length` = "150", `Content-Type` = "text/csv; charset=utf-8"), class = "httr2_headers"),
    body = charToRaw("﻿ ID,Date,Parameter/Paramètre,Value/Valeur,Qualifier/Qualificatif,Symbol/Symbole,Approval/Approbation,Grade/Classification,Qualifiers/Qualificatifs"),
    timing = c(redirect = 0, namelookup = 0.001, connect = 0.050,
    pretransfer = 0.100, starttransfer = 0.150, total = 0.151
    ), cache = new.env(parent = emptyenv())), class = "httr2_response")
