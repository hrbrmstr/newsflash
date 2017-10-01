utils::globalVariables(c("station_values", "date_start", "date_end", "keyword", "network", "date_range",
                         "station", "show", "show_date", "word", "snippet", ".x"))

sfj <- purrr::safely(jsonlite::fromJSON)

s_head <- purrr::safely(httr::HEAD)