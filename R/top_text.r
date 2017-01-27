#' Helper function to extract the text snippets from the top matches as a tidytext-compatible
#' tibble or plain character vector
#'
#' @param x query result object from calling \code{query_tv}
#' @param tidy if \code{TRUE} (default) reuturn a \code{tidytext} tibble with
#'   \code{station}, \code{show}, \code{show_date} and \code{word} columns. If
#'   \code{FALSE} it just returns the character vector of the caption snippets.
#' @export
#' @examples
#' brexit <- query_tv("brexit", start_date=as.Date("2016-01-01"), end_date=as.Date("2016-12-31"))
#' top_text(brexit)
top_text <- function(x, tidy=TRUE) {

  if (!inherits(x, "newsflash")) stop("Not a newsflash object", call.=FALSE)

  if (!tidy) {
    x$top_matches$snippet
  } else {
    select(x$top_matches, station, show, show_date, snippet) %>%
      unnest_tokens(word, snippet)
  }

}

