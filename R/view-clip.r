#' View news segment clips from chyron details frament
#'
#' Opens a browser to show the a clip of the scraped segment
#'
#' @param details_fragment a single entry from the `details` column of a data
#'        frame created by [cyclops()]. It will look something like:
#'        `FOXNEWSW_20170919_100000_FOX__Friends/start/792`
#' @export
view_clip <- function(details_fragment) {
  clip_url <- sprintf("https://archive.org/details/%s", details_fragment[1])
  utils::browseURL(clip_url)
}
