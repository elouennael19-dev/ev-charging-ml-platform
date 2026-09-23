# Machine learning models (BC1 → BC4)

## BC2 — Clustering
Script.py besoin client 2
Objectif : 
Le script permet de prédire le cluster d’une nouvelle borne IRVE à partir de ses coordonnées GPS.

On utilise le fichier modele_kmeans.pk1 crée par le besoin_client_2.
Le script charge alors le modèle Kmeans puis demande à l’utilisateur de saisir une latitude et une longitude. Puis il vérifie si les coordonnées sont situées en métropole puis prédit le cluster dans lequel il est situé.

## BC3 — Classification
# Classification de l'implantation des stations IRVE

## Description

Ce notebook réalise une **classification supervisée multi-classes** pour prédire le type d'implantation d'une borne de recharge pour véhicules électriques (`implantation_station`) à partir du jeu de données `IRVE_IA_clean.csv`.

Les 5 classes cibles sont :

| Classe | Description |
|---|---|
| `Parking public` | Borne située dans un parking ouvert au public |
| `Parking prive usage public` | Parking privé accessible au public |
| `Parking prive clientele` | Parking privé réservé à la clientèle |
| `Voirie` | Borne implantée sur la voie publique |
| `Station recharge rapide` | Station dédiée à la recharge rapide |



## Structure du notebook

### 1. Chargement des données
Lecture du fichier `IRVE_IA_clean.csv` via `pandas`.

### 2. Nettoyage des données
- Sélection des features numériques : `puissance_nominale`, `nbre_pdc`, `consolidated_latitude`, `consolidated_longitude`
- Suppression des valeurs manquantes
- Filtrage géographique sur la France métropolitaine (lat 41–51.5, lon -5.5–10.0)
- Suppression des classes trop rares (< 10 occurrences)
- Normalisation Unicode des labels catégoriels (minuscules, suppression des accents)

### 3. Préparation du pipeline ML
- Encodage de la cible avec `LabelEncoder`
- Normalisation des features numériques avec `StandardScaler`
- Split stratifié 80 % train / 20 % test (`random_state=42`)

### 4. Visualisation
Graphique horizontal de la distribution des classes cibles.

### 5. Apprentissage supervisé — comparaison de modèles
Entraînement et évaluation de 4 algorithmes via un `Pipeline` scikit-learn :

| Modèle | Paramètres |
|---|---|
| Decision Tree | `class_weight='balanced'` |
| Random Forest | `n_estimators=100`, `class_weight='balanced'` |
| KNN | `n_neighbors=5` |
| Gradient Boosting | `random_state=42` |

Métriques comparées : **Accuracy**, **F1-score pondéré**, temps d'entraînement et de prédiction.

### 6. Optimisation avec GridSearchCV
Recherche des meilleurs hyperparamètres pour Random Forest via `GridSearchCV` :


clf__n_estimators : [100]
clf__max_depth    : [10, None]
clf__class_weight : ['balanced', None]


### 7. Matrice de confusion
Visualisation graphique (`ConfusionMatrixDisplay`, colormap `Blues`) et affichage de la matrice brute (DataFrame avec labels Réel / Prédit).

### 8. Sauvegarde du modèle
Les artefacts sont sauvegardés dans `/IA/projet-ia-irve/models/` :

| Fichier | Contenu |
|---|---|
| `classification_model.pkl` | Pipeline complet (préprocesseur + modèle) |
| `label_encoder_implantation.pkl` | `LabelEncoder` de la cible |
| `classification_config.json` | Liste des features et nom de la cible |



## Prérequis

bash
pip install pandas numpy scikit-learn matplotlib seaborn joblib
```

**Python** 



## Utilisation

1. Placer le fichier `IRVE_IA_clean.csv` dans `C:/Users/Administrator/Desktop/IA/`
2. Ouvrir `bs3.ipynb` dans Jupyter Notebook ou JupyterLab
3. Exécuter toutes les cellules dans l'ordre (`Kernel > Restart & Run All`)



## Fichiers produits


projet-ia-irve/
├── IRVE_IA_clean.csv          # Jeu de données source
├── bs3.ipynb                  # Notebook principal
└── models/
    ├── classification_model.pkl
    ├── label_encoder_implantation.pkl
    └── classification_config.json

## BC4 — Regression
Prédiction de puissance nominale — Random Forest
===================================================

DESCRIPTION
-----------
Ce script prédit la puissance nominale (en kW) d'une borne de recharge 
électrique à partir de ses caractéristiques techniques, en utilisant un 
modèle Random Forest préalablement entraîné.


PRÉREQUIS
---------

Fichiers nécessaires (dans le même dossier que le script) :
- random_forest_model.pkl   : modèle Random Forest entraîné
- onehot_encoder.pkl        : encodeur one-hot ajusté sur les variables catégorielles
- feature_columns.pkl       : liste ordonnée des colonnes attendues par le modèle

Dépendances Python :
    pip install pandas joblib scikit-learn


UTILISATION
-----------

1. Placez les trois fichiers .pkl dans le même répertoire que le script.

2. Renseignez les caractéristiques de la borne à prédire dans le 
   dictionnaire "borne" :

   - prise_type_combo_ccs  : Présence d'une prise Combo CCS      (0 ou 1)
   - prise_type_2          : Présence d'une prise Type 2         (0 ou 1)
   - prise_type_ef         : Présence d'une prise type E/F       (0 ou 1)
   - prise_type_chademo    : Présence d'une prise CHAdeMO        (0 ou 1)
   - reservation           : Réservation possible                (0 ou 1)
   - paiement_acte         : Paiement à l'acte possible          (0 ou 1)
   - implantation_station  : Type d'implantation       (ex : "Voirie")
   - condition_acces       : Conditions d'accès        (ex : "Acces libre")
   - accessibilite_pmr     : Accessibilité PMR         (ex : "Accessibilite inconnue")

3. Lancez le script :
       python script.py

4. Le résultat s'affiche puissance nominale prédite


NOTES
-----
- Les valeurs textuelles (implantation_station, condition_acces, 
  accessibilite_pmr) doivent correspondre EXACTEMENT aux catégories vues 
  par l'encodeur lors de l'entraînement (même orthographe, même casse).

- Si une catégorie saisie est inconnue de l'encodeur, l'encodage one-hot 
  peut échouer ou produire un résultat non pertinent.

- feature_columns.pkl garantit que les colonnes sont dans le même ordre 
  qu'à l'entraînement