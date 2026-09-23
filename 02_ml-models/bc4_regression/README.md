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