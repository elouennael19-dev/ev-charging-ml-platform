library(here)
##### Même principe que le code 00_exploration mais crée un tableau récapitulatif des colonnes avant nettoyage. 

# Chargement du dataset brut
IRVE <- read.csv(here("data", "raw", "irve_raw.csv"), header = TRUE, sep = ",")

# Dimension du dataset
dim(IRVE)

# Description de chaque colonnes 
class(IRVE)

# Résumé des données
summary(IRVE)

# Création d'un tableau avec chaque variable. 
# Pour chaque variable leurs : nom, nb de valeurs renseignées/manquantes, pourcentage de valeurs manquantes, nb de valeurs différentes.
n_total <- nrow(IRVE)
stats_base <- data.frame(
  Variable = names(IRVE),
  n_non_NA = colSums(!is.na(IRVE)),
  NA_nb    = colSums(is.na(IRVE)),
  NA_pct   = round(100 * colMeans(is.na(IRVE)), 2),
  Uniques  = sapply(IRVE, function(x) length(unique(x))),
  row.names = NULL
)
# Créé un diagramme en boîte de la répartition des puissances
boxplot(IRVE$puissance_nominale)

# Affiche le tableau dans le terminale
stats_base

## Exporte le tableau au format CSV
if (!dir.exists("data")) dir.create("data")
write.csv(stats_base, here("outputs", "01_stats_base.csv"), row.names = FALSE)
