library(here)
####### Objectif : réaliser une heatmap des stations de recharge.

#On charge le package
library(leaflet)
library(leaflet.extras)

#On recupere les donnees nettoyees
IRVE <- read.csv(here("data", "processed", "irve_clean.csv"))

# Récupération des coordonnées géographiques de chaque stations (latitude/longitude}
lon <- IRVE$consolidated_longitude
lat <- IRVE$consolidated_latitude

## Palette de couleurs selon la puissance nominale
pal <- colorNumeric(
  palette = "viridis",          # palette de couleurs
  domain = IRVE$puissance_nominale  # variable utilisée pour colorer
)

## Création de la heatmap
# Plus il y a de stations dans la zone plus la zone est rouge. 
leaflet(IRVE) %>%
  addTiles() %>%   # Carte OpenStreetMap
  addHeatmap(
    lng = ~lon,
    lat = ~lat,
    blur = 20,      # adoucit la heatmap
    max = 0.05,     # intensité max
    radius = 15     # taille des points
  )%>%
  
# Points colorés selon la puissance
addCircleMarkers(
    lng = ~lon,
    lat = ~lat,
    radius = 5,
    color = ~pal(puissance_nominale),
    stroke = FALSE,
    fillOpacity = 0.8,
    popup = ~paste(
      "<b>Puissance :</b>", puissance_nominale, "kW<br>",
      "<b>Adresse :</b>", adresse_station
    )
) %>%
  
  # Marqueurs regroupés (clusters)
  addMarkers(
    lng = ~lon,
    lat = ~lat,
    clusterOptions = markerClusterOptions()
  )%>%
  
  # Légende
  addLegend(
    pal = pal,
    values = ~puissance_nominale,
    title = "Puissance nominale (kW)"
  )
