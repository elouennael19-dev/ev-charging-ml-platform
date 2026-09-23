library(here)
##### Étape 0 — Exploration du dataset brut IRVE.
##### Aucune modification du dataset : diagnostic uniquement.

chemin <- here("data", "raw", "irve_raw.csv")

# na.strings : indispensable, sinon les cellules vides des colonnes texte
# restent des chaînes "" et is.na() ne les voit pas (46 colonnes sur 52 ici).
IRVE <- read.csv(chemin, header = TRUE, sep = ",",
                 na.strings = c("", "NA", "NULL"), stringsAsFactors = FALSE)

# --- Structure générale ---
dim(IRVE)
str(IRVE)

# --- Statistiques descriptives, séparées par type ---
num  <- names(IRVE)[sapply(IRVE, is.numeric)]
summary(IRVE[num])

# Pour les colonnes texte : nombre de modalités distinctes plutôt que summary()
sapply(IRVE[setdiff(names(IRVE), num)], function(x) length(unique(x)))

# --- Complétude des colonnes ---
completude <- data.frame(
  variable    = names(IRVE),
  nb_manquant = colSums(is.na(IRVE)),
  pct_manquant = round(100 * colMeans(is.na(IRVE)), 1)
)
completude <- completude[order(-completude$pct_manquant), ]
print(completude, row.names = FALSE)

# --- Doublons ---
# Sur la ligne entière : inopérant, les horodatages techniques rendent
# chaque ligne unique (résultat = 0).
sum(duplicated(IRVE))

# Sur la clé métier : c'est le vrai test.
sum(duplicated(IRVE$id_pdc_itinerance))                    # 60 754 (26,6 %)
sum(duplicated(IRVE[c("id_station_itinerance", "id_pdc_itinerance")]))

# --- Cohérences à vérifier avant nettoyage ---
sum(IRVE$puissance_nominale <= 0, na.rm = TRUE)            # 3 360
range(IRVE$puissance_nominale, na.rm = TRUE)               # 0 à 160 000 → unités mixtes
sum(IRVE$consolidated_latitude < 41 | IRVE$consolidated_latitude > 52, na.rm = TRUE)

# --- Sauvegarde pour le rapport ---
dir.create(here("outputs"), showWarnings = FALSE)
write.csv(completude, here("outputs", "00_completude.csv"), row.names = FALSE)