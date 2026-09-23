# BC1 — Map visualization

`map_visualization.py` loads the ML dataset (latitude, longitude, implantation type, nominal power, number of charging points), drops incomplete rows and generates:

- `carte_bornes.html`: interactive map of charging stations with marker clustering (Folium)
- `carte_chaleur.html`: heatmap of station density
- `repartition_implantation.png` and `repartition_puissance.png`: bar charts of implantation types and nominal power

Run: `python map_visualization.py`

> Input path and output location are currently hard-coded and will be updated.
