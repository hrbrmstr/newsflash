nf_markets <- c("National", "International", "Japan",
                "Ames", "Arlington Virginia", "Asheville", "Baltimore",
                "Belmont", "Boston", "Cedar Rapids", "Charlotte", "Chicago",
                "Cincinnati", "Cleveland", "Colorado Springs", "Columbia", 
                "Costa Mesa California", "Dakota Dunes SD", "Daytona Beach", 
                "Denver", "Des Moines", "Durham", "Goldsboro", "Greenville",
                "Hampton", "Lake Shore Maryland", "Las Vegas", "Lynchburg",
                "Maryland", "Miami", "Milwaukee", "New York City", "Newport KY", 
                "Norfolk", "Orlando", "Philadelphia", "Phoenix", "Portsmouth",
                "Pueblo", "Raleigh", "Reno", "Roanoke", "San Francisco", 
                "San Mateo California", "Shaker Heights", "Sioux City",
                "Sonoma California", "Spartanburg", "St. Petersburg", "Tampa", 
                "Toledo", "Virginia Beach", "Washington DC", "Waterloo")

nf_networks <- c("ALJAZ", "ALJAZAM", "BBCNEWS", "BET", "BLOOMBERG", "CNBC", "CNN",        
                 "COM", "CSPAN", "CurrentTV", "DW", "FBC", "FOXNEWS", "HLN", "CW", 
                 "ABC", "CBS", "SonLife", "PBS", "FOX", "Univision", "UniMas",        
                 "IonTV", "NBC", "MyNetworkTV", "MYTV", "Telemundo", "KTLN", 
                 "EstrellaTV", "LINKTV", "MSNBC", "NHK", "RT", "Trinity", "Daystar",
                 "Azteca")

#' Issue a query to the TV Explorer
#'
#' Successful queries (API errors tend to be date-range related but there
#' isn't enough to go on in the API response to provide better diagnostics)
#' result in a list of 4 tidy tibbles:
#'
#' \describe{
#' \item{\code{query_details}}{spits back what you put in.}
#' \item{\code{timeline}}{a long tibble of the number of times
#' the keywords combo was on a particulare station.}
#' \item{\code{station_histogram}}{what it says it is.}
#' \item{\code{top_matches}}{also what it says it is except
#' that it includes juicy metadata with the Internet Archive preview URL,
#' thumbnail URL, \emph{caption text snippet} and more.}
#' }
#'
#' See the Reference URL for more detailed parameter info.
#'
#' @section Queries:
#'
#' Queries resulting in no matches will display a message and return \code{NULL} invisibly.
#'
#' Both query fields support "OR" queries by including search terms in a list (e.g., 
#' query_tv(query = c("Trump", "Obama")).
#'
#' There is a maximum of 2,500 results per query. If you need to return more results than
#' this, split your query time frame up into multiple smaller date ranges (ie, if your query
#' returns 3,000 results over a 30 day period, split it into two 15 day period queries).
#'
#' When specifying dates and the time period is 7 days or less, the timeline result will
#' switch from daily resolution to hourly resolution to make it possible to examine how
#' coverage of a topic changed over the course of a day and when each network first started
#' discussing it.
#'
#' @param query primary keyword
#' @param context context keywords, with separate keywords in list format 
#'    (optional, but see web site for details on why this is a useful parameter)
#' @param network filter by network. Use \code{list_networks()} to see valid values
#'    and to get a hint about valid date ranges for \code{start_date} and \code{end_date}.
#'    Defaults to \code{national}.
#' @param timespan if "\code{all}" (the default) all possible timeline data will be returned
#'    (there is a max number of timeline results and that limit is changing regularly enough
#'    that you need to check the site to know what it is). If not "\code{all}" then you
#'    must specify \code{start_date} and \code{end_date}.
#' @param start_date,end_date start/end dates for search if \code{timespan} is
#'    not "\code{all}". Can be a \code{Date} object or an ISO character date (e.g. \code{2016-11-12}).
#'    Use "" (empty string) for most current date.
#' @param timelinesmooth a smoothing value applying moving averages over 15-minute increments
#' @param datacomb if "\code{combined}", all network volume is combined into a single value.
#'    Defaults to "\code{separate}".
#' @references \url{https://blog.gdeltproject.org/gdelt-2-0-television-api-debuts/}
#' @export
#' @examples
#' query_tv("terror", "isis")
#' query_tv("british prime minister")
#' query_tv("mexican president")
query_tv <- function(query, 
                     context=NULL,
                     network = "National",
                     timespan = "ALL",
                     start_date = NULL, 
                     end_date = NULL,
                     timelinesmooth = 0,
                     datacomb = "separate") {

  # check if network or market specified
  news_source <- network[which(network %in% nf_networks)]
  
  if (length(news_source) > 0) {
      
    # construct the query string
    source_string <- sprintf("(%s)", paste0("Network:", news_source, sep = "", collapse = " OR "))
  
  # length zero, check for market match    
  } else {
    
    news_source <- network[which(network %in% nf_markets)]
    
    if (length(news_source) > 0) {
      
      source_string <- sprintf("(%s)", paste0("market:\"", news_source, "\"", sep = "", collapse = " OR "))

    # specified networks/markets not in any list, default to national  
    } else {
      message("Networks not in allowed list. Defaulting to 'National'.")
      source_string <- "market:\"National\""
    } 
    
  } 

    
  if (is.null(timespan) || (tolower(timespan) != "all")) {

    if (is.null(start_date) & is.null(end_date)) {

      message("timespan was not 'all' but neither start nor end date were not specified. Defaulting to 'all'.")
      timespan <- "all"

    } else {

      if (!is.null(start_date)) {
        
        # add warning message about timespans < 7 days (no times included in json currently)
        message("Warning: Date ranges of 7 days or less currently do not receive timestamps from the server")
        
        start_date <- purrr::map_chr(start_date, function(x) {
          if ((is.character(x) && (x != "")) | inherits(x, "Date")) {
            paste(format(as.Date(x), "%Y%m%d"), "000000", sep = "")
          } else { 
            x
          }
        })
      }

      if (!is.null(end_date)) {
        end_date <- purrr::map_chr(end_date, function(x) {
          if ((is.character(x) && (x != "")) | inherits(x, "Date")) {
            paste(format(as.Date(x), "%Y%m%d"), "230000", sep = "")
          } else {
            x
          }
        })
      }

    }

  }

  # check for context keywords and format appropriately
  if (!is.null(context)) {
    
    # if context length > 1, add parantheses around query
    if (length(context) > 1) {
      context <- sprintf("(%s)", paste0("context:\"", context, "\"", sep = "", collapse = " OR "))
    } else {
      context <- paste0("context:\"", context, "\"", sep = "")
    }
    
  }

  query <- list(
    # paste together query, news source, and context keywords
    query = URLencode(paste(gsub(" ", "+", query), source_string, context, sep = " ")),
    datacomb = datacomb,
    mode = "timelinevol",
    datanorm = "perc",
    format = "json",
    timelinesmooth = timelinesmooth
  )

  if (!is.null(timespan) && tolower(timespan) == "all") {
    query$filter_timespan <- "ALL"
  } else {
    query$filter_timespan <- "CUSTOM"
    query$STARTDATETIME <- start_date
    query$ENDDATETIME <- end_date
  }

  URL <- "https://api.gdeltproject.org/api/v2/tv/tv"
  URL <- sprintf("%s?%s", URL, paste0(sprintf("%s=%s", names(query), unlist(query)), collapse="&"))
  
  res <- httr::GET(URL)

  if (!(res$status_code < 300)) {
    stop(sprintf("[%s] Query or API error on request [%s]", res$status_code, URL), call.=FALSE)
  }

  res$content <- httr::content(res)

  res$timeline <- tibble::data_frame(
      network = res$content$timeline %>%
        purrr::map_chr("series"),
      data = res$content$timeline %>%
        purrr::map("data")) %>%
    tidyr::unnest(data) %>%
    dplyr::mutate(
      date = data %>%
        purrr::map_chr("date") %>%
        # hourly data doesn't have times - API doesn't return time values - split off non-hms data from date-time
        sapply(., function(x) strsplit(x, "T")[[1]][1]) %>%
        lubridate::ymd(),
      value = data %>%
        purrr::map_dbl("value")
    ) %>%
    dplyr::select(-data)

  # return results
  res
  
}
