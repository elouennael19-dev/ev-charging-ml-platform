import pandas as pd
import folium
import matplotlib.pyplot as plt
from folium.plugins import HeatMap, MarkerCluster

# 1. Charger les données
df = pd.read_csv("/Users/maelgue/Desktop/A3/Projet_IA/IRVE_IA_clean.csv")

# 2. Garder les colonnes utiles
df = df[
    [
        "consolidated_latitude",
        "consolidated_longitude",
        "implantation_station",
        "puissance_nominale",
        "nbre_pdc"
    ]
]

# 3. Supprimer les lignes incomplètes
df = df.dropna()

print("Nombre de lignes utilisées :", len(df))

# 4. Créer des graphiques simples

df["implantation_station"].value_counts().plot(kind="bar")
plt.title("Répartition des types d'implantation")
plt.xlabel("Type d'implantation")
plt.ylabel("Nombre de bornes")
plt.tight_layout()
plt.savefig("repartition_implantation.png")
plt.close()

df["puissance_nominale"].value_counts().sort_index().plot(kind="bar")
plt.title("Répartition des puissances nominales")
plt.xlabel("Puissance nominale")
plt.ylabel("Nombre de bornes")
plt.tight_layout()
plt.savefig("repartition_puissance.png")
plt.close()

# 5. Centrer les cartes
latitude_moyenne = df["consolidated_latitude"].mean()
longitude_moyenne = df["consolidated_longitude"].mean()

# 6. Carte des bornes avec clustering
carte = folium.Map(
    location=[latitude_moyenne, longitude_moyenne],
    zoom_start=6
)

cluster = MarkerCluster().add_to(carte)

for _, ligne in df.iterrows():
    folium.Marker(
        location=[
            ligne["consolidated_latitude"],
            ligne["consolidated_longitude"]
        ],
        popup=f"""
        Type : {ligne["implantation_station"]}<br>
        Puissance : {ligne["puissance_nominale"]} kW<br>
        Nombre de points de charge : {ligne["nbre_pdc"]}
        """
    ).add_to(cluster)

carte.save("carte_bornes.html")

# 7. Carte de chaleur
carte_chaleur = folium.Map(
    location=[latitude_moyenne, longitude_moyenne],
    zoom_start=6
)

donnees_chaleur = df[
    ["consolidated_latitude", "consolidated_longitude"]
].values.tolist()

HeatMap(donnees_chaleur).add_to(carte_chaleur)

carte_chaleur.save("carte_chaleur.html")

print("Fichiers créés :")
print("- carte_bornes.html")
print("- carte_chaleur.html")
print("- repartition_implantation.png")
print("- repartition_puissance.png")