library(fs)
library(sf)
library(here)
#-------------------------------------------------------------------------------
mandates <- st_read(path(here(), "data", "preprocessed", "mandates.gpkg"))
