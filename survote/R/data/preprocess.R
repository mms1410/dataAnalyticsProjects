library(fs)
library(here)
library(dplyr)
library(stringr)
library(tidyr)
library(sf)
#-------------------------------------------------------------------------------
source("R/data/utils.R")
root <- here()
folders <- dir_ls(path(here(), "data", "raw"), type = "directory")
destination_dir <- path(here(), "data", "preprocessed")
#-------------------------------------------------------------------------------

result <- tibble() 
for (folder in folders) {
  year <- basename(folder)
  constituencies <- dir_ls(folder, regexp = ".gpkg")
  constituencies <- st_read(constituencies, quiet = TRUE)
  
  mandates <- dir_ls(folder, regexp = ".rds")
  mandates <- readRDS(mandates)
  mandates_ids <- mandates$electoral_data$constituency$label |>
    str_extract(pattern = ("^\\d{1,3}"))
  
  checkmate::assert(all(mandates_ids[!is.na(mandates_ids)] %in% constituencies$WKR_NR))
  
  data <- mandates |>
    unnest_wider(politician, names_sep = "_") |>
    unnest_wider(fraction_membership, names_sep = "_") |>
    unnest_wider(fraction_membership_fraction, names_sep = "_") |>
    unnest_wider(electoral_data, names_sep = "_") |>
    unnest_wider(electoral_data_constituency, names_sep = "_") |>
    mutate(year = year,
           fraction = parse_fractions(fraction_membership_fraction_label),
           constituency_id = parse_consituency_label(electoral_data_constituency_label)) |>
    select(year, fraction, constituency_id, politician_label, politician_id) |>
    inner_join(constituencies, by = c("constituency_id" = "WKR_NR")) |>
    select(year, fraction, constituency_id, constituency_label = WKR_NAME,
           bundesland = LAND_NAME,
           politician_label, politician_id, geom
           )
  result <- bind_rows(result, data)
}
dir_create(destination_dir)
st_write(result, path(destination_dir, "mandates.gpkg"), append = FALSE)
#-------------------------------------------------------------------------------
rm(list= ls())