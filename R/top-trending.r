#' Top Trending Tables
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
#' **The time is expected to be GMT for the API and this function will eventually be
#' modified to auto-convert local timezone to GMT with a parameter.**
#'
#' @md
#' @note If an error occurred with the API or transmission, `NULL` is returned.
#' @param ymd a `Date` object or a character string in `YYYYMMDD` or `YYYY-MM-DD` format.
#'        (Defaults to today).
#' @param hour `0` to `23` (Defaults to `0`)
#' @param minute one of `0`, `15`, `30`, or `45`. (Defaults to `0`)
#' @return `list` with
#'   - `DateGenerated` (character vector)
#'   - `OverallTrendigTopics` (character vector)
#'   - `StationTrendingTopics` (data frame with a `Station` column and a `list` column of `Topics`)
#'   - `StationTopTopics` (same structure as `StationTrendingTopics`)
#'   - `OverallTrendingPhrases`
#' @export
#' @examples
#' top_trending(hour=14, minute=30)
top_trending <-  function(ymd=Sys.Date(), hour=0:24, minute=c(0,15,30,45)) {

  base_url <- "http://data.gdeltproject.org/gdeltv3/iatv_trending/%s%s%s00.tvtrending.v3.15min.json"

  ymd <- format(lubridate::ymd(ymd), "%Y%m%d")

  hour <- sprintf("%02d", as.integer(match.arg(as.character(hour), as.character(c(0:24)))))
  minute <- sprintf("%02d", as.integer(match.arg(as.character(minute), as.character(c(0,15,30,45)))))

  tmp_url <- sprintf(base_url, ymd, hour, minute)

  res <- sfj(tmp_url, flatten=TRUE)

  res <- res$result
  if (!is.null(res)) {

    nres <- gsub("[[:punct:][:space:]]", "", names(res))
    names(res) <- nres

    res$DateGenerated <- lubridate::ymd_hms(res$DateGenerated)

  }

  res

}

