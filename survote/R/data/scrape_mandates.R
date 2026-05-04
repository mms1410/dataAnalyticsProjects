library(jsonlite)
library(rvest)
library(httr2)
library(tidyverse)
library(fs)
library(here)
library(sf)
#-------------------------------------------------------------------------------
source("R/data/utils.R")
url <- "https://www.abgeordnetenwatch.de/api/v2/parliament-periods?range_end=1000"
#-------------------------------------------------------------------------------
bundestage <- fromJSON(url)[["data"]] |>
  as_tibble() |>
  filter(str_detect(label, "Bundestag")) |>
  filter(type == "legislature")

for (row in seq_len(nrow(bundestage))) {
  bundestag <- bundestage[row,]
  mandates <- get_mandates(bundestag$id)
  shape_url <- get_url_shapes(year(bundestag$start_date_period))
  constituencies <- get_sf_from_url(shape_url)
  destination <- path(here(), "data", "raw", year(bundestag$start_date_period))
  dir_create(destination)
  saveRDS(mandates, path(destination, "mandates.rds"))
  st_write(constituencies, path(destination, "constituencies.gpkg"),
           delete_layer = TRUE)
  
}
#-------------------------------------------------------------------------------
rm(list = ls())