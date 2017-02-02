#' Tools to Work with the Internet Archive and GDELT Television Explorer
#'
#' @name newsflash
#' @docType package
#' @author Bob Rudis (bob@@rud.is)
#' @import httr
#' @importFrom rvest html_nodes html_attr html_text
#' @importFrom stringi stri_match_all_regex stri_replace_all_regex
#' @importFrom xml2 read_html
#' @importFrom lubridate ymd_hms is.Date
#' @importFrom tidyr unnest
#' @importFrom dplyr tbl_df %>% mutate data_frame count as_data_frame select
#' @importFrom purrr map_df %||%
#' @importFrom jsonlite fromJSON
#' @importFrom DT datatable
#' @importFrom scales comma
#' @importFrom txtplot txtbarchart
#' @importFrom tidytext unnest_tokens
#' @importFrom curl curl_fetch_memory
NULL
