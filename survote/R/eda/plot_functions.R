library(ggplot2)
library(dplyr)
library(fs)
library(here)
library(viridis)
#-------------------------------------------------------------------------------
plot_dir <- path(here(), "assets", "plots")
dir_create(plot_dir, recurse = TRUE)
fraction_colors <- c(
  "CDU/CSU" = "#000000",
  "SPD" = "#E3000F",
  "Die Grünen" = "#64A12D",
  "FDP" = "#FFED00",
  "Die Linke" = "#BE3075",
  "AfD" = "#009EE0",
  "Fraktionslos" = "grey60")

theme_set(theme_light())
options(
  ggplot2.discrete.colour = viridis::viridis,
  ggplot2.discrete.fill = viridis::viridis
)
#-------------------------------------------------------------------------------
gg_save <- function(filename,
                    destination_dir = plot_dir,
                    dpi = 300) {
  ggsave(
    filename = path(destination_dir, paste0(filename, ".png")),
    dpi = dpi
  )
}