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
#' @examples
#' list_networks() # widget
#' list_networks(FALSE) # console
list_networks <- function(widget=interactive()) {

  xml2::read_html("http://television.gdeltproject.org/cgi-bin/iatv_ftxtsearch/iatv_ftxtsearch") %>%
    rvest::html_nodes("select[name='filter_network'] > option") -> networks

  detail_text <- rvest::html_text(networks) %>% gsub("=*> (.*)", "All \\1 (See individual networks for dates)", .)

  stri_match_all_regex(detail_text, "(.*) (\\(.*\\))") %>%
    map_df(~tbl_df(setNames(as.list(.[,2:3]), c("network", "date_range")))) %>%
    mutate(keyword=rvest::html_attr(networks, "value")) %>%
    select(keyword, network, date_range) -> df

  if (widget) DT::datatable(df) else print(df, n=nrow(df))

}

