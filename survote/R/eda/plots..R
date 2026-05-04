library(tidyverse)
library(ggplot2)
library(ggalluvial)
#-------------------------------------------------------------------------------
source("R/data/load.R")
source("R/eda/plot_functions.R")

filter_stable_mps <- function(mandates) {
  mandates |>
    group_by(politician_id) |>
    filter(n_distinct(fraction) == 1) |>
    ungroup() |>
    filter(!is.na(fraction)) |>
    filter(fraction != "Fraktionslos")
}
#-------------------------------------------------------------------------------
mandates |>
  filter_stable_mps() |>
  count(politician_id, fraction, name = "elections") |>
  count(elections, fraction, name = "n") |>
  ggplot(aes(x = factor(elections), y = n, fill = fraction)) +
  geom_col() +
  facet_wrap(~fraction, scales = "fixed", strip.position = "top") +
  scale_fill_manual(values = fraction_colors, name = "fraction/party") +
  geom_text(aes(label = paste0("[n = ", n, "]")),size = 2, vjust = -0.3) +
  labs(x = "Election count per MP", y = "Number of MPs") +
  theme(strip.text = element_text(face = "bold")) +
  xlab("Legistlature Period") +
  ylab("") +
  ggtitle("Election counts for each consecutive legislature period")
gg_save("bar_election")
