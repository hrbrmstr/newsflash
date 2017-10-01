readr::cols(
  ts = readr::col_datetime(format = ""),
  channel = readr::col_character(),
  duration = readr::col_integer(),
  details = readr::col_character(),
  text = readr::col_character()
) -> .third_eye_cols

.third_eye_col_names <- c("ts", "channel", "duration", "details", "text")
.third_eye_url_tmpl <- "https://archive.org/download/third-eye/%s%s.tsv"

#' Retrieve TV News Archive chyrons from the Internet Archive's Third Eye project
#'
#' The TV News Archive's Third Eye project captures the chyrons–or narrative text–that appear on the lower third of TV news screens and turns them into downloadable data and a Twitter feed for research, journalism, online tools, and other projects. At project launch (September 2017) we are collecting chyrons from BBC News, CNN, Fox News, and MSNBC–more than four million collected over just two weeks. Chyrons have public value because:
#'  - Breaking news often appears on chyrons before TV newscasters begin reporting or video is available, whether it's a hurricane or a breaking political story.
#'  - Which chyrons a TV news network chooses to display can reveal editorial decisions that can inform public understanding of how news is filtered for different audiences.
#'  - Providing chyrons as data–and also on Twitter–in near real-time can serve as a alert system, showing how TV news stations are reporting the news. Often the chyrons are ahead of the general conversation on Twitter.
#'
#' Some notes on the data
#'
#' - chyrons are derived in near real-time from the TV News Archive's collection of TV news. The constantly updating public collection contains 1.4 million TV news shows, some dating back to 2009.
#' - At launch, Third Eye captures four TV cable news channels: BBC News, CNN, Fox News, and MSNBC.
#' - Data can be affected by temporary collection outages, which typically can last minutes or hours, but rarely more.
#' - Dates/times are in UTC (Coordinated Universal Time).
#' - Because the size of the raw data is so large (about 20 megabytes per day), results are limited to seven days per request.
#' - Raw data collection began on August 25, 2017; the clean feed begins on September 7, 2017.
#' - "`duration`" column is in seconds–the amount of time that particular chyron appeared on the screen.
#'
#' @md
#' @note It is _highly_ recommended that you use the "clean" feed unless you're researching
#'       how to correct text. This package does it's best to read in the raw feed but
#'       it often contains embedded nulls and non-standard text encodings which
#'       make it difficult to process.
#' @param chyron_day archive day (`Date` or `character`; if `character` should be
#'        in `YYYY-mm-dd` format)
#' @param cleaned logical, default `TRUE`. The "raw feed" option provides all of the
#'       OCR'ed text from chyrons at the rate of approximately one entry per second.
#'       The "clean feed" download provides the data feed that fuels the Third Eye
#'       Twitter bots; this has been filtered to find the most representative,
#'       clearest chyrons from a 60-second period, with no more than one entry/tweet per
#'       minute (though the duration may be shorter than 60 seconds.) The clean feed
#'       relies on algorithms that are a work in progress.
#' @return `NULL` on irrecoverable errors, otherwise a data frame with five columns:
#' - `ts` (`POSIXct`) chyron timestamp
#' - `channel` (`character`) news channel the chyron appeared on
#' - `duration` (`integer`) see Description
#' - `details` (`character`) Internet Archive details path
#' - `text` (`character`) the chyron text
#' @export
read_chyrons <- function(chyron_day = Sys.Date()-1, cleaned = TRUE) {

  if (length(chyron_day) > 1) {
    message("Can only retrieve one day's archive at a time. Using first value.")
    chyron_day <- chyron_day[1]
  }

  if (inherits(chyron_day, "character")) {
    chyron_day <- as.Date(chyron_day) # ensure it's valid
  }

  chyron_day <- format(chyron_day, "%Y-%m-%d")

  archive_type <- if (cleaned) "-tweets" else ""

  archive_url <- sprintf(.third_eye_url_tmpl, chyron_day, archive_type)

  # see if it's there
  res <- s_head(archive_url)
  if (is.null(res)) {
    message(sprintf("Error reaching the Internet Archive [%s]", res$error))
    return(NULL)
  }

  if (httr::status_code(res$result) != 200) {
    message(sprintf("Chyron archive request failed: [%s]", httr::http_status(res$result)$message))
    return(NULL)
  }

  tf <- tempfile()
  download.file(archive_url, tf, quiet = TRUE)
  if (cleaned) {
    third_eye <- read_tsv(tf, col_names = .third_eye_col_names, .third_eye_cols)
  } else {
    suppressWarnings(stri_read_lines(tf)) %>%
      stri_split_fixed("\t", simplify = TRUE) %>%
      as_data_frame() %>%
      set_names(c("ts", "channel", "duration", "details", "text")) %>%
      mutate(ts = lubridate::ymd_hms(ts)) -> third_eye
  }

  unlink(tf)

  third_eye

}
