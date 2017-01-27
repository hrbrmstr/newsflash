#' Displays a summary of the query results
#'
#' Use \code{str()} for an object-level overview.
#'
#' @param x A \code{newsflash} object
#' @export
print.newsflash <- function(x) {

  if ("query_details" %in% names(x)) {

    cat("Query:\n")
    cat("   Primary keyword:", x$query_details$keyword_primary, "\n")
    cat("  Context keywords:", x$query_details$keywords_context, "\n")
    cat("          Stations:", x$query_details$stations, "\n")
    cat("        Start date:",
        as.character(as.Date(anytime::anytime(x$query_details$date_start[1]))), "\n")
    cat("          End date:",
        as.character(as.Date(anytime::anytime(x$query_details$date_end[1]))), "\n")

    cat("\n")

  }

  if ("timeline" %in% names(x)) {

    cat(sprintf("%s timeline results from %d stations:\n\n",
                scales::comma(nrow(x$timeline)),
                length(unique(x$timeline$station))))

  }

  if ("station_histogram" %in% names(x)) {
    txtbarchart(factor(rep(x$station_histogram$station,
                           x$station_histogram$value)),
                height=10)
    cat("\n")
  }

  if ("top_matches" %in% names(x)) {
    cat(sprintf("%s top query matches from the following shows:\n\n",
                scales::comma(nrow(x$top_matches))))

    dplyr::count(x$top_matches, station, show, sort=TRUE) %>%
      print()

  }

}
