"""Prédit le type d'implantation d'une station IRVE."""

import argparse
import warnings
import numpy as np
import joblib

warnings.filterwarnings("ignore")


def check_arguments():
    """Vérifie et retourne les arguments du programme."""
    parser = argparse.ArgumentParser(
        description="Prédit le type d'implantation d'une station de recharge IRVE."
    )
    parser.add_argument(
        "-m", "--model",
        type=str,
        required=True,
        help="Chemin vers le fichier modèle (.pkl)"
    )
    parser.add_argument(
        "-le", "--label_encoder",
        type=str,
        required=True,
        help="Chemin vers le fichier LabelEncoder (.pkl)"
    )
    parser.add_argument(
        "-puissance_nominale", "--puissance_nominale",
        type=float,
        required=True,
        help="Puissance nominale de la borne (kW)"
    )
    parser.add_argument(
        "-nbre_pdc", "--nbre_pdc",
        type=int,
        required=True,
        help="Nombre de points de charge"
    )
    parser.add_argument(
        "-latitude", "--latitude",
        type=float,
        required=True,
        help="Latitude (consolidated_latitude)"
    )
    parser.add_argument(
        "-longitude", "--longitude",
        type=float,
        required=True,
        help="Longitude (consolidated_longitude)"
    )
    return parser.parse_args()


def main():
    args = check_arguments()

    # Chargement des fichiers pkl
    try:
        import joblib
    except ImportError:
        print("Erreur : la librairie 'joblib' est requise. Installez-la avec : pip install joblib")
        exit(1)

    try:
        model = joblib.load(args.model)
    except Exception as e:
        print(f"Erreur lors du chargement du modèle : {e}")
        exit(1)

    try:
        le = joblib.load(args.label_encoder)
    except Exception as e:
        print(f"Erreur lors du chargement du LabelEncoder : {e}")
        exit(1)

    # Construction du vecteur de features
    # Ordre attendu par le modèle : puissance_nominale, nbre_pdc, consolidated_latitude, consolidated_longitude
    X = np.array([[
        args.puissance_nominale,
        args.nbre_pdc,
        args.latitude,
        args.longitude
    ]])

    # Prédiction
    pred_encoded = model.predict(X)
    pred_label = le.inverse_transform(pred_encoded)[0]

    # Probabilités par classe
    probas = model.predict_proba(X)[0]
    classes = le.classes_

    # Affichage du résultat
    print(f"\n=== Résultat de la prédiction ===")
    print(f"Type d'implantation prédit : {pred_label}")
    print(f"\nProbabilités par classe :")
    for cls, prob in sorted(zip(classes, probas), key=lambda x: -x[1]):
        bar = "█" * int(prob * 20)
        print(f"  {cls:<35} {prob:.1%}  {bar}")


if __name__ == "__main__":
    main()

modele = joblib.load("classification_model.pkl")
preprocessor = joblib.load("label_encoder_implantation.pkl")