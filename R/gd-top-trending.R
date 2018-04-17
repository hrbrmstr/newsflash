#' Top Trending (GDELT)
#'
#' Retrieve current (last 15 minute) "top topics" being discussed on stations
#' @export
gd_top_trending <- function() {
  query_tv("", mode = "TrendingTopics")
}

