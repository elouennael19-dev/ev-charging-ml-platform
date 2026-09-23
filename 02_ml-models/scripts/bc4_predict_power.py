import pandas as pd
import joblib
import os

# Chargement du modèle et des encodeurs entraînés et sauvegardés
BASE_DIR = os.path.dirname(os.path.abspath(__file__))  # Récupère le dossier contenant ce script

model   = joblib.load(os.path.join(BASE_DIR, "random_forest_model.pkl"))      # Modèle Random Forest entraîné pour prédire puissance_nominale
ohe     = joblib.load(os.path.join(BASE_DIR, "onehot_encoder.pkl"))           # OneHotEncoder ajusté sur les variables catégorielles à l'entraînement
columns = joblib.load(os.path.join(BASE_DIR, "feature_columns.pkl"))          # Liste ordonnée des colonnes attendues par le modèle (même ordre qu'à l'entraînement)

# Caractéristiques de la borne de recharge dont on veut prédire la puissance nominale
borne = {
    "prise_type_combo_ccs"  : 1,                          # Présence d'une prise Combo CCS (1 = oui, 0 = non)
    "prise_type_2"          : 1,                          # Présence d'une prise Type 2
    "prise_type_ef"         : 0,                          # pareil
    "prise_type_chademo"    : 1,                          
    "reservation"           : 0,                          
    "paiement_acte"         : 1,                          
    "implantation_station"  : "Voirie",                   
    "condition_acces"       : "Acces libre",              
    "accessibilite_pmr"     : "Accessibilite inconnue"    
}

# Liste des colonnes catégorielles qui nécessitent un encodage one-hot
cat_cols = ["implantation_station", "condition_acces", "accessibilite_pmr"]

# Conversion du dictionnaire en DataFrame à une seule ligne, pour pouvoir appliquer
df_input = pd.DataFrame([borne])

# Application de l'encodeur déjà entraîné : transforme chaque catégorie en colonnes binaires
X_cat_ohe = ohe.transform(df_input[cat_cols])

# Reconstruction d'un DataFrame à partir du résultat encodé, en récupérant les noms de colonnes
df_ohe = pd.DataFrame(X_cat_ohe, columns=ohe.get_feature_names_out(cat_cols))

# On retire les colonnes catégorielles d'origine (textuelles) du DataFrame et on les remplace par leurs équivalents encodés en one-hot
df_input = df_input.drop(columns=cat_cols).join(df_ohe)

# On réaligne les colonnes du DataFrame sur celles utilisées à l'entraînement (même ordre, mêmes noms)
df_input = df_input.reindex(columns=columns, fill_value=0)

# Prédiction de la puissance nominale (en kW) à partir du vecteur de caractéristiques préparé : [0] permet de récupérer la valeur unique car predict() renvoie un tableau
prediction = model.predict(df_input)[0]
print(f"\nPuissance nominale prédite : {prediction:.1f} kW")