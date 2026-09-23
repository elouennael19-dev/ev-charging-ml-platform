library(here)
# Lecture du fichier source
IRVE <- read.csv(here("data", "raw", "irve_raw.csv"),
  header = TRUE,
  sep = ",")

##Découverte générale
# Dimensions du dataset
dim(IRVE)
# Noms des colonnes
names(IRVE)
# Statistiques descriptives
summary(IRVE)
# Traitement de valeurs manquantes
na_count <- colSums(is.na(IRVE))
na_count
# Doublons : lignes strictement identiques sur toutes les colonnes
sum(duplicated(IRVE))
any(duplicated(IRVE))



# Création d'une copie du dataset original
IRVE_clean <- IRVE

## Variable géolocalisation
# Suppression des lignes sans latitude ou longitude
IRVE_clean <- IRVE_clean[
  !is.na(IRVE_clean$consolidated_latitude) &
    !is.na(IRVE_clean$consolidated_longitude),]
# Conservation uniquement des stations situées en France métropolitaine
IRVE_clean <- IRVE_clean[
  IRVE_clean$consolidated_latitude >= 41 &
    IRVE_clean$consolidated_latitude <= 51 &
    IRVE_clean$consolidated_longitude >= -5 &
    IRVE_clean$consolidated_longitude <= 9.8,]

##Variable puissance
#Gérer les virgule : 
IRVE_clean$puissance_nominale <- floor(IRVE_clean$puissance_nominale)
#Vérification des puissance sous forme d'entier
IRVE_clean$puissance_nominale[1:12]
# Suppression des puissances nulles ou négatives
IRVE_clean <- IRVE_clean[
  IRVE_clean$puissance_nominale > 0,
]
# Suppression des puissances très élevées
IRVE_clean <- IRVE_clean[
  IRVE_clean$puissance_nominale < 500,
]




## Variable date de mise en place : Supression des stations avant 2000 
# On convertit en Date (format attendu : "YYYY-MM-DD")
IRVE_clean$date_mise_en_service <- as.Date(IRVE_clean$date_mise_en_service)

# Seuil
seuil <- as.Date("2000-01-01")

# On garde :les dates NA (vides) + les dates >= seuil
IRVE_clean <- IRVE_clean[
  is.na(IRVE_clean$date_mise_en_service) | IRVE_clean$date_mise_en_service >= seuil,
]


## Transformation des colonnes booléennes TRUE/FALSE -> 1/0
cols_bool <- c(
  "prise_type_ef", "prise_type_2", "prise_type_combo_ccs",
  "prise_type_chademo", "prise_type_autre",
  "gratuit", "paiement_acte", "paiement_cb", "paiement_autre",
  "reservation",
  "station_deux_roues", "cable_t2_attache"
)
# Sécurité : ne traiter que les colonnes réellement présentes
cols_bool <- intersect(cols_bool, names(IRVE_clean))
# Conversion (gère les TRUE/FALSE logiques ET les "TRUE"/"FALSE" texte)
IRVE_clean[cols_bool] <- lapply(IRVE_clean[cols_bool], function(x) {
  as.integer(as.logical(x))
})
# Vérification
head(IRVE_clean[cols_bool])

## Supréssion des variables non nécéssaire
# Colonnes à garder
cols_a_garder <- c(
  "implantation_station", "puissance_nominale",
  
  "consolidated_longitude", "consolidated_latitude",
  
  "nbre_pdc",
  "prise_type_ef", "prise_type_2", "prise_type_combo_ccs",
  "prise_type_chademo", "prise_type_autre",
  "gratuit", "paiement_acte", "paiement_cb", "paiement_autre",
   "reservation", "station_deux_roues", "condition_acces",
  "accessibilite_pmr"
)
# Garder uniquement ces colonnes (IMPORTANT : sur IRVE_clean)
IRVE_clean <- IRVE_clean[, cols_a_garder]


# Vérification et affichage des dimensions avant/après nettoyage
dim(IRVE)
dim(IRVE_clean)

# Création d'un nouveau fichier de data propre
dir.create(here("data", "processed"), recursive = TRUE, showWarnings = FALSE)
write.csv(
  IRVE_clean,
  here("data", "processed", "irve_ml.csv"),
  row.names = FALSE
)


#Verification de base de "condition_acces"
length(unique(IRVE_clean$condition_acces))  # nb de valeurs distinctes
unique(IRVE_clean$condition_acces)   # liste les valeurs distinctes

#Verification de base de "accessibilite_pmr"
length(unique(IRVE_clean$accessibilite_pmr))  # nb de valeurs distinctes
unique(IRVE_clean$accessibilite_pmr)   # liste les valeurs distinctes

