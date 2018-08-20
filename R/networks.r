#' Helper function to identify station/network keyword and corpus date range for said market
#'
#' The \code{filter_network} of \code{query_tv()} is picky so this helps you idenitify the
#' keyword to use for the particular network/station.
#'
#' The list also shows the date ranges available for the captions, so you can use that as
#' a guide when picking dates.
#'
#' In interactive mode it uses \code{DT::datatable()}. You can force it to just display to
#' the console by passing in \code{widget=FALSE}
#'
#' @export
#' @param widget if `TRUE` then an HTML widget will be displayed to make it easier to
#'        sift through stations/networks
#' @return data frame
#' @examples
#' list_networks() # widget
#' print(list_networks(FALSE)) # no widget
list_networks <- function(widget = interactive()) {

  xdf <- jsonlite::fromJSON("https://api.gdeltproject.org/api/v2/tv/tv?mode=stationdetails&format=json")

  xdf$station_details %>%
  mutate(StartDate = as.Date(anytime::anytime(StartDate))) %>%
    mutate(EndDate = as.Date(anytime::anytime(StartDate))) -> xdf

  if (widget) DT::datatable(xdf)

  class(xdf) <- c("tbl_df", "tbl", "data.frame")

  xdf

}

