library(here)
library(dplyr)
library(ggplot2)
######## Objectif principal : Réaliser les graphiques sur les 6 critères les plus pertinents selon nous. 
####### Les années de mise en service. Pour ce critère nous ajoutons un filtre afin d'obtenir un histogramme propre. 
###### Les communes avec le plus de stations. Même chose pour ce critère.
##### Le nombre de stations par puissance nominale
#### Le top 10 des opérateurs 
### Les lieux d'implantation des stations
## Le nombre de point de charge 
# Le type de prise

IRVE_clean <- read.csv(here("data", "processed", "irve_clean.csv"), header = TRUE, sep = ",")


### histogramme des années
## On extrait les 4 premiers caractères de la date, soit l'information de l'année.
annees <- substr(IRVE_clean$date_mise_en_service, 1, 4) 
### On garde seulement les années que l'on juge réaliste sur l'installation de stations de recharge en France
## Cette focntion réalise l'équivalent d'une boucle qui parcourt la liste années pour ne garder que les caractères avec nos critères.
# Cela permet notamment de retirer les années jugées impossibles, notamment les années 1900.
annees <- annees[annees >= "2010" & annees <= "2025"] 

stations_par_annee <- table(annees) # On compte les stations par année

barplot(stations_par_annee,
        main = "Evolution du nombre de stations par année",
        xlab = "Année", ylab = "Nombre de stations",
        las = 2) # On affiche le graphique de l'evolution du nombre de stations par année


##### Top 10 des communes
#### On applique la même méthode que pour les années.
### Création d'un liste d'une liste avec toute les communes de chaque lignes
communes <- IRVE_clean$consolidated_commune# On copie la colonne des communes
## Même fonction que pour les années. Principe de boucle qui garde uniquement les caractères différents du caractère nul ""
communes <- communes[communes != ""]# On enlève les communes vides
# Compte le nombre de commune
communes <- sort(table(communes), decreasing = TRUE)
# Réalisation de l'histogramme. 
barplot(head(communes, 10),
        horiz = TRUE, las = 1,
        main = "Top 10 des communes",
        xlab = "Nombre de stations")


### Histogramme des puissances nominales 
## Affiche le graphe des puissances nominales en fonction du nombre de station
# Utilisation de hist et non de barplot par soucis de clarté. Hist change les valeurs décimales en nombre entier. 
hist(IRVE_clean$puissance_nominale,
     main = "Répartition des puissances nominales",
     xlab = "Puissance nominale en kW",
     ylab = "Nombre de stations")


######## Top 10 des opérateurs
### On compte les opérateurs
## table() compte le nombre d'occurrences
# sort() trie dans l'ordre décroissant
operateurs <- sort(table(IRVE_clean$nom_operateur), decreasing = TRUE)
## On ne garde uniquement les 10 premiers indices
# as.data rend le résultat exploitable par ggplot
df_op <- as.data.frame(operateurs[1:10]) #selection des 10 premiers 
colnames(df_op) <- c("operateur", "nb")

# Calcul du pourcentage des opérateurs.
df_op <- df_op %>%
  mutate(
    pct   = nb / sum(nb) * 100,
    label = paste0(round(pct, 1), "%")
  )

# Création du Camembert
ggplot(df_op, aes(x = "", y = nb, fill = operateur)) +
  geom_col(width = 1, color = "white") +
  coord_polar(theta = "y") + ## Transforme l'histogramme en cammembert
  geom_text(aes(label = label),
            position = position_stack(vjust = 0.5),
            size = 3) +
  theme_void() +
  labs(title = "Top 10 des opérateurs", fill = "Opérateur")

### Lieu d'implantation des stations
## Montre où sont installées les stations

implantations <- table(
  IRVE_clean$implantation_station
)

barplot(
  implantations,
  las = 2,
  main = "Lieu d'implantation des stations",
  ylab = "Nombre de stations"
)




## Nombre de points de charge
points_charge <- table(
  IRVE_clean$nbre_pdc
)

barplot(
  points_charge,
  main = "Nombre de points de charge par station",
  xlab = "Nombre de points de charge",
  ylab = "Nombre de stations"
)

## Nombre de stations possédant chaque type de prise
# Compte le nm de caractère true de chaque type de prise afin d'en réaliser l'histogramme.
prises <- c(
  sum(IRVE_clean$prise_type_2 == "true"),
  sum(IRVE_clean$prise_type_combo_ccs == "true"),
  sum(IRVE_clean$prise_type_chademo == "true"),
  sum(IRVE_clean$prise_type_ef == "true"),
  sum(IRVE_clean$prise_type_autre == "true")
)

# Graphique de type de recharge 

barplot(
  prises,
  names.arg = c("Type 2", "CCS", "CHAdeMO", "EF", "Autre"),
  main = "Types de prises",
  ylab = "Nombre de stations"
)

