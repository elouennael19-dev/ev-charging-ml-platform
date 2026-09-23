# Installe les packages R nécessaires au pipeline (à lancer une seule fois)
pkgs <- c("here", "dplyr", "ggplot2", "leaflet", "leaflet.extras",
          "tidyverse", "caret", "nnet", "yardstick", "scales", "stringr")
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
