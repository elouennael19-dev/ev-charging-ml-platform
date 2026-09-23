import joblib
import pandas as pd
import os

# chargement du modèle de Kmeans sauvegardé
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
modele_kmeans = joblib.load(os.path.join(BASE_DIR, "modele_kmeans.pkl"))

# on demande à l'utilisateur de saisir les coordonnées géographiques de la borne à prédire
latitude = float(input("Latitude : "))
longitude = float(input("Longitude : "))

# On ne prend en compt que les brones sur le territoire métropolitain français : latitudes entre 41 et 52, longitudes entre -6 et 10
if not (41 < latitude < 52 and -6 < longitude < 10):
    print("Erreur : les coordonnées ne semblent pas être situées en France métropolitaine.")
else:
    borne_a_predire = pd.DataFrame(
        [[latitude, longitude]],
        columns=[
            "consolidated_latitude",
            "consolidated_longitude"
        ]
    )
# On prédit le secteur auquel appartient la borne à partir de ses coordonnées géographiques
    secteur = modele_kmeans.predict(borne_a_predire)[0]
    print("La borne appartient au secteur :", secteur)