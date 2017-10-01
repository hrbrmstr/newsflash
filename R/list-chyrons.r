#' Retrieve Third Eye chyron index
#'
#' Returns a data frame with available chyron dates & selected metadata.
#'
#' @md
#' @return data frame with three columns:
#' - `ts` (`POSIXct`) chyron timestamp
#' - `type` (`character`) `raw` or `cleaned`
#' - `size` (`numeric`) size of the feed file in bytes
#' @export
list_chyrons <- function() {

  doc <- xml2::read_xml("https://archive.org/download/third-eye/third-eye_files.xml")
  fils <- xml_find_all(doc, ".//file[contains(@name, 'tsv') and (contains(@name, '20'))]")

  fname <- xml_attr(fils, "name")

  data_frame(
    ts = as.Date(substr(fname, 1, 10)),
    type = ifelse(grepl("twe", fname), "cleaned", "raw"),
    size = as.numeric(xml_text(xml_find_first(fils, ".//size")))
  ) %>% arrange(desc(ts))

}
