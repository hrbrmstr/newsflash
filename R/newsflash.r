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
#' Queries resulting in no matches will display a message and return \code{NULL} invisibly.
#'
#' See the Reference URL for parameter info
#'
#' @param primary_keyword primary keyword
#' @param context_keywords context keywords (optional, but see web site for details on
#'    why this is a useful parameter)
#' @param filter_network filter by network. Use \code{list_networks()} to see valid values
#'    and to get a hint about valid date ranges for \code{start_date} and \code{end_date}.
#'    Defaults to \code{NATIONAL}.
#' @param timespan if \code{all} (the default) all possible timeline data will be returned
#'    (there is a max number of timeline results and that limit is changing regularly enough
#'    that you need to check the site to know what it is). If not \code{all} then you
#'    must specify \code{start_date} and \code{end_date}.
#' @param start_date,end_date start/end dates for search if \code{timespan} is
#'    not \code{ALL}. Can be a \code{Date} object or an ISO character date (e.g. \code{2016-11-12}).
#' @references \url{http://television.gdeltproject.org/cgi-bin/iatv_ftxtsearch/iatv_ftxtsearch}
#' @export
#' @examples
#' query_tv("terror", "isis")
#' query_tv("trump")
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

  if (tolower(timespan) == "all") {

    httr::GET(url="http://television.gdeltproject.org/cgi-bin/iatv_ftxtsearch/iatv_ftxtsearch",
              query=list(primary_keyword = primary_keyword,
                         context_keywords = context_keywords,
                         filter_network = filter_network,
                         filter_timespan = "ALL",
                         filter_displayas = "RAW",
                         filter_combineseparate = "SEPARATE",
                         filter_outputtype = "JSON")) -> res

  } else {

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

  }

  httr::stop_for_status(res)

  res <- httr::content(res, as="text", encoding="UTF-8")
  res <- jsonlite::fromJSON(res)

  if (length(res) == 1) {
    message("No results found")
    return(invisible(NULL))
  }

  res$query_details <- dplyr::tbl_df(res$query_details)

  res$timeline <- tidyr::unnest(res$timeline, station_values) %>%
    dplyr::mutate(date_start=as.Date(lubridate::ymd_hms(date_start)),
                  date_end=as.Date(lubridate::ymd_hms(date_end))) %>%
    dplyr::tbl_df()

  res$station_histogram <- dplyr::tbl_df(res$station_histogram)

  res$top_matches <- dplyr::tbl_df(res$top_matches) %>%
    dplyr::mutate(date=as.Date(lubridate::ymd_hms(date)),
                  show_date=lubridate::ymd_hms(show_date))

  class(res) <- c("newsflash", class(res))

  res

}
