#' Helper function to extract the text snippets from the top matches
#'
#' @param x query result object from calling \code{query_tv}
#' @export
top_text <- function(x) {
  x$top_matches$snippet
}