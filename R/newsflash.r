nf_markets <- c("NATIONAL", "ALJAZAM", "BLOOMBERG", "CNBC", "CNN", "FBC", "FOXNEWSW",
                "MSNBC", "INTERNATIONAL", "BBCNEWSSEG", "AFFNETALL", "AFFNET_ABC",
                "AFFNET_CBS", "AFFNET_FOX", "AFFNET_MYTV", "AFFNET_NBC", "AFFNET_PBS",
                "AFFMARKALL", "AFFMARKET_Boston", "AFFMARKET_Cedar Rapids",
                "AFFMARKET_Charlotte", "AFFMARKET_Cincinnati", "AFFMARKET_Cleveland",
                "AFFMARKET_Colorado Springs", "AFFMARKET_Columbia", "AFFMARKET_Dakota Dunes SD",
                "AFFMARKET_Daytona Beach", "AFFMARKET_Denver", "AFFMARKET_Des Moines",
                "AFFMARKET_Durham", "AFFMARKET_Goldsboro", "AFFMARKET_Greenville",
                "AFFMARKET_Hampton", "AFFMARKET_Las Vegas", "AFFMARKET_Lynchburg",
                "AFFMARKET_Miami", "AFFMARKET_Newport KY", "AFFMARKET_Norfolk",
                "AFFMARKET_Orlando", "AFFMARKET_Philadelphia", "AFFMARKET_Portsmouth",
                "AFFMARKET_Pueblo", "AFFMARKET_Raleigh", "AFFMARKET_Reno",
                "AFFMARKET_Roanoke", "AFFMARKET_San Francisco", "AFFMARKET_Shaker Heights",
                "AFFMARKET_Sioux City", "AFFMARKET_Tampa", "AFFMARKET_Virginia Beach",
                "AFFMARKET_Washington DC", "AFFMARKET_Waterloo")

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
#' Both query fields support "OR" queries by separating query keywords with a comma ("\code{,}").
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
#' @param primary_keyword primary keyword
#' @param context_keywords context keywords (optional, but see web site for details on
#'    why this is a useful parameter)
#' @param filter_network filter by network. Use \code{list_networks()} to see valid values
#'    and to get a hint about valid date ranges for \code{start_date} and \code{end_date}.
#'    Defaults to \code{NATIONAL}.
#' @param timespan if "\code{all}" (the default) all possible timeline data will be returned
#'    (there is a max number of timeline results and that limit is changing regularly enough
#'    that you need to check the site to know what it is). If not "\code{all}" then you
#'    must specify \code{start_date} and \code{end_date}.
#' @param start_date,end_date start/end dates for search if \code{timespan} is
#'    not "\code{all}". Can be a \code{Date} object or an ISO character date (e.g. \code{2016-11-12}).
#' @references \url{http://television.gdeltproject.org/cgi-bin/iatv_ftxtsearch/iatv_ftxtsearch}
#' @export
#' @examples
#' query_tv("terror", "isis")
#' query_tv("british prime minister")
#' query_tv("mexican president")
query_tv <- function(primary_keyword, context_keywords=NULL,
                     filter_network = "NATIONAL",
                     timespan="ALL",
                     start_date=NULL, end_date=NULL) {

  if (is.null(timespan) | (tolower(timespan) != "all")) {

    if (is.null(start_date) | is.null(end_date)) {

      message("timespan was not 'all' but no start/end date(s) were specified. Defaulting to 'all'.")
      timespan <- "all"

    } else {

      start_date <- format(as.Date(start_date), "%m/%d/%Y")
      end_date <- format(as.Date(end_date), "%m/%d/%Y")

    }

  }

  filter_network <- match.arg(filter_network, nf_markets)

  query <- list(
    primary_keyword = gsub(" ", "+", primary_keyword),
    context_keywords = context_keywords %||% "",
    filter_network = filter_network,
    filter_displayas = "RAW",
    filter_combineseparate = "SEPARATE",
    filter_outputtype = "JSON"
  )

  query$context_keywords <- gsub(" ", "+", query$context_keywords)

  if (tolower(timespan) == "all") {
    query$filter_timespan <- "ALL"
  } else {
    query$filter_timespan <- "CUSTOM"
    query$filter_timespan_custom_start <- start_date
    query$filter_timespan_custom_end <- end_date
  }

  URL <- "http://television.gdeltproject.org/cgi-bin/iatv_ftxtsearch/iatv_ftxtsearch"
  URL <- sprintf("%s?%s", URL, paste0(sprintf("%s=%s", names(query), unlist(query)), collapse="&"))

  res <- curl_fetch_memory(URL)

  if (!(res$status_code < 300)) {
    stop(sprintf("[%s] Query or API error on request [%s]", res$status_code, URL), call.=FALSE)
  }

  res$content <- res$content[res$content != as.raw(0x00)]

  rc <- rawConnection(res$content)
  out <- jsonlite::fromJSON(rc)
  close(rc)

  if (length(out) == 1) {
    message("No results found")
    return(invisible(NULL))
  }

  res <- out
  res$query_details <- dplyr::tbl_df(res$query_details)

  res$timeline <- tidyr::unnest(res$timeline, station_values) %>%
    dplyr::mutate(date_start=lubridate::ymd_hms(date_start),
                  date_end=lubridate::ymd_hms(date_end)) %>%
    dplyr::tbl_df()

  res$station_histogram <- dplyr::tbl_df(res$station_histogram)

  res$top_matches <- dplyr::tbl_df(res$top_matches) %>%
    dplyr::mutate(date=lubridate::ymd_hms(date),
                  show_date=lubridate::ymd_hms(show_date))

  class(res) <- c("newsflash", class(res))

  res

}
