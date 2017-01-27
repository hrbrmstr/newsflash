utils::globalVariables(c("station_values", "date_start", "date_end", "keyword", "network", "date_range"))

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
#' See the Reference URL for parameter info
#'
#' @param primary_keyword primary keyword
#' @param context_keywords context keywords (optional, but see web site for details on
#'    why this is a useful parameter)
#' @param filter_network filter by network. Use \code{list_networks()} to see valid values
#'    and to get a hint about valid date ranges for \code{start_date} and \code{end_date}.
#'    Defaults to \code{NATIONAL}.
#' @param start_date,end_date \code{Date} object for start/end of search. Defaults to the
#'    last quarter of 2016: Oct-2016 to Dec-2016
#' @references \url{http://television.gdeltproject.org/cgi-bin/iatv_ftxtsearch/iatv_ftxtsearch}
#' @export
#' @examples
#' query_tv("terror", "isis")
#' query_tv("trump")
query_tv <- function(primary_keyword, context_keywords=NULL,
                     filter_network = "NATIONAL",
                     start_date=as.Date("2016-10-01"), end_date=as.Date("2016-12-31")) {

  start_date <- format(start_date, "%m/%d/%Y")
  end_date <- format(end_date, "%m/%d/%Y")

  filter_network <- match.arg(filter_network, nf_markets)

  httr::GET(url="http://television.gdeltproject.org/cgi-bin/iatv_ftxtsearch/iatv_ftxtsearch",
            query=list(primary_keyword = primary_keyword,
                       context_keywords = context_keywords,
                       filter_network = filter_network,
                       filter_timespan = "CUSTOM",
                       filter_timespan_custom_start = start_date,
                       filter_timespan_custom_end = end_date,
                       filter_displayas = "RAW",
                       filter_combineseparate = "SEPARATE",
                       filter_outputtype = "JSON")) -> res

  httr::stop_for_status(res)

  res <- httr::content(res, as="text", encoding="UTF-8")
  res <- jsonlite::fromJSON(res)

  res$query_details <- dplyr::tbl_df(res$query_details)

  res$timeline <- tidyr::unnest(res$timeline, station_values) %>%
    dplyr::mutate(date_start=anytime::anytime(date_start),
                  date_end=anytime::anytime(date_end)) %>%
    dplyr::tbl_df()

  res$station_histogram <- dplyr::tbl_df(res$station_histogram)

  res$top_matches <- dplyr::tbl_df(res$top_matches) %>%
    dplyr::mutate(date=anytime::anytime(date),
                  show_date=anytime::anytime(show_date))

  class(res) <- c("newsflash", class(res))

  res

}
