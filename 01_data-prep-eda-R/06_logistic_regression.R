library(here)
## Chargement des packages (installation : install_packages.R)
# tidyverse caret nnet ggplot2 yardstick scales stringr
packages <- c("tidyverse","dplyr", "caret", "nnet", "ggplot2",
              "yardstick", "scales", "stringr")
lapply(packages, library, character.only = TRUE)

##Chargement & nettoyage
#chargement du CSV et extraction du prix en €/kWh 
IRVE <- read_csv(here("data", "raw", "irve_raw.csv"))

#les dimensions lignes et colonnes
cat("Dimensions :", nrow(IRVE), "x", ncol(IRVE), "\n")

#les colonnes a mettre en avant pour l analyse
cat("Colonnes clés :", paste(c("tarification","puissance_nominale",
                               "prise_type_2","prise_type_combo_ccs",
                               "implantation_station"), collapse=", "), "\n\n")

#Extraction du prix depuis la variable tarification
extract_price <- function(txt) {
  txt <- str_replace_all(txt, ",", ".")
  
  # Recherche un nombre au format €/kWh
  m <- str_match(txt, "(\\d+\\.?\\d*)\\s*[€$]?\\s*/?\\s*k[wW][hH]")[, 2]
  if (!is.na(m)) return(as.numeric(m)) # si trouvé retourne le prix
  
  # Recherche un prix au fromat €
  m2 <- str_match(txt, "(\\d+\\.?\\d*)\\s*€")[, 2]
  if (!is.na(m2)) return(as.numeric(m2)) # si trouvé retourne le prix
  return(NA_real_) # sinon retourne NA
}

## Création colonne avec les prix extraient 
IRVE <- IRVE %>%
  #map_dbl=applique la fonction extract_price a toutes les lignes de tarification
  mutate(price_kwh = map_dbl(tarification, extract_price)) #mutate= met dans une nouvelle colonne

cat("Prix extraits (non-NA) :", sum(!is.na(IRVE$price_kwh)), "\n") # extrait les tarifs NA

#distribution des prix 25% 1er quartile, 50% mediane, 75% 3e quartile
cat("Distribution :", round(quantile(IRVE$price_kwh, c(.25,.5,.75), na.rm=TRUE), 3), "\n\n")

# Calcul des seuils séparant les trois classes de prix
q33 <- quantile(IRVE$price_kwh, 0.33, na.rm = TRUE)
q66 <- quantile(IRVE$price_kwh, 0.66, na.rm = TRUE)

cat(sprintf("Seuils des tertiles : q33 = %.3f, q66 = %.3f €/kWh\n\n", q33, q66)) # affichr les seuils 

#creation d une variable à trois critères : bas/modere/eleve
IRVE <- IRVE %>%
  mutate(tarif_classe = case_when(
    price_kwh <= q33         ~ "bas",
    price_kwh <= q66         ~ "modere",
    !is.na(price_kwh)        ~ "eleve",
    TRUE                     ~ NA_character_
  ) %>% factor(levels = c("bas", "modere", "eleve")))

#conversion des variables textuelles en variables numerique
to_int <- function(x) as.integer(as.logical(x))

# création variables numériques utilisées dans les modèles
df_feat <- IRVE %>%
  mutate(
    prise_ef       = to_int(prise_type_ef),
    prise_t2       = to_int(prise_type_2),
    prise_ccs      = to_int(prise_type_combo_ccs),
    prise_chademo  = to_int(prise_type_chademo),
    prise_autre    = to_int(prise_type_autre),
    gratuit        = to_int(gratuit),
    paiement_acte  = to_int(paiement_acte),
    paiement_cb    = to_int(paiement_cb),
    reservation    = to_int(reservation),
    deux_roues     = to_int(station_deux_roues),
    coord_ok       = to_int(consolidated_is_lon_lat_correct),
    implantation_n = as.integer(factor(replace_na(implantation_station, "inconnu")))
  ) %>%
  
  #enlèves toutes les colonnes inutiles du dataset et garde celles utiles pour la regression logistique
  select(puissance_nominale, nbre_pdc,
         consolidated_longitude, consolidated_latitude,
         prise_ef, prise_t2, prise_ccs, prise_chademo, prise_autre,
         gratuit, paiement_acte, paiement_cb, reservation, deux_roues,
         coord_ok, implantation_n,
         tarif_classe, price_kwh)


##Régression logistique (tarification)
#liste de variables utiles
features_log <- c("puissance_nominale","nbre_pdc",
                  "consolidated_longitude","consolidated_latitude",
                  "prise_ef","prise_t2","prise_ccs","prise_chademo","prise_autre",
                  "gratuit","paiement_acte","paiement_cb","reservation",
                  "deux_roues","coord_ok","implantation_n")

## Suppression lignes incomplètes
## Remplacement des valeurs manquantes par la médiane
df_log <- df_feat %>%
  filter(!is.na(tarif_classe)) %>% #retires toutes les lignes où la classe tarifaire est manquante
  select(all_of(features_log), tarif_classe) %>%
  mutate(across(all_of(features_log), ~replace_na(.x, median(.x, na.rm=TRUE)))) #enleve les valeurs NA

cat("Taille dataset logistique :", nrow(IRVE), "\n")
cat("Répartition des classes :\n")
print(table(IRVE$tarif_classe))
cat("\n")

set.seed(42) #séparation train/test soit reproductible
idx_log <- createDataPartition(IRVE$tarif_classe, p = 0.8, list = FALSE) #80 % des données vont dans le train
train_log <- df_log[idx_log, ]
test_log  <- df_log[-idx_log, ]

# mise à la même échelle des variables
preproc_log <- preProcess(train_log[, features_log], method = c("center", "scale"))
train_log_s <- predict(preproc_log, train_log) #jeu d entrainement 80 % des données
test_log_s  <- predict(preproc_log, test_log) #jeu de test 20 % des données

# Entraînement (multinom de nnet) => prédire la classe tarifaire 
model_log <- multinom(tarif_classe ~ ., data = train_log_s, MaxNWts = 5000, maxit = 300, trace = FALSE)

# Prédictions & métriques
pred_log <- predict(model_log, test_log_s)
cm_log   <- confusionMatrix(pred_log, test_log_s$tarif_classe) # matrice de confusion

cat("Accuracy :", round(cm_log$overall["Accuracy"], 4), "\n") # taux de bonnes prédictions
cat("\nRapport de classification :\n")
print(cm_log$byClass[, c("Precision","Recall","F1")])
cat("\nMatrice de confusion :\n")
print(cm_log$table)

# Coefficients (log-odds par classe)
coef_log <- coef(model_log)
cat("\nTop 5 features (|coef| moyen) :\n")
top5 <- sort(colMeans(abs(coef_log[, -1])), decreasing = TRUE)[1:5]
print(round(top5, 4))

#Régression linéaire (puissance nominale)

features_reg <- setdiff(features_log, "puissance_nominale") # toues les variables sauf la puissance

df_reg <- df_feat %>%
  filter(!is.na(puissance_nominale)) %>%
  select(all_of(features_reg), puissance_nominale) %>%
  mutate(across(all_of(features_reg), ~replace_na(.x, median(.x, na.rm=TRUE))))

cat("Taille dataset régression :", nrow(df_reg), "\n")
cat("Puissance nominale — résumé :\n")
print(summary(df_reg$puissance_nominale))
cat("\n")

set.seed(42)
idx_reg <- createDataPartition(df_reg$puissance_nominale, p = 0.8, list = FALSE)
train_reg <- df_reg[idx_reg, ]
test_reg  <- df_reg[-idx_reg, ]

preproc_reg <- preProcess(train_reg[, features_reg], method = c("center", "scale"))
train_reg_s <- predict(preproc_reg, train_reg)
test_reg_s  <- predict(preproc_reg, test_reg)

## régression linéaire => prédire la puissance nominale
model_reg  <- lm(puissance_nominale ~ ., data = train_reg_s)
pred_reg   <- predict(model_reg, test_reg_s)

# Coefficient de détermination 
r2   <- cor(test_reg$puissance_nominale, pred_reg)^2
rmse <- sqrt(mean((test_reg$puissance_nominale - pred_reg)^2)) # erreur quadratique moyenne
mae  <- mean(abs(test_reg$puissance_nominale - pred_reg)) # erreur absolue moyenne 

cat(sprintf("R²   : %.4f\n", r2))
cat(sprintf("RMSE : %.2f kW\n", rmse))
cat(sprintf("MAE  : %.2f kW\n\n", mae))

coef_reg_df <- data.frame(
  feature = names(coef(model_reg))[-1],
  coef    = coef(model_reg)[-1]
) %>% arrange(desc(abs(coef)))

cat("Coefficients (features normalisées — top 10) :\n")
print(head(coef_reg_df, 10), row.names = FALSE)

##affichage

#matrice de confusion
cm_df <- as.data.frame(cm_log$table)
colnames(cm_df) <- c("Prédit","Réel","n")
p1 <- ggplot(cm_df, aes(x = Prédit, y = Réel, fill = n)) +
  geom_tile(color = "white") +
  geom_text(aes(label = n), size = 5, fontface = "bold") +
  scale_fill_gradient(low = "#E1F5EE", high = "#0F6E56") +
  labs(title = "Matrice de confusion — Régression logistique",
       subtitle = "Tarification (bas / modéré / élevé)",
       fill = "Effectif") +
  theme(plot.title = element_text(size = 14, face = "bold"),
        legend.position = "right")
p1 ## Visualisation des bonnes et mauvaise prédictions 

feat_imp_log <- data.frame(
  feature  = colnames(coef_log)[-1],   #les coefficients du modèle logistique
  mean_abs = colMeans(abs(coef_log[, -1])) #valeur absolue des coefficients puis la moyenne
) %>% arrange(desc(mean_abs))

p2 <- ggplot(feat_imp_log, aes(x = reorder(feature, mean_abs), y = mean_abs)) + #Trie les variables du moins important au plus important
  geom_col(fill = "#1D9E75") + #Crée un barplot
  coord_flip() + #Retourne le graphique → barres horizontales (plus lisible)
  labs(title = "Importance des variables — Régression logistique", #Ajoute un titre propre
       x = NULL, y = "|coef| moyen") +
  theme(plot.title = element_text(size = 14, face = "bold"))
p2

#Coefficients — régression linéaire
##### Variable avec le plus d'influence sur la puisance
p3 <- ggplot(head(coef_reg_df, 10), aes(x = reorder(feature, coef), y = coef,
                                        fill = coef > 0)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(values = c("#D85A30", "#1D9E75"), guide = "none") +
  labs(title = "Coefficients — Régression linéaire (puissance nominale)",
       subtitle = "Features normalisées — vert = positif, orange = négatif",
       x = NULL, y = "Coefficient") +
  theme(plot.title = element_text(size = 14, face = "bold"))
p3

#Valeurs prédites vs réelles — régression linéaire
set.seed(1); idx_sample <- sample(length(pred_reg), 2000)
df_pred_plot <- data.frame(
  reel  = test_reg$puissance_nominale[idx_sample],
  predit = pred_reg[idx_sample]
)

## Comparaison entre valeurs réelles et valeurs prédites par le modèle
p4 <- ggplot(df_pred_plot, aes(x = reel, y = predit)) +
  geom_point(alpha = 0.3, size = 1, color = "#378ADD") +
  geom_abline(slope = 1, intercept = 0, color = "#D85A30", linewidth = 1) +
  labs(title = "Réel vs Prédit — Régression linéaire (puissance nominale)",
       subtitle = sprintf("R² = %.3f · RMSE = %.1f kW (échantillon n=2000)", r2, rmse),
       x = "Puissance réelle (kW)", y = "Puissance prédite (kW)") +
  theme(plot.title = element_text(size = 14, face = "bold"))
p4
