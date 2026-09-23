library(here)
##### Ce code à pour but le premier nettoyage du dataset brut. 
#### Une fois les critères de nettoyage appliqués création d'un dataset clean : IRVE_clean.csv.
### Application de critère notament sur les coordonnées et la puissance des stations.

#Lecture du dataset brut
IRVE <- read.csv(
  here("data", "raw", "irve_raw.csv"),
  header = TRUE,
  sep = ","
)

# Le dataset brut est copié afin de ne pas l'écraser.  
IRVE_clean <- IRVE

# Suppression des lignes dupliquées
IRVE_clean <- IRVE_clean[!duplicated(IRVE_clean), ]

# Suppression des lignes sans latitude ou longitude
IRVE_clean <- IRVE_clean[
  !is.na(IRVE_clean$consolidated_latitude) &
    !is.na(IRVE_clean$consolidated_longitude),
]

### Premier réel critère de trie. On ne garde que les stations situées en France métropolitaine.
## pour ce faire on trace un rectangle autour du territoire métropolitain. 
# En pratique on constate que certaines stations situées en belgique et au sud de l'angleterre sont conservés.
IRVE_clean <- IRVE_clean[
  IRVE_clean$consolidated_latitude >= 41 &
    IRVE_clean$consolidated_latitude <= 51 &
    IRVE_clean$consolidated_longitude >= -5 &
    IRVE_clean$consolidated_longitude <= 9.8,
]

# Suppression des puissances nulles ou négatives
IRVE_clean <- IRVE_clean[
  IRVE_clean$puissance_nominale > 0,
]

## Suppressions des stations possédant une puissance supérieure à 500kW
# Limite placée à 500kW car limite de la réglementation française
IRVE_clean <- IRVE_clean[
  IRVE_clean$puissance_nominale < 500,
]


### Affichage des dimensions avant/après nettoyage
## On passe de 184504 à 183383 lignes. 
dim(IRVE)
dim(IRVE_clean)

# Création du nouveau fichier data_clean.csv
dir.create(here("data", "processed"), recursive = TRUE, showWarnings = FALSE)
write.csv(
  IRVE_clean,
  here("data", "processed", "irve_clean.csv"),
  row.names = FALSE
)

