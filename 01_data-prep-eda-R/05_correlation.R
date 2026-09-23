library(here)
#### Objectif : déterminer si la puissance influence le prix, si la puissance des stations diffère avec le prix et si le type d'implantation est lié à la condition d'accès. 


IRVE_clean <- read.csv(
  here("data", "processed", "irve_clean.csv"),
  stringsAsFactors = FALSE ## Empèche R de transformer les textes en facteurs automatiquement
)


## Corrélation entre puissance nominale et prix
# Remplacement des "," par des "." afin de convertir les chr en nombre
IRVE_clean$puissance_num <- gsub(",", ".", IRVE_clean$puissance_nominale)
# Conversion de la puissance en variable numérique
IRVE_clean$puissance_num <- as.numeric(IRVE_clean$puissance_num)

# Même chose avec les "," et les "."
IRVE_clean$prix_kwh <- gsub(",", ".", IRVE_clean$tarification)
IRVE_clean$prix_kwh <- sub(".*?([0-9]+\\.?[0-9]*).*", "\\1", IRVE_clean$prix_kwh)
IRVE_clean$prix_kwh <- as.numeric(IRVE_clean$prix_kwh)

#### Garde uniquement les lignes exploitables :
### puissance numérique valide
## prix numérique valide
# Prix entre 0 et 1 €/kW (hors ce critère = valeurs aberrantes)
df <- IRVE_clean[
  is.finite(IRVE_clean$puissance_num) &
    is.finite(IRVE_clean$prix_kwh) &
    IRVE_clean$prix_kwh >= 0 & IRVE_clean$prix_kwh <= 1,
]

#### Création nuage de points 
### Chaque point = une station 
## Axe X = puissance
## Axe Y = prix au kWh
plot(
  x = df$puissance_num,
  y = df$prix_kwh,
  pch = 16,
  col = "steelblue",
  xlab = "Puissance nominale (kW)",
  ylab = "Prix (€/kWh)",
  main = "Prix (€/kWh) en fonction de la puissance (0 à 1€)",
  ylim = c(0, 1)
)

# Corrélation de Pearson => relation linéaire entre puissance et prix
pearson <- cor.test(df$puissance_num, df$prix_kwh, method = "pearson")
pearson

# Ajout d'une droite sur le graphique 
abline(lm(prix_kwh ~ puissance_num, data = df), col = "red", lwd = 2)
grid()




## Puissance vs gratuit ou payant

# Même chose avec les "," et les "."
IRVE_clean$puissance_num <- as.numeric(gsub(",", ".", IRVE_clean$puissance_nominale))

### Converti le texte en 0 ou 1 
## 1 = gratuit
## 0 = payant
to01 <- function(x) {
  x <- trimws(tolower(as.character(x)))
  out <- rep(NA_integer_, length(x))
  out[x %in% c("1", "true", "t", "yes", "y", "oui", "__yes__")] <- 1L ## toutes ces chaines de caractères sont interprétées comme oui
  out[x %in% c("0", "false", "f", "no", "n", "non", "__no__")] <- 0L ## toutes ces chaines de caractères sont interprétées comme non
  out
}
IRVE_clean$gratuit01 <- to01(IRVE_clean$gratuit)

## On conserve uniquelent les lignes où la puissance est valide et la gratuité renseigné
df_g <- IRVE_clean[is.finite(IRVE_clean$puissance_num) & !is.na(IRVE_clean$gratuit01), ]
df_g$gratuit_fac <- factor(df_g$gratuit01, levels = c(0, 1), labels = c("Non", "Oui")) ## 0 devient non et 1 devient oui 

## Boxplot visuel
# compare la puissance nominale entre les stations gratuites et payantes
boxplot(
  puissance_num ~ gratuit_fac,
  data = df_g,
  col = "lightblue",
  xlab = "Gratuit",
  ylab = "Puissance nominale (kW)",
  main = "Puissance nominale selon gratuit (Oui/Non)",
  ylim = c(0, 300)
)
grid()

# test de student vérifie si la puissance moyenne est différente entre les stations gratuites et payantes. 
t.test(puissance_num ~ gratuit_fac, data = df_g, var.equal = FALSE)


##Implantation_station vs condition_acces

## On conserve uniqument 2 conditions d'accès principales 
# condition_acces : seulement "Accès libre" et "Accès réservé"
acc_keep <- c("Accès libre", "Accès réservé")
# implantation_station : seulement les 5 implantations listées
imp_keep <- c("Parking privé à usage public",
              "Parking privé réservé à la clientèle",
              "Parking public",
              "Station dédiée à la recharge rapide",
              "Voirie")

## Création dataset avec les modalitées choisies
df_sub <- subset(IRVE_clean,
                 condition_acces %in% acc_keep &
                   implantation_station %in% imp_keep)

## Les conditions d'accès et l'implantation deviennent des facteurs
df_sub$condition_acces <- factor(df_sub$condition_acces, levels = acc_keep)
df_sub$implantation_station <- factor(df_sub$implantation_station, levels = imp_keep)

#### Vérifications rapides :
nrow(df_sub)
# vérification effectif
table(df_sub$condition_acces) 
table(df_sub$implantation_station)
# affichage de toutes les valeurs ewistantes dans le dataset original 
sort(unique(IRVE_clean$condition_acces))
sort(unique(IRVE_clean$implantation_station))

# Tableau croisé => compte le nombre de stations pour chaque combinaison : imlantation x condition d'accès
tab <- table(df_sub$implantation_station, df_sub$condition_acces)
tab

# Pourcentages par ligne (donc, pour chaque type d’implantation, répartition en % entre accès libre/réservé)
prop.table(tab, 1) * 100

# Test du chi2 d’indépendance :
# vérifie si "implantation_station" et "condition_acces" sont liées
chi <- chisq.test(tab)
round(chi$stdres, 2)
chi




# Mosaic plot :
# représentation visuelle du tableau croisé
# shade = TRUE colore selon les résidus (écarts à l’indépendance), las = 2 incline les labels
mosaicplot(tab, shade = TRUE, las = 2,
           main = "Implantation vs condition d'accès")
