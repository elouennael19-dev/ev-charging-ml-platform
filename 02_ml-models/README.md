# Machine learning models (BC1 → BC4)

Each client need ("besoin client") has its own folder with the same layout: `README.md`, a training notebook when relevant, a prediction script, and a `models/` folder for saved artifacts.

| Need | Folder | Task | Approach | Result (June 2026 run) |
|---|---|---|---|---|
| BC1 | `bc1_map/` | Map visualization | Folium markers + heatmap | — |
| BC2 | `bc2_clustering/` | Geographic clustering | K-means (k = 5, on latitude/longitude) | — |
| BC3 | `bc3_classification/` | Predict `implantation_station` (5 classes) | Random Forest, tuned with GridSearchCV | Accuracy 0.926 (RF baseline) |
| BC4 | `bc4_regression/` | Predict `puissance_nominale` (kW) | Random Forest vs Ridge baseline | RF: R² 0.934, MAE 6.20 kW · Ridge: R² 0.632 |

> Status: trained models (`.pkl`) are not versioned yet. They will be regenerated from the notebooks.
