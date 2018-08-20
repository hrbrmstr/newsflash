#' Issue a query to the TV Explorer
#'
#' NOTE: The `mode` parameter controls what is returned. See the section on `Mode` for more information on available modes.
#'
#' @section Mode:
#'
#' This specifies the specific output you would like from the API, ranging from timelines to word clouds to clip galleries.
#'
#' - `TimelineVol`. (Default) This tracks how many results your search generates by day/hour over the selected time period, allowing you to assess the relative attention each is paying to the topic and how that attention has varied over time. Using the DATANORM parameter you can control whether this reports results as raw clip counts or as normalized percentages of all coverage (the most robust way of comparing stations). By default, the timeline will not display the most recent 24 hours, since those results are still being generated (it can take up to 2-12 hours for a show to be processed by the Internet Archive and ready for analysis), but you can include those if needed via the LAST24 option. You can also smooth the timeline using the TIMELINESMOOTH option and combine all selected stations into a single time series using the DATACOMB option.
#' - `StationChart`. This compares how many results your search generates from each of the selected stations over the selected time period, allowing you to assess the relative attention each is paying to the topic. Using the DATANORM parameter you can control whether this reports results as raw clip counts or as normalized percentages of all coverage (the most robust way of comparing stations).
#' - `TimelineVolNorm`. This displays the total airtime (in terms of 15 second clips) monitored from each of the stations in your query. It must be combined with a valid query, since it displays the airtime for the stations queried in the search. This mode can be used to identify brief monitoring outages or for advanced normalization, since it reports the total amount of clips monitored overall from each station in each day/hour.
#'
#' @section Queries:
#'
#' The GDELT TV API supports keyword and keyphrase searches, OR statements and a variety of advanced operators. NOTE – all of the operators below must be used as part of the value of the QUERY field, separated by spaces, and cannot be used as URL parameters on their own.
#'
#' - `""`. Anything found inside of quote marks is treated as an exact phrase search. Thus, you can search for "Donald Trump" to find all matches of his name. (e.g  `"donald trump"`)
#' - `(a OR b)`. You can specify a list of keywords to be boolean OR'd together by enclosing them in parentheses and placing the capitalized word "OR" between each keyword or phrase. Boolean OR blocks cannot be nested at this time. For example, to search for mentions of Clinton, Sanders or Trump, you would use "`(clinton OR sanders OR trump)`"
#' - `-`. You can place a minus sign in front of any operator, word or phrase to exclude it. For example "-sanders" would exclude results that contained "sanders" from your results. (e.g. `-sanders`)
#' - `Context`. By default all of your keywords/phrases must appear in a single 15 second clip. (Phrases are allowed to span across two clips and are counted towards the clip they started in). The "context" operator allows you to require that a given keyword/phrase appears either in the 15 second clip or in the 15 second clips immediately before or after it. This gives you a bit of additional search fuzziness. Even when searching for a single word, it must appear in quote marks. (e.g. `context:"russia"`)
#' - `Market`. This narrows your search to a particular geographic market. The list of available markets can be found via the Station Details mode (look for the city name in the description of local stations). Example markets include "San Francisco" and "Philadelphia". The market name must be enclosed in quote marks. You can also use the special reserved market "National" to search the major national networks together. (e.g. `market:"San Francisco"`)
#' - `Network`. This narrows your search to a particular television network. The list of available networks can be found via the Station Details mode (look for the network name in the description of local stations). Example markets include "CBS" and "NBC". Do not use quote marks around the network name. (e.g. `network:CBS`)
#' - Show. This narrows your search to a particular television show. This must be the complete show name as returned by the TV API. To find a particular show, search the API and use the "clipgallery" mode to display matching clips and their source show. For example, to limit your search to the show Hardball With Chris Matthews, you'd search for "show:"Hardball With Chris Matthews"". Note that you must surround the show name with quote marks. Remember that the TV API only searches shows monitored by the Internet Archive's Television News Archive, which may not include all shows. (e.g. `show:"Hardball With Chris Matthews"`)
#' - `Station`. This narrows your search to a particular television station. Remember that the TV API only searches stations monitored by the Internet Archive's Television News Archive and not all of those stations have been monitored for the entire 2009-present time period. Do not use quote marks around the name of the station. To find the Station ID of a particular station, use the Station Details mode. (e.g. `station:CNN`)
#'
#' @md
#' @param query query string in GDELT format. See `QUERY` in https://blog.gdeltproject.org/gdelt-2-0-television-api-debuts/
#'     for details; use [list_networks()] to obtain valid station/network identifiers. If
#'     no `Network:`, `Market:` or `Station:` qualifiers are found `Market:"National"` is automatically added.
#' @param mode See `Mode` section
#' @param start_date,end_date start/end dates. Leaving both `NULL` searches all archive history.
#'     Leaving just `start_date` `NULL` sets the start date to July 2009. Leaving just `end_date`
#'     `NULL` sets the end date to today.
#' @param datanorm normalized ("`perc`") vs "`raw`" counts; defaults to `perc`.
#' @param timelinesmooth a smoothing value applying moving averages over 15-minute increments
#' @param datacomb if "`combined`", all network volume is combined into a single value.
#'    Defaults to "`separate`".
#' @param last_24  It can take the Internet Archive up to 24 hours to process a broadcast once
#'    it concludes. Thus, by default the TV API does not return results from the most recent
#'    24 hours to ensure that analyses are not skewed by partial results. However, when
#'    tracking breaking news events, it may be desirable to view partial results with the
#'    understanding that any time or station-based trends may not accurately reflect the
#'    totality of their coverage. To include results from the most recent 24 hours,
#'    set this URL parameter to "yes".
#' @return Different objects for different `mode`s:
#' - `TimelineVol` : a data frame with stations & counts (raw or normalied)
#' - `TimelineVolNorm` : a data frame of station & topic airtime
#' - `StationChart` : a data frame of stations and search result counts (raw or normalized)
#' @references <https://blog.gdeltproject.org/gdelt-2-0-television-api-debuts/>
#' @export
#' @examples
#' query_tv("(terror isis")
#' query_tv("british prime minister")
#' query_tv("mexican president")
query_tv <- function(query,
                     mode = c("TimelineVol", "StationChart", "TimelineVolNorm"),
                     start_date = NULL,
                     end_date = NULL,
                     datanorm = c("perc", "raw"),
                     timelinesmooth = 0,
                     datacomb = c("separate", "combined"),
                     last_24 = c("yes", "no")) {

  if (!grepl("Network:|Market:|Station:", query, ignore.case = TRUE)) {
    query <- sprintf('%s Market:"National"', query)
  }

  mode <- mode[1]

  if (!(mode %in% c("TimelineVol", "ClipGallery", "StationChart",
                            "TimelineVolNorm", "TrendingTopics", "WordCloud"))) {
     stop("Invalid 'mode'", call.=FALSE)
  }

  datanorm <- match.arg(datanorm, c("perc", "raw"))

  datacomb <- match.arg(datacomb, c("separate", "combined"))
  if (datacomb == "separate") datacomb <- NULL

  last_24 <-  match.arg(last_24, c("yes", "no"))
  if (last_24 == "no") last_24 <- NULL

  if (is.null(start_date)) start_date <- as.Date("2009-07-02")
  if (is.null(end_date)) end_date <- Sys.Date()

  start_date <- as.POSIXct(start_date)
  end_date <- as.POSIXct(end_date)

  start_date <- format(start_date, "%Y%m%d%H%M%S")
  end_date <- format(end_date, "%Y%m%d%H%M%S")

  list(
    query = query,
    mode = mode,
    format = "json",
    datanorm = datanorm,
    datacomb = datacomb,
    startdatetime = start_date,
    enddatetime = end_date,
    timelinesmooth = timelinesmooth,
    last24 = last_24
  ) -> query

  if (mode == "ClipGallery") query$maxresults <- 3000L

  httr::GET(
    url = "https://api.gdeltproject.org/api/v2/tv/tv",
    query = query
  ) -> res

  if (!(res$status_code < 300)) {
    stop(sprintf("[%s] Query or API error on request [%s]", res$status_code, URL), call.=FALSE)
  }

  res <- httr::content(res)

  if (mode %in% c("TimelineVol", "TimelineVolNorm")) {

    tibble::data_frame(
      network = res$timeline %>% purrr::map_chr("series"),
      data = res$timeline %>% purrr::map("data")) %>%
      tidyr::unnest(data) %>%
      dplyr::mutate(
        date = data %>%
          purrr::map_chr("date") %>%
          # hourly data doesn't have times - API doesn't return time values - split off non-hms data from date-time
          #sapply(., function(x) strsplit(x, "T")[[1]][1]) %>%
          lubridate::ymd_hms(),
        value = data %>%purrr::map_dbl("value")
      ) %>%
      dplyr::select(-data)

  } else if (mode == "ClipGallery") {

    purrr::map_df(res$clips, ~.x) %>%
      dplyr::mutate(date = anytime::anydate(date)) %>%
      dplyr::mutate(show_date = anytime::anydate(show_date))

  } else if (mode == "StationChart") {

    purrr::map_df(res$stationchart, ~.x)

  } else if (mode == "TrendingTopics") {

    list(
      overall_trending_topics = unlist(res$OverallTrendingTopics, use.names = FALSE),
      station_trending_topics = purrr::map_df(res$StationTrendingTopics, ~{
        dplyr::data_frame(
          station = .x$Station,
          topic = unlist(.x$Topics, use.names = FALSE)
        )
      }),
      station_top_topics = purrr::map_df(res$StationTopTopics, ~{
        dplyr::data_frame(
          station = .x$Station,
          topic = unlist(.x$Topics, use.names = FALSE)
        )
      }),
      overall_trending_phrases = unlist(res$OverallTrendingPhrases, use.names=FALSE)
    )

  } else if (mode == "WordCloud") {

    purrr::map_df(res$wordcloud, ~.x)

  }

}
