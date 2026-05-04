library(sf)
library(rvest)
library(httr2)
library(tidyverse)
#-------------------------------------------------------------------------------
get_url_shapes <- function(election_year) {
  
  url1 <- paste0("https://bundeswahlleiterin.de/bundestagswahlen/",
                 election_year,"/wahlkreiseinteilung/downloads.html")
  url2 <- paste0("https://bundeswahlleiterin.de/bundestagswahlen/",
                 election_year, "/wahlkreiseinteilung.html")
  urls <- c(url1, url2)
  
  page <- NULL
  for (url in urls) {
    page <- tryCatch(read_html(url),
                     error = function(e) NULL)
    if (!is.null(page)) break
  }
  
  html <- read_html(url)
  nodeset <- html |>
    html_elements("a[href$='.zip']") |>
    shape_filter()
  shapefiles_url <- url_absolute(html_attr(nodeset, "href"), url)
  shapefiles_url[1]
}

get_sf_from_url <- function(url) {
  temp <- tempfile(fileext = ".zip")
  download.file(url, temp)
  temp_dir <- tempdir()
  unzip(temp, exdir = temp_dir)
  shp_file <- list.files(temp_dir, pattern = "\\.shp$", full.names = TRUE, recursive = TRUE)
  geo_data <- st_read(shp_file[1])
}

get_mandates <- function(period_id) {
  url <- paste0("https://www.abgeordnetenwatch.de/api/v2/candidacies-mandates?parliament_period=",
                period_id, "&range_end=1000")
  fromJSON(url)[["data"]] |>
    as_tibble()
}


shape_filter <- function(nodes) {
  hrefs <- html_attr(nodes, "href")
  titles <- html_attr(nodes, "title")
  
  pattern_title <- "(?<!Nicht )Generalisiert"
  pattern_href <- "shp.*\\.zip$"
  condition_title <- grepl(pattern_title, titles, ignore.case = TRUE, perl = TRUE)
  condition_href <- grepl(pattern_href, hrefs, ignore.case = TRUE, perl = TRUE)
  
  if (!any(condition_title) & any(condition_href)){
    message(paste0("Pattern for title '", pattern_title, "' did not match anything and is ignored"))
    return(nodes[condition_href])
  }
  if (!any(condition_href) & any(condition_title)){
    message(paste0("Pattern for href '", pattern_href, "' did not match anything and is ignored"))
    return(nodes[condition_title])
  }
  if (!any(condition_href) & !any(condition_title)) {
    message(paste0("Patterns for href and title['",
                   pattern_href, "' & '", pattern_title,
                   "] did not match anything and are ignored"))
    return(nodes)
  }
  return(nodes[condition_title & condition_href])
}

parse_fractions <- function(fractions) {
  case_when(
    str_detect(fractions, regex("GRÜN", ignore_case = TRUE)) ~ "Die Grünen",
    str_detect(fractions, regex("LINKE", ignore_case = TRUE)) ~ "Die Linke",
    str_detect(fractions, regex("SPD", ignore_case = TRUE)) ~ "SPD",
    str_detect(fractions, regex("CDU/CSU", ignore_case = TRUE)) ~ "CDU/CSU",
    str_detect(fractions, regex("FDP", ignore_case = TRUE)) ~ "FDP",
    str_detect(fractions, regex("AfD", ignore_case = TRUE)) ~ "AfD",
    str_detect(fractions, regex("fraktionslos", ignore_case = TRUE)) ~ "Fraktionslos",
    TRUE ~ NA_character_
    )
}

parse_consituency_label <- function(labels) {
  as.integer(str_extract(labels, pattern = "^\\d{1,3}"))
}
