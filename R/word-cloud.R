#' Retrieve top words that appear most frequently in clips matching your search
#'
#' The API takes the 200 most relevant clips that match your search and returns the
#' terms for a "word cloud" of up to the top 200 most frequent words that appeared in
#' those clips (common stop words are automatically removed). This is a powerful way
#' of understanding the topics and words dominating the relevant coverage and
#' suggesting additional contextual search terms to narrow or evolve your search.
#' Note that if there are too few matching clips for your query, the word cloud may
#' be blank.
#'
#' @md
#' @param query query string in GDELT format. See `QUERY` in https://blog.gdeltproject.org/gdelt-2-0-television-api-debuts/
#'     for details; use [list_networks()] to obtain valid station/network identifiers
#' @param start_date,end_date start/end dates. Leaving both `NULL` searches all archive history.
#'     Leaving just `start_date` `NULL` sets the start date to July 2009. Leaving just `end_date`
#'     `NULL` sets the end date to today.
#' @export
word_cloud <- function(query, start_date = NULL, end_date = NULL) {

  query_tv(
    query = query,
    mode = "WordCloud",
    start_date = start_date,
    end_date = end_date
  )

}
