#' Top Trending Topics (Internet Archive TV Archive)
#'
#' Provide start & end times in current time zone and this function will generate
#' the proper "every 15-second" values, convert them to GMT values and issue the queries,
#' returning a nested data frame of results. If you want more control, use [top_trending()].
#'
#' GDELT now generates a snapshot every 15 minutes that records all of the "top trending"
#' tables into a single archive enabling users to ook back over time at what was trending
#' in 15 minute increments historically back to midnight on 2017-09-07.
#'
#' Note that the archives are generated every 15 minutes based on the television shows that
#' have completed processing at that time. It can take several hours for a show to be fully
#' processed by the Internet Archive and available for processing, thus the presence/absence
#' of a topic in these files should not be used to date it precisely to that 15 minute mark,
#' but rather as a rough temporal indicator of what topics were trending up/down in that
#' general time frame. For precise timelines, you should take a topic from this archive and
#' run a search on it using the main Television Explorer interface, select a timeframe of
#' 72 hours and use the resulting timeline to precisely date the topic's coverage (since
#' the Explorer timeline is based on the broadcast timestamp of the show, even if it is
#' processed hours later).
#'
#' @md
#' @param from,to start and end date/time ranges (will auto-convert if properly formatted strings)
#' @param .progress show a progress bar? Defaukts to `TRUE` if in an interactive session.
#' @note The times are auto-converted to GMT
#' @export
#' @examples
#' top_trending("2017-09-08 18:00", "2017-09-09 06:00")
iatv_top_trending <-  function(from, to, .progress=interactive()) {

  from <- anytime::anytime(from)
  to <- anytime::anytime(to)

  base_url <- "http://data.gdeltproject.org/gdeltv3/iatv_trending/%s.tvtrending.v3.15min.json"

  start_ymd <- format(from, "%Y-%m-%d")
  end_ymd <- format(to, "%Y-%m-%d")

  start_hr <- as.numeric(format(from, "%H"))
  end_hr <- as.numeric(format(to, "%H"))

  start_min <- as.numeric(format(from, "%M"))
  if (!start_min %in% c(0, 15, 30, 45)) start_min <- 0

  end_min <- as.numeric(format(to, "%M"))
  if (!end_min %in% c(0, 15, 30, 45)) end_min <- 45

  from <- as.POSIXct(sprintf("%s %02d:%02d:00", start_ymd, start_hr, start_min))
  to <- as.POSIXct(sprintf("%s %02d:%02d:00", end_ymd, end_hr, end_min))

  full_range <- seq(from, to, "15 mins")

  attr(full_range, "tzone") <- "GMT"

  url_list <- sprintf(base_url, format(full_range, "%Y%m%d%H%M00"))

  pb <- dplyr::progress_estimated(length(url_list))
  purrr::map(url_list, ~{
    if (.progress) pb$tick()$print()
    res <- sfj(.x, flatten=TRUE)
    res$result
  }) -> res

  res <- purrr::discard(res, is.null)

  purrr::map_df(res, ~{

    date_gen <- .x[["DateGenerated:"]]
    suppressWarnings(date_gen <- lubridate::ymd_hms(date_gen))
    suppressWarnings(attr(date_gen, "tzone") <- Sys.timezone())

    dplyr::data_frame(
      ts = date_gen,
      overall_trending_topics = list(.x[["OverallTrendingTopics"]]),
      station_trending_topics = list(.x[["StationTrendingTopics"]]),
      station_top_topics = list(.x[["StationTopTopics"]]),
      overall_trending_phrases = list(.x[["OverallTrendingPhrases"]])
    )

  }) -> out

  out

}

